# Iteration 4：入力の誤りを知らせる(解説)

演習用の`docs/iteration-4.md`の各手順について，解答の例と考え方を説明する．

## 演習4-1：パッケージを登録してビルドする

Iteration 3のコードでは，誤った引数に対して次のようになる．

```console
$ cabal run -v0 kakeibo-iteration4 -- 食費:1200 交通費:abc
kakeibo: Prelude.read: no parse
$ echo $?
1
$ cabal run -v0 kakeibo-iteration4 -- 食費:-500
食費 -,500円
費目別:
  食費 -,500円
合計: -,500円
```

`交通費:abc`では，`read`が失敗してプログラムが止まる．
終了コードは1だが，メッセージからは，どの引数が誤っているのかがわからない．
`食費:0`や`食費:-500`は，誤りとして扱われずに表示されてしまう．

## 演習4-2：`Maybe`と`Either`を試す

```console
ghci> import Text.Read (readMaybe)
ghci> readMaybe "1200" :: Maybe Int
Just 1200
ghci> readMaybe "abc" :: Maybe Int
Nothing
ghci> readMaybe "-5" :: Maybe Int
Just (-5)
ghci> read "abc" :: Int
*** Exception: Prelude.read: no parse
ghci> :t read
read :: Read a => String -> a
ghci> :t readMaybe
readMaybe :: Read a => String -> Maybe a
```

`Read a =>`は「`a`は文字列から読み取れる型である」という条件である(型クラスはIteration 5で学ぶ)．
`read`の型は「どんな文字列からも`a`の値を返す」と言っているが，`"abc"`からは`Int`の値を作れないので，エラーで止まるしかない．
`readMaybe`は，読めなかったことを`Nothing`という値で返せるので，どんな文字列に対しても値を返す．

```haskell
parsePositive :: String -> Maybe Int
parsePositive text =
  case readMaybe text of
    Nothing -> Nothing
    Just n
      | n > 0 -> Just n
      | otherwise -> Nothing

parsePositiveE :: String -> Either String Int
parsePositiveE text =
  case parsePositive text of
    Nothing -> Left ("正の整数ではありません: " ++ text)
    Just n -> Right n
```

## 演習4-3：テストリストを書く

解答例のテストリストは[TESTLIST.md](../TESTLIST.md)である．

- 「正の整数でない」文字列は，数として読めない(`abc`)，空文字列，小数(`1.5`)，0，負の数(`-5`)の5種類に分けた．読み取りに失敗するもの(前の3つ)と，読めるが範囲外のもの(後の2つ)で，実装の中で通る道が違う．
- `parseEntry`と`run`の既存のテストは，期待値を`Right`で包む．表示の内容は変わらない．
- 標準エラー出力と終了コードは`main`の中の処理なので，自動のテストでは確かめず，手で確かめる．テストリストにも「手で確かめること」として書いた．

## 演習4-4：設計書を更新する

解答例の設計書は[../design/](../design/)にある．
Iteration 3からの変更点は次のとおり．

- Context・Container：誤りの理由を標準エラー出力に表示することを足した．
- Component：`Main`の説明にエラーメッセージの表示を足し，`Kakeibo.App`が使う関数を`parseEntries`にした．
- Code：
  - 型と関数の流れで，`parseEntries`の結果を`Either String [Entry]`のノードにし，`Left`はそのまま返し，`Right`は`report`で行にする，と分けた．失敗しない`report`は別の図にした．
  - `parseEntry`の中で，`parseAmount`の`Maybe Int`が`Nothing`なら`Left`，`Just`なら`Right`になる流れを描いた．
  - `IO`の順序の図に，`Left`なら標準エラー出力に表示して`exitFailure`し，`Right`なら行を表示する場合分けを`alt`で描いた．

型と関数の流れの図で，`Either`のノードから`Left`と`Right`に矢印が分かれるところが，エラーを受け渡す場所である．
テストリストのエラーの項目は，この分かれ目ごとに置いている．

## 演習4-5：テスト駆動で実装する

### `parseAmount`：正の整数を読み取る

```haskell
  describe "parseAmount" $ do
    it "正の整数を読み取る" $
      parseAmount "1200" `shouldBe` Just 1200
```

`parseAmount`を型シグネチャと`error "TODO"`で用意し，エクスポートしてRedを確かめる．
仮実装で通す．

```haskell
parseAmount :: String -> Maybe Int
parseAmount _ = Just 1200
```

### `parseAmount`：数として読めなければ`Nothing`

```haskell
    it "数として読めなければNothingを返す" $
      parseAmount "abc" `shouldBe` Nothing
```

仮実装では`Just 1200`が返って失敗する．
`readMaybe`をそのまま使う．

```haskell
import Text.Read (readMaybe)

parseAmount :: String -> Maybe Int
parseAmount text = readMaybe text
```

### `parseAmount`：空文字列・小数

