# Iteration 7：日付と月での絞り込み(解説)

演習用の`docs/iteration-7.md`の各手順について，解答の例と考え方を説明する．

## 演習7-1：パッケージを登録してビルドする

`cabal.project`の`packages`に`iterations/iteration-7/exercise`を追記し，`cabal test kakeibo-iteration7`でテストを実行する．

`case`で`Nothing`・`Left`の場合をそのまま返している箇所は，次の7つである．

| モジュール | 関数 | 形 |
|---|---|---|
| `Kakeibo.Entry` | `parseAmount` | `Nothing -> Nothing` |
| `Kakeibo.Entry` | `parseEntries` | `Left err -> Left err`(2か所) |
| `Kakeibo.Command` | `parseCommand` | `Left err -> Left err` |
| `Kakeibo.Storage` | `decodeEntry` | `Nothing -> Nothing` |
| `Kakeibo.Storage` | `decodeEntries` | `Left err -> Left err` |
| `Kakeibo.Storage` | `loadEntries` | `Right entries -> pure (Right entries)` |
| `Kakeibo.App` | `run` | `Left err -> pure (Left err)` |

## 演習7-2：`Functor`・`Applicative`・`Monad`を試す

```console
ghci> import Text.Read (readMaybe)
ghci> (* 2) <$> (readMaybe "21" :: Maybe Int)
Just 42
ghci> (* 2) <$> (readMaybe "x" :: Maybe Int)
Nothing
```

```haskell
addStrings :: String -> String -> Maybe Int
addStrings a b = (+) <$> readMaybe a <*> readMaybe b

addStrings' :: String -> String -> Maybe Int
addStrings' a b = do
  x <- readMaybe a
  y <- readMaybe b
  pure (x + y)
```

```console
ghci> traverse (\s -> readMaybe s :: Maybe Int) ["1", "2"]
Just [1,2]
ghci> traverse (\s -> readMaybe s :: Maybe Int) ["1", "x"]
Nothing
ghci> maybe (Left "not a number") Right (readMaybe "x" :: Maybe Int)
Left "not a number"
```

## 演習7-3：テストリストを書く

解答例のテストリストは[TESTLIST.md](../TESTLIST.md)である．

- 書き直しは振る舞いを変えないので，テストは足さない．既存のテストが通り続けることで確かめる．
- 日付の誤りは，形の誤り(区切り，桁数，数でない)と，値の誤り(月の範囲，月ごとの日数，うるう年)に分けた．うるう年は，通る例(2028年)と通らない例(2026年)の両方を置いた．
- 月での絞り込みは，`inMonth`の単体テストで年と月の比べ方を，結合テストで「指定した月の支出だけが表示される」ことを確かめる．結合テストの支出には，前の月の末日(8月31日)と次の月の初日(10月1日)を入れ，境目の日付が含まれないことを確かめた．
- `summarize`・`listReport`など，日付が結果に関係しないテストでは，テストのモジュールに補助の関数を作り，決まった日付の支出を作るようにした．

## 演習7-4：設計書を更新する

解答例の設計書は[../design/](../design/)にある．
Iteration 6からの変更点は次のとおり．

- Context・Container：説明に日付と月での絞り込みを足し，データファイルの行に日付が入ることを書いた．
- Component：`Kakeibo.Date`を足した．`Kakeibo.Entry`(`Entry`が`Date`を持つ)，`Kakeibo.Command`(日付と年月を読む)，`Kakeibo.Storage`(データファイルの日付を読む)，`Kakeibo.App`(`inMonth`で絞り込む)から矢印を引いた．
- Code：
  - データ型の図に`Date`と`YearMonth`を足し，`Entry`の`date`のフィールドと，`Command`の`List`・`Summary`が持つ`Maybe YearMonth`を描いた．
  - `add`の読み取りは，日付を読んでからその日付で支出を読むので，`d <- …`の`do`記法の流れとして描いた．
  - `decodeEntry`は，日付・費目・金額を互いに関係なく読むので，`Entry <$> … <*> … <*> …`の1本の矢印として描いた．
  - `list`・`summary`は，読み込んだ結果に`report . selectMonth target`を`<$>`で適用する流れにした．

