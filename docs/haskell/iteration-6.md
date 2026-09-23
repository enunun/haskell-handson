# Iteration 6：`IO`と`do`記法

Iteration 6で使う文法と概念をまとめる．

## `IO`型

`IO a`は，「実行すると入出力などの副作用を起こし，最後に`a`型の値を返す処理」を表す型である．
この処理をアクションと呼ぶ．

| アクション | 型 | 意味 |
|---|---|---|
| `getArgs` | `IO [String]` | コマンドライン引数を読む． |
| `putStrLn "abc"` | `IO ()` | 文字列を表示する．返す値はない(`()`)． |
| `readFile' path` | `IO String` | ファイルの中身を読む． |
| `appendFile path s` | `IO ()` | ファイルの末尾に文字列を書き足す．ファイルがなければ作る． |
| `writeFile path s` | `IO ()` | ファイルの中身を文字列で置き換える．ファイルがなければ作る． |
| `doesFileExist path` | `IO Bool` | ファイルがあるかを調べる． |
| `lookupEnv "NAME"` | `IO (Maybe String)` | 環境変数を読む．なければ`Nothing`． |

`()`は「値を1つしか持たない型」で，その値も`()`と書く．
返す値に意味がないアクションは`IO ()`型にする．

`IO String`の値は，文字列そのものではない．
`readFile' path ++ "abc"`のように，`IO String`をそのまま`String`として使うとコンパイルエラーになる．
アクションが返す値を使うには，`do`記法の中で`<-`を使って取り出す．

`FilePath`は`String`の別名(`type FilePath = String`)で，ファイルのパスを表すことを示すために使う．

## `do`記法

`do`の中には，アクションを1行に1つずつ書く．
上から順に実行され，最後の行のアクションが返す値が，`do`全体が返す値になる．

```haskell
greet :: IO ()
greet = do
  putStrLn "名前は?"
  name <- getLine
  let message = "こんにちは，" ++ name
  putStrLn message
```

| 書き方 | 意味 |
|---|---|
| `アクション` | アクションを実行する．返す値は使わない． |
| `名前 <- アクション` | アクションを実行し，返した値に名前を付ける．`IO a`のアクションなら，名前の型は`a`になる． |
| `let 名前 = 式` | 式に名前を付ける．アクションは実行しない．`let … in`と違い，`in`は書かない． |

`<-`と`let`の違いは，右辺がアクションかどうかである．
`name <- getLine`は，`getLine`を実行して読んだ文字列に名前を付ける．
`let message = …`は，ただの式に名前を付ける．

返す値を使わないアクションは，`_ <- アクション`と書いて，値を捨てることをはっきり示せる．

## `pure`

`pure x`は，副作用を何も起こさずに`x`を返すアクションである．
`do`の最後で，計算した値をアクションの結果として返すときに使う．

```haskell
loadCount :: FilePath -> IO Int
loadCount path = do
  contents <- readFile' path
  pure (length (lines contents))
```

`pure`は，ほかの言語の`return`文と違い，関数の実行を途中で終わらせない．
`IO Int`型のアクションを作る関数である．

## `if`式

`if 条件 then 式1 else 式2`は，条件が`True`なら式1，`False`なら式2の値になる式である．
`else`は省けない．

```haskell
loadEntries path = do
  exists <- doesFileExist path
  if exists
    then do
      contents <- readFile' path
      …
    else pure (Right [])
```

`then`と`else`の後ろにアクションを書けば，条件によって実行するアクションを選べる．
複数のアクションを並べるときは，そこにも`do`を書く．

## `do`の中の`case`

`do`の中でも`case`で場合分けできる．
各選択肢の右辺は，`do`全体と同じ型のアクションにする．

```haskell
run :: FilePath -> [String] -> IO (Either String [String])
run path args =
  case parseCommand args of
    Left err -> pure (Left err)
    Right List -> do
      loaded <- loadEntries path
      case loaded of
        Left err -> pure (Left err)
        Right entries -> pure (Right (listReport entries))
    …
```

`parseCommand args`は`IO`ではないただの値なので，`<-`を使わずに`case`で分けられる．
`loadEntries path`はアクションなので，`<-`で結果を取り出してから`case`で分ける．

## 純粋な関数と副作用のある処理を分ける

`IO`の型が付いていない関数は，同じ引数に対していつも同じ値を返し，ファイルや画面に触れない．
そのような関数を純粋な関数という．
Haskellでは，型を見るだけで，関数が副作用を起こすかどうかがわかる．

