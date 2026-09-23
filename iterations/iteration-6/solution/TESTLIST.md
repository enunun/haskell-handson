# テストリスト(Iteration 6・解答例)

## 単体テスト

- [x] `listReport`：支出がなければ，支出がないことを表示する
- [x] `listReport`：支出を1件ずつ表示し，最後に合計を表示する
- [x] `summaryReport`：支出がなければ，支出がないことを表示する
- [x] `summaryReport`：費目ごとの小計を金額の大きい順に表示し，最後に合計を表示する
- [x] `encodeEntry`：費目の名前と金額をタブで区切る
- [x] `decodeEntry`：費目の名前と金額をタブで区切った行を読み取る
- [x] `decodeEntry`：タブがなければ`Nothing`
- [x] `decodeEntry`：金額が正の整数でなければ`Nothing`
- [x] `decodeEntries`：空なら支出は0件
- [x] `decodeEntries`：1行を支出1件として読み取る
- [x] `decodeEntries`：読み取れない行があれば，その行番号を示すエラーメッセージを返す
- [x] `parseCommand`：`add`の後ろの支出を読み取る
- [x] `parseCommand`：`add`の後ろに支出を複数並べられる
- [x] `parseCommand`：`add`の後ろの支出が読み取れなければ，そのエラーメッセージを返す
- [x] `parseCommand`：`add`の後ろに支出がなければ，使い方を返す
- [x] `parseCommand`：`list`を読み取る
- [x] `parseCommand`：`summary`を読み取る
- [x] `parseCommand`：引数がなければ，使い方を返す
- [x] `parseCommand`：知らないサブコマンドなら，使い方を返す
- [x] `parseCommand`：`list`の後ろに余分な引数があれば，使い方を返す

## 結合テスト

- [x] `run`：`add`で追加した支出を知らせる
- [x] `run`：`add`で追加した支出を，`list`で表示する(`add`を2回に分けても，すべて表示する)
- [x] `run`：`add`で追加した支出の費目ごとの小計を，`summary`で表示する
- [x] `run`：データファイルがなければ，支出がないことを表示する
- [x] `run`：`add`の支出に誤りがあれば，エラーメッセージを返し，何も追加しない
- [x] `run`：データファイルに読めない行があれば，ファイル名と行番号を示すエラーメッセージを返す
- [x] `run`：知らないサブコマンドなら，使い方を返す
- [x] 引数で支出を渡していた前の`run`の結合テストを消す(表示の規則は`listReport`・`summaryReport`の単体テストに移した)

## 手で確かめること

- [x] `KAKEIBO_FILE`で指定したファイルに保存され，指定がなければ`kakeibo.tsv`に保存される
- [x] エラーメッセージが標準エラー出力に表示され，終了コードが1になる