年月での絞り込み(`selectMonth`)は，サブコマンドを実行する`Kakeibo.App`に置いた．
`Kakeibo.Date`には，1つの日付がその年月に含まれるか(`inMonth`)だけを置き，支出のリストを扱う処理は持たせていない．
`Kakeibo.Date`は`Entry`を知らずに済むので，Componentの図で`Kakeibo.Date`から出る矢印は`Kakeibo.Display`への1本だけになる．

## 演習7-5：テスト駆動で実装する

### 1. 書き直す(テストはすべて通ったまま)

`parseAmount`は，`Maybe`の`do`記法で書ける．

```haskell
parseAmount :: String -> Maybe Yen
parseAmount text = do
  n <- readMaybe text
  if n > 0 then Just (Yen n) else Nothing
```

`parseEntries`は`traverse`の1行になる．

```haskell
parseEntries :: [String] -> Either String [Entry]
parseEntries args = traverse parseEntry args
```

`parseCommand`の`add`は，`Right`のときだけ`Add`を適用するので`<$>`で書ける．

```haskell
parseCommand ("add" : args@(_ : _)) = Add <$> parseEntries args
```

`decodeEntry`は，金額が読めたときだけ`Entry`を作るので，`<$>`で書ける．

```haskell
decodeEntry :: String -> Maybe Entry
decodeEntry line =
  case break (== '\t') line of
    (name, _ : amountText) -> Entry (parseCategory name) <$> parseAmount amountText
    (_, []) -> Nothing
```

`decodeEntries`は，行番号と行の組を読み取る関数を作り，`traverse`に渡す．
`decodeEntry`の`Maybe`は，`maybe`で`Either`に変える．

```haskell
decodeEntries :: String -> Either String [Entry]
decodeEntries contents = traverse decodeNumbered (zip [1 :: Int ..] (lines contents))
  where
    decodeNumbered (lineNumber, line) =
      maybe (Left (show lineNumber ++ "行目を読めません")) Right (decodeEntry line)
```

`loadEntries`は，`Left`のメッセージにパスを付け，`Right`はそのまま返す．
`either`で書ける．

```haskell
    then do
      contents <- readFile' path
      pure (either (\err -> Left (path ++ ": " ++ err)) Right (decodeEntries contents))
```

`run`の`withEntries`は，読み込んだ結果が`Right`のときだけ`report`を適用するので，`<$>`で書ける．

```haskell
    withEntries report = do
      loaded <- loadEntries path
      pure (report <$> loaded)
```

どの書き直しのあとも，テストはすべて通る．

### 2. `Kakeibo.Date`

`parseDate`は，正しい日付を読む場合から始めた．

```haskell
-- test/unit/Kakeibo/DateSpec.hs
  describe "parseDate" $ do
    it "YYYY-MM-DDの形の日付を読み取る" $
      parseDate "2026-09-01" `shouldBe` Just (Date 2026 9 1)
```

文字列を`-`で分け，3つの部分をそれぞれ読む．

```haskell
parseDate :: String -> Maybe Date
parseDate text =
  case splitOn '-' text of
    [y, m, d] -> Date <$> readMaybe y <*> readMaybe m <*> readMaybe d
    _ -> Nothing

splitOn :: Char -> String -> [String]
splitOn separator text =
  case break (== separator) text of
    (chunk, []) -> [chunk]
    (chunk, _ : rest) -> chunk : splitOn separator rest
```

区切りの誤り(`2026/09/01`)と数でない場合(`2026-ab-01`)は，書いた時点で通る．
桁数の誤り(`2026-9-1`)は`Just (Date 2026 9 1)`になって失敗するので，`case`の選択肢にガードを付ける．

```haskell
    [y, m, d]
      | map length [y, m, d] == [4, 2, 2] -> Date <$> readMaybe y <*> readMaybe m <*> readMaybe d
```

13月のテストでは，読んだ数の範囲を確かめる必要が出てくる．
範囲を確かめるには読んだ値を使うので，`<*>`ではなく`do`記法に書き直す．

```haskell
    [y, m, d]
      | map length [y, m, d] == [4, 2, 2] -> do
          yearNumber <- readMaybe y
          monthNumber <- readMaybe m
          dayNumber <- readMaybe d
          if validMonth monthNumber
            then Just (Date yearNumber monthNumber dayNumber)
            else Nothing
```

