# Iteration 1：3桁区切りと，支出がないときの表示(解説)

演習用の`docs/iteration-1.md`の各手順について，解答の例と考え方を説明する．

## 演習1-1：パッケージを登録してビルドする

`cabal.project`は次のようになる．

```cabal
packages:
  iterations/iteration-0/solution
  iterations/iteration-1/solution
  iterations/iteration-0/exercise
  iterations/iteration-1/exercise
```

テストと実行のコマンドは次のとおり．

```sh
cabal test kakeibo-iteration1
cabal run kakeibo-iteration1 -- 1234567
cabal run kakeibo-iteration1
```

今の表示は`合計: 1234567円`と`合計: 0円`である．

## 演習1-2：パターンマッチと再帰を試す

```console
ghci> take 1 "1234"
"1"
ghci> drop 1 "1234"
"234"
ghci> :{
ghci| count :: [Int] -> Int
ghci| count [] = 0
ghci| count (_ : rest) = 1 + count rest
ghci| :}
ghci> count [7, 8, 9]
3
```

`[]`の場合を消すと，`count [7, 8, 9]`は再帰で`count []`まで進んだところで，どの定義にも合わずに止まる．

```
*** Exception: <interactive>:…: Non-exhaustive patterns in function count
```

ガードを使った関数の例は次のとおり．

```haskell
classify :: Int -> String
classify amount
  | amount >= 1000 = "高額"
  | otherwise = "少額"
```

## 演習1-3：テストリストを書く

解答例のテストリストは[TESTLIST.md](../TESTLIST.md)である．

- 既存のテストのうち，期待値が変わるのは3つある．単体テストの`formatYen 1200`(`1200円`から`1,200円`に)，結合テストの2つ(`合計: 2,350円`と`支出はありません`)である．
- 単体テストの「金額の後ろに「円」を付ける」は，4桁の`1200`を例にしていた．カンマが入ると「円を付ける」ことを確かめる例として読みにくくなるので，3桁の`350`に変え，`1200`はカンマの例として使った．
- 3桁区切りの境目は，3桁と4桁(カンマが入るかどうか)，6桁と7桁(カンマが1つか2つか)である．
- `total`の書き直しは振る舞いを変えないので，新しいテストは要らない．既存の3つのテストが，書き直しの前後で通ることを確かめる．

## 演習1-4：設計書を更新する

解答例の設計書は[../design/](../design/)にある．
Iteration 0からの変更点は次のとおり．

- Context：`kakeibo`の説明に，3桁区切りで表示することを足した．
- Component：モジュールの構成は変わらない．`Kakeibo.Money`の説明を「3桁区切りの文字列にする」に直した．
- Code：
  - 型と関数の流れに，引数が空のリストのとき`支出はありません`になる流れを点線で足した．
  - `formatYen`の中の流れ(`show`→`insertCommas`→「円」を付ける)を，別の図にした．
  - 関数の表に「公開」の列を足し，`insertCommas`を公開しない関数として書いた．公開しない関数はテストから直接呼べないので，`formatYen`のテストで確かめることが表から読み取れる．
  - `total`と`insertCommas`の再帰の考え方を，図の下に書いた．

## 演習1-5：テスト駆動で実装する

テストリストの上から順に進めた場合の，各段階のテストとコードを示す．

### `formatYen`：4桁の金額にカンマを入れる

既存のテストを次のように変える．

```haskell
  describe "formatYen" $ do
    it "金額の後ろに「円」を付ける" $
      formatYen 350 `shouldBe` "350円"
    it "0円を表示する" $
      formatYen 0 `shouldBe` "0円"
    it "4桁の金額は，上から1桁目の後ろにカンマを入れる" $
      formatYen 1200 `shouldBe` "1,200円"
```

実行すると，次のように失敗する(Red)．

```
       expected: "1,200円"
        but got: "1200円"
```

4桁の場合だけを考えて，右から3桁の前にカンマを1つ入れる．

```haskell
formatYen :: Int -> String
formatYen amount = insertCommas (show amount) ++ "円"

insertCommas :: String -> String
insertCommas digits = take (len - 3) digits ++ "," ++ drop (len - 3) digits
  where
    len = length digits
```

単体テストを実行すると，`350円`と`0円`のテストが失敗する．
3桁以下の数字の並びにもカンマを入れてしまうからである．
3桁以下ならそのまま返すガードを足す．

```haskell
insertCommas :: String -> String
insertCommas digits
  | len <= 3 = digits
  | otherwise = take (len - 3) digits ++ "," ++ drop (len - 3) digits
  where
    len = length digits
```

単体テストはGreenになる．
パッケージのテストをすべて実行すると，結合テストの`合計: 2350円`が失敗する．
これはテストリストの「`run`：合計を3桁区切りで表示する」の項目である．
期待値を`合計: 2,350円`に変えると通る．

