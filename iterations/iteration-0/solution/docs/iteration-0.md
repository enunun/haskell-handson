# Iteration 0：合計を表示する(解説)

演習用の`docs/iteration-0.md`の各手順について，解答の例と考え方を説明する．

## 演習0-1：パッケージを登録してビルドする

`cabal.project`の`packages`に`iterations/iteration-0/exercise`を追記すると，cabalとHLSがこのパッケージを扱えるようになる．
追記する前は，`cabal build kakeibo-iteration0`はパッケージが見つからずに失敗し，エディタでも型が表示されない．

`cabal test kakeibo-iteration0`で`0 examples`となるのは，テストスイートの`Spec.hs`がhspec-discoverのドライバだけで，Specファイルがまだ1つもないからである．

`cabal run kakeibo-iteration0 -- 1200 350 800`の出力は次のようになる．

```
kakeibo: TODO: 「合計: 〜円」という1行だけのリストを返す
CallStack (from HasCallStack):
  error, called at src/Kakeibo/App.hs:6:9 in kakeibo-iteration0-0.1.0.0-inplace:Kakeibo.App
```

`src/Kakeibo/App.hs:6:9`は「6行目の9文字目」である．
`main`が`run`を呼び，`run`の`error`が評価されたところでプログラムが止まっている．

## 演習0-2：GHCiで式を試す

```console
ghci> sum [1200, 350, 800]
2350
ghci> show 2350 ++ "円"
"2350\20870"
ghci> putStrLn (show 2350 ++ "円")
2350円
ghci> import Kakeibo.Money
ghci> :t total
total :: [Int] -> Int
ghci> :t formatYen
formatYen :: Int -> String
ghci> map read ["1200", "350"] :: [Int]
[1200,350]
ghci> read "abc" :: Int
*** Exception: Prelude.read: no parse
```

GHCiは評価した値を`show`で表示するので，文字列の中の`円`は`\20870`という番号で表示される．
`putStrLn`で表示すると，`円`がそのまま表示される．

`show 1 + 2`は，関数の呼び出しが演算子より先に結び付くので`(show 1) + 2`と読まれる．
`show 1`は`String`なので，`String`と数を`+`で足そうとして型エラーになる．
`show (1 + 2)`は，括弧の中の`1 + 2`を先に計算して`3`にし，それを`show`するので`"3"`になる．

## 演習0-3：テストリストを書く

解答例のテストリストは[TESTLIST.md](../TESTLIST.md)である．

- `total`は，要素が0個・1個・複数個の3つの場合を試す．0個は「何も足さないと0」という境界，1個は「足す相手がいない」場合，複数個は足し算そのものを確かめる．
- `formatYen`は，ふつうの金額と0円を試す．0円は，実装によっては空文字列や`円`だけになりうる境界である．
- `run`の結合テストは，使い方の例の2つ(金額を並べた場合と引数がない場合)にした．`total`の場合分けは単体テストで確かめているので，結合テストでは「引数が`total`と`formatYen`を通って1行になる」ことを確かめれば足りる．

## 演習0-4：設計書を書く

解答例の設計書は[../design/](../design/)にある．

| ファイル | 描いたもの |
|---|---|
| [01-context.md](../design/01-context.md) | 利用者が金額を引数で渡し，`kakeibo`が合計を表示する関係 |
| [02-container.md](../design/02-container.md) | 実行ファイル1つだけのコンテナ |
| [03-component.md](../design/03-component.md) | `Main`(`IO`)と，`Kakeibo.App`・`Kakeibo.Money`(純粋)の3つのモジュールと依存関係 |
| [04-code.md](../design/04-code.md) | `[String]`→`[Int]`→`Int`→`String`→`[String]`の型と関数の流れ，関数の型の表，`main`の`IO`の順序 |

- Componentの図で，`IO`を行うのは`Main`だけで，計算は純粋な部分にあることを示した．テストから直接呼べるのは純粋な部分の関数である．
- 型と関数の流れの矢印のラベルは，実装で使う関数(`map read`・`total`・`formatYen`)の名前にした．図を読むと，どの関数をどの順に組み合わせればよいかがわかる．
- テストリストの単体テストは`total`と`formatYen`(型と関数の流れの途中の矢印)を，結合テストは`run`(流れ全体)を確かめる．

## 演習0-5：テスト駆動で実装する

テストリストの上から順に進めた場合の，各段階のテストとコードを示す．

### `total`：空のリストなら0を返す

```haskell
-- test/unit/Kakeibo/MoneySpec.hs
spec :: Spec
spec = do
  describe "total" $ do
    it "空のリストなら0を返す" $
      total [] `shouldBe` 0
```

`other-modules: Kakeibo.MoneySpec`を`test-suite unit`に追記して実行すると，`error`の`TODO`メッセージで失敗する(Red)．
仮実装で通す．

