# kakeibo-solution-iteration8(解答例)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 8の解答例パッケージ．
演習用パッケージ[../exercise/](../exercise/)を完成させた状態であり，このハンズオンで作る`kakeibo`の完成形である．

## このIterationで作ったもの

これまでに作った関数が満たすべき性質を，QuickCheckでランダムに作った入力を使って確かめるテストを足した．
ライブラリと実行ファイルのコードは，Iteration 7の解答例と同じである．

```console
$ export KAKEIBO_FILE=/tmp/kakeibo.tsv
$ cabal run -v0 kakeibo-solution-iteration8 -- add 2026-09-01 食費:1200
追加しました: 2026-09-01 食費 1,200円
$ cabal run -v0 kakeibo-solution-iteration8 -- add 2026-09-03 交通費:350
追加しました: 2026-09-03 交通費 350円
$ cabal run -v0 kakeibo-solution-iteration8 -- list 2026-09
2026-09-01 食費 1,200円
2026-09-03 交通費 350円
合計: 1,550円
$ cabal run -v0 kakeibo-solution-iteration8 -- summary
食費 1,200円
交通費 350円
合計: 1,550円
```

## ディレクトリ構成

```
kakeibo-solution-iteration8.cabal    パッケージの定義
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
test/common/Kakeibo/Generators.hs    性質のテストで使うジェネレータ
test/unit/Kakeibo/*Spec.hs           各モジュールの単体テスト(例と性質)
test/integration/Kakeibo/AppSpec.hs  runの結合テスト(例と性質)
TESTLIST.md                          テストリストの模範解答
docs/iteration-8.md                  演習の各手順の解説
```

## 資料

- [演習の各手順の解説](docs/iteration-8.md)
- [Iteration 8で使う文法・概念](../../../docs/haskell/iteration-8.md)
