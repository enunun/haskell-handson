# Iteration 5：型クラスで金額を表す(演習)

## このIterationで作るもの

費目ごとの小計を，金額の大きい順に表示する．

```console
$ cabal run kakeibo-iteration5 -- 食費:350 交通費:1200 800
食費 350円
交通費 1,200円
その他 800円
費目別:
  交通費 1,200円
  その他 800円
  食費 350円
合計: 2,350円
```

あわせて，コードの書き方を改める．

- 金額を`Int`のままではなく，金額を表す型`Yen`で表す．金額の足し算を，型クラス`Semigroup`・`Monoid`のインスタンスとして定義する．
- `formatYen`・`categoryName`・`formatEntry`という別々の名前の表示の関数を，自分で定義する型クラス`Display`の`display`という1つの名前にまとめる．
- 費目ごとの集計を，`Data.Map`を使って書き直す．

## 進め方

演習5-1から順に進める．
詰まったら，`../solution/docs/iteration-5.md`の同じ番号の節を読む．
コマンドはすべてリポジトリ直下で実行する．

## 演習5-1：パッケージを登録してビルドする

1. `cabal.project`の`packages`に，このパッケージのディレクトリを追記する．
2. このパッケージのテストをすべて実行し，引き継いだテストがすべて通ることを確かめる．
3. このパッケージの実行ファイルを，引数`食費:350 交通費:1200 800`で実行し，今の小計の並び順を確かめる．

## 演習5-2：型クラスと`Data.Map`を試す

[Iteration 5で使う文法・概念](../../../../docs/haskell/iteration-5.md)を読み，GHCiで例を試す．
読み終えたら，GHCiで次を試す．

1. `:i Ord`で，`Ord`のメソッドとインスタンスの一覧を表示する．`Ord`のインスタンスになっている型をいくつか挙げる．
2. `newtype Count = Count Int deriving (Show, Eq, Ord)`を定義する．`Count 3 + Count 4`がエラーになることを確かめ，エラーメッセージを読む．
3. `Count`を`Semigroup`と`Monoid`のインスタンスにして(`<>`は足し算，`mempty`は`Count 0`)，`mconcat [Count 3, Count 4]`と`mconcat []`を評価する．`mconcat []`は，`:: Count`で型を指定する．
4. `Data.Map.Strict`をqualifiedでimportし，`Map.fromListWith (+) [("a", 1), ("b", 2), ("a", 3)]`を評価する．結果を`Map.toList`でリストにする．

## 演習5-3：テストリストを書く

次の要求を読み，[TESTLIST.md](../TESTLIST.md)にテストリストを書く．

### 要求

- 費目ごとの小計を，金額の大きい順に表示する．金額が同じ費目どうしは，費目の定義の順(食費・交通費・日用品・その他)に並べる．
- 表示は，小計の並び順のほかはこれまでと変えない．
- 金額を`newtype Yen = Yen Int`で表す．`Yen`は`Semigroup`・`Monoid`のインスタンスにし，`<>`を金額の足し算，`mempty`を0円にする．
- 表示の関数を，型クラス`Display`のインスタンスにまとめる．`Yen`・`Category`・`Entry`を`Display`のインスタンスにし，`formatYen`・`categoryName`・`formatEntry`はなくす．
- 費目ごとの集計を，`Data.Map.Strict`を使って書き直す．

### 作るもの

新しいモジュール`Kakeibo.Display`を作り，型クラスを定義する．

```haskell
class Display a where
  display :: a -> String
```

| モジュール | 型・関数 | このIterationで変えること |
|---|---|---|
| `Kakeibo.Money` | `newtype Yen = Yen Int` | 新しく作る．`Show`・`Eq`・`Ord`を`deriving`し，`Semigroup`・`Monoid`・`Display`のインスタンスにする． |
| `Kakeibo.Money` | `total :: [Yen] -> Yen` | 型を変え，`mconcat`で定義する． |
| `Kakeibo.Entry` | `Entry`の`amount :: Yen` | フィールドの型を変える．`Category`と`Entry`を`Display`のインスタンスにする． |
| `Kakeibo.Entry` | `parseAmount :: String -> Maybe Yen` | 型を変える． |
| `Kakeibo.Summary` | `summarize :: [Entry] -> [(Category, Yen)]` | 型を変え，金額の大きい順に並べる． |

`Kakeibo.Display`は`library`の`exposed-modules`に，`containers`は`library`の`build-depends`に追記する．

### 考えること

