# Iteration 7：日付と月での絞り込み(演習)

## このIterationで作るもの

支出に日付を付けて記録する．
`list`と`summary`は，年月を指定すると，その月の支出だけを対象にする．

```console
$ export KAKEIBO_FILE=/tmp/kakeibo7.tsv
$ cabal run -v0 kakeibo-iteration7 -- add 2026-09-01 食費:1200 交通費:350
追加しました: 2026-09-01 食費 1,200円
追加しました: 2026-09-01 交通費 350円
$ cabal run -v0 kakeibo-iteration7 -- add 2026-10-03 食費:800
追加しました: 2026-10-03 食費 800円
$ cabal run -v0 kakeibo-iteration7 -- list
2026-09-01 食費 1,200円
2026-09-01 交通費 350円
2026-10-03 食費 800円
合計: 2,350円
$ cabal run -v0 kakeibo-iteration7 -- summary 2026-09
食費 1,200円
交通費 350円
合計: 1,550円
```

あわせて，`Maybe`や`Either`を返す関数の組み合わせを，`case`の入れ子から`<$>`・`<*>`・`do`記法・`traverse`で書き直す．

## 進め方

演習7-1から順に進める．
詰まったら，`../solution/docs/iteration-7.md`の同じ番号の節を読む．
コマンドはすべてリポジトリ直下で実行する．

## 演習7-1：パッケージを登録してビルドする

1. `cabal.project`の`packages`に，このパッケージのディレクトリを追記する．
2. このパッケージのテストをすべて実行し，引き継いだテストがすべて通ることを確かめる．
3. `src/`の中から，`case`で`Nothing`・`Left`の場合をそのまま返している箇所を探し，一覧にする．演習7-5で書き直す対象になる．

## 演習7-2：`Functor`・`Applicative`・`Monad`を試す

[Iteration 7で使う文法・概念](../../../../docs/haskell/iteration-7.md)を読み，GHCiで例を試す．
読み終えたら，GHCiで次を試す．

1. `import Text.Read (readMaybe)`と入力し，`(* 2) <$> (readMaybe "21" :: Maybe Int)`と`(* 2) <$> (readMaybe "x" :: Maybe Int)`を評価する．
2. 2つの文字列を`Int`として読み，その和を`Maybe Int`で返す関数を，`<$>`と`<*>`で定義する．次に，`do`記法で定義し直す．
3. 文字列のリストをすべて`Int`として読む式を，`traverse`で書く．読めない文字列が1つでもある場合の結果を確かめる．
4. `maybe (Left "not a number") Right (readMaybe "x" :: Maybe Int)`を評価し，`Maybe`が`Either`に変わることを確かめる．

## 演習7-3：テストリストを書く

次の要求を読み，[TESTLIST.md](../TESTLIST.md)にテストリストを書く．

### 要求

- `add`は，1つ目の引数に日付を`YYYY-MM-DD`の形で書き，その後ろに支出を並べる．並べた支出はすべてその日の支出になる．
- 日付は，年が4桁，月と日が2桁の数で，`-`で区切る．存在しない日付(13月，4月31日，うるう年でない年の2月29日など)は誤りである．うるう年は，4で割り切れる年のうち，100で割り切れない年と，400で割り切れる年である．
- 日付が誤っていれば，`存在する日付をYYYY-MM-DDの形で書いてください: 引数`というエラーメッセージを表示し，何も追記しない．
- `list`と`summary`は，後ろに年月を`YYYY-MM`の形で1つ書ける．書いたときは，その年月の支出だけを対象にする．
- 年月が誤っていれば，`年月はYYYY-MMの形で書いてください: 引数`というエラーメッセージを表示する．
- 支出は`日付 費目 金額`の形で表示する(`追加しました:`の行と`list`の行)．日付は`2026-09-01`のように，月と日を2桁で表示する．
- データファイルの各行は`日付<タブ>費目の名前<タブ>金額`にする．
- 使い方の表示を`使い方: kakeibo add YYYY-MM-DD 費目:金額 … | kakeibo list [YYYY-MM] | kakeibo summary [YYYY-MM]`に変える．

