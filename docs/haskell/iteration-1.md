# Iteration 1：パターンマッチ・再帰・ガード

Iteration 1で使う文法と概念をまとめる．

## 複数行の定義をGHCiで試す

GHCiで複数行にわたる定義を入力するときは，`:{`と`:}`で囲む．

```console
ghci> :{
ghci| isZero :: Int -> Bool
ghci| isZero 0 = True
ghci| isZero _ = False
ghci| :}
ghci> isZero 0
True
```

## パターンマッチ

関数は，引数の形(パターン)ごとに分けて定義できる．
呼び出されると，上の定義から順に引数とパターンを照らし合わせ，最初に合った定義を使う．

```haskell
describeCount :: Int -> String
describeCount 0 = "なし"
describeCount 1 = "1件"
describeCount n = show n ++ "件"
```

| パターン | 合う値 |
|---|---|
| `0`，`"abc"`などのリテラル | その値と等しい値 |
| `n`などの変数 | どんな値にも合う．合った値にその名前が付く． |
| `_` | どんな値にも合う．名前は付けない． |

上から順に照らし合わせるので，どんな値にも合うパターンは最後に書く．
`describeCount n = …`を最初に書くと，`0`や`1`の定義は使われなくなる．

## リストのパターン

リストは，空のリスト`[]`か，先頭の要素と残りのリストを`:`でつないだもののどちらかである．

```console
ghci> 1 : [2, 3]
[1,2,3]
ghci> 1 : 2 : 3 : []
[1,2,3]
```

`[1, 2, 3]`は`1 : (2 : (3 : []))`の書き方を短くしたものである．
`:`はリストの先頭に要素を1つ付け足す演算子で，右から結び付く．

パターンでも同じ形を使える．

```haskell
firstOr :: Int -> [Int] -> Int
firstOr def [] = def
firstOr _ (x : _) = x
```

- `[]`は空のリストに合う．
- `(x : rest)`は要素が1つ以上のリストに合い，先頭の要素に`x`，残りのリストに`rest`という名前を付ける．
- `[x]`は要素がちょうど1つのリストに合う．

`String`は`Char`のリストなので，文字列にも同じパターンが使える．

## パターンの漏れの警告

このハンズオンのパッケージは，`.cabal`の`ghc-options`に`-Wall`を指定している．
そのため，引数のとりうる形をすべて書いていない定義には，コンパイル時に警告が出る．

```haskell
firstOf :: [Int] -> Int
firstOf (x : _) = x
```

```
warning: [GHC-62161] [-Wincomplete-patterns]
    Pattern match(es) are non-exhaustive
    In an equation for ‘firstOf’:
        Patterns of type ‘[Int]’ not matched: []
```

この`firstOf []`を実行すると，プログラムはエラーで止まる．
警告が出たら，漏れているパターンの定義を足す．

## 再帰

関数の定義の中で，その関数自身を呼ぶことを再帰という．
Haskellには`for`や`while`のようなループの構文がない．
リストの要素を1つずつ処理するときは，再帰で書く．

```haskell
count :: [Int] -> Int
count [] = 0
count (_ : rest) = 1 + count rest
```

`count [7, 8, 9]`は，定義に当てはめると次のように計算される．

```
count [7, 8, 9]
= 1 + count [8, 9]
= 1 + (1 + count [9])
= 1 + (1 + (1 + count []))
= 1 + (1 + (1 + 0))
= 3
```

再帰の定義は2つの部分でできている．

- 空のリストのように，それ以上分けられない場合の答え(基底部)．
- 残りのリストについての答えを使って，全体の答えを作る方法(再帰部)．

再帰部では，引数が必ず基底部に近づく(リストが短くなる)ようにする．
そうしないと，計算が終わらない．

## ガード

`|`のあとに条件(`Bool`の式)を書くと，条件によって定義を分けられる．
上の条件から順に調べ，最初に`True`になった定義を使う．

```haskell
classify :: Int -> String
classify amount
  | amount >= 10000 = "高額"
  | amount >= 1000 = "中額"
  | otherwise = "少額"
```

`otherwise`は`True`と同じ値で，「それ以外すべて」を表す．
パターンが値の形で分けるのに対し，ガードは任意の条件で分けられる．

## `where`

`where`は，定義の中で使う名前を，定義の後ろにまとめて書く構文である．
同じ式を何度も書かずに済み，式に意味のある名前を付けられる．

```haskell
lastThree :: String -> String
lastThree s
  | len <= 3 = s
  | otherwise = drop (len - 3) s
  where
    len = length s
```

`where`で定義した名前は，その定義のすべてのガードから使える．
`where`の中では，関数も定義できる．

## `let`

`let 名前 = 式 in 式`は，`in`の後ろの式の中だけで使える名前を定義する．

```haskell
withTax :: Int -> Int
withTax amount =
  let tax = amount `div` 10
   in amount + tax
```

`where`は定義全体の後ろに，`let`は式の途中に書く．
どちらを使っても意味は同じである．
GHCiでは`let`を使わずに，`x = 5`のように直接名前を定義できる．

## 文字列を操作する関数

| 関数 | 型 | 例 |
|---|---|---|
| `length` | `[a] -> Int` | `length "1234"`は`4` |
| `take` | `Int -> [a] -> [a]` | `take 2 "1234"`は`"12"` |
| `drop` | `Int -> [a] -> [a]` | `drop 2 "1234"`は`"34"` |
| `reverse` | `[a] -> [a]` | `reverse "123"`は`"321"` |

型の中の`a`は「どんな型でもよい」という意味の型変数である．
`length`は，要素が何の型であってもリストの長さを返す．
`take 2 "1234"`では`a`が`Char`に，`take 2 [5, 6, 7]`では`a`が数の型になる．

## モジュールの中だけで使う関数

エクスポートリスト(`module Kakeibo.Money (total, formatYen) where`の括弧の中)に書かなかった関数は，そのモジュールの中でしか使えない．
ほかの関数を組み立てるための部品は，エクスポートせずにモジュールの中に置ける．
エクスポートしていない関数は，テストからも直接は呼べないので，それを使う公開された関数のテストを通して確かめる．
