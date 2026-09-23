# Iteration 6：ファイルへの保存とサブコマンド(解説)

演習用の`docs/iteration-6.md`の各手順について，解答の例と考え方を説明する．

## 演習6-1：パッケージを登録してビルドする

`cabal.project`の`packages`に`iterations/iteration-6/exercise`を追記し，`cabal test kakeibo-iteration6`でテストを実行する．

`IO`の型が付いているのは`app/Main.hs`の`main`だけである．
`Kakeibo.App`の`run`を含め，ライブラリの関数はすべて純粋な関数である．
このIterationで，ファイルを読み書きする`IO`の関数がライブラリに入る．

## 演習6-2：`IO`と`do`記法を試す

```console
ghci> import System.IO (readFile')
ghci> writeFile "/tmp/memo.txt" "a\nb\n"
ghci> appendFile "/tmp/memo.txt" "c\n"
ghci> readFile' "/tmp/memo.txt"
"a\nb\nc\n"
ghci> :t readFile'
readFile' :: FilePath -> IO String
ghci> :t lines
lines :: String -> [String]
```

`lines`は`String`を受け取るが，`readFile' "/tmp/memo.txt"`は`IO String`なので，型が合わない．
`IO String`は「実行すると文字列を返すアクション」で，文字列そのものではない．

```haskell
countLines :: FilePath -> IO Int
countLines path = do
  contents <- readFile' path
  pure (length (lines contents))
```

`lookupEnv "HOME"`は`Just "/root"`のような値を，`lookupEnv "KAKEIBO_FILE"`は(設定していなければ)`Nothing`を返す．

## 演習6-3：テストリストを書く

解答例のテストリストは[TESTLIST.md](../TESTLIST.md)である．

- 純粋な関数(`listReport`・`summaryReport`・`encodeEntry`・`decodeEntry`・`decodeEntries`・`parseCommand`)は単体テストで，場合分けを細かく確かめる．
- `IO`の関数(`loadEntries`・`appendEntries`・`run`)は結合テストで確かめる．結合テストでは，「追加したものが一覧に出る」のような，複数のサブコマンドを続けて使う例を中心にした．
- 前の`run`の結合テストで確かめていた表示の規則(明細の形，小計の並び順，合計)は，`listReport`・`summaryReport`の単体テストに移した．
- 結合テストでは，テストごとに一時ディレクトリを作る．テストが同じデータファイルを使うと，前のテストで追加した支出が次のテストの結果に混ざり，テストの結果が実行の順番で変わってしまう．
- 環境変数と終了コードは`main`の処理なので，手で確かめる．

## 演習6-4：設計書を更新する

解答例の設計書は[../design/](../design/)にある．
Iteration 5からの変更点は次のとおり．

- Context：利用者がサブコマンド(`add`・`list`・`summary`)を実行する関係にした．
- Container：データファイルを`ContainerDb`で足し，実行ファイルが`add`で追記し，`list`・`summary`で読み込む関係を描いた．データファイルのパスの決め方(環境変数`KAKEIBO_FILE`)を図の下に書いた．
- Component：
  - `Kakeibo.Command`・`Kakeibo.Report`を純粋な部分に，`Kakeibo.App`・`Kakeibo.Storage`を`IO`を行う部分に足した．
  - `Kakeibo.Storage`は，`IO`の関数(`loadEntries`・`appendEntries`)と純粋な関数(`encodeEntry`・`decodeEntry`・`decodeEntries`)の両方を持つ．データファイルに触れるモジュールなので`IO`の境界に入れ，説明に「行と支出の変換は純粋な関数」と書いた．
  - データファイルを境界の外に描き，`Kakeibo.Storage`だけがデータファイルに触れることを示した．
- Code：
  - データ型の図に`Command`を足した．
  - 型と関数の流れを，サブコマンドの読み取り，`list`・`summary`，データファイルの行と支出の変換の3つの図に分けた．
  - `IO`の順序の図を`add`と`list`・`summary`に分け，データファイルへの読み書きの順序を描いた．`add`では，`parseCommand`がすべての支出を読み終えてから`appendEntries`を呼ぶ．この順序が「誤りがあれば何も追記しない」ことを保証する．

