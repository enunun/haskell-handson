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
  Entry --> Category : category
```

- `Category`と`Entry`は`Kakeibo.Entry`で定義し，`deriving (Show, Eq)`でテストの`shouldBe`で比べられるようにする．

## 型と関数の流れ

コマンドライン引数から表示する行までを，型の変換の流れで示す．

```mermaid
flowchart LR
  args(["[String]<br/>コマンドライン引数"]) -- "map parseEntry" --> entries(["[Entry]"])
  entries -- "map formatEntry" --> details(["[String]<br/>明細の行"])
  entries -- "map amount" --> amounts(["[Int]<br/>金額"])
  amounts -- total --> sum(["Int<br/>合計"])
  sum -- formatYen --> yen(["String"])
  yen -- "「合計: 」を前に付ける" --> totalLine(["String<br/>合計の行"])
  details -- "++" --> out(["[String]<br/>表示する行"])
  totalLine -- "++" --> out
  args -. "空のリスト" .-> none(["[String]<br/>支出はありません"])
```

`parseEntry`は，引数を`:`の前と後ろに分け，`:`があるかどうかで場合分けする．

```mermaid
flowchart LR
  arg(["String<br/>食費:1200"]) -- "break isColon" --> pair(["(String, String)<br/>(食費, :1200)"])
  pair -- "「:」がある：parseCategoryとread" --> withCategory(["Entry<br/>Food 1200"])
  pair -- "「:」がない：全体をread" --> other(["Entry<br/>Other 800"])
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
| `Kakeibo.App` | `run` | `[String] -> [String]` | する |

- 知らない費目の名前は「その他」(`Other`)として読む．
- 金額は整数として読める前提である．

## IOの順序

`main`が実行する`IO`のアクションと，純粋な関数`run`の呼び出しの順序を示す．

```mermaid
sequenceDiagram
  actor user as 利用者
  participant main as Main
  participant app as Kakeibo.App
  user->>main: kakeibo 食費:1200 交通費:350
  main->>main: getArgs
  main->>app: run args
  app-->>main: ["食費 1,200円", "交通費 350円", "合計: 1,550円"]
  main->>user: 行を表示する(putStr)
```
