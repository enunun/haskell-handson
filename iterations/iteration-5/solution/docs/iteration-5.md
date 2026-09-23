# Iteration 5：型クラスで金額を表す(解説)

演習用の`docs/iteration-5.md`の各手順について，解答の例と考え方を説明する．

## 演習5-1：パッケージを登録してビルドする

`cabal.project`の`packages`に`iterations/iteration-5/exercise`を追記し，`cabal test kakeibo-iteration5`でテストを実行する．
`cabal run kakeibo-iteration5 -- 食費:350 交通費:1200 800`では，小計が費目の定義順(食費・交通費・その他)に並ぶ．

## 演習5-2：型クラスと`Data.Map`を試す

`:i Ord`の出力には`instance Ord Int`，`instance Ord Char`，`instance Ord Bool`，`instance Ord a => Ord [a]`などが並ぶ．
リストは，要素の型が`Ord`なら`Ord`である(文字列は辞書順で比べられる)．

`Count 3 + Count 4`は次のエラーになる．
`+`は`Num`のメソッドで，`Count`は`Num`のインスタンスではないからである．

```
error: [GHC-39999]
    • No instance for ‘Num Count’ arising from a use of ‘+’
```

```haskell
instance Semigroup Count where
  Count a <> Count b = Count (a + b)

instance Monoid Count where
  mempty = Count 0
```

```console
ghci> mconcat [Count 3, Count 4]
Count 7
ghci> mconcat [] :: Count
Count 0
ghci> import Data.Map.Strict qualified as Map
ghci> Map.toList (Map.fromListWith (+) [("a", 1), ("b", 2), ("a", 3)])
[("a",4),("b",2)]
```

## 演習5-3：テストリストを書く

解答例のテストリストは[TESTLIST.md](../TESTLIST.md)である．

- 型が変わるテストは，テストファイルのほぼすべてにわたる．「書き換える」項目としてまとめて書いた．
- `formatYen`の3桁区切りのテストは，`display (Yen …)`のテストとして引き継ぐ．表示の規則は変わらないので，期待値はそのままである．
- 既存の`summarize`の「費目の定義順に並べる」のテスト(`その他 800円`・`交通費 350円`・`食費 1,200円`)は，金額の大きい順では`食費`・`その他`・`交通費`になるので，期待値が変わる．
- 「金額が同じなら定義順」は，同じ金額の支出を，定義順と逆の順で与えて確かめる．
- 結合テストの既存の例は，どれも金額の大きい順と定義順が一致しているので，書き換えずに通る．並び順の変化は，定義順と金額の順が逆になる新しい例(`食費:350 交通費:1200`)で確かめる．

## 演習5-4：設計書を更新する

解答例の設計書は[../design/](../design/)にある．
Iteration 4からの変更点は次のとおり．

- Context：説明に「金額の大きい順の小計」を足した．
- Component：`Kakeibo.Display`を足し，`Data.Map.Strict`を境界の外の`Component_Ext`として描いた．
- Code：
  - データ型の図に，`newtype Yen`，型クラス(`Display`・`Semigroup`・`Monoid`・`Ord`・`Enum`・`Bounded`)と，インスタンスの関係を描いた．インスタンスの定義は表にした．
  - 型と関数の流れで，金額を`Yen`，合計を`total`(`mconcat`)，表示を`display`にした．
  - `summarize`の中の流れを，`Map.fromListWith (<>)`で表を作り，`Map.toList`と`sortOn (Down . snd)`で並べる形に描き直した．

`Display`の型クラスは，`Kakeibo.Money`(`Yen`)と`Kakeibo.Entry`(`Category`・`Entry`)の両方がインスタンスを定義する．
どちらかのモジュールに置くと，もう一方がそのモジュールに依存することになるので，どちらにも依存しない`Kakeibo.Display`に置いた．
Componentの図の矢印を描くと，このような依存の向きを決めやすい．

## 演習5-5：テスト駆動で実装する

### 1. `Display`型クラスを作る

```haskell
-- src/Kakeibo/Display.hs
-- | 値を画面に表示する文字列にする型クラス．
module Kakeibo.Display (Display (..)) where

-- | 画面に表示できる型．
-- Showは値をHaskellの式の形で表すのに対し，Displayは利用者向けの表記にする．
class Display a where
  display :: a -> String
```

`exposed-modules`に`Kakeibo.Display`を追記する．

### 2. `Yen`を作る

`<>`のテストから始める．

```haskell
-- test/unit/Kakeibo/MoneySpec.hs
  describe "Yen" $ do
    it "<>で金額を足し合わせる" $
      Yen 1200 <> Yen 350 `shouldBe` Yen 1550
```

