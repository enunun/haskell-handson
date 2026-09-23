# kakeibo-iteration3(演習用)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 3の演習用パッケージ．
Iteration 2の解答例と同じコードから始まる．

## このIterationで作るもの

明細と合計のあいだに，費目ごとの小計を表示する．

```console
$ cabal run kakeibo-iteration3 -- 食費:1200 交通費:350 食費:350
食費 1,200円
交通費 350円
食費 350円
費目別:
  食費 1,550円
  交通費 350円
合計: 1,900円
```

作りながら，高階関数(`map`・`filter`・`foldr`)，ラムダ式，部分適用，セクション，関数合成を学ぶ．

## 進め方

1. [docs/iteration-3.md](docs/iteration-3.md)を読み，演習3-1から順に進める．
2. テストリストは[TESTLIST.md](TESTLIST.md)に書く．
3. 詰まったら，解答例[../solution/](../solution/)の同じ番号の解説(`../solution/docs/iteration-3.md`)を読む．

コマンドはリポジトリ直下で実行する．

## ディレクトリ構成

```
kakeibo-iteration3.cabal             パッケージの定義
app/Main.hs                          実行ファイルの入口
src/Kakeibo/Money.hs                 金額の計算と表示(total，formatYen)
src/Kakeibo/Entry.hs                 費目と支出の型，読み取りと表示
src/Kakeibo/App.hs                   引数から表示する行を作る(run)
test/unit/Kakeibo/MoneySpec.hs       Kakeibo.Moneyの単体テスト
test/unit/Kakeibo/EntrySpec.hs       Kakeibo.Entryの単体テスト
test/integration/Kakeibo/AppSpec.hs  runの結合テスト
TESTLIST.md                          テストリスト(自分で書く)
design/                              設計書(C4モデルの4つの階層．自分で更新する)
docs/iteration-3.md                  演習の手順
```

このIterationで，`src/Kakeibo/Summary.hs`と`test/unit/Kakeibo/SummarySpec.hs`を自分で作る．

## 資料

- [Iteration 3で使う文法・概念](../../../docs/haskell/iteration-3.md)
- [テスト駆動開発とテストリスト](../../../docs/tdd.md)
- [設計書の書き方](../../../docs/design.md)
- [cabal](../../../docs/cabal.md)
