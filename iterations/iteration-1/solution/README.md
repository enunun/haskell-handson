# kakeibo-solution-iteration1(解答例)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 1の解答例パッケージ．
演習用パッケージ[../exercise/](../exercise/)を完成させた状態である．

## このIterationで作ったもの

金額を3桁ごとにカンマで区切って表示し，支出がないときはそのことを知らせる．
`total`は再帰で定義し直した．

```console
$ cabal run kakeibo-solution-iteration1 -- 1200 350 800
合計: 2,350円
$ cabal run kakeibo-solution-iteration1
支出はありません
```

## ディレクトリ構成

```
kakeibo-solution-iteration1.cabal    パッケージの定義
app/Main.hs                          実行ファイルの入口
src/Kakeibo/Money.hs                 金額の計算と表示(total，formatYen)
src/Kakeibo/App.hs                   引数から表示する行を作る(run)
test/unit/Kakeibo/MoneySpec.hs       Kakeibo.Moneyの単体テスト
test/integration/Kakeibo/AppSpec.hs  runの結合テスト
TESTLIST.md                          テストリストの模範解答
design/                              設計書の模範解答(C4モデルの4つの階層)
docs/iteration-1.md                  演習の各手順の解説
```

## 資料

- [演習の各手順の解説](docs/iteration-1.md)
- [Iteration 1で使う文法・概念](../../../docs/haskell/iteration-1.md)
