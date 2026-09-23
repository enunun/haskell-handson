# kakeibo-solution-iteration6(解答例)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 6の解答例パッケージ．
演習用パッケージ[../exercise/](../exercise/)を完成させた状態である．

## このIterationで作ったもの

支出をデータファイルに保存し，サブコマンドで追加・一覧・集計をする．

```console
$ export KAKEIBO_FILE=/tmp/kakeibo.tsv
$ cabal run -v0 kakeibo-solution-iteration6 -- add 食費:1200 交通費:350
追加しました: 食費 1,200円
追加しました: 交通費 350円
$ cabal run -v0 kakeibo-solution-iteration6 -- list
食費 1,200円
交通費 350円
合計: 1,550円
$ cabal run -v0 kakeibo-solution-iteration6 -- summary
食費 1,200円
交通費 350円
合計: 1,550円
```

## ディレクトリ構成

```
kakeibo-solution-iteration6.cabal    パッケージの定義
app/Main.hs                          実行ファイルの入口(環境変数，エラーの表示と終了コード)
src/Kakeibo/Display.hs               表示のための型クラスDisplay
src/Kakeibo/Money.hs                 金額の型Yenと合計(total)
src/Kakeibo/Entry.hs                 費目と支出の型，読み取りと表示
src/Kakeibo/Summary.hs               費目ごとの集計(summarize)
src/Kakeibo/Report.hs                list・summaryで表示する行
src/Kakeibo/Storage.hs               データファイルの読み書き
src/Kakeibo/Command.hs               サブコマンドの読み取り
src/Kakeibo/App.hs                   サブコマンドの実行(run)
test/unit/Kakeibo/*Spec.hs           各モジュールの単体テスト
test/integration/Kakeibo/AppSpec.hs  runの結合テスト(一時ディレクトリのデータファイルを使う)
TESTLIST.md                          テストリストの模範解答
design/                              設計書の模範解答(C4モデルの4つの階層)
docs/iteration-6.md                  演習の各手順の解説
```

## 資料

- [演習の各手順の解説](docs/iteration-6.md)
- [Iteration 6で使う文法・概念](../../../docs/haskell/iteration-6.md)