4月31日，うるう年の2月29日，うるう年でない年の2月29日のテストを1つずつ足し，日数の条件を育てた．

```haskell
          if validMonth monthNumber && dayNumber >= 1 && dayNumber <= daysInMonth yearNumber monthNumber
            then Just (Date yearNumber monthNumber dayNumber)
            else Nothing

daysInMonth :: Int -> Int -> Int
daysInMonth y m
  | m == 2 = if isLeapYear y then 29 else 28
  | m `elem` [4, 6, 9, 11] = 30
  | otherwise = 31

isLeapYear :: Int -> Bool
isLeapYear y = (y `mod` 4 == 0 && y `mod` 100 /= 0) || y `mod` 400 == 0
```

`Display`のインスタンス，`parseYearMonth`，`inMonth`も，テストを1つずつ足して作った．

```haskell
instance Display Date where
  display (Date y m d) = show y ++ "-" ++ twoDigits m ++ "-" ++ twoDigits d

twoDigits :: Int -> String
twoDigits n
  | n < 10 = "0" ++ show n
  | otherwise = show n

inMonth :: YearMonth -> Date -> Bool
inMonth (YearMonth y m) d = year d == y && month d == m
```

### 3. `Entry`に日付を足す

`Kakeibo.Entry`のテストを書き換えてから，`Entry`と`parseEntry`・`parseEntries`を変える．

```haskell
sep1 :: Date
sep1 = Date 2026 9 1

  describe "parseEntry" $ do
    it "「費目:金額」を，その日の支出として読み取る" $
      parseEntry sep1 "食費:1200" `shouldBe` Right (Entry {date = sep1, category = Food, amount = Yen 1200})
```

```haskell
data Entry = Entry
  { date :: Date,
    category :: Category,
    amount :: Yen
  }
  deriving (Show, Eq)

instance Display Entry where
  display entry = display (date entry) ++ " " ++ display (category entry) ++ " " ++ display (amount entry)

parseEntry :: Date -> String -> Either String Entry
parseEntry d arg =
  Entry d c <$> maybe (Left ("金額は正の整数で書いてください: " ++ arg)) Right (parseAmount amountText)
  where
    (c, amountText) =
      case break (== ':') arg of
        (name, _ : rest) -> (parseCategory name, rest)
        (whole, []) -> (Other, whole)

parseEntries :: Date -> [String] -> Either String [Entry]
parseEntries d args = traverse (parseEntry d) args
```

`Entry d c`は，`Entry`に日付と費目だけを渡した部分適用で，`Yen -> Entry`の関数である．
それを`<$>`で，金額の読み取り結果(`Either String Yen`)に適用している．

`summarize`のテストには，決まった日付の支出を作る関数を作った．

```haskell
-- test/unit/Kakeibo/SummarySpec.hs
entry :: Category -> Int -> Entry
entry c n = Entry (Date 2026 9 1) c (Yen n)

    it "同じ費目の支出を足し合わせる" $
      summarize [entry Food 1200, entry Food 350] `shouldBe` [(Food, Yen 1550)]
```

### 4. データファイルとサブコマンド

`encodeEntry`と`decodeEntry`のテストを3つの項目に書き換え，`decodeEntry`を`<$>`と`<*>`で書く．
日付・費目・金額はそれぞれ独立に読めるので，`<*>`が合う．

```haskell
encodeEntry :: Entry -> String
encodeEntry entry = display (date entry) ++ "\t" ++ display (category entry) ++ "\t" ++ show n
  where
    Yen n = amount entry

decodeEntry :: String -> Maybe Entry
decodeEntry line =
  case splitTabs line of
    [dateText, name, amountText] -> Entry <$> parseDate dateText <*> pure (parseCategory name) <*> parseAmount amountText
    _ -> Nothing
```

`splitTabs`は，`Kakeibo.Date`の`splitOn`と同じ形の関数を，タブで分けるように書いた．

`parseCommand`の`add`は，日付を読んでから，その日付を使って支出を読む．
前の結果を使うので，`do`記法で書く．