Componentの図の境界は，テストの分け方とも対応する．
純粋な部分の関数は単体テストで，`IO`を行う部分の関数は一時ディレクトリを使う結合テストで確かめる．

## 演習6-5：テスト駆動で実装する

### 1. `Kakeibo.Report`

```haskell
-- test/unit/Kakeibo/ReportSpec.hs
  describe "listReport" $ do
    it "支出がなければ，支出がないことを表示する" $
      listReport [] `shouldBe` ["支出はありません"]
```

```haskell
-- src/Kakeibo/Report.hs
listReport :: [Entry] -> [String]
listReport _ = ["支出はありません"]
```

```haskell
    it "支出を1件ずつ表示し，最後に合計を表示する" $
      listReport [Entry Food (Yen 1200), Entry Transport (Yen 350), Entry Food (Yen 350)]
        `shouldBe` ["食費 1,200円", "交通費 350円", "食費 350円", "合計: 1,900円"]
```

```haskell
listReport :: [Entry] -> [String]
listReport [] = ["支出はありません"]
listReport entries = map display entries ++ ["合計: " ++ display (total (map amount entries))]
```

`summaryReport`も同じ順で進める．
合計の行は`listReport`と共通なので，`totalLine`という関数にまとめた．

```haskell
summaryReport :: [Entry] -> [String]
summaryReport [] = ["支出はありません"]
summaryReport entries = map formatSubtotal (summarize entries) ++ [totalLine entries]
  where
    formatSubtotal (c, subtotal) = display c ++ " " ++ display subtotal

totalLine :: [Entry] -> String
totalLine entries = "合計: " ++ display (total (map amount entries))
```

### 2. `Kakeibo.Storage`の純粋な関数

```haskell
  describe "encodeEntry" $ do
    it "費目の名前と金額をタブで区切る" $
      encodeEntry (Entry Food (Yen 1200)) `shouldBe` "食費\t1200"
```

```haskell
encodeEntry :: Entry -> String
encodeEntry entry = display (category entry) ++ "\t" ++ show n
  where
    Yen n = amount entry
```

`show (amount entry)`と書くと`"Yen 1200"`になるので，`Yen`の中の`Int`を取り出してから`show`する．

`decodeEntry`は，タブがある場合から始め，タブがない場合，金額が誤っている場合の順にテストを足した．

```haskell
decodeEntry :: String -> Maybe Entry
decodeEntry line =
  case break isTab line of
    (name, _ : amountText) ->
      case parseAmount amountText of
        Nothing -> Nothing
        Just yen -> Just (Entry (parseCategory name) yen)
    (_, []) -> Nothing
  where
    isTab c = c == '\t'
```

`decodeEntries`は，空の場合を仮実装(`decodeEntries _ = Right []`)で通したあと，2行のテストで一般的な実装にし，読めない行のテストで行番号を付けた．

```haskell
    it "読み取れない行があれば，その行番号を示すエラーメッセージを返す" $
      decodeEntries "食費\t1200\n壊れた行\n交通費\t350\n" `shouldBe` Left "2行目を読めません"
```

```haskell
decodeEntries :: String -> Either String [Entry]
decodeEntries contents = decodeLines (zip [1 :: Int ..] (lines contents))
  where
    decodeLines [] = Right []
    decodeLines ((lineNumber, line) : rest) =
      case decodeEntry line of
        Nothing -> Left (show lineNumber ++ "行目を読めません")
        Just entry ->
          case decodeLines rest of
            Left err -> Left err
            Right entries -> Right (entry : entries)
```

`[1 :: Int ..]`の`:: Int`は，行番号の型を決めるために書く．
書かないと，`show lineNumber`だけからは数の型が決まらず，GHCが`Integer`を選んだうえで`-Wall`の警告を出す．

### 3. `Kakeibo.Command`

