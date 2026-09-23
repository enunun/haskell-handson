# kakeibo-solution-iteration3(解答例)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 3の解答例パッケージ．
演習用パッケージ[../exercise/](../exercise/)を完成させた状態である．

## このIterationで作ったもの

明細と合計のあいだに，費目ごとの小計を表示する．
`total`は`foldr`で定義し直した．

```console
$ cabal run kakeibo-solution-iteration3 -- 食費:1200 交通費:350 食費:350
食費 1,200円
交通費 350円
食費 350円
費目別:
  食費 1,550円
  交通費 350円
合計: 1,900円
```

## ディレクトリ構成

```
kakeibo-solution-iteration3.cabal    パッケージの定義
app/Main.hs                          実行ファイルの入口
src/Kakeibo/Money.hs                 金額の計算と表示(total，formatYen)
src/Kakeibo/Entry.hs                 費目と支出の型，読み取りと表示
src/Kakeibo/Summary.hs               費目ごとの集計(summarize)
src/Kakeibo/App.hs                   引数から表示する行を作る(run)
test/unit/Kakeibo/MoneySpec.hs       Kakeibo.Moneyの単体テスト
test/unit/Kakeibo/EntrySpec.hs       Kakeibo.Entryの単体テスト
test/unit/Kakeibo/SummarySpec.hs     Kakeibo.Summaryの単体テスト
test/integration/Kakeibo/AppSpec.hs  runの結合テスト
TESTLIST.md                          テストリストの模範解答
design/                              設計書の模範解答(C4モデルの4つの階層)
docs/iteration-3.md                  演習の各手順の解説
```

## 資料

- [演習の各手順の解説](docs/iteration-3.md)
- [Iteration 3で使う文法・概念](../../../docs/haskell/iteration-3.md)
