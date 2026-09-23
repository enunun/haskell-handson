# Iteration 4：`Maybe`と`Either`

Iteration 4で使う文法と概念をまとめる．

## 部分関数と全域関数

`read`は，数として読めない文字列を渡されるとエラーでプログラムを止める．

```console
ghci> read "abc" :: Int
*** Exception: Prelude.read: no parse
```

型シグネチャ`String -> Int`は「どんな`String`にも`Int`を返す」と読めるが，実際には返せない引数がある．
このように，一部の引数に対して値を返さない関数を部分関数という．
リストの先頭を返す`head`も，空のリストに対しては値を返せない部分関数である．

すべての引数に対して値を返す関数を全域関数という．
失敗しうる処理は，「失敗したこと」も値として返す全域関数にすると，呼び出す側は型を見て失敗に備えられる．
Haskellでは，そのために`Maybe`型や`Either`型を使う．

## `Maybe`

`Maybe`は，値が「ある」か「ない」かを表す型である．
標準のライブラリで，次のように定義されている．

```haskell
data Maybe a = Nothing | Just a
```

`a`は型変数で，`Maybe Int`や`Maybe String`のように，中身の型を後から決められる．
`Maybe Int`の値は，`Nothing`(値がない)か，`Just 1200`のような`Just`と`Int`の組のどちらかである．

`Text.Read`モジュールの`readMaybe`は，`read`の全域関数版である．

```console
ghci> import Text.Read (readMaybe)
ghci> readMaybe "1200" :: Maybe Int
Just 1200
ghci> readMaybe "abc" :: Maybe Int
Nothing
ghci> readMaybe "1.5" :: Maybe Int
Nothing
```

`Maybe`の値は，`case`で`Nothing`と`Just`に分けて扱う．

```haskell
describeAmount :: String -> String
describeAmount text =
  case readMaybe text :: Maybe Int of
    Nothing -> "数ではありません"
    Just n -> show n ++ "円"
```

`Just n`というパターンは，`Just`の中身の値に`n`という名前を付ける．
`Maybe Int`を`Int`として直接使うことはできない．
中身を取り出すには，`Nothing`の場合も必ず書くことになる．

## `case`の選択肢にガードを付ける

`case`の各選択肢にも，ガードを付けられる．

```haskell
parsePositive :: String -> Maybe Int
parsePositive text =
  case readMaybe text of
    Nothing -> Nothing
    Just n
      | n > 0 -> Just n
      | otherwise -> Nothing
```

`Just n`に合ったあと，ガードを上から調べ，最初に`True`になったものの値を使う．
`readMaybe text`が何の型を読むかは，戻り値の型`Maybe Int`と`Just n`から決まる．

## `Either`

`Either`は，2種類の値のどちらかを表す型である．

```haskell
data Either a b = Left a | Right b
```

失敗しうる処理の結果には，`Left`に失敗の情報を，`Right`に成功したときの値を入れる慣習がある．
「right」には「正しい」という意味もある．
`Maybe`は失敗したことしか表せないが，`Either`は失敗の理由も値として持てる．

```haskell
parseAge :: String -> Either String Int
parseAge text =
  case readMaybe text of
    Nothing -> Left ("not a number: " ++ text)
    Just n
      | n >= 0 -> Right n
      | otherwise -> Left ("negative: " ++ text)
```

```console
ghci> parseAge "20"
Right 20
ghci> parseAge "abc"
Left "not a number: abc"
```

hspecでは，`Either`の値もそのまま`shouldBe`で比べられる．
データコンストラクタに値を渡す式は，括弧で囲む．

```haskell
parseAge "20" `shouldBe` Right 20
parseEntry "食費:1200" `shouldBe` Right (Entry Food 1200)
```

## エラーを受け渡す

`Either`を返す関数を続けて呼ぶときは，前の結果が`Left`なら，そこで処理を打ち切って`Left`をそのまま返す．

```haskell
parseAges :: [String] -> Either String [Int]
parseAges [] = Right []
parseAges (text : rest) =
  case parseAge text of
    Left err -> Left err
    Right age ->
      case parseAges rest of
        Left err -> Left err
        Right ages -> Right (age : ages)
```

- 先頭の要素を読み，失敗したらそのエラーを返す．
- 成功したら残りの要素を再帰で読み，失敗したらそのエラーを返す．
- どちらも成功したら，結果をつなげて`Right`で返す．

最初に失敗した要素のエラーが返り，それより後ろの要素は読まれない．
`case`の入れ子で「失敗したら打ち切る」を毎回書くのは手間がかかる．
これを短く書く方法は，Iteration 7で学ぶ．

## 標準エラー出力と終了コード

コマンドラインのプログラムは，エラーを標準エラー出力に表示し，0以外の終了コードで終わるのが慣習である．

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

- `hPutStrLn stderr err`は，`err`を標準エラー出力に表示し，改行する．
- `exitFailure`は，終了コード1でプログラムを終える．
- `do`の中の`case`の選択肢で，複数のアクションを順に実行したいときは，選択肢の中に`do`を書く．

シェルでは，直前のコマンドの終了コードを`echo $?`で確かめられる．

```console
$ cabal run -v0 kakeibo-solution-iteration4 -- 食費:abc
金額は正の整数で書いてください: 食費:abc
$ echo $?
1
```

`-v0`は，cabal自身のメッセージを表示しないオプションである．
