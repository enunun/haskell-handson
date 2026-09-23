# Iteration 5：型クラス・`newtype`・`Data.Map`

Iteration 5で使う文法と概念をまとめる．

## 型クラス

型クラスは，いくつかの型に共通する操作の集まりに名前を付けたものである．
`class`で，型クラスの名前と，その型クラスに属する型が持つ関数(メソッド)の型を宣言する．

```haskell
class Display a where
  display :: a -> String
```

これは「`Display`に属する型`a`には，`a`を文字列にする`display`という関数がある」という宣言である．

型を型クラスに属させるには，`instance`で，その型についてのメソッドの定義を書く．

```haskell
instance Display Category where
  display Food = "食費"
  display Transport = "交通費"
  display Daily = "日用品"
  display Other = "その他"

instance Display Entry where
  display entry = display (category entry) ++ " " ++ display (amount entry)
```

`display`は，`Category`にも`Entry`にも使える1つの名前になる．
どのインスタンスの定義が使われるかは，引数の型で決まる．
`Entry`の`display`の中の`display (category entry)`は`Category`の定義を，`display (amount entry)`は金額の型の定義を使う．

## 型クラス制約

型クラスのメソッドの型には，`=>`の前に条件(型クラス制約)が付く．

```console
ghci> :t display
display :: Display a => a -> String
ghci> :t show
show :: Show a => a -> String
ghci> :t (+)
(+) :: Num a => a -> a -> a
```

`Display a => a -> String`は「`a`が`Display`に属する型なら，`a -> String`である」と読む．
`Display`のインスタンスがない型の値を`display`に渡すと，`No instance for ‘Display …’`というコンパイルエラーになる．

これまでに出てきた型クラスは，標準のライブラリで定義されている．

| 型クラス | 主なメソッド | 意味 |
|---|---|---|
| `Show` | `show` | 値をHaskellの式の形の文字列にする． |
| `Eq` | `==`，`/=` | 等しいかを比べる． |
| `Ord` | `compare`，`<`，`max` | 大小を比べる．`Eq`に属する型だけが属せる． |
| `Enum` | `succ`，`[x .. y]` | 値に順番がある． |
| `Bounded` | `minBound`，`maxBound` | 最小と最大の値がある． |
| `Num` | `+`，`*`，`negate` | 数として計算できる． |
| `Read` | `read` | 文字列から読み取れる． |

`deriving (Show, Eq)`は，これらの型クラスのインスタンスを自動で作る指示である．
`Display`のように自分で定義した型クラスは`deriving`できないので，`instance`を書く．

`:i 型クラス名`で，型クラスのメソッドとインスタンスの一覧を表示できる．

## `newtype`

`newtype`は，既存の型を包んで，別の型として扱えるようにする．

```haskell
newtype Yen = Yen Int
  deriving (Show, Eq, Ord)
```

`Yen 1200`は`Int`の`1200`と同じ情報を持つが，型は`Yen`である．
`Int`を受け取る関数に`Yen`を渡したり，金額と件数(どちらも`Int`)を取り違えたりすると，コンパイルエラーになる．
中の`Int`は，パターンマッチで取り出す．

```haskell
instance Display Yen where
  display (Yen n) = insertCommas (show n) ++ "円"
```

`newtype`は，データコンストラクタが1つで，値を1つだけ持つ型に使える．
`data Yen = Yen Int`と書いても同じように使えるが，`newtype`にすると，実行時には中の`Int`がそのまま使われ，包むための手間がかからない．

`type Yen = Int`と書くと，`Yen`は`Int`の別名になる．
別名は`Int`と区別されないので，取り違えを防ぐ役には立たない．

## `Semigroup`と`Monoid`

`Semigroup`は，同じ型の2つの値を1つにまとめる演算`<>`を持つ型クラスである．
`Monoid`は，それに加えて，まとめても相手を変えない値`mempty`を持つ型クラスである．

```haskell
instance Semigroup Yen where
  Yen a <> Yen b = Yen (a + b)

instance Monoid Yen where
  mempty = Yen 0
```

演算子のメソッドは，`Yen a <> Yen b = …`のように，演算子を2つの引数のあいだに書いて定義できる．

リストと文字列も`Monoid`である．
`<>`は`++`，`mempty`は空のリストになる．