`Yen`を定義しただけでは，`<>`が使えずにコンパイルエラーになる．

```
error: [GHC-39999]
    • No instance for ‘Semigroup Yen’ arising from a use of ‘<>’
```

`Semigroup`のインスタンスを定義する．

```haskell
-- src/Kakeibo/Money.hs
newtype Yen = Yen Int
  deriving (Show, Eq, Ord)

instance Semigroup Yen where
  Yen a <> Yen b = Yen (a + b)
```

`mempty`のテストでは，`mempty`がどの型の値かを`:: Yen`で指定する．

```haskell
    it "memptyは0円" $
      (mempty :: Yen) `shouldBe` Yen 0
```

```haskell
instance Monoid Yen where
  mempty = Yen 0
```

`display`のテストは，`formatYen`のテストを1つずつ書き換えて作る．

```haskell
  describe "display" $ do
    it "金額の後ろに「円」を付ける" $
      display (Yen 350) `shouldBe` "350円"
```

`Display`のインスタンスは，`formatYen`と同じ規則で定義する．

```haskell
import Kakeibo.Display (Display (..))

instance Display Yen where
  display (Yen n) = insertCommas (show n) ++ "円"
```

残りの5つのテスト(0円，3桁，4桁，6桁，7桁)も書き換えると，すべて通る．
`insertCommas`をそのまま使っているので，規則は同じだからである．

### 3. 金額の型を`Yen`に切り替える

`total`のテストを書き換える．

```haskell
  describe "total" $ do
    it "空のリストなら0円を返す" $
      total [] `shouldBe` Yen 0
    it "要素が1つなら，その値を返す" $
      total [Yen 1200] `shouldBe` Yen 1200
    it "複数の金額を足し合わせる" $
      total [Yen 1200, Yen 350, Yen 800] `shouldBe` Yen 2350
```

```haskell
total :: [Yen] -> Yen
total amounts = mconcat amounts
```

`Kakeibo.Entry`の`amount`と`parseAmount`の型を変える．

```haskell
data Entry = Entry
  { category :: Category,
    amount :: Yen
  }
  deriving (Show, Eq)

parseAmount :: String -> Maybe Yen
parseAmount text =
  case readMaybe text of
    Nothing -> Nothing
    Just n
      | n > 0 -> Just (Yen n)
      | otherwise -> Nothing
```

`parseEntry`の`Just n -> Right (Entry c n)`は，そのままで型が合う．
`n`が`Yen`になったからである．

コンパイルエラーは，`formatEntry`(`formatYen (amount entry)`)，`Kakeibo.Summary`(`summarize`の型)，`Kakeibo.App`(`formatYen`)に出る．
`formatYen`を`display`に置き換え，`summarize`の型を`[Entry] -> [(Category, Yen)]`にする．
テストの`Entry Food 1200`を`Entry Food (Yen 1200)`に，`Just 1200`を`Just (Yen 1200)`に書き換えると，テストがすべて通る．
最後に`formatYen`を消し，エクスポートリストを`Yen (..)`と`total`にする．

### 4. `Category`と`Entry`を`Display`のインスタンスにする

```haskell
  describe "display(Category)" $ do
    it "費目の名前を返す" $
      map display [Food, Transport, Daily, Other] `shouldBe` ["食費", "交通費", "日用品", "その他"]
```

```haskell
instance Display Category where
  display Food = "食費"
  display Transport = "交通費"
  display Daily = "日用品"
  display Other = "その他"
```

```haskell
  describe "display(Entry)" $ do
    it "費目と金額を空白で区切って表示する" $
      display (Entry {category = Transport, amount = Yen 1200}) `shouldBe` "交通費 1,200円"
```

```haskell
instance Display Entry where
  display entry = display (category entry) ++ " " ++ display (amount entry)
```

`Kakeibo.App`の`formatEntry`と`categoryName`を`display`に置き換えてから，2つの関数を消す．

```haskell
report :: [Entry] -> [String]
report entries =
  map display entries
    ++ ["費目別:"]
    ++ map formatSubtotal (summarize entries)
    ++ ["合計: " ++ display (total (map amount entries))]

formatSubtotal :: (Category, Yen) -> String
formatSubtotal (c, subtotal) = "  " ++ display c ++ " " ++ display subtotal
```

### 5. 小計を金額の大きい順に並べる

既存の並び順のテストを書き換える．

```haskell
    it "小計の大きい順に並べる" $
      summarize [Entry Other (Yen 800), Entry Transport (Yen 350), Entry Food (Yen 1200)]
        `shouldBe` [(Food, Yen 1200), (Other, Yen 800), (Transport, Yen 350)]
```

