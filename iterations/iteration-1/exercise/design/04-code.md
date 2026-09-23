# Code：型と関数

モジュールの中の型と関数を示す．

## 型と関数の流れ

コマンドライン引数から表示する行までを，型の変換の流れで示す．

```mermaid
flowchart LR
  args(["[String]<br/>コマンドライン引数"]) -- "map read" --> amounts(["[Int]<br/>金額"])
  amounts -- total --> sum(["Int<br/>合計"])
  sum -- formatYen --> yen(["String<br/>2350円"])
  yen -- "「合計: 」を前に付ける" --> out(["[String]<br/>表示する行"])
```

| モジュール | 関数 | 型 |
|---|---|---|
| `Kakeibo.Money` | `total` | `[Int] -> Int` |
| `Kakeibo.Money` | `formatYen` | `Int -> String` |
| `Kakeibo.App` | `run` | `[String] -> [String]` |

- 引数はすべて整数として読める前提である．

## IOの順序

`main`が実行する`IO`のアクションと，純粋な関数`run`の呼び出しの順序を示す．

```mermaid
sequenceDiagram
  actor user as 利用者
  participant main as Main
  participant app as Kakeibo.App
  user->>main: kakeibo 1200 350 800
  main->>main: getArgs
  main->>app: run args
  app-->>main: ["合計: 2350円"]
  main->>user: 行を表示する(putStr)
```