```console
ghci> "ab" <> "cd"
"abcd"
ghci> mempty :: String
""
ghci> mconcat ["ab", "cd", "ef"]
"abcdef"
ghci> foldMap show [1, 2, 3]
"123"
```

`Monoid`のインスタンスがあると，次の関数が使える．

| 関数 | 型 | 意味 |
|---|---|---|
| `mconcat` | `Monoid a => [a] -> a` | リストの要素をすべて`<>`でまとめる．空のリストなら`mempty`． |
| `foldMap` | `Monoid m => (a -> m) -> [a] -> m` | 各要素を関数で変換してから，すべて`<>`でまとめる． |

`mconcat [Yen 1200, Yen 350]`は`Yen 1550`，`mconcat []`は`Yen 0`になる．
`foldr (+) 0`で書いていた合計を，`Yen`の`Monoid`のインスタンスを使って`mconcat`で書ける．

`<>`は，`(a <> b) <> c`と`a <> (b <> c)`が同じ値になるように定義する(結合法則)．
`mempty`は，`mempty <> a`と`a <> mempty`が`a`と同じ値になるように定義する(単位元)．
`mconcat`は，この2つが成り立つことを前提に，要素をまとめる順番を決めている．

## `Ord`と並べ替え

`deriving (Ord)`で作った大小の順は，次のようになる．

- `data`で定義した直和型では，先に書いたデータコンストラクタほど小さい．
- `newtype`では，中の値の大小になる．

```console
ghci> data Size = Small | Medium | Large deriving (Show, Eq, Ord)
ghci> Small < Large
True
ghci> maximum [Medium, Small, Large]
Large
```

`Data.List`モジュールと`Data.Ord`モジュールに，並べ替えの関数がある．

| 関数 | 型 | 意味 |
|---|---|---|
| `sort` | `Ord a => [a] -> [a]` | 小さい順に並べる． |
| `sortOn` | `Ord b => (a -> b) -> [a] -> [a]` | 各要素に関数を適用した結果の，小さい順に並べる． |
| `Down` | `a -> Down a` | 大小を逆にする．`Down`で包んだ値は，元の値が大きいほど小さい． |

```console
ghci> import Data.List (sort, sortOn)
ghci> import Data.Ord (Down (..))
ghci> sort [3, 1, 2]
[1,2,3]
ghci> sortOn snd [("a", 3), ("b", 1), ("c", 2)]
[("b",1),("c",2),("a",3)]
ghci> sortOn Down [3, 1, 2]
[3,2,1]
```

`sortOn (Down . snd)`は，タプルの2つ目の要素の大きい順に並べる．
`sortOn`は，並べ替えの基準が同じ要素どうしの順番を，元のリストの順のまま保つ(安定な並べ替え)．

## `Data.Map`

`Data.Map.Strict`モジュールの`Map k v`は，キー(`k`)から値(`v`)を引ける表である．
`containers`パッケージにあるので，使うコンポーネントの`build-depends`に`containers`を追加する．
キーの型は`Ord`に属している必要がある．

```console
ghci> import Data.Map.Strict qualified as Map
ghci> m = Map.fromListWith (+) [("food", 1200), ("rent", 80000), ("food", 350)]
ghci> m
fromList [("food",1550),("rent",80000)]
ghci> Map.lookup "food" m
Just 1550
ghci> Map.lookup "book" m
Nothing
ghci> Map.toList m
[("food",1550),("rent",80000)]
```

| 関数 | 意味 |
|---|---|
| `Map.fromList` | キーと値の組のリストから表を作る．同じキーがあれば後の値を使う． |
| `Map.fromListWith f` | 同じキーの値を`f`でまとめながら表を作る． |
| `Map.lookup k m` | キー`k`の値を`Maybe`で返す．キーがなければ`Nothing`． |
| `Map.toList m` | キーの小さい順に，キーと値の組のリストにする． |

`Data.Map.Strict`には，Preludeの関数と同じ名前の関数(`filter`，`map`など)が多い．
そのため，`qualified`を付けてimportし，`Map.`を前に付けて呼ぶ．

```haskell
import Data.Map.Strict qualified as Map
```

`qualified`を付けたimportでは，そのモジュールの名前を`as`の後ろの名前(ここでは`Map`)を前に付けて使う．
`import qualified Data.Map.Strict as Map`と書いても同じ意味である．
このハンズオンで使う言語仕様`GHC2021`では，どちらの書き方もできる．
