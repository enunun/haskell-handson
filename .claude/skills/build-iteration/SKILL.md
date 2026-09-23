---
name: build-iteration
description: haskell-handsonの1つのIterationについて，演習用(exercise)と解答例(solution)のcabalパッケージ，演習手順・解説・テストリストと設計書(C4モデルのmermaidの図)の模範解答，Haskellの文法・概念の資料をそろえて作る(または作り直す)．docs/ROADMAP.mdの該当節を仕様とし，ビルド・テスト・図の検査で確かめてからfinalize-artifactsで仕上げる．「Iteration Nを作って」「次のIterationを追加して」「Iteration Nを直して」と頼まれたときに使う．
---

# build-iteration

家計簿プログラム`kakeibo`を育てるハンズオンの，Iterationを1つ作る．
1回の実行で扱うIterationは1つだけにする．複数頼まれたら，番号の小さい順に1つずつ最後まで仕上げてから次に進む．

## 仕様の出どころ

- 何を作るか(要求，使い方，モジュール，学ぶこと，設計書で更新するもの，学習者が行うcabalの作業)は，`docs/ROADMAP.md`の「Iteration N」の節だけを根拠にする．ROADMAPにない機能を足したくなったら，先にROADMAPを直す．
- 1つ前のIterationの解答例パッケージ(コード・テスト・設計書)は，そのまま引き継ぐ土台である．手で打ち直さず，ディレクトリごとコピーする．
- 文章(README，演習手順，解説，テストリスト)はIterationごとに新しく書く．前のIterationの文章をコピーして書き換えない．前のIterationの話題が紛れ込むのを防ぐため．

## 教材の設計原則

1. **演習用パッケージは，1つ前の解答例と同じコードと設計書から始まる．** Iteration N(N ≥ 1)の演習用パッケージのコード・テスト・設計書(`design/`)は，Iteration N-1の解答例と，パッケージ名を除いて同一にする．新しいモジュールのひな形，`error "TODO"`，新しいテスト，このIterationの設計は入れない．新しいモジュールのファイル作成，`.cabal`への追記，テストの追加，設計書の更新は，すべて学習者の作業である．
   - Iteration 0だけは例外で，ライブラリのモジュールを型シグネチャと`error "TODO: …"`だけのひな形として置き，テストディレクトリにはhspec-discoverのドライバ(`Spec.hs`)だけを置く．設計書は，4つのファイルに見出しと，何の図を書くかのHTMLコメントだけを置く．
2. **仕様書の代わりに，学習者がテストリストを書く．** 演習手順には「要求」と「使い方の例」と「作るモジュールの型シグネチャ」だけを書き，テストケースを列挙しない．学習者は`TESTLIST.md`に単体テストと結合テストのテストリストを書き，1項目ずつRed→Greenを回す．解答例の`TESTLIST.md`は模範解答で，全項目を`- [x]`にする．
   - 演習用の`TESTLIST.md`は，見出し(`## 単体テスト`・`## 結合テスト`)だけのひな形にする．
   - 演習手順では，テストリストを書く段階で，既存のテストのうち期待値が変わるものを探させる．見つけたものもテストリストに「〜に変える」という項目として書かせる．
3. **テストリスト→設計→実装→設計の見直し，のループを回す．** 学習者は，テストリストを書いたあと，その振る舞いを実現する型・関数・モジュールを設計書(`design/`)に描いてから実装し，実装したあとで設計書と実装を見比べて直す．
   - 設計書はC4モデルの4階層に分ける(`01-context.md`・`02-container.md`・`03-component.md`・`04-code.md`)．書き方は`docs/design.md`で決めている．Componentはモジュールと純粋な部分・`IO`を行う部分の境界，Codeは型と関数の流れ(型をノード，関数を矢印)・データ型・`IO`の順序(Iteration 8からは満たすべき性質も)である．
   - 演習手順の設計の段階には，どの階層のどこを考えるかのヒントだけを書き，図そのものは書かない．解答例の`design/`は模範解答で，解説では前のIterationからの変更点と判断の理由を書く．
   - 解答例の設計書は実装と一致させる．Componentの図の矢印は実装の`import`と(`check-component.sh`で確かめる)，Codeの図の名前は実装の名前と一致させる．`where`の中の名前のような細部は，図の下の説明に書く．
