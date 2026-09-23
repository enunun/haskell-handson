# kakeibo-solution-iteration2(解答例)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 2の解答例パッケージ．
演習用パッケージ[../exercise/](../exercise/)を完成させた状態である．

## このIterationで作ったもの

支出を`費目:金額`の形で入力し，1件ずつ明細を表示してから合計を表示する．

```console
$ cabal run kakeibo-solution-iteration2 -- 食費:1200 交通費:350
食費 1,200円
交通費 350円
合計: 1,550円
```

## ディレクトリ構成

```
kakeibo-solution-iteration2.cabal    パッケージの定義
app/Main.hs                          実行ファイルの入口
src/Kakeibo/Money.hs                 金額の計算と表示(total，formatYen)
src/Kakeibo/Entry.hs                 費目と支出の型，読み取りと表示
src/Kakeibo/App.hs                   引数から表示する行を作る(run)
test/unit/Kakeibo/MoneySpec.hs       Kakeibo.Moneyの単体テスト
test/unit/Kakeibo/EntrySpec.hs       Kakeibo.Entryの単体テスト
test/integration/Kakeibo/AppSpec.hs  runの結合テスト
TESTLIST.md                          テストリストの模範解答
docs/iteration-2.md                  演習の各手順の解説
```

## 資料

- [演習の各手順の解説](docs/iteration-2.md)
- [Iteration 2で使う文法・概念](../../../docs/haskell/iteration-2.md)
