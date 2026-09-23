# Iteration 2：費目付きの入力と明細(解説)

演習用の`docs/iteration-2.md`の各手順について，解答の例と考え方を説明する．

## 演習2-1：パッケージを登録してビルドする

`cabal.project`の`packages`に`iterations/iteration-2/exercise`を追記し，`cabal test kakeibo-iteration2`でテストを実行する．

`cabal run kakeibo-iteration2 -- 食費:1200`は`Prelude.read: no parse`で止まる．
Iteration 1の`run`は引数をすべて`read`で数として読むので，`食費:1200`を読めないからである．

## 演習2-2：データ型と`case`式を試す

```console
ghci> data Signal = Red | Yellow | Green deriving (Show, Eq)
ghci> Red
Red
ghci> Red == Green
False
```

`deriving`なしで定義すると，`Red`を評価したときに`No instance for ‘Show Signal’`というエラーになる．
GHCiは評価した値を`show`で文字列にして表示するが，`Signal`には`Show`の機能がないからである．

```haskell
action :: Signal -> String
action Red = "止まれ"
action Yellow = "注意"
action Green = "進め"
```

```haskell
case break isColon "交通費:350" of
  (_, _ : rest) -> rest
  (_, []) -> ""
```

## 演習2-3：テストリストを書く

解答例のテストリストは[TESTLIST.md](../TESTLIST.md)である．

- 既存のテストのうち期待値が変わるのは，結合テストの`run ["1200", "350", "800"]`である．`:`のない引数は「その他」の支出になり，明細の行が付くからである．引数がない場合の`支出はありません`は変わらない．
- `parseCategory`は，4つの名前それぞれと，知らない名前を確かめた．名前を1文字でも打ち間違えると，その費目の支出が「その他」になってしまうので，1つずつ確かめる価値がある．
- `categoryName`は，4つの費目をまとめて1つのテストにした．`map categoryName [Food, Transport, Daily, Other]`の結果を比べれば，1つの`it`で4つを確かめられる．
- `parseEntry`の引数の形は，`:`がある場合とない場合の2通りである．
- 3桁区切りは`formatYen`の単体テストで確かめているので，`formatEntry`は1つの例で「費目と金額を空白で区切る」ことを確かめれば足りる．

## 演習2-4：テスト駆動で実装する

### モジュールを作る

`src/Kakeibo/Entry.hs`に，型の定義だけを書く．

```haskell
-- | 支出1件の表し方と，その読み取り・表示．
module Kakeibo.Entry
  ( Category (..),
    Entry (..),
  )
where

-- | 支出の費目．
data Category
  = Food
  | Transport
  | Daily
  | Other
  deriving (Show, Eq)

-- | 支出1件．
data Entry = Entry
  { category :: Category,
    amount :: Int
  }
  deriving (Show, Eq)
```

`.cabal`ファイルの`exposed-modules`に追記する．

```cabal
library
    hs-source-dirs:   src
    exposed-modules:
        Kakeibo.App
        Kakeibo.Entry
        Kakeibo.Money
```

### `parseCategory`：「食費」を食費として読む

```haskell
-- test/unit/Kakeibo/EntrySpec.hs
module Kakeibo.EntrySpec (spec) where

import Kakeibo.Entry
import Test.Hspec

spec :: Spec
spec = do
  describe "parseCategory" $ do
    it "「食費」を食費として読む" $
      parseCategory "食費" `shouldBe` Food
```

`parseCategory`がまだないので，テストのコンパイルが`Variable not in scope: parseCategory`で失敗する．
型シグネチャと`error`だけを書き，エクスポートリストに`parseCategory`を足す．

```haskell
parseCategory :: String -> Category
parseCategory _ = error "TODO"
```

テストが`TODO`で失敗すること(Red)を確かめてから，仮実装で通す．

```haskell
parseCategory :: String -> Category
parseCategory _ = Food
```

### `parseCategory`：「交通費」「日用品」「その他」

1つずつテストを足し，そのたびに失敗を確かめて，リテラルのパターンの定義を足していく．
「日用品」まで進めた段階のコードは次のとおり．

```haskell
parseCategory :: String -> Category
parseCategory "食費" = Food
parseCategory "交通費" = Transport
parseCategory _ = Daily
```

「その他」のテストを足すと`Daily`が返って失敗するので，「日用品」の定義を足し，残りを`Other`にする．

```haskell
parseCategory :: String -> Category
parseCategory "食費" = Food
parseCategory "交通費" = Transport
parseCategory "日用品" = Daily
parseCategory _ = Other
```

### `parseCategory`：知らない名前はその他として読む

```haskell
    it "知らない名前はその他として読む" $
      parseCategory "書籍" `shouldBe` Other
```

最後の定義が`_`なので，書いた時点で通る．
要求の「それ以外の名前はその他」を表す例として残す．

### `categoryName`：費目の名前を返す

```haskell
  describe "categoryName" $ do
    it "費目の名前を返す" $
      map categoryName [Food, Transport, Daily, Other] `shouldBe` ["食費", "交通費", "日用品", "その他"]
```

データコンストラクタごとに定義を分ける．