```haskell
    it "引数の金額の合計を，3桁区切りの1行で表示する" $
      run ["1200", "350", "800"] `shouldBe` ["合計: 2,350円"]
```

### `formatYen`：3桁の金額にはカンマを入れない

```haskell
    it "3桁の金額にはカンマを入れない" $
      formatYen 999 `shouldBe` "999円"
```

前の段階でガードを足したので，書いた時点で通る．
カンマが入るかどうかの境目を示す例として残す．

### `formatYen`：6桁の金額

```haskell
    it "6桁の金額は，上から3桁目の後ろにカンマを入れる" $
      formatYen 123456 `shouldBe` "123,456円"
```

カンマが1つの範囲なので，書いた時点で通る．

### `formatYen`：7桁の金額

```haskell
    it "7桁の金額は，3桁ごとにカンマを2つ入れる" $
      formatYen 1234567 `shouldBe` "1,234,567円"
```

カンマを1つしか入れないので失敗する．

```
       expected: "1,234,567円"
        but got: "1234,567円"
```

カンマの前の部分(`take (len - 3) digits`)にも，同じ規則でカンマを入れればよい．
その部分は元より3桁短いので，`insertCommas`自身を呼んで処理できる(再帰)．
3桁以下になったところで再帰が止まる．

```haskell
insertCommas :: String -> String
insertCommas digits
  | len <= 3 = digits
  | otherwise = insertCommas (take (len - 3) digits) ++ "," ++ drop (len - 3) digits
  where
    len = length digits
```

`insertCommas "1234567"`は次のように計算される．

```
insertCommas "1234567"
= insertCommas "1234" ++ "," ++ "567"
= (insertCommas "1" ++ "," ++ "234") ++ "," ++ "567"
= ("1" ++ "," ++ "234") ++ "," ++ "567"
= "1,234,567"
```

### `run`：引数がなければ`支出はありません`と表示する

結合テストの期待値を変える．

```haskell
    it "引数がなければ，支出がないことを表示する" $
      run [] `shouldBe` ["支出はありません"]
```

```
       expected: ["支出はありません"]
        but got: ["合計: 0円"]
```

空のリストのパターンの定義を，一般の定義の前に足す．

```haskell
run :: [String] -> [String]
run [] = ["支出はありません"]
run args = ["合計: " ++ formatYen (total (map read args))]
```

### `total`：再帰に書き直す

書き直す前に単体テストを実行し，すべて通ることを確かめてから書き直す．

```haskell
total :: [Int] -> Int
total [] = 0
total (amount : rest) = amount + total rest
```

書き直したあとも，`total`の3つのテストがすべて通る．
振る舞いを変えずにコードを書き直すこと(リファクタリング)は，テストが通っていることを前後で確かめられるから安心して行える．

## 演習1-6：振り返る

1. 境目の例(3桁と4桁，6桁と7桁)を入れておくと，ガードの条件(`<=`か`<`か)の誤りに気付ける．たとえば`len < 3`と書くと，`999円`のテストが`,999円`で失敗する．
2. 定義の順番を入れ替えると，`run args`がどんなリストにも合うので，`run []`の定義は使われなくなる．コンパイル時に次の警告が出て，結合テストの`支出はありません`が失敗する．

   ```
   warning: [GHC-53633] [-Woverlapping-patterns]
       Pattern match is redundant
       In an equation for ‘run’: run [] = ...
   ```

3. `total`の3つの単体テストである．書き直しの前に通ることを確かめておけば，書き直しのあとに失敗したとき，原因は書き直しにあるとわかる．
4. 単体テストで確かめた．3桁区切りは`formatYen`だけの振る舞いで，境目の例を並べるには`formatYen`を直接呼ぶほうが短く書ける．結合テストは，`run`が`formatYen`を使って合計を表示していることを1つの例で確かめれば足りる．
5. 補助の関数`insertCommas`の名前と型は設計の段階で決め，中身はテストに合わせて，4桁だけに対応する形から再帰の形へ育てた．名前と型が設計書どおりなので，設計書は直さずに済んだ．

## 演習1-7(発展)：マイナスの金額を表示する

今の実装では，`formatYen (-1234)`は`-1,234円`になって通るが，`formatYen (-123)`は`-,123円`になって失敗する．
`show (-123)`は`"-123"`という4文字の並びで，マイナス記号も1桁と数えてしまうからである．
マイナスの金額は，絶対値に3桁区切りを入れてから`-`を付ける．

```haskell
formatYen :: Int -> String
formatYen amount
  | amount < 0 = "-" ++ formatYen (abs amount)
  | otherwise = insertCommas (show amount) ++ "円"
```
