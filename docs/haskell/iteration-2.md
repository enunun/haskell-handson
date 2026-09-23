# Iteration 2：データ型・`case`式・タプル

Iteration 2で使う文法と概念をまとめる．

## `data`で型を定義する

`data`で新しい型を定義できる．

```haskell
data Category
  = Food
  | Transport
  | Daily
  | Other
```

- `Category`が型の名前，`Food`・`Transport`・`Daily`・`Other`がその型の値を作るもの(データコンストラクタ)である．
- `|`は「または」を表す．`Category`の値は，この4つのうちのどれか1つである．このように，いくつかの候補のどれか1つを表す型を直和型という．
- 型の名前とデータコンストラクタの名前は，大文字で始める．

データコンストラクタは，値を持たせることもできる．

```haskell
data Entry = Entry Category Int
```

右辺の`Entry`はデータコンストラクタで，`Category`と`Int`の2つの値を受け取って`Entry`型の値を作る．
型の名前とデータコンストラクタの名前は別のものなので，このように同じ名前を付けてよい．

```console
ghci> :t Entry
Entry :: Category -> Int -> Entry
ghci> :t Entry Food 1200
Entry Food 1200 :: Entry
```

データコンストラクタは，値を受け取って型の値を返す関数のように使える．

## レコード構文

値の1つ1つに名前(フィールド名)を付けて定義することもできる．

```haskell
data Entry = Entry
  { category :: Category,
    amount :: Int
  }
```

レコード構文で定義すると，次のことができる．

- `Entry {category = Food, amount = 1200}`のように，フィールド名を書いて値を作れる．フィールドの順番は自由である．`Entry Food 1200`のように，名前なしで順番に並べて作ることもできる．
- フィールド名と同じ名前の関数ができる．`category :: Entry -> Category`と`amount :: Entry -> Int`で，値からそのフィールドを取り出せる．

```console
ghci> e = Entry {category = Food, amount = 1200}
ghci> amount e
1200
ghci> map amount [e, Entry Other 800]
[1200,800]
```

## `deriving`

`deriving (Show, Eq)`を定義の後ろに書くと，その型の値を文字列にする機能(`Show`)と，等しいかを比べる機能(`Eq`)が自動で作られる．

```haskell
data Category
  = Food
  | Transport
  | Daily
  | Other
  deriving (Show, Eq)
```

```console
ghci> show Food
"Food"
ghci> Food == Other
False
ghci> Entry Food 1200
Entry {category = Food, amount = 1200}
```

GHCiが値を表示するには`Show`が，hspecの`shouldBe`で値を比べるには`Show`と`Eq`の両方が必要である．
`shouldBe`は，値が等しいかを`Eq`で調べ，等しくなければ両方の値を`Show`で文字列にして表示するからである．
`Show`や`Eq`のような「型が持つ機能の集まり」を型クラスという．型クラスはIteration 5で詳しく学ぶ．

## データコンストラクタでのパターンマッチ

関数は，データコンストラクタごとに定義を分けられる．

```haskell
categoryName :: Category -> String
categoryName Food = "食費"
categoryName Transport = "交通費"
categoryName Daily = "日用品"
categoryName Other = "その他"
```

値を持つデータコンストラクタでは，パターンで中の値に名前を付けられる．

```haskell
isFood :: Entry -> Bool
isFood (Entry Food _) = True
isFood _ = False
```

`Category`に新しいデータコンストラクタを足すと，`-Wall`により，それを扱っていない関数(`categoryName`など)に「パターンが漏れている」という警告が出る．
型を変えたときに直すべき場所を，コンパイラが教えてくれる．

## `case`式

`case 式 of`は，式の値をパターンで場合分けする式である．
関数の定義を分ける代わりに，式の途中で場合分けしたいときに使う．

```haskell
countLabel :: Int -> String
countLabel n =
  case n of
    0 -> "なし"
    1 -> "1件"
    _ -> show n ++ "件"
```

`->`の左にパターン，右にそのときの値を書く．
上のパターンから順に調べ，最初に合ったものを使う．
パターンは，`of`の後ろで字下げをそろえて並べる．

## タプル

タプルは，いくつかの値を組にしたものである．
リストと違い，要素の型がそれぞれ違ってよく，要素の数は型で決まる．

```console
ghci> :t ("rent", 80000 :: Int)
("rent", 80000 :: Int) :: (String, Int)
ghci> fst ("rent", 80000)
"rent"
ghci> snd ("rent", 80000)
80000
```

タプルもパターンで分解できる．

```haskell
swap :: (String, Int) -> (Int, String)
swap (name, n) = (n, name)
```

## `break`

`break`は，リストを，条件を初めて満たす要素の手前で2つに分け，タプルで返す．

```console
ghci> :t break
break :: (a -> Bool) -> [a] -> ([a], [a])
ghci> isColon c = c == ':'
ghci> break isColon "food:1200"
("food",":1200")
ghci> break isColon "1200"
("1200","")
```

1つ目の引数は「要素を受け取って`Bool`を返す関数」で，分ける位置の条件を表す．
条件を満たす要素がなければ，2つ目の要素は空のリストになる．

`case`と組み合わせると，区切りがあるかどうかで場合分けできる．

```haskell
splitAtColon :: String -> (String, String)
splitAtColon s =
  case break isColon s of
    (before, _ : after) -> (before, after)
    (before, []) -> (before, "")
  where
    isColon c = c == ':'
```

`(before, _ : after)`は「2つ目の要素が空でないリスト」に合い，先頭の`:`を`_`で読み飛ばして，残りに`after`という名前を付ける．

## 型とデータコンストラクタのエクスポート

型をエクスポートするときは，データコンストラクタも公開するかを選べる．

```haskell
module Kakeibo.Entry
  ( Category (..),   -- 型とすべてのデータコンストラクタ
    Entry (..),      -- 型とデータコンストラクタとフィールド名
    parseEntry,
  )
where
```

`Category (..)`の`(..)`は「データコンストラクタをすべて」という意味である．
`(..)`を付けずに`Category`とだけ書くと，型の名前だけが公開され，ほかのモジュールでは`Food`などを使えない．
importするときも同じ書き方をする．

```haskell
import Kakeibo.Entry (Entry (..), parseEntry)
```

## 関数の中で関数を定義する

`where`の中では，値だけでなく関数も定義できる．

```haskell
parseEntry arg =
  case break isColon arg of
    …
  where
    isColon c = c == ':'
```

`isColon`は`parseEntry`の中だけで使える関数になる．