```haskell
parseCommand ("add" : dateText : args@(_ : _)) = do
  d <- maybe (Left ("存在する日付をYYYY-MM-DDの形で書いてください: " ++ dateText)) Right (parseDate dateText)
  entries <- parseEntries d args
  pure (Add entries)
parseCommand ["list"] = Right (List Nothing)
parseCommand ["list", monthText] = List . Just <$> readYearMonth monthText
parseCommand ["summary"] = Right (Summary Nothing)
parseCommand ["summary", monthText] = Summary . Just <$> readYearMonth monthText
parseCommand _ = Left usage

readYearMonth :: String -> Either String YearMonth
readYearMonth text = maybe (Left ("年月はYYYY-MMの形で書いてください: " ++ text)) Right (parseYearMonth text)
```

`List . Just`は，年月を`Just`で包んでから`List`に渡す関数(`YearMonth -> Command`)である．

`run`は，年月の指定に従って支出を選んでから，表示する行を作る．

```haskell
    Right (List target) -> withEntries target listReport
    Right (Summary target) -> withEntries target summaryReport
  where
    withEntries target report = do
      loaded <- loadEntries path
      pure (report . selectMonth target <$> loaded)

selectMonth :: Maybe YearMonth -> [Entry] -> [Entry]
selectMonth Nothing entries = entries
selectMonth (Just target) entries = filter (inMonth target . date) entries
```

結合テストは，`add`に日付を足してから，月での絞り込みのテストを足した．

```haskell
    it "listに年月を指定すると，その月の支出だけを表示する" $
      withDataFile $ \path -> do
        _ <- run path ["add", "2026-08-31", "食費:500"]
        _ <- run path ["add", "2026-09-01", "食費:1200"]
        _ <- run path ["add", "2026-10-01", "交通費:350"]
        result <- run path ["list", "2026-09"]
        result `shouldBe` Right ["2026-09-01 食費 1,200円", "合計: 1,200円"]
```

### 5. `main`

```haskell
main :: IO ()
main = do
  args <- getArgs
  path <- fromMaybe defaultDataFile <$> lookupEnv "KAKEIBO_FILE"
  result <- run path args
  case result of
    Left err -> do
      hPutStrLn stderr err
      exitFailure
    Right outputLines -> mapM_ putStrLn outputLines
```

## 演習7-6：振り返る

1. 日付の誤りを1つの項目にまとめた人もいるだろう．うるう年の規則は誤りやすいので，通る例と通らない例を両方置いておくと，条件の誤りに気付ける．
2. `parseEntries`は7行から1行に，`decodeEntries`の中の再帰は7行から2行になった．書き直しの誤り(たとえば`traverse`に渡す関数の取り違え)は，Iteration 4とIteration 6で書いた`parseEntries`・`decodeEntries`のテストが見つける．
3. `decodeEntry`の日付・費目・金額は，どれもほかの値を使わずに読めるので`<*>`で書いた．`parseCommand`の`add`は，読んだ日付を`parseEntries`に渡すので，前の結果を使える`do`記法で書いた．
4. 結合テストでは，日付の誤りの代表として`add`の誤りを確かめる例は置かず，単体テスト(`parseCommand`の日付の誤り)に任せた．`run`は`parseCommand`の`Left`をそのまま返すことを，金額の誤りの結合テストで確かめているので，日付の誤りも同じ道を通ることがわかる．
5. `splitOn`(`Kakeibo.Date`)と`splitTabs`(`Kakeibo.Storage`)は，実装のときに作った公開しない補助の関数である．同じ形の関数が2つあるので，共通のモジュールにまとめる設計も考えられる．

## 演習7-7(発展)：期間を指定する

`Command`の`List`と`Summary`が持つ値を，年月か期間かを表す型にする．

```haskell
data Period
  = WholeMonth YearMonth
  | Between Date Date
  deriving (Show, Eq)

inPeriod :: Period -> Date -> Bool
inPeriod (WholeMonth ym) d = inMonth ym d
inPeriod (Between from to) d = from <= d && d <= to

parseCommand ["list", fromText, toText] = do
  from <- readDate fromText
  to <- readDate toText
  pure (List (Just (Between from to)))
```

`Date`は`deriving (Ord)`で年・月・日の順に比べられるので，`<=`で期間に含まれるかを確かめられる．