`add`の場合から始めた．

```haskell
  describe "parseCommand" $ do
    it "addの後ろの支出を読み取る" $
      parseCommand ["add", "食費:1200"] `shouldBe` Right (Add [Entry Food (Yen 1200)])
```

```haskell
parseCommand :: [String] -> Either String Command
parseCommand ("add" : args) =
  case parseEntries args of
    Left err -> Left err
    Right entries -> Right (Add entries)
parseCommand _ = Left usage
```

複数の支出，誤った支出のテストは，`parseEntries`を使っているので書いた時点で通る．
`["add"]`のテストは，`parseEntries []`が`Right []`を返すので`Right (Add [])`になって失敗する．
パターンを`"add" : args@(_ : _)`に変え，`add`の後ろに引数があるときだけ合うようにする．

```haskell
parseCommand ("add" : args@(_ : _)) =
  case parseEntries args of
    Left err -> Left err
    Right entries -> Right (Add entries)
parseCommand ["list"] = Right List
parseCommand ["summary"] = Right Summary
parseCommand _ = Left usage
```

`["list"]`・`["summary"]`は，要素がちょうど1つのリストのパターンなので，`["list", "食費"]`には合わず，最後の定義で使い方になる．

### 4. `Kakeibo.Storage`の`IO`の関数と`Kakeibo.App`

`build-depends`に追記する．

```cabal
library
    build-depends:
        base >=4.18 && <5,
        containers,
        directory

test-suite integration
    build-depends:
        base >=4.18 && <5,
        hspec,
        temporary,
        kakeibo-iteration6
```

結合テストでは，一時ディレクトリの中のデータファイルのパスを受け取る補助の関数を作った．

```haskell
-- test/integration/Kakeibo/AppSpec.hs
import System.IO.Temp (withSystemTempDirectory)

withDataFile :: (FilePath -> IO ()) -> IO ()
withDataFile test = withSystemTempDirectory "kakeibo" (\dir -> test (dir ++ "/kakeibo.tsv"))
```

最初のテストは，データファイルがない場合の`list`にした．

```haskell
    it "データファイルがなければ，支出がないことを表示する" $
      withDataFile $ \path -> do
        result <- run path ["list"]
        result `shouldBe` Right ["支出はありません"]
```

`run`の型を変え，`list`だけを実装する．

```haskell
run :: FilePath -> [String] -> IO (Either String [String])
run path args =
  case parseCommand args of
    Right List -> do
      loaded <- loadEntries path
      case loaded of
        Left err -> pure (Left err)
        Right entries -> pure (Right (listReport entries))
    _ -> error "TODO"
```

```haskell
loadEntries :: FilePath -> IO (Either String [Entry])
loadEntries path = do
  exists <- doesFileExist path
  if exists
    then error "TODO"
    else pure (Right [])
```

`app/Main.hs`は`run`の型が変わったのでコンパイルできなくなる．
ここで`main`も書き換える(5.)．

次に，`add`してから`list`するテストを書き，`appendEntries`と，ファイルがある場合の`loadEntries`を実装する．

```haskell
    it "addで追加した支出を，listで表示する" $
      withDataFile $ \path -> do
        _ <- run path ["add", "食費:1200", "交通費:350"]
        _ <- run path ["add", "食費:350"]
        result <- run path ["list"]
        result `shouldBe` Right ["食費 1,200円", "交通費 350円", "食費 350円", "合計: 1,900円"]
```

```haskell
appendEntries :: FilePath -> [Entry] -> IO ()
appendEntries path entries = appendFile path (unlines (map encodeEntry entries))

loadEntries :: FilePath -> IO (Either String [Entry])
loadEntries path = do
  exists <- doesFileExist path
  if exists
    then do
      contents <- readFile' path
      case decodeEntries contents of
        Left err -> pure (Left (path ++ ": " ++ err))
        Right entries -> pure (Right entries)
    else pure (Right [])
```

`run`の`add`の選択肢は，追記してから，追加した支出を知らせる行を返す．

