# Iteration 3：高階関数

Iteration 3で使う文法と概念をまとめる．
`Entry`や`Category`を使う例は，`cabal repl`でパッケージを読み込み，`import Kakeibo.Entry`としてから試す．

## 関数を値として扱う

Haskellでは，関数も`Int`や`String`と同じ値である．
関数を引数として渡したり，関数を返したりできる．
関数を引数に取る関数や，関数を返す関数を，高階関数という．

関数の型は`->`で書く．
`(Int -> Bool)`は「`Int`を受け取って`Bool`を返す関数」の型である．

```haskell
applyTwice :: (Int -> Int) -> Int -> Int
applyTwice f x = f (f x)

double :: Int -> Int
double n = n * 2
```

```console
ghci> applyTwice double 5
20
```

## `map`・`filter`・`foldr`

リストを処理するときによく使う高階関数が3つある．

| 関数 | 型 | 意味 |
|---|---|---|
| `map` | `(a -> b) -> [a] -> [b]` | 各要素に関数を適用したリストを返す． |
| `filter` | `(a -> Bool) -> [a] -> [a]` | 条件を満たす要素だけのリストを返す． |
| `foldr` | `(a -> b -> b) -> b -> [a] -> b` | 要素を右から順に1つの値にまとめる． |

```console
ghci> map double [1, 2, 3]
[2,4,6]
ghci> filter even [1, 2, 3, 4]
[2,4]
ghci> foldr (+) 0 [1, 2, 3]
6
```

`foldr`は`foldr (+) 0 [1, 2, 3]`を次のように計算する．

```
foldr (+) 0 [1, 2, 3]
= 1 + foldr (+) 0 [2, 3]
= 1 + (2 + foldr (+) 0 [3])
= 1 + (2 + (3 + foldr (+) 0 []))
= 1 + (2 + (3 + 0))
= 6
```

リストの`:`を関数`(+)`に，末尾の`[]`を初期値`0`に置き換えた式になる．
Iteration 1で書いた再帰の`total`と同じ計算である．

```haskell
total [] = 0
total (amount : rest) = amount + total rest
```

空のリストのときの値(`0`)と，先頭の要素と残りの結果をまとめる関数(`+`)だけが決まれば，再帰の形は`foldr`が受け持つ．
`map`と`filter`も，同じように再帰の形を関数にまとめたものである．

## 演算子を関数として使う

演算子を括弧で囲むと，ふつうの関数として使える．

```console
ghci> (+) 1 2
3
ghci> :t (+)
(+) :: Num a => a -> a -> a
```

`Num a =>`は「`a`は数の型である」という条件を表す．型クラスはIteration 5で学ぶ．

## ラムダ式

`\引数 -> 式`と書くと，名前のない関数を作れる．
`\`はギリシャ文字のλ(ラムダ)を表す．

```console
ghci> map (\n -> n * 2 + 1) [1, 2, 3]
[3,5,7]
ghci> filter (\e -> category e == Food) [Entry Food 1200, Entry Other 800]
[Entry {category = Food, amount = 1200}]
```

1回しか使わない小さな関数を，名前を付けずにその場で書くときに使う．

## 部分適用

Haskellの関数は，引数を1つずつ受け取る．
`Int -> Int -> Int`は`Int -> (Int -> Int)`のことで，「`Int`を受け取ると，`Int -> Int`の関数を返す関数」である．
そのため，引数の一部だけを渡すと，残りの引数を受け取る関数になる．
これを部分適用という．

```haskell
addTax :: Int -> Int -> Int
addTax rate amount = amount + amount * rate `div` 100
```

```console
ghci> :t addTax 10
addTax 10 :: Int -> Int
ghci> map (addTax 10) [100, 1200]
[110,1320]
```

`map amount entries`の`map amount`や，`filter even`も部分適用である．

## セクション

2引数の演算子に，片方の引数だけを渡して括弧で囲むと，残りの引数を受け取る関数になる．
これをセクションという．

| 書き方 | 意味 |
|---|---|
| `(+ 1)` | `\x -> x + 1` |
| `(2 *)` | `\x -> 2 * x` |
| `(== Food)` | `\x -> x == Food` |
| `(> 0)` | `\x -> x > 0` |

```console
ghci> map (+ 1) [1, 2, 3]
[2,3,4]
ghci> filter (> 1000) [1200, 350, 800]
[1200]
```

`(- 1)`だけは例外で，マイナス1という数になる．1を引く関数は`subtract 1`と書く．

## 関数合成

`f . g`は「`g`を適用してから`f`を適用する」関数である．
`(f . g) x`は`f (g x)`と同じ値になる．

```console
ghci> (show . double) 21
"42"
ghci> filter ((== Food) . category) [Entry Food 1200, Entry Other 800]
[Entry {category = Food, amount = 1200}]
```

`(== Food) . category`は，`Entry`から`category`で費目を取り出し，それが`Food`と等しいかを返す関数である．
ラムダ式`\e -> category e == Food`と同じ意味になる．

`not . null`は「空でない」を表す関数である．

```console
ghci> null []
True
ghci> (not . null) [1]
True
```

## `$`

Iteration 0で見た`$`は，関数合成と組み合わせて括弧を減らすのによく使う．

```haskell
show (double (sum [1, 2, 3]))
show . double $ sum [1, 2, 3]      -- 同じ意味
```

`$`はどの演算子よりも後に結び付くので，`show . double`という関数を，`sum [1, 2, 3]`の結果に適用する式になる．
括弧と`$`のどちらを使うかは，読みやすさで選ぶ．

## 範囲と`Enum`・`Bounded`

`[1 .. 5]`は，1から5までのリストである．

```console
ghci> [1 .. 5]
[1,2,3,4,5]
ghci> ['a' .. 'e']
"abcde"
```

`deriving (Enum, Bounded)`を付けた型では，自分で定義した型でも同じ書き方ができる．

```haskell
data Category
  = Food
  | Transport
  | Daily
  | Other
  deriving (Show, Eq, Enum, Bounded)
```

- `Enum`は，値に順番を付ける．順番はデータコンストラクタを書いた順になる．
- `Bounded`は，最小の値`minBound`と最大の値`maxBound`を決める．最初と最後のデータコンストラクタになる．

```console
ghci> [Food .. Daily]
[Food,Transport,Daily]
ghci> [minBound .. maxBound] :: [Category]
[Food,Transport,Daily,Other]
```

`[minBound .. maxBound]`は，その型のすべての値を定義の順に並べたリストになる．
費目を足しても，この式を書き換える必要はない．
`minBound`がどの型の値かは使われ方から決まるので，GHCiで単独で試すときは`:: [Category]`で型を指定する．

## リストをつなげて行を組み立てる

`++`はリストどうしをつなげる．
行のリストを組み立てるとき，1行だけのリストも`[ … ]`で囲めば，ほかの行のリストとつなげられる．

```haskell
map formatEntry entries
  ++ ["費目別:"]
  ++ map formatSubtotal (summarize entries)
```

1行目より深く字下げした行は，前の行の続きとして読まれる．
