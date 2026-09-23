# kakeibo-iteration1(演習用)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 1の演習用パッケージ．
Iteration 0の解答例と同じコードから始まる．

## このIterationで作るもの

金額を3桁ごとにカンマで区切って表示し，支出がないときはそのことを知らせる．

```console
$ cabal run kakeibo-iteration1 -- 1200 350 800
合計: 2,350円
$ cabal run kakeibo-iteration1
支出はありません
```

作りながら，パターンマッチ・再帰・ガード・`where`を学ぶ．

## 進め方

1. [docs/iteration-1.md](docs/iteration-1.md)を読み，演習1-1から順に進める．
2. テストリストは[TESTLIST.md](TESTLIST.md)に書く．
3. 詰まったら，解答例[../solution/](../solution/)の同じ番号の解説(`../solution/docs/iteration-1.md`)を読む．

コマンドはリポジトリ直下で実行する．

## ディレクトリ構成

```
kakeibo-iteration1.cabal             パッケージの定義
app/Main.hs                          実行ファイルの入口
src/Kakeibo/Money.hs                 金額の計算と表示(total，formatYen)
src/Kakeibo/App.hs                   引数から表示する行を作る(run)
test/unit/Kakeibo/MoneySpec.hs       Kakeibo.Moneyの単体テスト
test/integration/Kakeibo/AppSpec.hs  runの結合テスト
TESTLIST.md                          テストリスト(自分で書く)
design/                              設計書(C4モデルの4つの階層．自分で更新する)
docs/iteration-1.md                  演習の手順
```

## 資料

- [Iteration 1で使う文法・概念](../../../docs/haskell/iteration-1.md)
- [テスト駆動開発とテストリスト](../../../docs/tdd.md)
- [設計書の書き方](../../../docs/design.md)
- [cabal](../../../docs/cabal.md)
