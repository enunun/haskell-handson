# テストリスト(Iteration 5・解答例)

## 単体テスト

- [x] `Yen`：`<>`で金額を足し合わせる
- [x] `Yen`：`mempty`は0円
- [x] `display`(`Yen`)：`formatYen`の6つのテストを`display (Yen …)`のテストに書き換える
- [x] `total`：3つのテストの引数と期待値を`Yen`に書き換える
- [x] `parseAmount`・`parseEntry`・`parseEntries`：期待値の金額を`Yen`に書き換える
- [x] `summarize`：引数と期待値の金額を`Yen`に書き換える
- [x] `display`(`Category`)：`categoryName`のテストを書き換える
- [x] `display`(`Entry`)：`formatEntry`のテストを書き換える
- [x] `summarize`：小計の大きい順に並べる(既存の「費目の定義順に並べる」のテストを書き換える)
- [x] `summarize`：小計が同じなら，費目の定義順に並べる

## 結合テスト

- [x] `run`：費目別の小計は，金額の大きい順に表示する
- [x] `run`：既存のテストは書き換えずに通る(表示は変わらない)
