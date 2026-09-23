# ロードマップ

このハンズオンでは，コマンドラインで使う家計簿プログラム`kakeibo`を，Iteration 0から8までの9回に分けて少しずつ育てる．
各Iterationでは，機能を1つか2つ足しながら，Haskellの文法・概念を1まとまりずつ学ぶ．

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

## 進め方

どのIterationも，次の順に進める．

1. 演習用パッケージ(`iterations/iteration-N/exercise`)を`cabal.project`に登録し，ビルドする．
2. 資料(`docs/iteration-N.md`)の「要求」を読み，単体テストと結合テストのテストリストを`TESTLIST.md`に書く．
3. テストリストから1つずつ選び，テストを書いて失敗させ(Red)，実装して通す(Green)．
4. 必要ならテストが通ったまま整理する(Refactor)．
5. テストリストが空になったら，解答例(`iterations/iteration-N/solution`)と見比べる．

仕様書は用意しない．要求を読んで自分で書いたテストリストと，そこから育てたテストが，そのIterationの仕様になる．
テスト駆動開発(TDD)の進め方と，テストリストの書き方は[tdd.md](tdd.md)で説明する．

各Iterationの演習用パッケージは，1つ前のIterationの解答例と同じコードから始まる．
前のIterationを自分で書き終えていなくても，次のIterationに進める．

## テストの分け方

どのパッケージも，テストスイートを2つ持つ．

| テストスイート | 置き場所 | 確かめること |
|---|---|---|
| `unit`(単体テスト) | `test/unit/` | 1つのモジュールの関数を，単独で呼んで確かめる． |
| `integration`(結合テスト) | `test/integration/` | プログラムの入口(`Kakeibo.App.run`)を呼び，複数のモジュールを組み合わせた振る舞いを確かめる．Iteration 6からはファイルの読み書きも含む． |

## Iterationの一覧

| Iteration | 作る機能 | 学ぶ文法・概念 |
|---|---|---|
| 0 | 引数に並べた金額の合計を表示する | 関数，型，リスト，モジュール，cabal，hspec |
| 1 | 3桁区切りで表示する．支出がないことを知らせる | パターンマッチ，再帰，ガード，`where` |
| 2 | 費目付きで入力し，明細を表示する | `data`(直和型・レコード)，`deriving`，`case`，タプル |
| 3 | 費目ごとに集計する | 高階関数(`map`・`filter`・`foldr`)，ラムダ式，関数合成，セクション |
| 4 | 入力の誤りをエラーメッセージで知らせる | `Maybe`，`Either`，全域関数 |
| 5 | 費目ごとの小計を金額の大きい順に並べる | 型クラス，`newtype`，`Semigroup`・`Monoid`，`Data.Map` |
| 6 | 支出をファイルに保存し，サブコマンドで操作する | `IO`，`do`記法，純粋な部分と副作用の分離 |
| 7 | 日付を記録し，月で絞り込む | `Functor`・`Applicative`・`Monad`，`traverse` |
| 8 | 性質をランダムな入力で確かめる | QuickCheck，`Arbitrary`，プロパティベーステスト |

## Iteration 0：合計を表示する

- **要求**：コマンドライン引数に支出の金額を並べると，その合計を表示する．
- **使い方**：`kakeibo 1200 350 800`で`合計: 2350円`と表示する．引数がなければ`合計: 0円`．
- **モジュール**：`Kakeibo.Money`(`total`，`formatYen`)，`Kakeibo.App`(`run`)．
- **学ぶこと**：関数の定義と呼び出し，型シグネチャ，`Int`・`String`・リスト，モジュール，GHCi，hspec，cabalのパッケージ構成．
- **学習者が行うcabalの作業**：`cabal.project`への登録，`cabal build`・`cabal repl`・`cabal test`・`cabal run`，テストモジュールの`other-modules`への追記．

## Iteration 1：3桁区切りと，支出がないときの表示

- **要求**：金額を3桁ごとにカンマで区切る(`1,234,567円`)．引数がないときは`支出はありません`と表示する．
- **リファクタリング**：`total`を，`sum`を使わずに再帰で書き直す．
- **学ぶこと**：パターンマッチ(リテラル・リスト)，再帰，ガード，`where`，`let`．
- **既存のテストへの影響**：金額の表示を確かめるテストと，引数がないときの結合テストの期待値が変わる．

## Iteration 2：費目付きの入力と明細

