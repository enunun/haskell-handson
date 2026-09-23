# kakeibo-iteration8(演習用)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 8の演習用パッケージ．
Iteration 7の解答例と同じコードから始まる．

## このIterationで作るもの

新しい機能は足さない．
これまでに作った関数が満たすべき性質を，QuickCheckでランダムに作った入力を使って確かめるテストを書く．

```console
$ cabal test kakeibo-iteration8:test:unit
…
  データファイルの読み書きの性質
    encodeEntryした行をdecodeEntryで読むと，元の支出に戻る [✔]
      +++ OK, passed 100 tests.
…
```

作りながら，プロパティベーステスト，QuickCheckのジェネレータ，性質の見つけ方を学ぶ．

## 進め方

1. [docs/iteration-8.md](docs/iteration-8.md)を読み，演習8-1から順に進める．
2. テストリストは[TESTLIST.md](TESTLIST.md)に書く．
3. 詰まったら，解答例[../solution/](../solution/)の同じ番号の解説(`../solution/docs/iteration-8.md`)を読む．

コマンドはリポジトリ直下で実行する．

## ディレクトリ構成

```
kakeibo-iteration8.cabal             パッケージの定義
app/Main.hs                          実行ファイルの入口(環境変数，エラーの表示と終了コード)
src/Kakeibo/*.hs                     ライブラリ(Iteration 7と同じ)
test/unit/Kakeibo/*Spec.hs           各モジュールの単体テスト
test/integration/Kakeibo/AppSpec.hs  runの結合テスト
TESTLIST.md                          テストリスト(自分で書く)
design/                              設計書(C4モデルの4つの階層．自分で更新する)
docs/iteration-8.md                  演習の手順
```

このIterationで，`test/common/Kakeibo/Generators.hs`を自分で作る．

## 資料

- [Iteration 8で使う文法・概念](../../../docs/haskell/iteration-8.md)
- [テスト駆動開発とテストリスト](../../../docs/tdd.md)
- [設計書の書き方](../../../docs/design.md)
- [cabal](../../../docs/cabal.md)