データファイルの形が変わるので，Iteration 6で作ったデータファイルは読めない(`1行目を読めません`になる)．
このIterationでは，新しいデータファイルを使う．

### 作るもの

| モジュール | 型・関数 | 役割 |
|---|---|---|
| `Kakeibo.Date` | `data Date = Date {year :: Int, month :: Int, day :: Int}` | 日付．`Show`・`Eq`・`Ord`を`deriving`し，`Display`のインスタンスにする．(新規) |
| `Kakeibo.Date` | `data YearMonth = YearMonth Int Int` | 年月．(新規) |
| `Kakeibo.Date` | `parseDate :: String -> Maybe Date` | 日付を読み取る．(新規) |
| `Kakeibo.Date` | `parseYearMonth :: String -> Maybe YearMonth` | 年月を読み取る．(新規) |
| `Kakeibo.Date` | `inMonth :: YearMonth -> Date -> Bool` | 日付がその年月に含まれるか．(新規) |
| `Kakeibo.Entry` | `Entry`の`date :: Date` | 最初のフィールドとして足す． |
| `Kakeibo.Entry` | `parseEntry :: Date -> String -> Either String Entry` | 日付を受け取るように変える． |
| `Kakeibo.Entry` | `parseEntries :: Date -> [String] -> Either String [Entry]` | 日付を受け取るように変える． |
| `Kakeibo.Command` | `data Command = Add [Entry] \| List (Maybe YearMonth) \| Summary (Maybe YearMonth)` | `list`・`summary`に年月を持たせる． |

### 考えること

- 日付の誤りには，どんな種類があるか．どれを`parseDate`の単体テストで確かめるか．
- 月での絞り込みは，どの関数の単体テストと，どんな結合テストで確かめるか．「月の境目」の支出を含めると，何を確かめられるか．
- `Entry`にフィールドが増えると，既存のテストのどこを書き換えることになるか．日付が関係ないテスト(`summarize`など)で，毎回日付を書かずに済む工夫はあるか．
- 振る舞いを変えない書き直し(`traverse`などへの置き換え)を確かめるテストは，新しく要るか．

## 演習7-4：設計書を更新する

`design/`の設計書を，このIterationの要求に合わせて更新する．
書き方は[設計書の書き方](../../../../docs/design.md)を参照する．

- Context・Containerの図の説明に，日付と月での絞り込みを書き足す．データファイルの形が変わることも反映する．
- `03-component.md`に`Kakeibo.Date`を足す．日付を読むモジュール，日付を持つ型を定義するモジュールから，矢印を引く．
- `04-code.md`のデータ型の図に，`Date`と`YearMonth`を足し，`Entry`と`Command`の変更を描く．
- 型と関数の流れで，`<$>`・`<*>`・`do`記法・`traverse`で組み合わせるところは，その書き方を矢印のラベルに書く．
  - 前の結果を使う組み合わせ(日付を読んでから，その日付で支出を読む)と，互いに関係しない組み合わせ(日付・費目・金額をそれぞれ読む)を，図の上でも区別する．
- 年月で支出を絞り込む関数を，どこに置くかを決める．

更新したら，`mise run lint`で図の構文を確かめる．

## 演習7-5：テスト駆動で実装する

振る舞いを変えない書き直しを先に済ませ，そのあとで日付を足す．

### 1. 書き直す(テストはすべて通ったまま)

演習7-1で一覧にした箇所を，次のように書き直す．1か所書き直すたびにテストを実行する．

