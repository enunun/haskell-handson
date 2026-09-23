# kakeibo-solution-iteration7(解答例)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 7の解答例パッケージ．
演習用パッケージ[../exercise/](../exercise/)を完成させた状態である．

## このIterationで作ったもの

支出に日付を付けて記録し，一覧と集計を月で絞り込めるようにした．
`Maybe`・`Either`を返す関数の組み合わせは，`<$>`・`<*>`・`do`記法・`traverse`で書いている．

```console
$ export KAKEIBO_FILE=/tmp/kakeibo7.tsv
$ cabal run -v0 kakeibo-solution-iteration7 -- add 2026-09-01 食費:1200
追加しました: 2026-09-01 食費 1,200円
$ cabal run -v0 kakeibo-solution-iteration7 -- add 2026-10-03 交通費:350
追加しました: 2026-10-03 交通費 350円
$ cabal run -v0 kakeibo-solution-iteration7 -- list 2026-09
2026-09-01 食費 1,200円
合計: 1,200円
```

## ディレクトリ構成

```
kakeibo-solution-iteration7.cabal    パッケージの定義
app/Main.hs                          実行ファイルの入口(環境変数，エラーの表示と終了コード)
src/Kakeibo/Display.hs               表示のための型クラスDisplay
src/Kakeibo/Money.hs                 金額の型Yenと合計(total)
src/Kakeibo/Date.hs                  日付と年月
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
docs/iteration-7.md                  演習の各手順の解説
```

## 資料

- [演習の各手順の解説](docs/iteration-7.md)
- [Iteration 7で使う文法・概念](../../../docs/haskell/iteration-7.md)
