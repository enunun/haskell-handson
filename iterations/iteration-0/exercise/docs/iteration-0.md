# Iteration 0：合計を表示する(演習)

## このIterationで作るもの

家計簿プログラム`kakeibo`の最初の版を作る．
コマンドライン引数に支出の金額を並べると，その合計を表示する．

```console
$ cabal run kakeibo-iteration0 -- 1200 350 800
合計: 2350円
```

作りながら，Haskellの関数と型，cabalでのビルドとテスト，hspecでのテストの書き方，mermaidでの設計書の書き方を学ぶ．
このハンズオンでは，Iterationを重ねるごとに，このプログラムに費目・集計・エラー処理・ファイルへの保存・日付などを足していく．

## 進め方

演習0-1から順に進める．
詰まったら，`../solution/docs/iteration-0.md`の同じ番号の節を読む．
コマンドはすべてリポジトリ直下(`cabal.project`がある場所)で実行する．

## 演習0-1：パッケージを登録してビルドする

このパッケージ(`kakeibo-iteration0`)は，まだcabalのプロジェクトに登録されていない．
登録して，ビルド・テスト・実行ができることを確かめる．
cabalのプロジェクトとパッケージについては[cabal](../../../../docs/cabal.md)を参照する．

1. リポジトリ直下の`cabal.project`を開き，`packages`の最後の行の下に，このパッケージのディレクトリを追記する．

   ```cabal
   packages:
     iterations/iteration-0/solution
     iterations/iteration-0/exercise
   ```

2. `src/Kakeibo/Money.hs`をVSCodeで開き，`total`の上にマウスカーソルを置く．型が表示されることを確かめる．表示されないときは，コマンドパレットから「Haskell: Restart Haskell LSP Server」を実行する．
3. パッケージをビルドする．初回は依存するライブラリ(hspecなど)のビルドも行うので時間がかかる．

   ```sh
   cabal build kakeibo-iteration0
   ```

4. テストを実行する．単体テスト(`unit`)と結合テスト(`integration`)の2つのテストスイートが実行され，どちらも`0 examples, 0 failures`と表示される．テストはまだ1つもない．

   ```sh
   cabal test kakeibo-iteration0
   ```

5. プログラムを実行する．`--`より後ろが，プログラムに渡すコマンドライン引数になる．

   ```sh
   cabal run kakeibo-iteration0 -- 1200 350 800
   ```

   `TODO: 「合計: 〜円」という1行だけのリストを返す`と表示されて止まる．
   メッセージの`error, called at`の行から，どのファイルの何行目で止まったかを読み取る．

## 演習0-2：GHCiで式を試す

[Iteration 0で使う文法・概念](../../../../docs/haskell/iteration-0.md)を読む．
読みながら，GHCiで例を試す．

```sh
cabal repl kakeibo-iteration0
```

読み終えたら，GHCiで次を試す．

1. `sum [1200, 350, 800]`と`show 2350 ++ "円"`を評価する．2つ目の結果の`円`がどう表示されるかを確かめ，`putStrLn (show 2350 ++ "円")`の表示と比べる．
2. `import Kakeibo.Money`と入力してから，`:t total`と`:t formatYen`で型を表示する．`src/Kakeibo/Money.hs`の型シグネチャと同じであることを確かめる．
3. `total [1200, 350]`を評価する．演習0-1の実行と同じく，`TODO`のメッセージが表示される．
4. `map read ["1200", "350"] :: [Int]`と`read "abc" :: Int`を評価し，結果を比べる．
5. `show 1 + 2`がエラーになる理由と，`show (1 + 2)`が`"3"`になる理由を説明する．

## 演習0-3：テストリストを書く

[テスト駆動開発とテストリスト](../../../../docs/tdd.md)を読む．
次の要求を読み，[TESTLIST.md](../TESTLIST.md)にテストリストを書く．

### 要求

- コマンドライン引数に，支出の金額(整数)を並べて渡す．
- 金額の合計を，`合計: 〜円`という1行で表示する．
- 引数がないときは，合計を0円として表示する．

このIterationでは，引数はすべて整数として読める前提でよい．
数として読めない引数の扱いは，Iteration 4で決める．

### 使い方の例

```console
$ kakeibo 1200 350 800
合計: 2350円
$ kakeibo
合計: 0円
```

### 作るもの

型シグネチャは，`src/`のファイルにすでに書いてある．

| モジュール | 関数 | 役割 |
|---|---|---|
| `Kakeibo.Money` | `total :: [Int] -> Int` | 金額のリストの合計を求める． |
| `Kakeibo.Money` | `formatYen :: Int -> String` | 金額を`1200円`のような文字列にする． |
| `Kakeibo.App` | `run :: [String] -> [String]` | コマンドライン引数を受け取り，表示する行のリストを返す． |

`app/Main.hs`の`main`は，コマンドライン引数を`run`に渡し，返ってきた行を1行ずつ表示する．
`main`はすでにできているので，変更しなくてよい．

### 考えること

- `total`と`formatYen`は単体テストで，`run`は結合テストで確かめる．
- 関数ごとに，どんな入力を試せば「正しく動く」と言えるかを考える．要素が0個・1個・複数個のリストは，それぞれ試す価値があるか．
- `total`で確かめた場合分けを，`run`の結合テストでもすべて確かめる必要はあるか．

## 演習0-4：設計書を書く

[設計書の書き方](../../../../docs/design.md)を読み，このパッケージの`design/`に設計書を書く．
`design/`には，C4モデルの4つの階層のファイルが，見出しだけの状態で置いてある．
演習0-3で書いたテストリストの振る舞いを，どんな部品で実現するかを図にする．

