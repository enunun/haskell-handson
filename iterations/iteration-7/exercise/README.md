# kakeibo-iteration7(演習用)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 7の演習用パッケージ．
Iteration 6の解答例と同じコードから始まる．

## このIterationで作るもの

支出に日付を付けて記録し，一覧と集計を月で絞り込めるようにする．

```console
$ export KAKEIBO_FILE=/tmp/kakeibo7.tsv
$ cabal run -v0 kakeibo-iteration7 -- add 2026-09-01 食費:1200
追加しました: 2026-09-01 食費 1,200円
$ cabal run -v0 kakeibo-iteration7 -- add 2026-10-03 交通費:350
追加しました: 2026-10-03 交通費 350円
$ cabal run -v0 kakeibo-iteration7 -- list 2026-09
2026-09-01 食費 1,200円
合計: 1,200円
```

作りながら，`Functor`・`Applicative`・`Monad`と，`Maybe`・`Either`の`do`記法，`traverse`を学ぶ．

## 進め方

1. [docs/iteration-7.md](docs/iteration-7.md)を読み，演習7-1から順に進める．
2. テストリストは[TESTLIST.md](TESTLIST.md)に書く．
3. 詰まったら，解答例[../solution/](../solution/)の同じ番号の解説(`../solution/docs/iteration-7.md`)を読む．

コマンドはリポジトリ直下で実行する．

## ディレクトリ構成

```
kakeibo-iteration7.cabal             パッケージの定義
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
test/integration/Kakeibo/AppSpec.hs  runの結合テスト
TESTLIST.md                          テストリスト(自分で書く)
docs/iteration-7.md                  演習の手順
```

このIterationで，`src/Kakeibo/Date.hs`と`test/unit/Kakeibo/DateSpec.hs`を自分で作る．

## 資料

- [Iteration 7で使う文法・概念](../../../docs/haskell/iteration-7.md)
- [テスト駆動開発とテストリスト](../../../docs/tdd.md)
- [cabal](../../../docs/cabal.md)