```haskell
-- src/Kakeibo/Money.hs
total :: [Int] -> Int
total _ = 0
```

### `total`：要素が1つなら，その値を返す

```haskell
    it "要素が1つなら，その値を返す" $
      total [1200] `shouldBe` 1200
```

仮実装は0を返すので，次のように失敗する．

```
       expected: 1200
        but got: 0
```

仮実装では通らない例が出てきたので，一般的な実装に書き換える(三角測量)．

```haskell
total :: [Int] -> Int
total amounts = sum amounts
```

### `total`：複数の金額を足し合わせる

```haskell
    it "複数の金額を足し合わせる" $
      total [1200, 350, 800] `shouldBe` 2350
```

このテストは，書いた時点で通る．
前の段階で`sum`を使う一般的な実装にしたからである．
テストを書いたら最初から通った，ということは，その振る舞いがすでにできているということである．
このテストは「複数の金額を足す」という要求を表す例として残しておく．

### `formatYen`：金額の後ろに「円」を付ける

```haskell
  describe "formatYen" $ do
    it "金額の後ろに「円」を付ける" $
      formatYen 1200 `shouldBe` "1200円"
```

`import Kakeibo.Money (formatYen, total)`のように，importする名前も足す．
`TODO`のメッセージで失敗することを確かめ，仮実装で通す．

```haskell
formatYen :: Int -> String
formatYen _ = "1200円"
```

### `formatYen`：0円を表示する

```haskell
    it "0円を表示する" $
      formatYen 0 `shouldBe` "0円"
```

仮実装は`"1200円"`を返すので失敗する．
`show`で数を文字列にし，`++`で`"円"`をつなげる実装に書き換える．

```haskell
formatYen :: Int -> String
formatYen amount = show amount ++ "円"
```

### `run`：引数の金額の合計を`合計: 〜円`の1行で表示する

```haskell
-- test/integration/Kakeibo/AppSpec.hs
module Kakeibo.AppSpec (spec) where

import Kakeibo.App (run)
import Test.Hspec

spec :: Spec
spec = do
  describe "run" $ do
    it "引数の金額の合計を1行で表示する" $
      run ["1200", "350", "800"] `shouldBe` ["合計: 2350円"]
```

`other-modules: Kakeibo.AppSpec`を`test-suite integration`に追記し，Redを確かめる．
単体テストで作った部品を組み合わせて実装する．

```haskell
-- src/Kakeibo/App.hs
import Kakeibo.Money (formatYen, total)

run :: [String] -> [String]
run args = ["合計: " ++ formatYen (total (map read args))]
```

`map read args`の`read`がどの型の値を作るかは，型推論で決まる．
`total`は`[Int]`を受け取るので，`map read args`は`[Int]`，つまり`read`は`String`を`Int`として読む．

### `run`：引数がなければ合計は0円

```haskell
    it "引数がなければ合計は0円" $
      run [] `shouldBe` ["合計: 0円"]
```

このテストも書いた時点で通る．
`total []`が0になることは，単体テストですでに確かめている．
結合テストとしては，使い方の例の1つを表す例として残す．

## 演習0-6：振り返る

1. テストリストの粒度は人によって違ってよい．たとえば`formatYen`で大きな金額(`1234567`)を試す項目を足した人もいるだろう．その項目は，Iteration 1で3桁区切りを作るときに期待値が変わる．
2. `total`が最後の要素を返す誤りなら，`total [1200, 350, 800]`の単体テストと，`run ["1200", "350", "800"]`の結合テストの両方が失敗する．単体テストの失敗は「`total`が誤っている」ことを直接示す．結合テストだけだと，`run`の中の`map read`・`total`・`formatYen`のどれが誤っているのかを，失敗から調べる必要がある．
3. `read "abc"`が`Prelude.read: no parse`で失敗し，プログラムが止まる．`read`は，読めない文字列を渡されると値を返せないからである．エラーメッセージを表示して終わるようにする方法は，Iteration 4で学ぶ．
4. 解答例は設計書どおりに実装できた．型と関数の流れの矢印が，そのまま`run`の定義(`"合計: " ++ formatYen (total (map read args))`)になっている．

## 演習0-7(発展)：件数を表示する

テストリストに次の項目を足す．

- `run`：合計の次の行に件数を表示する(`["1200", "350", "800"]`なら`件数: 3件`)
- `run`：引数がなければ件数は0件
- 既存の結合テスト2つの期待値を，2行のリストに変える

件数の計算は`length`だけなので，単体の関数を作らずに`run`の中に書いた．

```haskell
run :: [String] -> [String]
run args =
  [ "合計: " ++ formatYen (total (map read args)),
    "件数: " ++ show (length args) ++ "件"
  ]
```
