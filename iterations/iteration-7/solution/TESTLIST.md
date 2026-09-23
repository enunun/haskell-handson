# テストリスト(Iteration 7・解答例)

## 書き直し(テストは足さない)

- [x] `parseAmount`・`parseEntries`・`parseCommand`・`decodeEntry`・`decodeEntries`・`loadEntries`・`run`の`case`を，`<$>`・`<*>`・`do`記法・`traverse`などで書き直しても，既存のテストがすべて通る

## 単体テスト

- [x] `parseDate`：YYYY-MM-DDの形の日付を読み取る
- [x] `parseDate`：区切りが`-`でなければ`Nothing`
- [x] `parseDate`：月と日が2桁でなければ`Nothing`
- [x] `parseDate`：数でなければ`Nothing`
- [x] `parseDate`：13月は`Nothing`
- [x] `parseDate`：その月にない日(4月31日)は`Nothing`
- [x] `parseDate`：うるう年の2月29日を読み取る
- [x] `parseDate`：うるう年でない年の2月29日は`Nothing`
- [x] `display`(`Date`)：月と日を2桁にして表示する
- [x] `display`(`Date`)：2桁の月と日はそのまま表示する
- [x] `parseYearMonth`：YYYY-MMの形の年月を読み取る
- [x] `parseYearMonth`：月が2桁でなければ`Nothing`
- [x] `parseYearMonth`：13月は`Nothing`
- [x] `inMonth`：同じ年月の日付なら`True`
- [x] `inMonth`：月が違えば`False`
- [x] `inMonth`：年が違えば`False`
- [x] `parseEntry`・`parseEntries`：日付を受け取り，その日の支出として読み取る(既存のテストを書き換える)
- [x] `display`(`Entry`)：日付と費目と金額を空白で区切って表示する(既存のテストを書き換える)
- [x] `summarize`・`listReport`・`summaryReport`：支出に日付を付ける(既存のテストを書き換える)
- [x] `encodeEntry`：日付と費目の名前と金額をタブで区切る(既存のテストを書き換える)
- [x] `decodeEntry`：日付と費目の名前と金額をタブで区切った行を読み取る(既存のテストを書き換える)
- [x] `decodeEntry`：項目が3つでなければ`Nothing`
- [x] `decodeEntry`：日付が読み取れなければ`Nothing`
- [x] `decodeEntries`：既存のテストのデータに日付を足す
- [x] `parseCommand`：`add`の後ろの日付と支出を読み取る(既存のテストを書き換える)
- [x] `parseCommand`：`add`の後ろの日付が読み取れなければ，エラーメッセージを返す
- [x] `parseCommand`：`list`・`summary`の後ろの年月を読み取る
- [x] `parseCommand`：`list`の後ろの年月が読み取れなければ，エラーメッセージを返す
- [x] `parseCommand`：`list`の後ろに年月より多くの引数があれば，使い方を返す

## 結合テスト

- [x] `run`：既存のテストの`add`に日付を足し，表示に日付を足す
- [x] `run`：`list`に年月を指定すると，その月の支出だけを表示する(前後の月の境目の支出を含める)
- [x] `run`：`summary`に年月を指定すると，その月の支出だけを集計する
- [x] `run`：指定した年月に支出がなければ，支出がないことを表示する

## 手で確かめること

- [x] ROADMAPの完成例どおりに動く
