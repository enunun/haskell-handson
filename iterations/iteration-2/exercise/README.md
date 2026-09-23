# kakeibo-iteration2(演習用)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 2の演習用パッケージ．
Iteration 1の解答例と同じコードから始まる．

## このIterationで作るもの

支出を`費目:金額`の形で入力し，1件ずつ明細を表示してから合計を表示する．

```console
$ cabal run kakeibo-iteration2 -- 食費:1200 交通費:350
食費 1,200円
交通費 350円
合計: 1,550円
```

作りながら，`data`による型の定義，レコード，`deriving`，`case`式，タプルを学ぶ．

## 進め方

1. [docs/iteration-2.md](docs/iteration-2.md)を読み，演習2-1から順に進める．
2. テストリストは[TESTLIST.md](TESTLIST.md)に書く．
3. 詰まったら，解答例[../solution/](../solution/)の同じ番号の解説(`../solution/docs/iteration-2.md`)を読む．

コマンドはリポジトリ直下で実行する．

## ディレクトリ構成

```
kakeibo-iteration2.cabal             パッケージの定義
app/Main.hs                          実行ファイルの入口
src/Kakeibo/Money.hs                 金額の計算と表示(total，formatYen)
src/Kakeibo/App.hs                   引数から表示する行を作る(run)
test/unit/Kakeibo/MoneySpec.hs       Kakeibo.Moneyの単体テスト
test/integration/Kakeibo/AppSpec.hs  runの結合テスト
TESTLIST.md                          テストリスト(自分で書く)
docs/iteration-2.md                  演習の手順
```

このIterationで，`src/Kakeibo/Entry.hs`と`test/unit/Kakeibo/EntrySpec.hs`を自分で作る．

## 資料

- [Iteration 2で使う文法・概念](../../../docs/haskell/iteration-2.md)
- [テスト駆動開発とテストリスト](../../../docs/tdd.md)
- [cabal](../../../docs/cabal.md)
