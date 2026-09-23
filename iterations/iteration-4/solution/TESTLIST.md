# テストリスト(Iteration 4・解答例)

## 単体テスト

- [x] `parseAmount`：正の整数を読み取る
- [x] `parseAmount`：数として読めなければ`Nothing`
- [x] `parseAmount`：空文字列なら`Nothing`
- [x] `parseAmount`：小数なら`Nothing`
- [x] `parseAmount`：0なら`Nothing`
- [x] `parseAmount`：負の数なら`Nothing`
- [x] `parseEntry`：既存の2つのテストの期待値を`Right`で包む
- [x] `parseEntry`：金額が正の整数でなければ，引数を含むエラーメッセージを返す
- [x] `parseEntry`：`:`がなく，全体が正の整数でなければ，エラーメッセージを返す
- [x] `parseEntries`：空のリストなら空のリストを返す
- [x] `parseEntries`：すべての引数を読み取り，同じ順に並べる
- [x] `parseEntries`：読み取れない引数があれば，そのエラーメッセージを返す
- [x] `parseEntries`：読み取れない引数が複数あれば，最初のもののエラーメッセージを返す

## 結合テスト

- [x] `run`：既存の4つのテストの期待値を`Right`で包む
- [x] `run`：金額が正の整数でない引数があれば，エラーメッセージを返す

## 手で確かめること

- [x] 誤った引数を渡すと，エラーメッセージが標準エラー出力に表示され，終了コードが1になる
