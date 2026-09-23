# Context：システムコンテキスト

`kakeibo`を使う人と，`kakeibo`の関係を示す．

```mermaid
C4Context
  title kakeiboのシステムコンテキスト
  Person(user, "利用者", "支出を記録し，合計を確かめる人")
  System(kakeibo, "kakeibo", "コマンドライン引数に並べた支出の明細，費目ごとの小計，合計を表示する")
  Rel(user, kakeibo, "支出を「費目:金額」の形でコマンドライン引数で渡し，明細・小計・合計を読む")
```
