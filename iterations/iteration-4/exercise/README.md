# kakeibo-iteration4(演習用)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 4の演習用パッケージ．
Iteration 3の解答例と同じコードから始まる．

## このIterationで作るもの

金額が正の整数でない引数があれば，エラーメッセージを標準エラー出力に表示し，終了コード1で終わる．

```console
$ cabal run -v0 kakeibo-iteration4 -- 食費:1200 交通費:abc
金額は正の整数で書いてください: 交通費:abc
$ echo $?
1
```

作りながら，部分関数と全域関数の違い，`Maybe`と`Either`によるエラーの表し方を学ぶ．

## 進め方

1. [docs/iteration-4.md](docs/iteration-4.md)を読み，演習4-1から順に進める．
2. テストリストは[TESTLIST.md](TESTLIST.md)に書く．
3. 詰まったら，解答例[../solution/](../solution/)の同じ番号の解説(`../solution/docs/iteration-4.md`)を読む．

コマンドはリポジトリ直下で実行する．

## ディレクトリ構成

```
kakeibo-iteration4.cabal             パッケージの定義
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
docs/iteration-4.md                  演習の手順
```

## 資料

- [Iteration 4で使う文法・概念](../../../docs/haskell/iteration-4.md)
- [テスト駆動開発とテストリスト](../../../docs/tdd.md)
- [cabal](../../../docs/cabal.md)