```haskell
    Right (Add entries) -> do
      appendEntries path entries
      pure (Right (map addedLine entries))
```

`add`の結果を知らせるテスト，`summary`のテスト，使い方のテストを1つずつ足し，最後に`run`を次の形にした．
`list`と`summary`は「読み込んで，表示する行を作る」部分が同じなので，`where`の`withEntries`にまとめた．

```haskell
run :: FilePath -> [String] -> IO (Either String [String])
run path args =
  case parseCommand args of
    Left err -> pure (Left err)
    Right (Add entries) -> do
      appendEntries path entries
      pure (Right (map addedLine entries))
    Right List -> withEntries listReport
    Right Summary -> withEntries summaryReport
  where
    withEntries report = do
      loaded <- loadEntries path
      case loaded of
        Left err -> pure (Left err)
        Right entries -> pure (Right (report entries))
```

「`add`に誤りがあれば何も追記しない」テストと，「読めない行があればエラー」のテストは，書いた時点で通る．
前者は，`parseCommand`がすべての支出を読み終えてから`Add`を返し，`appendEntries`はその後にしか呼ばれないからである．
後者は，`decodeEntries`のエラーに`loadEntries`がパスを付けているからである．

最後に，引数で支出を渡していた前の結合テストを消した．

### 5. `main`

```haskell
main :: IO ()
main = do
  args <- getArgs
  maybePath <- lookupEnv "KAKEIBO_FILE"
  let path = fromMaybe defaultDataFile maybePath
  result <- run path args
  case result of
    Left err -> do
      hPutStrLn stderr err
      exitFailure
    Right outputLines -> putStr (unlines outputLines)
```

`defaultDataFile`(`"kakeibo.tsv"`)は`Kakeibo.App`に置いた．
`maybePath`は`IO`の結果なので`<-`で，`path`はただの式なので`let`で名前を付けている．

## 演習6-6：振り返る

1. `parseCommand`の使い方になる場合を1つの項目にまとめた人もいるだろう．パターンの書き方によって誤りやすいのは，`add`の後ろが空の場合と，`list`の後ろに余分な引数がある場合である．
2. `decodeEntries`は文字列を受け取るので，テストでは読めない行を含む文字列を書くだけで済んだ．`loadEntries`の中で行ごとに処理していたら，テストのたびに一時ファイルを作って中身を書き込む必要があった．
3. 前のテストが追加した支出が残り，`list`の結果がテストの実行順で変わる．hspecはテストを定義順に実行するが，`--match`で一部のテストだけを実行したときや，順番を入れ替えたときに結果が変わってしまう．
4. `parseCommand args`がすべての支出を読み取れたときだけ`Right (Add entries)`を返し，`appendEntries`はその選択肢の中でしか呼ばれない．誤りの判定がファイルへの書き込みより先に，純粋な関数で済んでいる．
5. `list`と`summary`で共通の部分を`withEntries`にまとめたのは，実装のときの判断である．`where`の中の名前なので設計書には描いていない．Componentの図の矢印は，実装の`import`と照らし合わせて確かめた．

## 演習6-7(発展)：最後の支出を取り消す

`undo`は，データファイルを読み，最後の1件を除いた内容で書き直す．

```haskell
data Command = Add [Entry] | List | Summary | Undo

parseCommand ["undo"] = Right Undo

-- Kakeibo.Storage
saveEntries :: FilePath -> [Entry] -> IO ()
saveEntries path entries = writeFile path (unlines (map encodeEntry entries))

-- Kakeibo.App.runの選択肢
    Right Undo -> do
      loaded <- loadEntries path
      case loaded of
        Left err -> pure (Left err)
        Right [] -> pure (Left "取り消す支出がありません")
        Right entries -> do
          saveEntries path (init entries)
          pure (Right ["取り消しました: " ++ display (last entries)])
```

`init`は最後の要素を除いたリストを，`last`は最後の要素を返す．
どちらも空のリストには使えない部分関数なので，空の場合を`Right []`のパターンで先に分けている．
