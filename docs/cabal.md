# cabal

cabalは，Haskellのビルドツールである．
依存するライブラリを取ってきてビルドし，自分のコードをコンパイルし，テストや実行ファイルを動かす．

## プロジェクト・パッケージ・コンポーネント

cabalで扱う単位は3つある．

| 単位 | 定義する場所 | このリポジトリでは |
|---|---|---|
| プロジェクト | `cabal.project` | リポジトリ全体．まとめてビルドするパッケージを`packages`に並べる． |
| パッケージ | `パッケージ名.cabal` | Iterationごとの演習用・解答例．パッケージ名は`.cabal`の`name`に書く． |
| コンポーネント | `.cabal`の中の各節 | ライブラリ(`library`)，実行ファイル(`executable`)，テストスイート(`test-suite`)． |

cabalのコマンドは，プロジェクトの`packages`に書いたパッケージしか扱えない．
エディタのHLS(型の表示やエラー表示をする仕組み)も，`packages`に書いたパッケージだけを解析する．
新しいパッケージで作業を始めるときは，まず`cabal.project`に追記する．

```cabal
packages:
  iterations/iteration-0/solution
  iterations/iteration-0/exercise
```

`packages`には，`.cabal`ファイルがあるディレクトリをリポジトリ直下からの相対パスで書く．
2行目以降は字下げをそろえる．
`--`から行末まではコメントである．

## `.cabal`ファイル

```cabal
cabal-version:   3.0
name:            kakeibo-iteration0
version:         0.1.0.0

library
    hs-source-dirs:   src
    exposed-modules:
        Kakeibo.App
        Kakeibo.Money
    build-depends:    base >=4.18 && <5
    default-language: GHC2021
    ghc-options:      -Wall

executable kakeibo
    hs-source-dirs:   app
    main-is:          Main.hs
    build-depends:
        base >=4.18 && <5,
        kakeibo-iteration0

test-suite unit
    type:               exitcode-stdio-1.0
    hs-source-dirs:     test/unit
    main-is:            Spec.hs
    other-modules:      Kakeibo.MoneySpec
    build-depends:
        base >=4.18 && <5,
        hspec,
        kakeibo-iteration0
    build-tool-depends: hspec-discover:hspec-discover
```

| 項目 | 意味 |
|---|---|
| `hs-source-dirs` | ソースファイルを置くディレクトリ．モジュール`Kakeibo.Money`は`src/Kakeibo/Money.hs`になる． |
| `exposed-modules` | ライブラリが外に公開するモジュール．ほかのコンポーネント(実行ファイルやテスト)から`import`できる． |
| `other-modules` | コンポーネントの中だけで使うモジュール．テストスイートのSpecファイルはここに書く． |
| `main-is` | `main`を定義したファイル． |
| `build-depends` | 依存するパッケージ．カンマで区切る．同じパッケージのライブラリを使うときも，パッケージ名を書く． |
| `build-tool-depends` | ビルドのときに使うプログラム．`hspec-discover`がこれにあたる． |
| `default-language` | 使うHaskellの言語仕様．`GHC2021`は，GHCでよく使う機能をまとめて有効にした版である． |
| `ghc-options` | コンパイラへの指示．`-Wall`は，使っていない変数や漏れのあるパターンマッチなどを警告させる． |

モジュールを新しく作ったら，そのファイルを置くコンポーネントの`exposed-modules`か`other-modules`に追記する．
`exposed-modules`にないモジュールはライブラリに含まれず，ほかのコンポーネントから`import`できない．
Specファイルを`other-modules`に書き忘れると，テストは動くが，cabalが警告を出す．

`build-depends`に書いたパッケージは，初めてビルドするときにHackage(Haskellのパッケージの公開場所)から取ってきてビルドされる．
`base`はPreludeなどを含む標準のパッケージで，どのコンポーネントにも必要である．

## コマンド

コマンドはリポジトリ直下(`cabal.project`がある場所)で実行する．
`<ターゲット>`には，パッケージ名かコンポーネントを書く．

| コマンド | 意味 |
|---|---|
| `cabal build <ターゲット>` | ビルドする． |
| `cabal test <ターゲット>` | テストスイートをビルドして実行する． |
| `cabal run <ターゲット> -- <引数>…` | 実行ファイルをビルドして実行する．`--`より後ろが，プログラムに渡すコマンドライン引数になる． |
| `cabal repl <ターゲット>` | ターゲットを読み込んだ状態でGHCiを起動する． |
| `cabal clean` | ビルドの結果(`dist-newstyle`)を消す． |

ターゲットは次のように書く．

| 書き方 | 意味 | 例 |
|---|---|---|
| `パッケージ名` | パッケージの全コンポーネント(`cabal test`ならテストスイートすべて) | `kakeibo-iteration0` |
| `パッケージ名:test:名前` | テストスイート1つ | `kakeibo-iteration0:test:unit` |
| `パッケージ名:exe:名前` | 実行ファイル1つ | `kakeibo-iteration0:exe:kakeibo` |
| `all` | プロジェクトの全パッケージ | `all` |

`cabal run`にパッケージ名だけを渡すと，そのパッケージの実行ファイルが1つしかなければ，それが実行される．

`.cabal`ファイルを編集した直後に，`Ambiguous target`というエラーでターゲットを選べなくなることがある．
そのときは`cabal clean`を実行してからやり直す．
