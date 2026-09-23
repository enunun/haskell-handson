# Context：システムコンテキスト

`kakeibo`を使う人と，`kakeibo`の関係を示す．

```mermaid
C4Context
  title kakeiboのシステムコンテキスト
  Person(user, "利用者", "支出を記録し，合計を確かめる人")
  System(kakeibo, "kakeibo", "コマンドライン引数に並べた支出の金額の合計を，3桁区切りで表示する")
  Rel(user, kakeibo, "金額をコマンドライン引数で渡し，合計を読む")
```
