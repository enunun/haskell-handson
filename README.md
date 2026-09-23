# haskell-handson

Haskellを初めて学ぶ人向けのハンズオン教材．
他の言語でプログラミングをした経験があれば，Haskellの予備知識は要らない．

## 構成

Iterationごとに，演習用(exercise)と解答例(solution)の2つのcabalパッケージを置く．
すべてのパッケージは，リポジトリ直下の`cabal.project`で1つのプロジェクトにまとめる．

```
iterations/iteration-N/
  exercise/    演習用パッケージ．ここに実装とテストを書き足していく．
  solution/    解答例パッケージ．詰まったときや，書き終えたあとの答え合わせに使う．
docs/          Haskellの文法・概念のリファレンスなど，Iterationをまたいで参照する資料．
cabal.project  全パッケージをまとめるcabalプロジェクト．
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

cabalが取得したパッケージ一覧とビルド済みの依存パッケージは，Dockerのボリュームに置く．
そのため，コンテナを作り直しても依存パッケージのビルドはやり直さずに済む．

## コマンド

コマンドはリポジトリ直下で実行する．

```sh
mise run test    # すべてのパッケージのテストを実行する
mise run fmt     # Haskellのコードを整形する
mise run lint    # 整形の検査とhlintを実行する
mise run check   # lintとtestをまとめて実行する(コミット前の確認用)
```

個別のパッケージを扱うときは，cabalを直接使う．

```sh
cabal test <パッケージ名>   # 1つのパッケージのテストを実行する
cabal repl <パッケージ名>   # パッケージを読み込んだ状態でGHCi(対話環境)を起動する
```

コミット時には，[lefthook](https://lefthook.dev/)がステージしたHaskellのファイルにormoluとhlintをかける．