```haskell
categoryName :: Category -> String
categoryName Food = "食費"
categoryName Transport = "交通費"
categoryName Daily = "日用品"
categoryName Other = "その他"
```

### `parseEntry`：`費目:金額`を読み取る

```haskell
  describe "parseEntry" $ do
    it "「費目:金額」を読み取る" $
      parseEntry "食費:1200" `shouldBe` Entry {category = Food, amount = 1200}
```

`:`がある場合だけを考えて実装する．

```haskell
parseEntry :: String -> Entry
parseEntry arg = Entry (parseCategory name) (read (drop 1 rest))
  where
    (name, rest) = break isColon arg
    isColon c = c == ':'
```

`where`の中で`(name, rest) = …`と書くと，タプルの2つの要素にそれぞれ名前を付けられる．

### `parseEntry`：`:`がなければ，全体を金額とし，費目をその他とする

```haskell
    it "「:」がなければ，全体を金額とし，費目をその他とする" $
      parseEntry "800" `shouldBe` Entry {category = Other, amount = 800}
```

`break isColon "800"`は`("800", "")`になる．
今の実装では`name`が`"800"`，`rest`が`""`なので，`read ""`で失敗する．

`:`があるかどうかを`case`式で分ける．

```haskell
parseEntry :: String -> Entry
parseEntry arg =
  case break isColon arg of
    (name, _ : amountText) -> Entry (parseCategory name) (read amountText)
    (amountText, []) -> Entry Other (read amountText)
  where
    isColon c = c == ':'
```

### `formatEntry`：費目と金額を空白で区切って表示する

```haskell
  describe "formatEntry" $ do
    it "費目と金額を空白で区切って表示する" $
      formatEntry (Entry {category = Transport, amount = 1200}) `shouldBe` "交通費 1,200円"
```

```haskell
import Kakeibo.Money (formatYen)

formatEntry :: Entry -> String
formatEntry entry = categoryName (category entry) ++ " " ++ formatYen (amount entry)
```

### `run`：支出を1件ずつ表示し，最後に合計を表示する

```haskell
    it "支出を1件ずつ表示し，最後に合計を表示する" $
      run ["食費:1200", "交通費:350"]
        `shouldBe` ["食費 1,200円", "交通費 350円", "合計: 1,550円"]
```

```haskell
import Kakeibo.Entry (Entry (..), formatEntry, parseEntry)
import Kakeibo.Money (formatYen, total)

run :: [String] -> [String]
run [] = ["支出はありません"]
run args = map formatEntry entries ++ ["合計: " ++ formatYen (total (map amount entries))]
  where
    entries = map parseEntry args
```

このテストが通ると，既存の`run ["1200", "350", "800"]`のテストが失敗する．
`1200`などが「その他」の支出として読まれ，明細の行が付くからである．

### `run`：費目のない金額は，その他として表示する

既存のテストの期待値を，要求どおりの表示に変える．

```haskell
    it "費目のない金額は，その他として表示する" $
      run ["1200", "350", "800"]
        `shouldBe` ["その他 1,200円", "その他 350円", "その他 800円", "合計: 2,350円"]
```

## 演習2-5：振り返る

1. `categoryName`を費目ごとの4つのテストに分けてもよい．1つにまとめると短く書けるが，失敗したときにどの費目が誤っているかは，表示されたリストを見比べて探すことになる．
2. `deriving (Show, Eq)`を消すと，テストのコンパイルが次のように失敗する．

   ```
   error: [GHC-39999]
       • No instance for ‘Show Entry’ arising from a use of ‘shouldBe’
   ```

   `shouldBe`は，値を`==`で比べ(`Eq`)，違っていれば両方を文字列にして表示する(`Show`)．そのため，比べる値の型には`Show`と`Eq`の両方が必要である．
3. `categoryName`に次の警告が出る．`parseCategory`は最後が`_`なので警告は出ないが，「娯楽」を読めるようにするには，やはり定義を足す必要がある．

   ```
   warning: [GHC-62161] [-Wincomplete-patterns]
       Pattern match(es) are non-exhaustive
       In an equation for ‘categoryName’:
           Patterns of type ‘Category’ not matched: Entertainment
   ```

4. 要求の「`:`がない引数は，全体を金額とし，費目を「その他」とする」と「支出を1件ずつ表示する」の2つから，`その他 1,200円`などの明細の行が付くことが決まる．

## 演習2-6(発展)：費目「娯楽」を足す

テストリストに次の項目を足す．

- `parseCategory`：「娯楽」を娯楽として読む
- `categoryName`：費目の名前を返す(期待値に「娯楽」を足す)

```haskell
data Category
  = Food
  | Transport
  | Daily
  | Entertainment
  | Other
  deriving (Show, Eq)

parseCategory :: String -> Category
parseCategory "食費" = Food
parseCategory "交通費" = Transport
parseCategory "日用品" = Daily
parseCategory "娯楽" = Entertainment
parseCategory _ = Other

categoryName :: Category -> String
categoryName Food = "食費"
categoryName Transport = "交通費"
categoryName Daily = "日用品"
categoryName Entertainment = "娯楽"
categoryName Other = "その他"
```

`parseCategory "娯楽"`の定義は，どんな名前にも合う`parseCategory _`より前に書く．
