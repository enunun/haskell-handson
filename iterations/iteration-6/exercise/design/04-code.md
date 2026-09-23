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
  class Ord {
    <<型クラス>>
  }
  class Enum {
    <<型クラス>>
  }
  class Bounded {
    <<型クラス>>
  }
  Entry --> Category : category
  Entry --> Yen : amount
  Display <|.. Yen : instance
  Display <|.. Category : instance
  Display <|.. Entry : instance
  Semigroup <|.. Yen : instance
  Monoid <|.. Yen : instance
  Ord <|.. Yen : deriving
  Ord <|.. Category : deriving
  Enum <|.. Category : deriving
  Bounded <|.. Category : deriving
```

| 型 | インスタンス | 定義 |
|---|---|---|
| `Yen` | `Semigroup` | `Yen a <> Yen b = Yen (a + b)` |
| `Yen` | `Monoid` | `mempty = Yen 0` |
| `Yen` | `Display` | 3桁区切りの数の後ろに「円」を付ける(`1,200円`) |
| `Category` | `Display` | 費目の名前(`食費`など) |
| `Entry` | `Display` | `費目 金額`(`食費 1,200円`) |

- `Yen`と`Category`は`Ord`を`deriving`する．`Yen`は中の数の大小，`Category`は定義の順で比べる．

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
  entries(["[Entry]"]) -- "map display" --> details(["[String]<br/>明細の行"])
  entries -- summarize --> subtotals(["[(Category, Yen)]<br/>費目ごとの小計"])
  subtotals -- "map formatSubtotal" --> subtotalLines(["[String]<br/>小計の行"])
  entries -- "map amount" --> amounts(["[Yen]"])
  amounts -- "total(mconcat)" --> sum(["Yen"])
  sum -- "display，「合計: 」を前に付ける" --> totalLine(["String<br/>合計の行"])
  details -- "++" --> out(["[String]"])
  subtotalLines -- "「費目別:」の後ろに ++" --> out
  totalLine -- "++" --> out
```

`summarize`は，費目をキー，金額を値にした表を作り，金額の大きい順に並べる．

```mermaid
flowchart LR
  entries(["[Entry]"]) -- "map (\e -> (category e, amount e))" --> pairs(["[(Category, Yen)]"])
  pairs -- "Map.fromListWith (<>)" --> table(["Map Category Yen<br/>同じ費目の金額を<>でまとめた表"])
  table -- "Map.toList" --> byCategory(["[(Category, Yen)]<br/>費目の定義順"])
  byCategory -- "sortOn (Down . snd)" --> sorted(["[(Category, Yen)]<br/>金額の大きい順"])
```

| モジュール | 関数 | 型 | 公開 |
|---|---|---|---|
| `Kakeibo.Display` | `display` | `Display a => a -> String` | する |
| `Kakeibo.Money` | `total` | `[Yen] -> Yen` | する |
| `Kakeibo.Money` | `insertCommas` | `String -> String` | しない |
| `Kakeibo.Entry` | `parseCategory` | `String -> Category` | する |
| `Kakeibo.Entry` | `parseAmount` | `String -> Maybe Yen` | する |
| `Kakeibo.Entry` | `parseEntry` | `String -> Either String Entry` | する |
| `Kakeibo.Entry` | `parseEntries` | `[String] -> Either String [Entry]` | する |
| `Kakeibo.Summary` | `summarize` | `[Entry] -> [(Category, Yen)]` | する |
| `Kakeibo.App` | `run` | `[String] -> Either String [String]` | する |
| `Kakeibo.App` | `report` | `[Entry] -> [String]` | しない |
| `Kakeibo.App` | `formatSubtotal` | `(Category, Yen) -> String` | しない |

- 小計が同じ費目どうしは，費目の定義順に並べる．`sortOn`は基準が同じ要素の順番を保ち，`Map.toList`は定義順に並べるので，この順になる．
- 金額は正の整数でなければならない．誤った引数が複数あれば，最初のもののエラーメッセージを返す．

## IOの順序

`main`が実行する`IO`のアクションと，純粋な関数`run`の呼び出しの順序を示す．

```mermaid
sequenceDiagram
  actor user as 利用者
  participant main as Main
  participant app as Kakeibo.App
  user->>main: kakeibo 食費:350 交通費:1200
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