```haskell
    it "空文字列ならNothingを返す" $
      parseAmount "" `shouldBe` Nothing
    it "小数ならNothingを返す" $
      parseAmount "1.5" `shouldBe` Nothing
```

どちらも`readMaybe`が`Nothing`を返すので，書いた時点で通る．
要求に挙げた誤りの種類を表す例として残す．

### `parseAmount`：0・負の数

```haskell
    it "0ならNothingを返す" $
      parseAmount "0" `shouldBe` Nothing
```

```
       expected: Nothing
        but got: Just 0
```

読めた数が正かどうかを，`case`の選択肢のガードで調べる．

```haskell
parseAmount :: String -> Maybe Int
parseAmount text =
  case readMaybe text of
    Nothing -> Nothing
    Just n
      | n > 0 -> Just n
      | otherwise -> Nothing
```

負の数のテスト(`parseAmount "-5"`)は，書いた時点で通る．

### `parseEntry`：既存のテストの期待値を`Right`で包む

既存のテストを書き換える．

```haskell
  describe "parseEntry" $ do
    it "「費目:金額」を読み取る" $
      parseEntry "食費:1200" `shouldBe` Right (Entry {category = Food, amount = 1200})
    it "「:」がなければ，全体を金額とし，費目をその他とする" $
      parseEntry "800" `shouldBe` Right (Entry {category = Other, amount = 800})
```

`parseEntry`の型を`String -> Either String Entry`に変え，今の実装を`Right`で包む．

```haskell
parseEntry :: String -> Either String Entry
parseEntry arg =
  case break isColon arg of
    (name, _ : amountText) -> Right (Entry (parseCategory name) (read amountText))
    (amountText, []) -> Right (Entry Other (read amountText))
  where
    isColon c = c == ':'
```

`Kakeibo.App`の`run`は`parseEntry`の結果を`Entry`として使っているので，コンパイルできなくなる．
単体テストを進めるために，`run`をいったん次のようにする．

```haskell
run :: [String] -> [String]
run _ = error "TODO"
```

単体テストはGreenになる．結合テストは，`run`を直すまで失敗する．

### `parseEntry`：金額が正の整数でなければ，エラーメッセージを返す

```haskell
    it "金額が正の整数でなければ，引数を含むエラーメッセージを返す" $
      parseEntry "食費:abc" `shouldBe` Left "金額は正の整数で書いてください: 食費:abc"
```

`read`で`abc`を読もうとして，テストが`Prelude.read: no parse`で失敗する．
費目と金額の文字列に分けるところと，金額を読むところを分け，金額は`parseAmount`で読む．

```haskell
parseEntry :: String -> Either String Entry
parseEntry arg =
  case parseAmount amountText of
    Nothing -> Left ("金額は正の整数で書いてください: " ++ arg)
    Just n -> Right (Entry c n)
  where
    (c, amountText) =
      case break isColon arg of
        (name, _ : rest) -> (parseCategory name, rest)
        (whole, []) -> (Other, whole)
    isColon ch = ch == ':'
```

`where`の中で，`case`式の結果のタプルを`(c, amountText)`で受け取り，2つの名前を付けている．
`isColon`の引数名は，費目の`c`と区別するために`ch`にした．

### `parseEntry`：`:`がなく，全体が正の整数でなければ，エラーメッセージを返す

```haskell
    it "「:」がなく，全体が正の整数でなければ，エラーメッセージを返す" $
      parseEntry "abc" `shouldBe` Left "金額は正の整数で書いてください: abc"
```

`:`がない場合も`parseAmount`で読むようにしたので，書いた時点で通る．

### `parseEntries`：空のリストなら空のリストを返す

```haskell
  describe "parseEntries" $ do
    it "空のリストなら空のリストを返す" $
      parseEntries [] `shouldBe` Right []
```

```haskell
parseEntries :: [String] -> Either String [Entry]
parseEntries _ = Right []
```

### `parseEntries`：すべての引数を読み取り，同じ順に並べる

```haskell
    it "すべての引数を読み取り，同じ順に並べる" $
      parseEntries ["食費:1200", "交通費:350"]
        `shouldBe` Right [Entry Food 1200, Entry Transport 350]
```

先頭を`parseEntry`で，残りを再帰で読む．
この段階では，失敗する場合を考えずに書く．

```haskell
parseEntries :: [String] -> Either String [Entry]
parseEntries [] = Right []
parseEntries (arg : rest) =
  case parseEntry arg of
    Left err -> Left err
    Right entry ->
      case parseEntries rest of
        Left err -> Left err
        Right entries -> Right (entry : entries)
```

`case`の選択肢は，`Left`と`Right`の両方を書かないと`-Wall`で警告が出る．
`Left`の場合はエラーをそのまま返すのが自然なので，この時点で両方を書いた．

### `parseEntries`：読み取れない引数があれば，そのエラーメッセージを返す

