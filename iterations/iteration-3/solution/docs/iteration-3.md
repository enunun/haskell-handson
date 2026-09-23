# Iteration 3：費目ごとの集計(解説)

演習用の`docs/iteration-3.md`の各手順について，解答の例と考え方を説明する．

## 演習3-1：パッケージを登録してビルドする

`cabal.project`の`packages`に`iterations/iteration-3/exercise`を追記し，`cabal test kakeibo-iteration3`でテストを実行する．
`cabal run kakeibo-iteration3 -- 食費:1200 交通費:350 食費:350`は，3件の明細と`合計: 1,900円`を表示する．

## 演習3-2：高階関数を試す

```console
ghci> import Kakeibo.Entry
ghci> es = [Entry Food 1200, Entry Transport 350, Entry Food 350]
ghci> filter (\e -> category e == Food) es
[Entry {category = Food, amount = 1200},Entry {category = Food, amount = 350}]
ghci> filter ((== Food) . category) es
[Entry {category = Food, amount = 1200},Entry {category = Food, amount = 350}]
ghci> map amount es
[1200,350,350]
ghci> foldr (+) 0 (map amount es)
1900
```

`deriving (Enum, Bounded)`がない`Category`で`[minBound .. maxBound]`を評価すると，次のエラーになる．

```
error: [GHC-39999]
    • No instance for ‘Enum Category’
        arising from the arithmetic sequence ‘minBound .. maxBound’
…
error: [GHC-39999]
    • No instance for ‘Bounded Category’
        arising from a use of ‘minBound’
```

`..`で範囲を作るには`Enum`が，`minBound`・`maxBound`を使うには`Bounded`が必要である．

## 演習3-3：テストリストを書く

解答例のテストリストは[TESTLIST.md](../TESTLIST.md)である．

- `summarize`の3つの性質(足し合わせる，並べる，含めない)を，それぞれ確かめる入力を選んだ．
  - 「足し合わせる」は，同じ費目の支出を2件与える．
  - 「並べる」は，定義の順と違う順に支出を与える．
  - 「含めない」は，1件だけの支出を与え，ほかの費目が結果にないことを確かめる．この例は「支出が1件なら，その費目と金額だけを返す」の項目で兼ねた．
- 小計の行の形(字下げ，`費目別:`の見出し)は`run`の結合テストで確かめる．小計の行を作る関数を`Kakeibo.App`の中に置き，エクスポートしていないからである．
- 既存の結合テストのうち，`run []`以外の2つは，小計の行が加わるので期待値が変わる．

## 演習3-4：設計書を更新する

解答例の設計書は[../design/](../design/)にある．
Iteration 2からの変更点は次のとおり．

- Context・Container：説明に費目ごとの小計を足した．
- Component：`Kakeibo.Summary`を足した．`Kakeibo.Summary`は`Category`・`Entry`の型(`Kakeibo.Entry`)と`total`(`Kakeibo.Money`)を使う．
- Code：
  - データ型の図に，`Category`が`Enum`・`Bounded`を`deriving`することを描いた．`[minBound .. maxBound]`ですべての費目を並べるための設計である．
  - 型と関数の流れに，`summarize`から小計の行を作る流れを足した．
  - `summarize`の中の流れ(すべての費目→支出がある費目→費目と小計の組)を別の図にした．

小計の行を作る関数(`formatSubtotal`)は，表示の形(字下げ)を決めるものなので，表示する行を組み立てる`Kakeibo.App`に置いた．
`Kakeibo.Summary`は集計の計算だけを受け持つ．

## 演習3-5：テスト駆動で実装する

### `summarize`：支出がなければ空のリストを返す

`src/Kakeibo/Summary.hs`を作り，`exposed-modules`に，`SummarySpec`を`other-modules`に追記する．

```haskell
-- test/unit/Kakeibo/SummarySpec.hs
module Kakeibo.SummarySpec (spec) where

import Kakeibo.Entry (Category (..), Entry (..))
import Kakeibo.Summary (summarize)
import Test.Hspec

spec :: Spec
spec = do
  describe "summarize" $ do
    it "支出がなければ空のリストを返す" $
      summarize [] `shouldBe` []
```

`error "TODO"`でRedを確かめてから，仮実装で通す．

```haskell
-- src/Kakeibo/Summary.hs
-- | 支出の集計．
module Kakeibo.Summary (summarize) where

import Kakeibo.Entry (Category, Entry (..))

summarize :: [Entry] -> [(Category, Int)]
summarize _ = []
```

### `summarize`：支出が1件なら，その費目と金額だけを返す

```haskell
    it "支出が1件なら，その費目と金額だけを返す" $
      summarize [Entry Daily 500] `shouldBe` [(Daily, 500)]
```

```
       expected: [(Daily,500)]
        but got: []
```

支出を1件ずつ費目と金額の組にすれば通る．

```haskell
summarize :: [Entry] -> [(Category, Int)]
summarize entries = map (\e -> (category e, amount e)) entries
```

### `summarize`：同じ費目の支出を足し合わせる

```haskell
    it "同じ費目の支出を足し合わせる" $
      summarize [Entry Food 1200, Entry Food 350] `shouldBe` [(Food, 1550)]
```

```
       expected: [(Food,1550)]
        but got: [(Food,1200),(Food,350)]
```

支出を1件ずつ見るのをやめ，費目を1つずつ見て，その費目の支出を集める．
`Category`の`deriving`に`Enum`と`Bounded`を足し，すべての費目のリストを`[minBound .. maxBound]`で作る．