- `parseAmount`：`case readMaybe text of …`を，`Maybe`の`do`記法にする．
- `parseEntries`：再帰と`case`の入れ子を，`traverse`にする．
- `parseCommand`の`add`：`case parseEntries args of …`を，`<$>`にする．
- `decodeEntry`：`case parseAmount … of …`を，`<$>`か`<*>`で書く．
- `decodeEntries`：`zip`した行の読み取りを，`traverse`にする．読めなかった行の`Nothing`を`Left`に変えるには`maybe`を使う．
- `loadEntries`：`case decodeEntries contents of …`を，`either`で書く．
- `run`の`withEntries`：`case loaded of …`を，`<$>`にする．

### 2. `Kakeibo.Date`

- `src/Kakeibo/Date.hs`と単体テストを作り，`exposed-modules`と`other-modules`に追記する．
- `parseDate`は，文字列を`-`で3つに分け，桁数を確かめてから，それぞれを`readMaybe`で読む．`Maybe`の`do`記法で書くと，どれかが読めなければ`Nothing`になる．文字列を区切り文字で分ける関数は，`break`と再帰で作れる．
- 月の日数を返す関数と，うるう年かを返す関数を，モジュールの中だけで使う補助の関数として作る．
- `Display`のインスタンスでは，1桁の月と日の前に`0`を付ける．
- 日付の誤りの種類ごとに，1つずつRed→Greenを回す．

### 3. `Entry`に日付を足す

- `Entry`の最初のフィールドに`date :: Date`を足し，`parseEntry`と`parseEntries`が日付を受け取るようにする．`Display`のインスタンスでは，日付を先頭に表示する．
- `Kakeibo.Entry`の単体テストを書き換えてから，型を変える．ほかのモジュールでコンパイルエラーが出るので，上から順に直す．
- `summarize`や`listReport`のテストでは，支出を作る補助の関数(費目と金額だけを受け取り，決まった日付の`Entry`を返す関数)をテストのモジュールに作ると，日付を毎回書かずに済む．

### 4. データファイルとサブコマンド

- `encodeEntry`・`decodeEntry`を3つの項目にする．`decodeEntry`は，行をタブで分けて3つになったときだけ，`Entry <$> … <*> … <*> …`で読む．
- `parseCommand`の`add`は，日付と支出を`Either`の`do`記法で読む．日付の`Maybe`は`maybe`で`Either`に変える．
- `list`と`summary`は，年月がない場合とある場合でパターンを分ける．年月を`Just`で包んでから`List`に渡す関数は，`List . Just`と書ける．
- `run`は，年月の指定があれば`inMonth`で支出を絞り込んでから，表示する行を作る．
- 結合テストを書き換え，月での絞り込みのテストを足す．

### 5. `main`

- `lookupEnv`の結果に`fromMaybe`を適用する処理を，`<$>`を使って1行にする．
- 行の表示を`mapM_`で書き直す．

最後に，「このIterationで作るもの」と同じ手順で動かして確かめる．

## 演習7-6：振り返る

1. 自分の`TESTLIST.md`と，解答例の[TESTLIST.md](../../solution/TESTLIST.md)を比べる．
2. 手順1の書き直しで，行数はどれだけ減ったか．書き直しの誤りに気付けたのは，どのテストのおかげか．
3. `decodeEntry`を`<*>`で，`parseCommand`の`add`を`do`記法で書いた．それぞれの書き方を選んだ理由を，値どうしの関係から説明する．
4. 日付の誤りの種類のうち，結合テストでも確かめたのはどれか．それだけで足りると言える理由は何か．
5. 設計書と実装を見比べる．実装してみて，設計書と違う形になったところはあるか．あれば，設計書を実装に合わせて直す．

## 演習7-7(発展)：期間を指定する

`list`と`summary`に，開始日と終了日を指定できるようにする．

```console
$ kakeibo list 2026-09-01 2026-09-15
```

1. 年月の指定と期間の指定を`Command`でどう表すかを決め，テストリストに項目を足す．
2. 1項目ずつRed→Greenを回す．`Date`は`Ord`のインスタンスなので，`<=`で比べられる．

発展課題でも，テストリストを書いたあとに設計書を更新してから実装し，実装したら設計書と見比べる．