- 型が変わると，既存のテストのどこを書き換えることになるか．書き換えたテストも，テストリストの項目にする．
- `formatYen`のテストで確かめていたこと(3桁区切りなど)は，何のテストとして残すか．
- 「大きい順」と「金額が同じなら定義順」は，それぞれどんな入力で確かめられるか．既存の`summarize`のテストのうち，期待値が変わるものはどれか．
- 結合テストでは，並び順の変化をどんな例で確かめるか．

## 演習5-4：テスト駆動で実装する

多くの関数の型が変わるので，一度にすべてを書き換えると，コンパイルエラーが大量に出て，どこから直せばよいかわからなくなる．
新しい型とインスタンスを古い関数と並べて作り，使う側を少しずつ切り替え，最後に古い関数を消す，という順に進める．
コンパイルが通り，テストがすべて通る状態に，こまめに戻ってくる．

### 1. `Display`型クラスを作る

- `src/Kakeibo/Display.hs`を作り，`Display`を定義する．エクスポートリストには`Display (..)`と書く(型クラスとそのメソッドを公開する)．
- `exposed-modules`に追記し，ビルドが通ることを確かめる．

### 2. `Yen`を作る

- `Kakeibo.Money`に`newtype Yen`を足し，エクスポートする．この段階では`total`と`formatYen`はそのまま残す．
- `<>`と`mempty`のテストを1つずつ書き，`Semigroup`・`Monoid`のインスタンスを定義する．
- `display`のテストを書き，`Yen`の`Display`のインスタンスを定義する．`formatYen`のテストを`display (Yen …)`のテストに書き換えていけば，3桁区切りの場合分けをそのまま引き継げる．

### 3. 金額の型を`Yen`に切り替える

- `total`の型を`[Yen] -> Yen`に変え，`total`のテストを書き換える．`total`は`mconcat`で定義できる．
- `Entry`の`amount`と`parseAmount`の型を変え，`Kakeibo.Entry`のテストを書き換える．
- コンパイルエラーを上から順に直す．`formatYen`を使っていた場所は，`display`に置き換える．`summarize`の型も`[(Category, Yen)]`に変わる．
- テストがすべて通ったら，`formatYen`を消す．

### 4. `Category`と`Entry`を`Display`のインスタンスにする

- `categoryName`のテストを`display`のテストに書き換え，`Category`の`Display`のインスタンスを定義する．
- `formatEntry`も同じように`Entry`の`Display`のインスタンスにする．
- 使う側を`display`に切り替えてから，`categoryName`と`formatEntry`を消す．

### 5. 小計を金額の大きい順に並べる

- `summarize`のテストを，要求の並び順に合わせて書き換え，足す．
- `containers`を`build-depends`に追記し，`Data.Map.Strict`で書き直す．費目をキー，金額を値にした表を`Map.fromListWith (<>)`で作ると，同じ費目の金額が`Yen`の`<>`でまとめられる．
- `Map`のキーにするには，`Category`が`Ord`のインスタンスである必要がある．
- `Map.toList`の結果は，キー(費目)の小さい順になる．それを`sortOn`と`Down`で金額の大きい順に並べ替える．`sortOn`は，基準が同じ要素の順番を保つ．
- 結合テストにも，並び順が変わったことがわかる例を足す．

## 演習5-5：振り返る

1. 自分の`TESTLIST.md`と，解答例の[TESTLIST.md](../../solution/TESTLIST.md)を比べる．
2. `Yen`を`Monoid`のインスタンスにしたことで，`total`と`summarize`はどう書けるようになったか．
3. `newtype Yen`の代わりに`type Yen = Int`と書いていたら，何が起きなかったか．金額と件数を取り違えるような誤りは，どちらで防げるか．
4. `Show`と`Display`はどちらも値を文字列にする．`Yen 1200`を`show`した結果と`display`した結果を比べ，2つを分けた理由を説明する．
5. 型を変えるとき，古い関数を残したまま新しい型を足していった．一度にすべてを書き換える場合と比べて，何がよかったか．

## 演習5-6(発展)：割合を表示する

小計の後ろに，合計に対する割合を整数の百分率で表示する(小数点以下は切り捨てる)．

```console
$ kakeibo 食費:350 交通費:1200 800
…
費目別:
  交通費 1,200円(51%)
  その他 800円(34%)
  食費 350円(14%)
合計: 2,350円
```

1. 割合を計算する関数を`Kakeibo.Money`に作ることを考え，テストリストに項目を足す．
2. 1項目ずつRed→Greenを回す．整数の割り算には`div`を使う．