1. `01-context.md`：利用者と`kakeibo`の関係を`C4Context`の図で描く．
2. `02-container.md`：`kakeibo`を構成するもの(このIterationでは実行ファイル1つ)を`C4Container`の図で描く．
3. `03-component.md`：実行ファイルの中のモジュール(`Main`・`Kakeibo.App`・`Kakeibo.Money`)と依存関係を`C4Component`の図で描く．`IO`を行うモジュールと純粋なモジュールを，別の境界に入れる．
4. `04-code.md`：次の2つを描く．
   - 型と関数の流れ：コマンドライン引数(`[String]`)から表示する行(`[String]`)まで，どの型をどの関数で変換していくか．関数の型の表も書く．
   - `IO`の順序：`main`が`getArgs`で引数を読み，`run`を呼び，結果を表示するまでの順序．

書き終えたら，次を確かめる．

- VSCodeのプレビュー(`Ctrl+Shift+V`)で，図が描かれること．
- `mise run lint`で，図の構文の誤りがないこと．
- テストリストの各項目が，図のどの関数を確かめる項目なのかを言えること．

## 演習0-5：テスト駆動で実装する

テストリストの項目を1つずつ選び，次のサイクルを回す．

1. その項目のテストを1つだけ書く．
2. テストを実行し，失敗すること(Red)を確かめる．失敗のメッセージが予想どおりかも読む．
3. テストを通すいちばん簡単なコードを書く．
4. テストを実行し，すべてのテストが通ること(Green)を確かめる．
5. `TESTLIST.md`の項目を`- [x]`にする．

### 最初の単体テスト

1. `test/unit/Kakeibo/MoneySpec.hs`を作る．テストリストの最初の項目が「`total`は空のリストなら0を返す」なら，次のように書く．

   ```haskell
   module Kakeibo.MoneySpec (spec) where

   import Kakeibo.Money (total)
   import Test.Hspec

   spec :: Spec
   spec = do
     describe "total" $ do
       it "空のリストなら0を返す" $
         total [] `shouldBe` 0
   ```

2. `kakeibo-iteration0.cabal`の`test-suite unit`に，作ったモジュールを追記する．

   ```cabal
   test-suite unit
       type:               exitcode-stdio-1.0
       hs-source-dirs:     test/unit
       main-is:            Spec.hs
       other-modules:      Kakeibo.MoneySpec
   ```

3. 単体テストだけを実行する．

   ```sh
   cabal test kakeibo-iteration0:test:unit
   ```

   `[✘]`と`uncaught exception: ErrorCall`に続いて，`TODO`のメッセージが表示される．
   これが最初のRedである．
4. `src/Kakeibo/Money.hs`の`total`の`error "TODO: …"`を，テストが通る実装に書き換える．いまのテストは空のリストしか試していないので，0を返すだけでも通る．
5. もう一度テストを実行し，Greenになったら，`TESTLIST.md`の項目に印を付ける．

### 残りの項目

テストリストの残りの項目も，同じサイクルで1つずつ進める．

- 同じ関数のテストは，同じ`describe`の`do`の中に`it`を並べる．別の関数のテストは，`spec`の`do`の中に`describe`を並べる．
- `total`の一般的な実装には`sum`，`formatYen`には`show`と`++`が使える．
- 仮実装(期待値をそのまま返す実装)で通したら，次のテストで一般的な実装に書き換える必要が出るかを考える．

### 結合テスト

1. `test/integration/Kakeibo/AppSpec.hs`を作る．モジュール名は`Kakeibo.AppSpec`，テストする関数は`Kakeibo.App`の`run`である．
2. `test-suite integration`の`other-modules`に追記する．
3. 結合テストだけを実行し，Redを確かめる．コマンドは単体テストのときの`unit`を`integration`に変えたものである．
4. `run`を実装する．`total`は`[Int]`を受け取るので，`[String]`の引数を`map read`で`[Int]`に変換してから渡す．`run`が返すのは行のリストなので，1行だけでも`[ … ]`で囲む．

すべての項目に印が付いたら，パッケージのテストをまとめて実行し，すべて通ることを確かめる．
最後に，演習0-1と同じコマンドでプログラムを実行し，`合計: 2350円`と表示されることを確かめる．

## 演習0-6：振り返る

1. 自分の`TESTLIST.md`と，解答例の[TESTLIST.md](../../solution/TESTLIST.md)を比べる．自分にだけある項目，解答例にだけある項目はそれぞれどれか．それはなぜか．
2. `total`に「要素が複数あると最後の要素を返す」という誤りがあったとする．単体テストと結合テストのどちらが失敗するか．両方のテストがあると，失敗したときに何がわかりやすくなるか．
3. `cabal run kakeibo-iteration0 -- 1200 abc`を実行すると何が起きるか．なぜそうなるか．
4. 設計書と実装を見比べる．実装してみて，設計書と違う形になったところはあるか．あれば，設計書を実装に合わせて直す．

## 演習0-7(発展)：件数を表示する

合計の次の行に，支出の件数を表示する．

```console
$ kakeibo 1200 350 800
合計: 2350円
件数: 3件
```

1. テストリストに項目を足す．既存のテストのうち，期待値が変わるものも探して「〜に変える」という項目にする．
2. 1項目ずつRed→Greenを回す．リストの要素の数は`length`で求められる．

解答例のパッケージには，この発展課題の実装は含まれていない．解答の一例は`../solution/docs/iteration-0.md`にある．

発展課題でも，テストリストを書いたあとに設計書を更新してから実装し，実装したら設計書と見比べる．