4. **cabalの操作は学習者が行う．** 演習手順には，次の作業を学習者がする手順として書く．
   - 演習用パッケージを`cabal.project`の`packages`に登録する．リポジトリの`cabal.project`には解答例のパッケージだけを登録しておき，演習用は登録しない．
   - `cabal build`・`cabal test`・`cabal run`・`cabal repl`の実行．コマンドの形(ターゲットの指定方法など)は，初めて使うIterationでは完全な形で示す．2回目以降は「単体テストだけを実行する」のように何をするかだけを書き，コマンドは学習者に組み立てさせる．
   - `.cabal`ファイルの編集(`exposed-modules`・`other-modules`・`build-depends`への追記)．
5. **単体テストと結合テストの役割を分ける．** 単体テスト(`test/unit/`)は1つのモジュールの関数を単独で確かめる．結合テスト(`test/integration/`)は`Kakeibo.App.run`を呼び，複数のモジュールの組み合わせを確かめる．Iteration 6以降の結合テストは一時ディレクトリのデータファイルを使う．
6. **テストは機能に属する．** Specファイルはモジュールごとに1つ(`Kakeibo/MoneySpec.hs`など)で，モジュールがある限り残る．既存の機能を変えるIterationでは，既存のSpecファイルにテストを足すか，期待値を書き換える．`IterationNSpec.hs`のようなファイルは作らない．
7. **後のIterationの形を先取りしない．** 型シグネチャ，モジュール構成，コメントは，そのIterationの時点で必要なものだけを書く．後で使う引数や型を先に用意しない．
8. **新しい文法・概念は，初めて使うIterationの資料で説明してから使う．** 説明は`docs/haskell/iteration-N.md`に書く．解答例のコードに，まだ説明していない文法(言語拡張，型クラス，演算子など)を使わない．
9. **肯定的に書く．** 「〜は使わない」「〜に依存しない」のような，教材の作り方の言い訳になる文を書かない．そのIterationで作るものと学ぶことを書く．後のIterationに触れるときは「Iteration Nで〜する」と前向きに書く．
10. **解説は演習の手順と1対1に対応させる．** 解答例の`docs/iteration-N.md`の見出しは，演習用の`docs/iteration-N.md`の手順と同じ番号・同じ名前にする．TDDの手順では，模範解答のテストリストの項目ごとに，テストと，その時点のコード(仮実装の段階ならその姿)を示す．

## パッケージ名とディレクトリ

- ディレクトリ：`iterations/iteration-N/exercise/`，`iterations/iteration-N/solution/`
- パッケージ名：`kakeibo-iterationN`(演習用)，`kakeibo-solution-iterationN`(解答例)．cabalはパッケージ名の中で数字だけの部分を許さないので，`iteration`と数字のあいだにハイフンを入れない．
- `.cabal`ファイル名はパッケージ名に合わせる．実行ファイル名はどちらも`kakeibo`にする(`cabal run <パッケージ名>`で起動できる)．
- モジュールは`Kakeibo.`で始める．Specファイルはテスト対象のモジュールと同じ階層に置く(`test/unit/Kakeibo/MoneySpec.hs`)．

## パッケージの中身

```
README.md             このIterationで作るもの，進め方，ディレクトリ構成
TESTLIST.md           テストリスト(演習用はひな形，解答例は模範解答)
design/0[1-4]-*.md    設計書(C4モデルの4階層．演習用は前の解答例のまま，解答例は模範解答)
docs/iteration-N.md   演習用：演習手順／解答例：各手順の解説
kakeibo-…N.cabal
app/Main.hs
src/Kakeibo/*.hs
test/unit/Spec.hs, test/unit/Kakeibo/*Spec.hs
test/integration/Spec.hs, test/integration/Kakeibo/AppSpec.hs
test/common/Kakeibo/Generators.hs   (Iteration 8以降．両方のテストスイートで使うジェネレータ)
```

演習用の`docs/iteration-N.md`は，次の流れで書く．

1. **N-1 準備**：`cabal.project`に登録し，ビルドし，引き継いだテストがすべて通ることを確かめる．今のプログラムを`cabal run`で動かす．
2. **N-2 文法・概念を学ぶ**：`docs/haskell/iteration-N.md`を読み，`cabal repl`で試す小さな課題を解く．
3. **N-3 テストリストを書く**：「要求」「使い方の例」「作るもの(モジュールと型シグネチャ)」を示し，`TESTLIST.md`を書かせる．既存のテストへの影響と，単体・結合の振り分けも考えさせる．
4. **N-4 設計書を更新する**：`design/`のどの階層のどこを更新するかのヒント(足すモジュール，描く型，流れの分かれ目など)を書く．更新したら`mise run lint`で図の構文を確かめさせる．Iteration 0では「設計書を書く」とし，`docs/design.md`を読ませる．
5. **N-5 テスト駆動で実装する**：テストリストの項目を1つずつRed→Greenにする．機能ごとのヒント(使う関数，はまりやすい点)と，必要なcabalの作業を書く．テストケースそのものは書かない．
6. **N-6 振り返る**：解答例の`TESTLIST.md`と自分のテストリストを比べる問いと，単体テストと結合テストの役割についての問いを置く．最後の問いは「設計書と実装を見比べ，ずれていれば設計書を直す」にする．
7. **N-7 発展課題**：同じサイクルを自力で回す，少し先の機能．末尾に，発展課題でもテストリスト→設計書→実装の順に進めることを書く．

