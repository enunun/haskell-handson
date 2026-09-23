# kakeibo-iteration0(演習用)

家計簿プログラム`kakeibo`を育てるハンズオンの，Iteration 0の演習用パッケージ．

## このIterationで作るもの

コマンドライン引数に並べた金額の合計を表示する，`kakeibo`の最初の版．

```console
$ cabal run kakeibo-iteration0 -- 1200 350 800
合計: 2350円
```

作りながら，Haskellの式・型・関数・モジュールと，cabalでのビルド・テスト，hspecでのテストの書き方を学ぶ．

## 進め方

1. [docs/iteration-0.md](docs/iteration-0.md)を読み，演習0-1から順に進める．
2. テストリストは[TESTLIST.md](TESTLIST.md)に書く．
3. 詰まったら，解答例[../solution/](../solution/)の同じ番号の解説(`../solution/docs/iteration-0.md`)を読む．

コマンドはリポジトリ直下で実行する．

## ディレクトリ構成

```
kakeibo-iteration0.cabal  パッケージの定義
app/Main.hs               実行ファイルの入口(コマンドライン引数を読み，結果を表示する)
src/Kakeibo/Money.hs      金額の計算と表示(total，formatYenを実装する)
src/Kakeibo/App.hs        引数から表示する行を作る(runを実装する)
test/unit/                単体テスト(Specファイルを自分で作る)
test/integration/         結合テスト(Specファイルを自分で作る)
TESTLIST.md               テストリスト(自分で書く)
docs/iteration-0.md       演習の手順
```

## 資料

- [Iteration 0で使う文法・概念](../../../docs/haskell/iteration-0.md)
- [テスト駆動開発とテストリスト](../../../docs/tdd.md)
- [cabal](../../../docs/cabal.md)
