# kakeibo-solution-iteration5(解答例)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 5の解答例パッケージ．
演習用パッケージ[../exercise/](../exercise/)を完成させた状態である．

## このIterationで作ったもの

費目ごとの小計を，金額の大きい順に表示する．
金額を`newtype Yen`で表し，表示の関数を型クラス`Display`のインスタンスにまとめた．

```console
$ cabal run kakeibo-solution-iteration5 -- 食費:350 交通費:1200 800
食費 350円
交通費 1,200円
その他 800円
費目別:
  交通費 1,200円
  その他 800円
  食費 350円
合計: 2,350円
```

## ディレクトリ構成

```
kakeibo-solution-iteration5.cabal    パッケージの定義
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
TESTLIST.md                          テストリストの模範解答
docs/iteration-5.md                  演習の各手順の解説
```

## 資料

- [演習の各手順の解説](docs/iteration-5.md)
- [Iteration 5で使う文法・概念](../../../docs/haskell/iteration-5.md)