## 手順

1. `docs/ROADMAP.md`のIteration Nの節と，Iteration N-1の節を読む．Iteration N-1の解答例パッケージのコード・テスト・設計書・`docs/haskell/iteration-(N-1).md`を読み，引き継ぐ状態と，説明済みの文法を把握する．
2. 解答例を丸ごとコピーし，パッケージ名を書き換える．`P`は1つ前の番号である．
   ```sh
   cd iterations
   for kind in solution exercise; do
     cp -r iteration-$P/solution iteration-$N/$kind
     rm -rf iteration-$N/$kind/dist-newstyle iteration-$N/$kind/docs/iteration-$P.md
   done
   sed -e "s/kakeibo-solution-iteration$P/kakeibo-solution-iteration$N/g" -e "s/Iteration $P・解答例/Iteration $N・解答例/" \
     iteration-$N/solution/kakeibo-solution-iteration$P.cabal > iteration-$N/solution/kakeibo-solution-iteration$N.cabal
   sed -e "s/kakeibo-solution-iteration$P/kakeibo-iteration$N/g" -e "s/Iteration $P・解答例/Iteration $N・演習用/" \
     iteration-$N/exercise/kakeibo-solution-iteration$P.cabal > iteration-$N/exercise/kakeibo-iteration$N.cabal
   rm iteration-$N/*/kakeibo-solution-iteration$P.cabal
   ```
   `README.md`・`TESTLIST.md`・`docs/`は後で書き直す．設計書(`design/`)は，演習用はそのまま残し，解答例は手順5で更新する．
3. 演習用パッケージの`TESTLIST.md`をひな形に戻し，`README.md`と`docs/iteration-N.md`を新しく書く(「パッケージの中身」の流れに従う)．コード・テスト・設計書には手を入れない．
   `TESTLIST.md`のひな形は次のとおり．
   ```markdown
   # テストリスト(Iteration N)

   `docs/iteration-N.md`の「要求」を読み，確かめたい振る舞いを1行に1つずつ書く．
   既存のテストのうち期待値が変わるものは，「〜に変える」という項目にする．
   書き方は[テスト駆動開発とテストリスト](../../../docs/tdd.md)を参照する．

   ## 単体テスト

   ## 結合テスト
   ```
4. 解答例パッケージの模範解答の`TESTLIST.md`を書く．
5. 解答例パッケージの設計書(`design/`)を，ROADMAPの「設計書で更新するもの」に沿って更新する．図の書き方は`docs/design.md`に従う．
6. 解答例パッケージで，ROADMAPの機能とリファクタリングをTDDで実装する．テストリストの項目の順に，テストを書いて失敗を確かめてから実装する．途中の段階のコードは，解説に載せるために控えておく．
7. 解答例の設計書を実装と見比べ，実装に合わせて直す．実装で決まったこと(補助の関数，型クラスのインスタンスなど)は，解説の振り返りの答えに書く．
8. 解答例の`README.md`と`docs/iteration-N.md`(演習の手順ごとの解説)を書く．設計の手順の解説には，前のIterationからの変更点を階層ごとに挙げ，判断の理由を書く．
9. `docs/haskell/iteration-N.md`を書き，`docs/haskell/README.md`の目次を更新する．このIterationで新しく使った文法・概念(言語拡張，演算子，型クラス，ライブラリの関数)を，型シグネチャと実際の振る舞いに基づいて説明する．GHCiで試せる例を添える．
10. 解答例のパッケージを`cabal.project`の`packages`に追記する．演習用は追記しない．
11. 確かめる．
    ```sh
    mise run fmt
    mise run check           # 整形・hlint・mermaidの図の検査・全パッケージ(演習用を含む)のビルドとテスト
    .claude/skills/build-iteration/check-component.sh iterations/iteration-N/solution
    ```
    - 解答例のテストがすべて通ること．
    - 演習用パッケージがビルドでき，引き継いだテストがすべて通ること．
    - 演習用パッケージのコード・テスト・設計書が，前のIterationの解答例と同じであること．
      ```sh
      diff -r -x '*.cabal' -x README.md -x TESTLIST.md -x docs -x dist-newstyle iterations/iteration-(N-1)/solution iterations/iteration-N/exercise
      ```
    - 解答例のComponentの図の矢印が，実装の`import`と一致すること(`check-component.sh`)．
    - `cabal run kakeibo-solution-iterationN -- …`で，ROADMAPの使い方の例どおりに動くこと．
    - 後のIterationがすでにあるなら，Iteration N+1の演習用パッケージがIteration Nの解答例と一致しているかも確かめる．一致しなければ，N+1以降の演習用パッケージ(と，影響があれば解答例)を直す．