```haskell
-- src/Kakeibo/Entry.hs
data Category
  = Food
  | Transport
  | Daily
  | Other
  deriving (Show, Eq, Enum, Bounded)
```

```haskell
-- src/Kakeibo/Summary.hs
import Kakeibo.Money (total)

summarize :: [Entry] -> [(Category, Int)]
summarize entries = map subtotal (filter hasEntries allCategories)
  where
    allCategories = [minBound .. maxBound]
    entriesOf c = filter (\e -> category e == c) entries
    hasEntries c = not (null (entriesOf c))
    subtotal c = (c, total (map amount (entriesOf c)))
```

- `entriesOf c`は，費目`c`の支出だけのリストである．
- `filter hasEntries allCategories`で，支出がある費目だけに絞る．
- `map subtotal`で，残った費目それぞれを，費目と小計の組にする．

### `summarize`：費目の定義順に並べる

```haskell
    it "費目の定義順に並べる" $
      summarize [Entry Other 800, Entry Transport 350, Entry Food 1200]
        `shouldBe` [(Food, 1200), (Transport, 350), (Other, 800)]
```

費目のリスト`[minBound .. maxBound]`が定義順なので，書いた時点で通る．
要求の「定義の順に並べる」を表す例として残す．

### 整える：ラムダ式をセクションと関数合成に

テストがすべて通っているので，`entriesOf`のラムダ式を書き直す．

```haskell
    entriesOf c = filter ((== c) . category) entries
```

`(== c) . category`は，`category`で費目を取り出してから`(== c)`で比べる関数である．
書き直したあとも，テストがすべて通ることを確かめる．

### `run`：同じ費目の支出を，費目別の小計でまとめて表示する

```haskell
    it "同じ費目の支出は，費目別の小計でまとめる" $
      run ["食費:1200", "交通費:350", "食費:350"]
        `shouldBe` [ "食費 1,200円",
                     "交通費 350円",
                     "食費 350円",
                     "費目別:",
                     "  食費 1,550円",
                     "  交通費 350円",
                     "合計: 1,900円"
                   ]
```

```haskell
-- src/Kakeibo/App.hs
import Kakeibo.Entry (Category, Entry (..), categoryName, formatEntry, parseEntry)
import Kakeibo.Money (formatYen, total)
import Kakeibo.Summary (summarize)

run :: [String] -> [String]
run [] = ["支出はありません"]
run args =
  map formatEntry entries
    ++ ["費目別:"]
    ++ map formatSubtotal (summarize entries)
    ++ ["合計: " ++ formatYen (total (map amount entries))]
  where
    entries = map parseEntry args

formatSubtotal :: (Category, Int) -> String
formatSubtotal (c, subtotal) = "  " ++ categoryName c ++ " " ++ formatYen subtotal
```

### `run`：既存の2つのテストの期待値に，小計の行を足す

新しいテストが通ると，既存の2つのテストが失敗する．
要求どおり，期待値に`費目別:`と小計の行を足す．

```haskell
    it "支出を1件ずつ表示し，費目別の小計と合計を表示する" $
      run ["食費:1200", "交通費:350"]
        `shouldBe` [ "食費 1,200円",
                     "交通費 350円",
                     "費目別:",
                     "  食費 1,200円",
                     "  交通費 350円",
                     "合計: 1,550円"
                   ]
```

`run ["1200", "350", "800"]`の期待値には，`費目別:`と`  その他 2,350円`の2行を足す．

### `total`：`foldr`で書き直す

```haskell
total :: [Int] -> Int
total amounts = foldr (+) 0 amounts
```

書き直す前と後で，`total`のテストがすべて通ることを確かめる．

## 演習3-6：振り返る

1. テストリストの項目の分け方は人によって違ってよい．「支出がない費目を含めない」を独立した項目にした人もいるだろう．
2. `0`は再帰の定義の`total [] = 0`に，`(+)`は`total (amount : rest) = amount + total rest`の`+`に対応する．再帰の形そのもの(残りのリストに`total`を適用すること)は，`foldr`が受け持っている．
3. 書き換える必要はない．`[minBound .. maxBound]`が，定義に足した費目も含めてすべての費目のリストになる．
4. 単体テストで確かめた．`summarize [Entry Daily 500]`の結果に，ほかの費目が含まれないことを確かめている．結合テストでも，`食費:1200 交通費:350`の小計に日用品とその他がないことを，期待値の行として確かめている．
5. 解答例は設計書どおり．`summarize`の中の`entriesOf`・`hasEntries`・`subtotal`は`where`の中の名前なので，設計書では流れの図と図の下の説明で示した．

## 演習3-7(発展)：費目ごとの件数を表示する

`summarize`の結果を，費目・小計・件数の3つ組のリストにする．

```haskell
summarize :: [Entry] -> [(Category, Int, Int)]
summarize entries = map subtotal (filter hasEntries allCategories)
  where
    allCategories = [minBound .. maxBound]
    entriesOf c = filter ((== c) . category) entries
    hasEntries c = not (null (entriesOf c))
    subtotal c = (c, total (map amount (entriesOf c)), length (entriesOf c))
```

`summarize`の型が変わるので，既存の`summarize`のテストの期待値もすべて3つ組に書き換える．
`run`の小計の行を作る関数は，3つ組のパターン`(c, subtotal, count)`で分解する．
