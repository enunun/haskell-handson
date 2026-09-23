# kakeibo-solution-iteration4(解答例)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 4の解答例パッケージ．
演習用パッケージ[../exercise/](../exercise/)を完成させた状態である．

## このIterationで作ったもの

金額が正の整数でない引数があれば，エラーメッセージを標準エラー出力に表示し，終了コード1で終わる．

```console
$ cabal run -v0 kakeibo-solution-iteration4 -- 食費:1200 交通費:abc
金額は正の整数で書いてください: 交通費:abc
$ echo $?
1
```

## ディレクトリ構成

```
kakeibo-solution-iteration4.cabal    パッケージの定義
app/Main.hs                          実行ファイルの入口(エラーの表示と終了コード)
src/Kakeibo/Money.hs                 金額の計算と表示(total，formatYen)
src/Kakeibo/Entry.hs                 費目と支出の型，読み取りと表示
src/Kakeibo/Summary.hs               費目ごとの集計(summarize)
src/Kakeibo/App.hs                   引数から表示する行を作る(run)
test/unit/Kakeibo/MoneySpec.hs       Kakeibo.Moneyの単体テスト
test/unit/Kakeibo/EntrySpec.hs       Kakeibo.Entryの単体テスト
test/unit/Kakeibo/SummarySpec.hs     Kakeibo.Summaryの単体テスト
test/integration/Kakeibo/AppSpec.hs  runの結合テスト
TESTLIST.md                          テストリストの模範解答
docs/iteration-4.md                  演習の各手順の解説
```

## 資料

- [演習の各手順の解説](docs/iteration-4.md)
- [Iteration 4で使う文法・概念](../../../docs/haskell/iteration-4.md)
