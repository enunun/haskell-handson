# kakeibo-iteration6(演習用)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 6の演習用パッケージ．
Iteration 5の解答例と同じコードから始まる．

## このIterationで作るもの

支出をデータファイルに保存し，サブコマンドで追加・一覧・集計をする．

```console
$ export KAKEIBO_FILE=/tmp/kakeibo.tsv
$ cabal run -v0 kakeibo-iteration6 -- add 食費:1200 交通費:350
追加しました: 食費 1,200円
追加しました: 交通費 350円
$ cabal run -v0 kakeibo-iteration6 -- list
食費 1,200円
交通費 350円
合計: 1,550円
$ cabal run -v0 kakeibo-iteration6 -- summary
食費 1,200円
交通費 350円
合計: 1,550円
```

作りながら，`IO`と`do`記法，ファイルの読み書き，純粋な関数と副作用のある処理の分け方を学ぶ．

## 進め方

1. [docs/iteration-6.md](docs/iteration-6.md)を読み，演習6-1から順に進める．
2. テストリストは[TESTLIST.md](TESTLIST.md)に書く．
3. 詰まったら，解答例[../solution/](../solution/)の同じ番号の解説(`../solution/docs/iteration-6.md`)を読む．

コマンドはリポジトリ直下で実行する．

## ディレクトリ構成

```
kakeibo-iteration6.cabal             パッケージの定義
app/Main.hs                          実行ファイルの入口
src/Kakeibo/Display.hs               表示のための型クラスDisplay
src/Kakeibo/Money.hs                 金額の型Yenと合計(total)
src/Kakeibo/Entry.hs                 費目と支出の型，読み取りと表示
src/Kakeibo/Summary.hs               費目ごとの集計(summarize)
src/Kakeibo/App.hs                   引数から表示する行を作る(run)
test/unit/Kakeibo/MoneySpec.hs       Kakeibo.Moneyの単体テスト
test/unit/Kakeibo/EntrySpec.hs       Kakeibo.Entryの単体テスト
test/unit/Kakeibo/SummarySpec.hs     Kakeibo.Summaryの単体テスト
test/integration/Kakeibo/AppSpec.hs  runの結合テスト
TESTLIST.md                          テストリスト(自分で書く)
design/                              設計書(C4モデルの4つの階層．自分で更新する)
docs/iteration-6.md                  演習の手順
```

このIterationで，`src/Kakeibo/`に`Command.hs`・`Report.hs`・`Storage.hs`と，それぞれの単体テストを自分で作る．

## 資料

- [Iteration 6で使う文法・概念](../../../docs/haskell/iteration-6.md)
- [テスト駆動開発とテストリスト](../../../docs/tdd.md)
- [設計書の書き方](../../../docs/design.md)
- [cabal](../../../docs/cabal.md)
