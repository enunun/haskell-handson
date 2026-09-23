# Code：型と関数

モジュールの中の型と関数を示す．

## データ型

```mermaid
classDiagram
  class Command {
    <<直和型>>
    Add [Entry]
    List (Maybe YearMonth)
    Summary (Maybe YearMonth)
  }
  class Entry {
    <<レコード>>
    date : Date
    category : Category
    amount : Yen
  }
  class Date {
    <<レコード>>
    year : Int
    month : Int
    day : Int
  }
  class YearMonth {
    <<data>>
    YearMonth Int Int
  }
  class Category {
    <<直和型>>
    Food
    Transport
    Daily
    Other
  }
  class Yen {
    <<newtype>>
    Int
  }
  class Display {
    <<型クラス>>
    display(a) String
  }
  Command --> Entry : Add
  Command --> YearMonth : List, Summary
  Entry --> Date : date
  Entry --> Category : category
  Entry --> Yen : amount
  Display <|.. Date : instance
  Display <|.. Yen : instance
  Display <|.. Category : instance
  Display <|.. Entry : instance
```

- `Date`は`Ord`を`deriving`し，年・月・日の順に比べる．`Display`では`2026-09-01`のように月と日を2桁で表示する．
- `Yen`は`Semigroup`(`<>`は足し算)と`Monoid`(`mempty`は0円)のインスタンスである．
- `Yen`と`Category`は`Ord`を，`Category`は`Enum`と`Bounded`を`deriving`する．

## 型と関数の流れ

`Maybe`・`Either`を返す関数どうしは，`<$>`・`<*>`・`do`記法・`traverse`で組み合わせる．

### サブコマンドの読み取り

`add`は，日付を読んでから，その日付で支出を読む．前の結果を使うので，`Either`の`do`記法で書く．

```mermaid
flowchart LR
  args(["[String]<br/>add 日付 費目:金額 …"]) -- "parseDate(日付)" --> maybeDate(["Maybe Date"])
  maybeDate -- "maybe (Left …) Right" --> eitherDate(["Either String Date"])
  eitherDate -- "d <- …" --> d(["Date"])
  d -- "parseEntries d(traverse (parseEntry d))" --> entries(["Either String [Entry]"])
  entries -- "Add <$>" --> add(["Either String Command"])
  month(["[String]<br/>list 年月"]) -- "parseYearMonth，maybe (Left …) Right" --> ym(["Either String YearMonth"])
  ym -- "List . Just <$>" --> list(["Either String Command"])
```

### list・summary

```mermaid
flowchart LR
  path(["FilePath"]) -- "loadEntries(IO)" --> loaded(["Either String [Entry]"])
  loaded -- "report . selectMonth target <$>" --> out(["Either String [String]"])
```

- `selectMonth`は，年月の指定(`Maybe YearMonth`)が`Nothing`ならすべての支出を，`Just ym`なら`inMonth ym . date`を満たす支出だけを選ぶ．
- `report`は，`list`なら`listReport`，`summary`なら`summaryReport`である．

### データファイルの行と支出の変換

日付・費目・金額は互いに関係なく読めるので，`<$>`と`<*>`で組み合わせる．

```mermaid
flowchart LR
  line(["String<br/>日付と費目と金額をタブで区切った行"]) -- splitTabs --> fields(["[String]<br/>3つの項目"])
  fields -- "Entry <$> parseDate d <*> pure (parseCategory c) <*> parseAmount a" --> decoded(["Maybe Entry"])
  contents(["String<br/>ファイルの中身"]) -- "lines，zip [1 ..]" --> numbered(["[(Int, String)]<br/>行番号と行"])
  numbered -- "traverse decodeNumbered" --> entries(["Either String [Entry]<br/>Left：N行目を読めません"])
```

| モジュール | 関数 | 型 | 公開 |
|---|---|---|---|
| `Kakeibo.Date` | `parseDate` | `String -> Maybe Date` | する |
| `Kakeibo.Date` | `parseYearMonth` | `String -> Maybe YearMonth` | する |
| `Kakeibo.Date` | `inMonth` | `YearMonth -> Date -> Bool` | する |
| `Kakeibo.Date` | `daysInMonth` | `Int -> Int -> Int` | しない |
| `Kakeibo.Date` | `isLeapYear` | `Int -> Bool` | しない |
| `Kakeibo.Command` | `parseCommand` | `[String] -> Either String Command` | する |
| `Kakeibo.Command` | `usage` | `String` | する |
| `Kakeibo.Report` | `listReport` | `[Entry] -> [String]` | する |
| `Kakeibo.Report` | `summaryReport` | `[Entry] -> [String]` | する |
| `Kakeibo.Storage` | `encodeEntry` | `Entry -> String` | する |
| `Kakeibo.Storage` | `decodeEntry` | `String -> Maybe Entry` | する |
| `Kakeibo.Storage` | `decodeEntries` | `String -> Either String [Entry]` | する |
| `Kakeibo.Storage` | `loadEntries` | `FilePath -> IO (Either String [Entry])` | する |
| `Kakeibo.Storage` | `appendEntries` | `FilePath -> [Entry] -> IO ()` | する |
| `Kakeibo.App` | `run` | `FilePath -> [String] -> IO (Either String [String])` | する |
| `Kakeibo.App` | `selectMonth` | `Maybe YearMonth -> [Entry] -> [Entry]` | しない |
| `Kakeibo.Summary` | `summarize` | `[Entry] -> [(Category, Yen)]` | する |
| `Kakeibo.Entry` | `parseAmount` | `String -> Maybe Yen` | する |
| `Kakeibo.Entry` | `parseEntry` | `Date -> String -> Either String Entry` | する |
| `Kakeibo.Entry` | `parseEntries` | `Date -> [String] -> Either String [Entry]` | する |

