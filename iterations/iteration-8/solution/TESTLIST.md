# テストリスト(Iteration 8・解答例)

## 単体テスト

- [x] `Yen`：`<>`は，まとめる順番によらない(結合法則)
- [x] `Yen`：`mempty`は，`<>`の相手を変えない(単位元)
- [x] `total`：中の数の和になる
- [x] `display`(`Yen`)：0以上の金額からカンマを除くと，数字の後ろに「円」を付けたものになる
- [x] `display`(`Yen`)：0以上の金額には，桁数に応じた数のカンマが入る
- [x] `parseCategory`：費目の名前を読むと，元の費目に戻る
- [x] `parseAmount`：正の整数は読める
- [x] `parseAmount`：0以下の整数は読めない
- [x] `parseDate`：表示した日付を読むと，元の日付に戻る
- [x] `inMonth`：日付は，その日付の年月に含まれる
- [x] `decodeEntry`：`encodeEntry`した行を読むと，元の支出に戻る
- [x] `decodeEntries`：支出の並びを書いた中身を読むと，元の並びに戻る
- [x] `summarize`：小計の和は，すべての支出の合計に等しい
- [x] `summarize`：同じ費目は1度しか現れない
- [x] `summarize`：小計は，大きい順に並ぶ
- [x] `parseCommand`：支出を表す引数を`add`で読むと，元の支出になる

## 結合テスト

- [x] `run`：`add`した支出の合計が，`list`の最後の行に表示される