```
       expected: [(Food,Yen 1200),(Other,Yen 800),(Transport,Yen 350)]
        but got: [(Food,Yen 1200),(Transport,Yen 350),(Other,Yen 800)]
```

`containers`を`library`の`build-depends`に追記し，`Data.Map.Strict`で集計してから並べ替える．
`Category`の`deriving`に`Ord`を足す．

```cabal
    build-depends:
        base >=4.18 && <5,
        containers
```

```haskell
-- src/Kakeibo/Summary.hs
import Data.List (sortOn)
import Data.Map.Strict qualified as Map
import Data.Ord (Down (..))
import Kakeibo.Entry (Category, Entry (..))
import Kakeibo.Money (Yen)

summarize :: [Entry] -> [(Category, Yen)]
summarize entries = sortOn (Down . snd) (Map.toList subtotals)
  where
    subtotals = Map.fromListWith (<>) (map (\e -> (category e, amount e)) entries)
```

- `map (\e -> (category e, amount e)) entries`で，支出を費目と金額の組のリストにする．
- `Map.fromListWith (<>)`で，同じ費目の金額を`Yen`の`<>`(足し算)でまとめた表を作る．
- `Map.toList`は，キー(費目)の小さい順，つまり定義順の組のリストを返す．
- `sortOn (Down . snd)`で，金額の大きい順に並べ替える．

支出がない費目は，表にキーが作られないので，結果に含まれない．
Iteration 3の`summarize`で書いていた`filter hasEntries`に当たる処理が要らなくなった．

```haskell
    it "小計が同じなら，費目の定義順に並べる" $
      summarize [Entry Other (Yen 500), Entry Food (Yen 500)]
        `shouldBe` [(Food, Yen 500), (Other, Yen 500)]
```

`sortOn`は基準(金額)が同じ要素の順番を保ち，並べ替える前のリストは定義順なので，書いた時点で通る．

結合テストに，並び順の変化がわかる例を足す．

```haskell
    it "費目別の小計は，金額の大きい順に表示する" $
      run ["食費:350", "交通費:1200"]
        `shouldBe` Right
          [ "食費 350円",
            "交通費 1,200円",
            "費目別:",
            "  交通費 1,200円",
            "  食費 350円",
            "合計: 1,550円"
          ]
```

`summarize`の変更で，すでに通る．
単体テストで確かめた並び順が，表示にも反映されていることを表す例として残す．

## 演習5-6：振り返る

1. 型の書き換えの項目を，関数ごとに分けて書いた人もいるだろう．書き換えの項目は，コンパイルエラーが教えてくれるので漏れにくい．
2. `total`は`mconcat`だけで書ける．`summarize`は`Map.fromListWith (<>)`で，同じ費目の金額のまとめ方を`Yen`の`<>`に任せられる．金額をどう足すかは`Yen`のインスタンスの1か所で決まり，使う側は「まとめる」とだけ書けばよい．
3. `type Yen = Int`は`Int`の別名なので，`Int`の件数を`Yen`として渡しても，コンパイルエラーにならない．`newtype`なら型が違うので，取り違えはコンパイルエラーになる．
4. `show (Yen 1200)`は`"Yen 1200"`，`display (Yen 1200)`は`"1,200円"`である．`show`は，GHCiやテストの失敗メッセージで，値をHaskellの式として読める形で表す．`display`は，利用者に見せる表記を表す．2つを分けておくと，テストの失敗メッセージで値の中身を正確に読める．
5. 古い関数を残しておくと，型を1つ変えるごとにコンパイルとテストを通した状態に戻れる．失敗したときに，直前の小さな変更だけを見直せばよい．
6. `Category`を`Map`のキーにするには`Ord`のインスタンスが要る．設計の段階で気付かなくても，実装のコンパイルエラーで気付く．気付いたら，データ型の図に`Ord`の`deriving`を足す．

## 演習5-7(発展)：割合を表示する

`Kakeibo.Money`に，割合を求める関数を足す．

```haskell
-- | 全体に対する部分の割合を，整数の百分率で返す(小数点以下は切り捨てる)．
percentOf :: Yen -> Yen -> Int
percentOf (Yen part) (Yen whole) = part * 100 `div` whole
```

テストリストには，次のような項目を足す．

- `percentOf`：全体と同じなら100
- `percentOf`：小数点以下を切り捨てる(`percentOf (Yen 1200) (Yen 2350)`は51)
- `run`：小計の後ろに割合を表示する(既存の結合テストの期待値も変わる)

`formatSubtotal`は合計も受け取るように変える．
合計が0円になるのは支出がないときだけで，そのときは`run`が`支出はありません`を返すので，`div`で0で割ることはない．
