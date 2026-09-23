# Code：型と関数

モジュールの中の型と関数を示す．

## データ型

```mermaid
classDiagram
  class Command {
    <<直和型>>
    Add [Entry]
    List
    Summary
  }
  class Category {
    <<直和型>>
    Food
    Transport
    Daily
    Other
  }
  class Entry {
    <<レコード>>
    category : Category
    amount : Yen
  }
  class Yen {
    <<newtype>>
    Int
  }
  class Display {
    <<型クラス>>
    display(a) String
  }
  class Semigroup {
    <<型クラス>>
    a <> a
  }
  class Monoid {
    <<型クラス>>
    mempty
  }
  Command --> Entry : Add
  Entry --> Category : category
  Entry --> Yen : amount
  Display <|.. Yen : instance
  Display <|.. Category : instance
  Display <|.. Entry : instance
  Semigroup <|.. Yen : instance
  Monoid <|.. Yen : instance
```

- `Yen`の`<>`は足し算，`mempty`は0円である．
- `Yen`と`Category`は`Ord`を，`Category`は`Enum`と`Bounded`を`deriving`する．

## 型と関数の流れ

### サブコマンドの読み取り

```mermaid
flowchart LR
  args(["[String]<br/>コマンドライン引数"]) -- parseCommand --> parsed(["Either String Command"])
  parsed -- "add 費目:金額 …" --> add(["Add [Entry]"])
  parsed -- "list" --> list(["List"])
  parsed -- "summary" --> summary(["Summary"])
  parsed -- "支出の誤り" --> err(["Left String<br/>エラーメッセージ"])
  parsed -- "それ以外" --> usage(["Left usage<br/>使い方"])
```

### list・summary

```mermaid
flowchart LR
  path(["FilePath"]) -- "loadEntries(IO)" --> loaded(["Either String [Entry]"])
  loaded -- "Right：listReport" --> listLines(["[String]<br/>明細と合計の行"])
  loaded -- "Right：summaryReport" --> summaryLines(["[String]<br/>小計と合計の行"])
  loaded -- "Left：そのまま返す" --> err(["Left String<br/>パス: N行目を読めません"])
```

### データファイルの行と支出の変換

```mermaid
flowchart LR
  entry(["Entry"]) -- encodeEntry --> line(["String<br/>費目と金額をタブで区切った行"])
  line -- decodeEntry --> decoded(["Maybe Entry"])
  contents(["String<br/>ファイルの中身"]) -- "lines，zip [1 ..]" --> numbered(["[(Int, String)]<br/>行番号と行"])
  numbered -- "decodeLines" --> entries(["Either String [Entry]<br/>Left：N行目を読めません"])
```

| モジュール | 関数 | 型 | 公開 |
|---|---|---|---|
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
| `Kakeibo.App` | `defaultDataFile` | `FilePath` | する |
| `Kakeibo.Summary` | `summarize` | `[Entry] -> [(Category, Yen)]` | する |
| `Kakeibo.Entry` | `parseCategory` | `String -> Category` | する |
| `Kakeibo.Entry` | `parseAmount` | `String -> Maybe Yen` | する |
| `Kakeibo.Entry` | `parseEntry` | `String -> Either String Entry` | する |
| `Kakeibo.Entry` | `parseEntries` | `[String] -> Either String [Entry]` | する |
| `Kakeibo.Money` | `total` | `[Yen] -> Yen` | する |

- `list`・`summary`は，支出が1件もなければ`支出はありません`を表示する．
- `add`の支出に1つでも誤りがあれば，何も追記しない．`parseCommand`がすべての支出を読み終えてから`Add`を返し，`appendEntries`はその後でだけ呼ぶ．

## IOの順序

### add

```mermaid
sequenceDiagram
  actor user as 利用者
  participant main as Main
  participant app as Kakeibo.App
  participant storage as Kakeibo.Storage
  participant file as データファイル
  user->>main: kakeibo add 食費:1200
  main->>main: getArgs，lookupEnv "KAKEIBO_FILE"
  main->>app: run path args
  app->>app: parseCommand args
  alt Left err
    app-->>main: Left err
  else Right (Add entries)
    app->>storage: appendEntries path entries
    storage->>file: appendFile
    app-->>main: Right ["追加しました: 食費 1,200円"]
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
  user->>main: kakeibo list
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
  app->>app: listReport(summaryならsummaryReport)
  app-->>main: Either String [String]
  alt Left err
    main->>user: エラーメッセージを表示する(hPutStrLn stderr)
    main->>main: exitFailure(終了コード1)
  else Right outputLines
    main->>user: 行を表示する(putStr)
  end
```