純粋な関数は，テストで引数を与えて戻り値を比べるだけで確かめられる．
副作用のある処理のテストには，ファイルの準備や後片付けが要る．
そこで，判断や計算はできるだけ純粋な関数にし，`IO`の関数は「読む」「純粋な関数に渡す」「書く」をつなぐだけの薄い層にする．

| モジュール | 関数 | 純粋か |
|---|---|---|
| `Kakeibo.Storage` | `decodeEntries :: String -> Either String [Entry]` | 純粋．ファイルの中身の文字列を読み取る． |
| `Kakeibo.Storage` | `loadEntries :: FilePath -> IO (Either String [Entry])` | `IO`．ファイルを読み，`decodeEntries`に渡す． |
| `Kakeibo.Report` | `listReport :: [Entry] -> [String]` | 純粋．表示する行を作る． |
| `Kakeibo.App` | `run :: FilePath -> [String] -> IO (Either String [String])` | `IO`．各部品をつなぐ． |

## hspecで`IO`をテストする

`it`の本体は，`IO`のアクションでもよい．
`do`の中で`<-`で結果を取り出し，`shouldBe`で比べる．

```haskell
it "データファイルがなければ，支出がないことを表示する" $
  withDataFile $ \path -> do
    result <- run path ["list"]
    result `shouldBe` Right ["支出はありません"]
```

`shouldBe`の型は`a -> a -> IO ()`(`Expectation`)で，`do`の中の1行として書ける．

## 一時ディレクトリ

`temporary`パッケージの`System.IO.Temp`モジュールにある`withSystemTempDirectory`は，一時ディレクトリを作り，そのパスを関数に渡して実行し，終わったらディレクトリを消す．

```haskell
withSystemTempDirectory :: String -> (FilePath -> IO a) -> IO a
```

2つ目の引数は「パスを受け取ってアクションを返す関数」である．
ラムダ式で書くことが多い．

```haskell
withSystemTempDirectory "kakeibo" (\dir -> run (dir ++ "/kakeibo.tsv") ["list"])
```

テストごとに新しい空のディレクトリを使うので，テストどうしがデータファイルを共有せず，前のテストの結果に影響されない．

## ライブラリの関数

| 関数 | モジュール(パッケージ) | 意味 |
|---|---|---|
| `readFile'` | `System.IO`(`base`) | ファイルの中身を最後まで読んでから返す． |
| `doesFileExist` | `System.Directory`(`directory`) | ファイルがあるかを調べる． |
| `lookupEnv` | `System.Environment`(`base`) | 環境変数を`Maybe`で返す． |
| `fromMaybe` | `Data.Maybe`(`base`) | `fromMaybe d m`は，`m`が`Just x`なら`x`，`Nothing`なら`d`． |
| `lines` | Prelude | 文字列を改行で区切ったリストにする．`unlines`の逆． |
| `zip` | Prelude | 2つのリストの要素を先頭から組にする． |

`System.IO`の`readFile`(`'`なし)は，中身を実際に使うまでファイルを読まない．
読み終える前に同じファイルに書き込むと失敗することがあるので，このハンズオンでは`readFile'`を使う．

```console
ghci> lines "a\tb\nc\n"
["a\tb","c"]
ghci> zip [1 ..] ["a", "b", "c"]
[(1,"a"),(2,"b"),(3,"c")]
```

文字列の中の`\t`はタブ，`\n`は改行を表す．
`[1 ..]`は1から始まって終わりのないリストである．
Haskellは値を必要になるまで計算しないので，`zip`で短いほうのリストに合わせれば，終わりのないリストも使える．

## パターンの書き方

### as-パターン

`名前@パターン`と書くと，パターンに合った値全体にも名前を付けられる．

```haskell
parseCommand ("add" : args@(_ : _)) = …
```

`args@(_ : _)`は「空でないリストに合い，その全体に`args`という名前を付ける」パターンである．
`"add"`の後ろに引数が1つ以上あるときだけ，この定義が使われる．

### `where`でのパターン

`where`や`let`で名前を付けるときも，左辺にパターンを書ける．

```haskell
encodeEntry entry = display (category entry) ++ "\t" ++ show n
  where
    Yen n = amount entry
```

`amount entry`の`Yen`の中の`Int`に，`n`という名前を付けている．
`Yen`はデータコンストラクタが1つだけなので，このパターンは必ず合う．

### データコンストラクタへのコメント

直和型の各データコンストラクタの前に`-- |`でコメントを書くと，そのデータコンストラクタの説明になる．

```haskell
data Command
  = -- | 支出をデータファイルに追記する．
    Add [Entry]
  | -- | 明細と合計を表示する．
    List
```
