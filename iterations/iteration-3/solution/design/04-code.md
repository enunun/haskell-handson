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

```mermaid
flowchart LR
  args(["[String]<br/>コマンドライン引数"]) -- "map parseEntry" --> entries(["[Entry]"])
  entries -- "map formatEntry" --> details(["[String]<br/>明細の行"])
  entries -- summarize --> subtotals(["[(Category, Int)]<br/>費目ごとの小計"])
  subtotals -- "map formatSubtotal" --> subtotalLines(["[String]<br/>小計の行"])
  entries -- "map amount" --> amounts(["[Int]<br/>金額"])
  amounts -- total --> sum(["Int<br/>合計"])
  sum -- "formatYen，「合計: 」を前に付ける" --> totalLine(["String<br/>合計の行"])
  details -- "++" --> out(["[String]<br/>表示する行"])
  subtotalLines -- "「費目別:」の後ろに ++" --> out
  totalLine -- "++" --> out
  args -. "空のリスト" .-> none(["[String]<br/>支出はありません"])
```

`summarize`は，すべての費目のリストから，支出がある費目だけを選び，それぞれの小計を求める．

```mermaid
flowchart LR
  all(["[Category]<br/>すべての費目"]) -- "filter hasEntries" --> used(["[Category]<br/>支出がある費目"])
  used -- "map subtotal" --> subtotals(["[(Category, Int)]"])
```

| モジュール | 関数 | 型 | 公開 |
|---|---|---|---|
| `Kakeibo.Money` | `total` | `[Int] -> Int` | する |
| `Kakeibo.Money` | `formatYen` | `Int -> String` | する |
| `Kakeibo.Money` | `insertCommas` | `String -> String` | しない |
| `Kakeibo.Entry` | `parseCategory` | `String -> Category` | する |
| `Kakeibo.Entry` | `categoryName` | `Category -> String` | する |
| `Kakeibo.Entry` | `parseEntry` | `String -> Entry` | する |
| `Kakeibo.Entry` | `formatEntry` | `Entry -> String` | する |
| `Kakeibo.Summary` | `summarize` | `[Entry] -> [(Category, Int)]` | する |
| `Kakeibo.App` | `run` | `[String] -> [String]` | する |
| `Kakeibo.App` | `formatSubtotal` | `(Category, Int) -> String` | しない |

- `total`は`foldr (+) 0`で求める．
- `allCategories`は`[minBound .. maxBound]`，`entriesOf c`は費目`c`の支出だけのリスト(`filter ((== c) . category)`)である．
- 小計の行は，行頭に空白を2つ入れて`  費目 金額`の形にする．
- 知らない費目の名前は「その他」(`Other`)として読む．金額は整数として読める前提である．

## IOの順序

`main`が実行する`IO`のアクションと，純粋な関数`run`の呼び出しの順序を示す．

```mermaid
sequenceDiagram
  actor user as 利用者
  participant main as Main
  participant app as Kakeibo.App
  user->>main: kakeibo 食費:1200 交通費:350 食費:350
  main->>main: getArgs
  main->>app: run args
  app-->>main: 明細・費目別の小計・合計の行
  main->>user: 行を表示する(putStr)
```
