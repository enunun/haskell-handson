# テストリスト(Iteration 2・解答例)

## 単体テスト

- [x] `parseCategory`：「食費」を食費として読む
- [x] `parseCategory`：「交通費」を交通費として読む
- [x] `parseCategory`：「日用品」を日用品として読む
- [x] `parseCategory`：「その他」をその他として読む
- [x] `parseCategory`：知らない名前はその他として読む
- [x] `categoryName`：費目の名前を返す
- [x] `parseEntry`：`費目:金額`を読み取る
- [x] `parseEntry`：`:`がなければ，全体を金額とし，費目をその他とする
- [x] `formatEntry`：費目と金額を空白で区切って表示する

## 結合テスト

- [x] `run`：支出を1件ずつ表示し，最後に合計を表示する
- [x] `run`：費目のない金額は，その他として表示する(既存のテストの期待値を変える)