```haskell
    it "読み取れない引数があれば，そのエラーメッセージを返す" $
      parseEntries ["食費:1200", "交通費:abc"]
        `shouldBe` Left "金額は正の整数で書いてください: 交通費:abc"
```

前の段階で`Left`の場合も書いたので，書いた時点で通る．

### `parseEntries`：読み取れない引数が複数あれば，最初のもののエラーメッセージを返す

```haskell
    it "読み取れない引数が複数あれば，最初のもののエラーメッセージを返す" $
      parseEntries ["食費:0", "交通費:abc"]
        `shouldBe` Left "金額は正の整数で書いてください: 食費:0"
```

先頭が`Left`なら残りを読まずに返すので，これも書いた時点で通る．
どちらのエラーが返るかは要求で決めたことなので，例として残す．

### `run`：既存のテストの期待値を`Right`で包む

```haskell
    it "支出を1件ずつ表示し，費目別の小計と合計を表示する" $
      run ["食費:1200", "交通費:350"]
        `shouldBe` Right
          [ "食費 1,200円",
            …
          ]
```

`run`の型を変え，`parseEntries`の結果で場合分けする．
明細・小計・合計の行を作る部分は`report`という関数に分けた．

```haskell
import Kakeibo.Entry (Category, Entry (..), categoryName, formatEntry, parseEntries)

run :: [String] -> Either String [String]
run [] = Right ["支出はありません"]
run args =
  case parseEntries args of
    Left err -> Left err
    Right entries -> Right (report entries)

report :: [Entry] -> [String]
report entries =
  map formatEntry entries
    ++ ["費目別:"]
    ++ map formatSubtotal (summarize entries)
    ++ ["合計: " ++ formatYen (total (map amount entries))]
```

`app/Main.hs`は`run`の結果を`[String]`として使っているので，コンパイルできなくなる．
`case`で`Left`と`Right`に分ける．

```haskell
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)

main :: IO ()
main = do
  args <- getArgs
  case run args of
    Left err -> do
      hPutStrLn stderr err
      exitFailure
    Right outputLines -> putStr (unlines outputLines)
```

### `run`：金額が正の整数でない引数があれば，エラーメッセージを返す

```haskell
    it "金額が正の整数でない引数があれば，エラーメッセージを返す" $
      run ["食費:1200", "交通費:abc"]
        `shouldBe` Left "金額は正の整数で書いてください: 交通費:abc"
```

`parseEntries`の`Left`をそのまま返しているので，書いた時点で通る．
結合テストとしては，「誤った引数があれば，明細を表示せずにエラーになる」という使い方の例を表す．

### 手で確かめる

```console
$ cabal run -v0 kakeibo-solution-iteration4 -- 食費:1200 交通費:abc
金額は正の整数で書いてください: 交通費:abc
$ echo $?
1
$ cabal run -v0 kakeibo-solution-iteration4 -- 食費:1200 交通費:abc 2> /dev/null
$
```

`2> /dev/null`で標準エラー出力を捨てると何も表示されないので，メッセージが標準エラー出力に出ていることがわかる．

## 演習4-6：振り返る

1. `parseAmount`の誤りの種類を1つのテストにまとめた人もいるだろう．種類ごとに分けておくと，たとえばガードの`n > 0`を`n >= 0`と書き誤ったときに，0のテストだけが失敗して原因がすぐわかる．
2. `Maybe Entry`では「読めなかった」ことしか返せないので，`run`はどの引数が誤っていたかを表示できない．`Either String Entry`にしたことで，誤りの内容(誤った引数)をエラーメッセージとして呼び出し元まで運べるようになった．
3. `main`はテストから呼ばないので，`main`の中の誤りは自動のテストでは見つからない．`main`には，引数を読む・結果を表示する・終了コードを決める，という最小限の処理だけを置き，判断はすべて`run`(テストできる関数)に任せる．
4. `parseEntries`の2つの`case`は，どちらも「`Left err`なら`Left err`を返し，`Right x`なら`x`を使って続ける」という同じ形である．Iteration 7で，この形を短く書く方法を学ぶ．
5. `report`は，`run`の型を変える段階で，明細・小計・合計の行を作る部分を切り出した関数である．設計の段階で描いていなかったら，実装したあとで関数の表と図に足す．

## 演習4-7(発展)：誤りの理由を分ける

`parseAmount`が理由を返せるように，`Either String Int`にする．

```haskell
parseAmount :: String -> Either String Int
parseAmount text =
  case readMaybe text of
    Nothing -> Left "金額は整数で書いてください"
    Just n
      | n > 0 -> Right n
      | otherwise -> Left "金額は1円以上にしてください"

parseEntry :: String -> Either String Entry
parseEntry arg =
  case parseAmount amountText of
    Left reason -> Left (reason ++ ": " ++ arg)
    Right n -> Right (Entry c n)
  where
    …
```

`parseAmount`の型が変わるので，`parseAmount`の既存のテストの期待値はすべて`Left …`か`Right …`に書き換える．
