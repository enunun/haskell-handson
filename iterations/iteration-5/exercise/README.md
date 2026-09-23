# kakeibo-iteration5(演習用)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 5の演習用パッケージ．
Iteration 4の解答例と同じコードから始まる．

## このIterationで作るもの

費目ごとの小計を，金額の大きい順に表示する．
あわせて，金額を表す型`Yen`と，表示のための型クラス`Display`を作り，コード全体をそれらを使う形に書き直す．

```console
$ cabal run kakeibo-iteration5 -- 食費:350 交通費:1200 800
食費 350円
交通費 1,200円
その他 800円
費目別:
  交通費 1,200円
  その他 800円
  食費 350円
合計: 2,350円
```

作りながら，型クラス，`newtype`，`Semigroup`・`Monoid`，並べ替え，`Data.Map`を学ぶ．

## 進め方

1. [docs/iteration-5.md](docs/iteration-5.md)を読み，演習5-1から順に進める．
2. テストリストは[TESTLIST.md](TESTLIST.md)に書く．
3. 詰まったら，解答例[../solution/](../solution/)の同じ番号の解説(`../solution/docs/iteration-5.md`)を読む．

コマンドはリポジトリ直下で実行する．

## ディレクトリ構成

```
kakeibo-iteration5.cabal             パッケージの定義
app/Main.hs                          実行ファイルの入口
src/Kakeibo/Money.hs                 金額の計算と表示(total，formatYen)
src/Kakeibo/Entry.hs                 費目と支出の型，読み取りと表示
src/Kakeibo/Summary.hs               費目ごとの集計(summarize)
src/Kakeibo/App.hs                   引数から表示する行を作る(run)
test/unit/Kakeibo/MoneySpec.hs       Kakeibo.Moneyの単体テスト
test/unit/Kakeibo/EntrySpec.hs       Kakeibo.Entryの単体テスト
test/unit/Kakeibo/SummarySpec.hs     Kakeibo.Summaryの単体テスト
test/integration/Kakeibo/AppSpec.hs  runの結合テスト
TESTLIST.md                          テストリスト(自分で書く)
design/                              設計書(C4モデルの4つの階層．自分で更新する)
docs/iteration-5.md                  演習の手順
```

このIterationで，`src/Kakeibo/Display.hs`を自分で作る．

## 資料

- [Iteration 5で使う文法・概念](../../../docs/haskell/iteration-5.md)
- [テスト駆動開発とテストリスト](../../../docs/tdd.md)
- [設計書の書き方](../../../docs/design.md)
- [cabal](../../../docs/cabal.md)