12. `system-development-skills:finalize-artifacts`スキルで，このIterationで書いた文章(両パッケージの`README.md`・`TESTLIST.md`・`docs/iteration-N.md`，解答例の設計書，ソースコードのコメント，`docs/haskell/iteration-N.md`)を仕上げる．設計原則9の言い訳めいた文が残っていないかを特に確かめる．

## Iterationを追加するとき

ROADMAPの最後に新しいIterationを足すときは，先に`docs/ROADMAP.md`に節(「設計書で更新するもの」を含む)と一覧表の行を足し，ルートの`README.md`のIteration一覧も更新してから，上の手順で作る．

## 資料に載せる出力は，実際に実行して確かめる

GHCiの評価結果，コンパイルエラー・警告のメッセージ，hspecの失敗メッセージ，QuickCheckの反例，プログラムの出力は，推測で書かずに実際に実行して写す．

- GHCiの出力は，入力をファイルに書いて`ghci -v0 < 入力ファイル`で得る(パッケージのモジュールを使うときは`cabal repl -v0 <ターゲット> < 入力ファイル`)．
- 演習用パッケージは`cabal.project`に登録されていないので，`mise run test-all`が作る`cabal.project.all`を使う(`cabal build --project-file=cabal.project.all --builddir=dist-newstyle/all <ターゲット>`)．新しいIterationを作ったあとは，`mise run test-all`を一度実行して`cabal.project.all`を作り直す．
- 失敗の出力を得るために実装を壊すときは，スクラッチパッドにパッケージをコピーして壊す．リポジトリのファイルは壊さない．

## はまりやすい点

- 日本語を含む文字列は，ロケールがUTF-8でないとGHCが扱えない．開発用コンテナでは`LANG=C.UTF-8`を設定している．コンテナの外で実行するときは`LANG=C.UTF-8`を付ける．
- GHCiは評価結果を`show`で表示するので，日本語は`"\20870"`のような番号になる(hspecの失敗メッセージではそのまま表示される)．資料のGHCiの例では，出力に日本語の文字列が出ないように英数字の値を使うか，`putStrLn`で表示する．
- GHCiの出力をパイプで`head`などに渡すと，パイプが閉じたあとGHCiが終わらずにメモリを使い続けることがある．出力はファイルに書いてから読む．
- QuickCheckが作る`Int`は，ふだん絶対値が100くらいまでに偏る．4桁以上の数で確かめたい性質には`Large`を使う(`\(NonNegative (Large n)) -> …`)．
- hlintは再帰を`foldr`に，`foldr (+) 0`を`sum`に，引数を省いた形に書き換えるよう提案する．教材の途中の形を残すために，`.hlint.yaml`でこれらの提案を止めている．
- `-Wall`は，テストのモジュールに書いた`Arbitrary`のインスタンスに，orphan instanceの警告を出す．テストでは，ジェネレータを関数として作り`forAll`で使う．
- `.cabal`ファイルを編集した直後に`cabal test <パッケージ名>`が`Ambiguous target`で失敗することがある．`dist-newstyle`に古いビルド計画が残っているためなので，`cabal clean`してからやり直す．
- hspec-discoverは`*Spec.hs`というファイル名のモジュールを集める．Specファイルを追加したら，テストスイートの`other-modules`にも追記する(しないとcabalが警告を出す)．
- mermaidの図の中の`<`・`>`や`&lt;`は，HTMLとして扱われて表示が崩れることがある．図の中では言葉で書く(「タブで区切った行」など)．ラベルの中で`"`を使うときは，ラベル全体を`"…"`で囲み，中の`"`は「」に置き換える．
- mermaidのC4の図は，`Component_Ext`・`ContainerDb_Ext`で境界の外のもの(外部のライブラリ，データファイル)を描ける．境界は`Container_Boundary`の中に`Boundary`を入れ子にできる．
- `mise run test-all`が，並列ビルドの途中で`ghc-pkg`の`getModificationTime … does not exist`というエラーで失敗することがある．パッケージデータベースのファイルの取り合いで起きるので，もう一度実行する．
