# kakeibo-solution-iteration0(解答例)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 0の解答例パッケージ．
演習用パッケージ[../exercise/](../exercise/)を完成させた状態である．

## このIterationで作ったもの

コマンドライン引数に並べた金額の合計を表示する．

```console
$ cabal run kakeibo-solution-iteration0 -- 1200 350 800
合計: 2350円
```

## ディレクトリ構成

```
kakeibo-solution-iteration0.cabal  パッケージの定義
app/Main.hs                        実行ファイルの入口
src/Kakeibo/Money.hs               金額の計算と表示(total，formatYen)
src/Kakeibo/App.hs                 引数から表示する行を作る(run)
test/unit/Kakeibo/MoneySpec.hs     Kakeibo.Moneyの単体テスト
test/integration/Kakeibo/AppSpec.hs  runの結合テスト
TESTLIST.md                        テストリストの模範解答
docs/iteration-0.md                演習の各手順の解説
```

## 資料

- [演習の各手順の解説](docs/iteration-0.md)
- [Iteration 0で使う文法・概念](../../../docs/haskell/iteration-0.md)