- **要求**：支出を`費目:金額`の形で入力する(`kakeibo 食費:1200 交通費:350`)．1件ずつ明細を表示し，最後に合計を表示する．費目は食費・交通費・日用品・その他の4つで，それ以外の名前は「その他」として扱う．`:`がない引数は全体を金額とし，費目を「その他」とする．
- **モジュール**：`Kakeibo.Entry`(`Category`，`Entry`，`parseCategory`，`categoryName`，`parseEntry`，`formatEntry`)を追加する．
- **学ぶこと**：`data`による直和型とレコード，`deriving (Show, Eq)`，`case`式，タプル，`break`．
- **学習者が行うcabalの作業**：新しいモジュールを`exposed-modules`に追記する．

## Iteration 3：費目ごとの集計

- **要求**：明細と合計のあいだに，費目ごとの小計を表示する．小計が0円の費目は表示しない．
- **モジュール**：`Kakeibo.Summary`(`summarize`)を追加する．
- **リファクタリング**：`total`を`foldr`で書き直す．
- **学ぶこと**：高階関数(`map`・`filter`・`foldr`)，ラムダ式，関数合成`(.)`，`($)`，セクション，`Enum`・`Bounded`と`[minBound .. maxBound]`．

## Iteration 4：入力の誤りを知らせる

- **要求**：金額が正の整数でない引数があれば，その引数と理由を示すエラーメッセージを標準エラー出力に表示し，終了コード1で終わる．
- **学ぶこと**：部分関数と全域関数，`Maybe`，`Either`，`Text.Read.readMaybe`，`case`によるエラーの受け渡し．
- **既存のテストへの影響**：`parseEntry`と`run`の型が`Either`を返すように変わるので，既存のテストも書き換える．

## Iteration 5：型クラスで金額を表す

- **要求**：費目ごとの小計を，金額の大きい順に表示する．同じ金額なら費目の定義順にする．
- **リファクタリング**：金額を`newtype Yen`で表し，`Semigroup`・`Monoid`のインスタンスで足し算を表す．表示用の型クラス`Display`を定義し，`formatYen`・`categoryName`・`formatEntry`をそのインスタンスに置き換える．集計を`Data.Map.Strict`で書き直す．
- **学ぶこと**：型クラスの定義とインスタンス，`newtype`，`Semigroup`・`Monoid`，`Ord`と並べ替え(`sortOn`・`Down`)，`Data.Map`，修飾付きimport．
- **学習者が行うcabalの作業**：`build-depends`に`containers`を追加する．

## Iteration 6：ファイルへの保存とサブコマンド

- **要求**：`kakeibo add 食費:1200 交通費:350`で支出をデータファイルに追記する．`kakeibo list`で明細と合計を，`kakeibo summary`で費目ごとの小計と合計を表示する．データファイルは環境変数`KAKEIBO_FILE`で指定し，未指定なら`kakeibo.tsv`を使う．ファイルがまだなければ，支出が0件として扱う．データファイルに読めない行があれば，その行番号を示すエラーにする．
- **モジュール**：`Kakeibo.Command`(`Command`，`parseCommand`)，`Kakeibo.Report`(`listReport`，`summaryReport`)，`Kakeibo.Storage`(`encodeEntry`，`decodeEntry`，`decodeEntries`，`loadEntries`，`appendEntries`)を追加する．`Kakeibo.App.run`はデータファイルのパスを受け取る`IO`アクションになる．
- **学ぶこと**：`IO`型，`do`記法，`<-`と`let`，`pure`，ファイルの読み書き，環境変数，純粋な関数と副作用のある処理の分離．
- **学習者が行うcabalの作業**：`build-depends`に`directory`(ライブラリ)と`temporary`(結合テスト)を追加する．

## Iteration 7：日付と月での絞り込み

- **要求**：`kakeibo add 2026-09-01 食費:1200`のように日付を付けて記録する．`list`と`summary`は`kakeibo list 2026-09`のように月を指定すると，その月の支出だけを対象にする．
- **モジュール**：`Kakeibo.Date`(`Date`，`YearMonth`，`parseDate`，`parseYearMonth`，`inMonth`)を追加する．`Entry`に日付のフィールドを足し，データファイルの各行の先頭にも日付を書く．
- **リファクタリング**：`Maybe`・`Either`を返す関数どうしの組み合わせを，`case`の入れ子から`<$>`・`<*>`・`do`記法・`traverse`で書き直す．
- **学ぶこと**：`Functor`・`Applicative`・`Monad`，`Either`と`Maybe`の`do`記法，`traverse`・`mapM_`．

## Iteration 8：プロパティベーステスト

- **要求**：新しい機能は足さない．これまでに作った関数が満たすべき性質(保存した支出を読み戻すと元に戻る，小計の和が合計に等しい，など)を，ランダムに作った入力で確かめる．
- **学ぶこと**：QuickCheck，`Arbitrary`型クラスとジェネレータ，`prop`，性質の見つけ方．
- **学習者が行うcabalの作業**：テストスイートの`build-depends`に`QuickCheck`を追加する．
