# Code：型と関数

モジュールの中の型と関数を示す．

## データ型

```mermaid
classDiagram
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
    amount : Int
  }
  class Enum {
    <<型クラス>>
  }
  class Bounded {
    <<型クラス>>
  }
  Entry --> Category : category
  Enum <|.. Category : deriving
  Bounded <|.. Category : deriving
```

- `Category`と`Entry`は`Kakeibo.Entry`で定義し，`deriving (Show, Eq)`でテストの`shouldBe`で比べられるようにする．
- `Category`は`Enum`と`Bounded`も`deriving`し，`[minBound .. maxBound]`ですべての費目を定義順に並べられるようにする．

## 型と関数の流れ

コマンドライン引数から表示する行までを，型の変換の流れで示す．
失敗しうる変換は`Either String …`を返し，`Left`にエラーメッセージを入れる．

```mermaid
flowchart LR
  args(["[String]<br/>コマンドライン引数"]) -- parseEntries --> parsed(["Either String [Entry]"])
  parsed -- "Left：そのまま返す" --> err(["Left String<br/>エラーメッセージ"])
  parsed -- "Right：report" --> out(["Right [String]<br/>明細・小計・合計の行"])
  args -. "空のリスト" .-> none(["Right [String]<br/>支出はありません"])
```

`report`は，支出のリストから明細・小計・合計の行を作る(失敗しない)．

```mermaid
flowchart LR
  entries(["[Entry]"]) -- "map formatEntry" --> details(["[String]<br/>明細の行"])
  entries -- summarize --> subtotals(["[(Category, Int)]<br/>費目ごとの小計"])
  subtotals -- "map formatSubtotal" --> subtotalLines(["[String]<br/>小計の行"])
  entries -- "map amount，total，formatYen" --> totalLine(["String<br/>合計の行"])
  details -- "++" --> out(["[String]"])
  subtotalLines -- "「費目別:」の後ろに ++" --> out
  totalLine -- "++" --> out
```

`parseEntries`は，引数を先頭から1つずつ`parseEntry`で読み，最初の`Left`で打ち切る．
`parseEntry`は，金額を`parseAmount`で読み，読めなければ引数を含むエラーメッセージを返す．

```mermaid
flowchart LR
  arg(["String<br/>食費:abc"]) -- "break isColon" --> pair(["(Category, String)<br/>(Food, abc)"])
  pair -- "parseAmount(金額の部分)" --> amount(["Maybe Int"])
  amount -- "Nothing" --> left(["Left String<br/>金額は正の整数で書いてください: 食費:abc"])
  amount -- "Just n" --> right(["Right Entry"])
```

| モジュール | 関数 | 型 | 公開 |
|---|---|---|---|
| `Kakeibo.Money` | `total` | `[Int] -> Int` | する |
| `Kakeibo.Money` | `formatYen` | `Int -> String` | する |
| `Kakeibo.Money` | `insertCommas` | `String -> String` | しない |
| `Kakeibo.Entry` | `parseCategory` | `String -> Category` | する |
| `Kakeibo.Entry` | `categoryName` | `Category -> String` | する |
| `Kakeibo.Entry` | `parseAmount` | `String -> Maybe Int` | する |
| `Kakeibo.Entry` | `parseEntry` | `String -> Either String Entry` | する |
| `Kakeibo.Entry` | `parseEntries` | `[String] -> Either String [Entry]` | する |
| `Kakeibo.Entry` | `formatEntry` | `Entry -> String` | する |
| `Kakeibo.Summary` | `summarize` | `[Entry] -> [(Category, Int)]` | する |
| `Kakeibo.App` | `run` | `[String] -> Either String [String]` | する |
| `Kakeibo.App` | `report` | `[Entry] -> [String]` | しない |
| `Kakeibo.App` | `formatSubtotal` | `(Category, Int) -> String` | しない |

- 金額は正の整数でなければならない．`parseAmount`は`readMaybe`で読み，1以上のときだけ`Just`を返す．
- 誤った引数が複数あれば，最初のもののエラーメッセージを返す．
- 知らない費目の名前は「その他」(`Other`)として読む．

## IOの順序

`main`が実行する`IO`のアクションと，純粋な関数`run`の呼び出しの順序を示す．

```mermaid
sequenceDiagram
  actor user as 利用者
  participant main as Main
  participant app as Kakeibo.App
  user->>main: kakeibo 食費:1200 交通費:abc
  main->>main: getArgs
  main->>app: run args
  app-->>main: Either String [String]
  alt Left err
    main->>user: エラーメッセージを表示する(hPutStrLn stderr)
    main->>main: exitFailure(終了コード1)
  else Right outputLines
    main->>user: 行を表示する(putStr)
  end
```