- 日付は`YYYY-MM-DD`の形で，存在する日付でなければならない(うるう年を考える)．年月は`YYYY-MM`の形である．
- `add`の支出に1つでも誤りがあれば，何も追記しない．

## 満たすべき性質

関数を組み合わせたときに，どんな入力でも成り立つべき性質を示す．
どの性質も，QuickCheckの`prop`で確かめる．

### 変換して逆変換すると元に戻る

```mermaid
flowchart LR
  entry(["Entry"]) -- encodeEntry --> line(["String<br/>データファイルの1行"])
  line -- decodeEntry --> back(["Maybe Entry<br/>Just(元の支出)"])
  entries(["[Entry]"]) -- "unlines . map encodeEntry" --> contents(["String<br/>データファイルの中身"])
  contents -- decodeEntries --> backs(["Either String [Entry]<br/>Right(元の並び)"])
  date(["Date"]) -- display --> dateText(["String"])
  dateText -- parseDate --> backDate(["Maybe Date<br/>Just(元の日付)"])
  category(["Category"]) -- display --> name(["String"])
  name -- parseCategory --> backCategory(["Category<br/>元の費目"])
  e(["Entry"]) -- "addの引数にする" --> args(["[String]"])
  args -- parseCommand --> command(["Either String Command<br/>Right(Add [元の支出])"])
```

### 集計しても全体の量は変わらない

```mermaid
flowchart LR
  entries(["[Entry]"]) -- summarize --> subtotals(["[(Category, Yen)]"])
  subtotals -- "total . map snd" --> sum1(["Yen"])
  entries -- "total . map amount" --> sum2(["Yen"])
  sum1 -. "等しい" .- sum2
```

- `summarize`の結果には，同じ費目が1度しか現れず，小計は大きい順に並ぶ．
- `Yen`の`<>`は結合法則を満たし，`mempty`は`<>`の単位元である．`total`は中の数の和になる．
- `add`した支出の合計は，`list`の最後の行に表示される(結合テスト)．

### 性質の前提

性質は，要求で正しいとされる値についてだけ成り立つ．
テスト用のジェネレータ(`test/common/Kakeibo/Generators.hs`)は，次の値だけを作る．

| ジェネレータ | 作る値 |
|---|---|
| `genCategory` | すべての費目のどれか |
| `genYen` | 1円から1,000万円までの金額 |
| `genDate` | 2000年から2099年までの，1日から28日までの日付(どの月にも存在する) |
| `genEntry` | 上の3つを組み合わせた支出 |

## IOの順序

### add

```mermaid
sequenceDiagram
  actor user as 利用者
  participant main as Main
  participant app as Kakeibo.App
  participant storage as Kakeibo.Storage
  participant file as データファイル
  user->>main: kakeibo add 2026-09-01 食費:1200
  main->>main: getArgs，lookupEnv "KAKEIBO_FILE"
  main->>app: run path args
  app->>app: parseCommand args
  alt Left err
    app-->>main: Left err
  else Right (Add entries)
    app->>storage: appendEntries path entries
    storage->>file: appendFile
    app-->>main: Right ["追加しました: 2026-09-01 食費 1,200円"]
  end
  main->>user: 行かエラーメッセージを表示する
```

### list・summary

```mermaid
sequenceDiagram
  actor user as 利用者
  participant main as Main
  participant app as Kakeibo.App
  participant storage as Kakeibo.Storage
  participant file as データファイル
  user->>main: kakeibo list 2026-09
  main->>main: getArgs，lookupEnv "KAKEIBO_FILE"
  main->>app: run path args
  app->>app: parseCommand args
  app->>storage: loadEntries path
  storage->>file: doesFileExist
  alt ファイルがある
    storage->>file: readFile'
    storage->>storage: decodeEntries contents
  else ファイルがない
    storage->>storage: Right []
  end
  storage-->>app: Either String [Entry]
  app->>app: selectMonth，listReport(summaryならsummaryReport)
  app-->>main: Either String [String]
  alt Left err
    main->>user: エラーメッセージを表示する(hPutStrLn stderr)
    main->>main: exitFailure(終了コード1)
  else Right outputLines
    main->>user: 行を表示する(mapM_ putStrLn)
  end
```
