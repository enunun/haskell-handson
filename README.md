# haskell-handson

Haskellを初めて学ぶ人向けのハンズオン教材．
他の言語でプログラミングをした経験があれば，Haskellの予備知識は要らない．

## このハンズオンで作るもの

コマンドラインで使う家計簿プログラム`kakeibo`を，Iteration 0から8までの9回に分けて少しずつ育てる．
最初は引数に並べた金額の合計を表示するだけのプログラムから始め，費目・集計・エラー処理・ファイルへの保存・日付を足していく．
完成すると，次のように使える．

```console
$ kakeibo add 2026-09-01 食費:1200
追加しました: 2026-09-01 食費 1,200円
$ kakeibo add 2026-09-03 交通費:350
追加しました: 2026-09-03 交通費 350円
$ kakeibo list 2026-09
2026-09-01 食費 1,200円
2026-09-03 交通費 350円
合計: 1,550円
$ kakeibo summary
食費 1,200円
交通費 350円
合計: 1,550円
```

作りながら，関数と型，パターンマッチ，データ型，高階関数，`Maybe`・`Either`，型クラス，`IO`，`Functor`・`Applicative`・`Monad`，プロパティベーステストまでを一通り学ぶ．

## 進め方

どの機能も，テスト駆動開発(TDD)で作る．
各Iterationの資料には仕様書がなく，「要求」と使い方の例だけが書いてある．
要求を読んで単体テストと結合テストのテストリストを自分で書き，1項目ずつテストを書いて失敗させ(Red)，実装して通す(Green)．

各Iterationは，次の順に進める．

1. 演習用パッケージ(`iterations/iteration-N/exercise`)を，自分で`cabal.project`に登録する．
2. 演習用パッケージの`docs/iteration-N.md`を読み，演習を順に進める．新しい文法は，[docs/haskell/](docs/haskell/)のそのIterationの資料で学ぶ．
3. テストリストを`TESTLIST.md`に書き，TDDで実装する．cabalのコマンドや`.cabal`ファイルの編集も自分で行う．
4. 詰まったとき，書き終えたときは，解答例パッケージ(`iterations/iteration-N/solution`)と，その`docs/iteration-N.md`(各手順の解説)を読む．

各Iterationの演習用パッケージは，1つ前のIterationの解答例と同じコードから始まる．
前のIterationを書き終えていなくても，次のIterationに進める．

| Iteration | 作る機能 | 学ぶ文法・概念 |
|---|---|---|
| [0](iterations/iteration-0/exercise/) | 引数に並べた金額の合計を表示する | 関数，型，リスト，モジュール，cabal，hspec |
| [1](iterations/iteration-1/exercise/) | 3桁区切りで表示する．支出がないことを知らせる | パターンマッチ，再帰，ガード，`where` |
| [2](iterations/iteration-2/exercise/) | 費目付きで入力し，明細を表示する | `data`(直和型・レコード)，`deriving`，`case`，タプル |
| [3](iterations/iteration-3/exercise/) | 費目ごとに集計する | 高階関数，ラムダ式，関数合成，セクション |
| [4](iterations/iteration-4/exercise/) | 入力の誤りをエラーメッセージで知らせる | `Maybe`，`Either`，全域関数 |
| [5](iterations/iteration-5/exercise/) | 費目ごとの小計を金額の大きい順に並べる | 型クラス，`newtype`，`Semigroup`・`Monoid`，`Data.Map` |
| [6](iterations/iteration-6/exercise/) | 支出をファイルに保存し，サブコマンドで操作する | `IO`，`do`記法，純粋な部分と副作用の分離 |
| [7](iterations/iteration-7/exercise/) | 日付を記録し，月で絞り込む | `Functor`・`Applicative`・`Monad`，`traverse` |
| [8](iterations/iteration-8/exercise/) | 性質をランダムな入力で確かめる | QuickCheck，プロパティベーステスト |

各Iterationの目的と内容は[docs/ROADMAP.md](docs/ROADMAP.md)にまとめている．

## 構成

Iterationごとに，演習用(exercise)と解答例(solution)の2つのcabalパッケージを置く．
パッケージは，リポジトリ直下の`cabal.project`で1つのプロジェクトにまとめる．
`cabal.project`には解答例のパッケージが登録してあり，演習用のパッケージは各Iterationの最初に自分で登録する．

```
iterations/iteration-N/
  exercise/        演習用パッケージ．ここに実装とテストを書き足していく．
    docs/iteration-N.md  演習の手順
    TESTLIST.md          テストリスト(自分で書く)
  solution/        解答例パッケージ．詰まったときや，書き終えたあとの答え合わせに使う．
    docs/iteration-N.md  演習の各手順の解説
    TESTLIST.md          テストリストの模範解答
docs/
  ROADMAP.md       各Iterationの目的と内容
  tdd.md           テスト駆動開発とテストリストの書き方
  cabal.md         cabalの使い方
  haskell/         Iterationごとの，Haskellの文法・概念の資料
cabal.project      パッケージをまとめるcabalプロジェクト
```

## 開発環境

VSCodeの[Dev Containers](https://containers.dev/)で開発する．

1. VSCodeに拡張機能「Dev Containers」(`ms-vscode-remote.remote-containers`)を入れる．
2. Dockerを起動した状態で，このリポジトリをVSCodeで開く．
3. コマンドパレットから「Dev Containers: Reopen in Container」を実行する．

コンテナには次のツールが入っている．

| ツール | 版 | 入れ方 |
|---|---|---|
| GHC(コンパイラ) | 9.10.3 | ghcup |
| cabal(ビルドツール) | 3.16.1.0 | ghcup |
| HLS(haskell-language-server) | 2.14.0.0 | ghcup |
| ghcup | 0.2.6.2 | mise |
| ormolu(フォーマッタ) | 0.8.1.1 | mise |
| hlint(リンタ) | 3.10 | mise |

ghcup本体と補助ツールは[mise](https://mise.jdx.dev/)で入れ，GHC・cabal・HLSはそのghcupで入れる．
版はすべて`mise.toml`で決めている(GHC・cabal・HLSは`[vars]`)．

VSCodeには公式のHaskell拡張(`haskell.haskell`)が入り，型の表示・エラー表示・補完が使える．
Haskellのファイルは保存時にormoluで整形される．
コンテナのロケールは`C.UTF-8`で，ソースコード・コマンドライン引数・入出力の日本語をそのまま扱える．

cabalが取得したパッケージ一覧とビルド済みの依存パッケージは，Dockerのボリュームに置く．
そのため，コンテナを作り直しても依存パッケージのビルドはやり直さずに済む．

## コマンド

コマンドはリポジトリ直下で実行する．

```sh
mise run test      # cabal.projectに登録したパッケージのテストを実行する
mise run fmt       # Haskellのコードを整形する
mise run lint      # 整形の検査とhlintを実行する
mise run test-all  # 演習用を含むすべてのパッケージのテストを実行する(教材の保守用)
mise run check     # lintとtest-allをまとめて実行する(教材を直したときの確認用)
```

個別のパッケージを扱うときは，cabalを直接使う．
使い方は[docs/cabal.md](docs/cabal.md)にまとめている．

```sh
cabal test <パッケージ名>   # 1つのパッケージのテストを実行する
cabal repl <パッケージ名>   # パッケージを読み込んだ状態でGHCi(対話環境)を起動する
cabal run <パッケージ名> -- <引数>…   # パッケージの実行ファイルを実行する
```

コミット時には，[lefthook](https://lefthook.dev/)がステージしたHaskellのファイルにormoluとhlintをかける．
