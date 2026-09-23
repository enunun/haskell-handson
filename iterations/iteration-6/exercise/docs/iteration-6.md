# Iteration 6：ファイルへの保存とサブコマンド(演習)

## このIterationで作るもの

これまでの`kakeibo`は，実行するたびに支出をすべて引数で渡す必要があった．
このIterationでは，支出をデータファイルに保存し，あとから一覧や集計を表示できるようにする．

```console
$ export KAKEIBO_FILE=/tmp/kakeibo.tsv
$ cabal run -v0 kakeibo-iteration6 -- add 食費:1200 交通費:350
追加しました: 食費 1,200円
追加しました: 交通費 350円
$ cabal run -v0 kakeibo-iteration6 -- add 食費:350
追加しました: 食費 350円
$ cabal run -v0 kakeibo-iteration6 -- list
食費 1,200円
交通費 350円
食費 350円
合計: 1,900円
$ cabal run -v0 kakeibo-iteration6 -- summary
食費 1,550円
交通費 350円
合計: 1,900円
```

作りながら，入出力を表す`IO`型と`do`記法を学ぶ．
ファイルの読み書きのような副作用のある処理と，テストしやすい純粋な関数を分けて設計する．

## 進め方

演習6-1から順に進める．
詰まったら，`../solution/docs/iteration-6.md`の同じ番号の節を読む．
コマンドはすべてリポジトリ直下で実行する．

## 演習6-1：パッケージを登録してビルドする

1. `cabal.project`の`packages`に，このパッケージのディレクトリを追記する．
2. このパッケージのテストをすべて実行し，引き継いだテストがすべて通ることを確かめる．
3. `app/Main.hs`と`src/Kakeibo/App.hs`を読み，今のプログラムで`IO`の型が付いている関数と，付いていない関数を分ける．

## 演習6-2：`IO`と`do`記法を試す

[Iteration 6で使う文法・概念](../../../../docs/haskell/iteration-6.md)を読み，GHCiで例を試す．
読み終えたら，GHCiで次を試す．

1. `import System.IO (readFile')`と入力し，`writeFile "/tmp/memo.txt" "a\nb\n"`，`appendFile "/tmp/memo.txt" "c\n"`，`readFile' "/tmp/memo.txt"`を順に評価する．
2. `:t readFile'`と`:t lines`を表示する．`lines (readFile' "/tmp/memo.txt")`がコンパイルエラーになる理由を，2つの型から説明する．
3. ファイルの行数を返すアクション`countLines :: FilePath -> IO Int`を，`do`記法で定義する(`:{`と`:}`を使う)．
4. `import System.Environment (lookupEnv)`と入力し，`lookupEnv "HOME"`と`lookupEnv "KAKEIBO_FILE"`を評価する．

## 演習6-3：テストリストを書く

次の要求を読み，[TESTLIST.md](../TESTLIST.md)にテストリストを書く．

### 要求

- 1つ目の引数でサブコマンドを選ぶ．
  - `add 費目:金額 …`：支出をデータファイルの末尾に追記し，追加した支出を`追加しました: 費目 金額`の形で1件ずつ表示する．支出は1つ以上並べる．
  - `list`：データファイルの支出を1件ずつ表示し，最後に`合計: 〜円`を表示する．
  - `summary`：費目ごとの小計を金額の大きい順に1行ずつ(`費目 金額`の形で)表示し，最後に`合計: 〜円`を表示する．
- `list`と`summary`は，支出が1件もなければ`支出はありません`と表示する．データファイルがまだないときも，支出が0件として扱う．
- `add`の支出に1つでも誤りがあれば，これまでと同じエラーメッセージを表示し，何も追記しない．
- サブコマンドがない，知らないサブコマンド，`add`の後ろに支出がない，`list`・`summary`の後ろに余分な引数がある，のいずれかなら，次の使い方を表示する．

  ```
  使い方: kakeibo add 費目:金額 … | kakeibo list | kakeibo summary
  ```

- データファイルは，支出1件を`費目の名前<タブ>金額`の1行で表すテキストファイルである(例：`食費	1200`)．
- データファイルに読めない行があれば，`データファイルのパス: N行目を読めません`というエラーメッセージを表示する．
- データファイルのパスは環境変数`KAKEIBO_FILE`で指定する．指定がなければ，実行した場所の`kakeibo.tsv`を使う．
- エラーメッセージは，これまでどおり標準エラー出力に表示し，終了コード1で終わる．

### 作るもの

| モジュール | 型・関数 | 役割 |
|---|---|---|
| `Kakeibo.Report` | `listReport :: [Entry] -> [String]` | `list`で表示する行を作る． |
| `Kakeibo.Report` | `summaryReport :: [Entry] -> [String]` | `summary`で表示する行を作る． |
| `Kakeibo.Storage` | `encodeEntry :: Entry -> String` | 支出1件をデータファイルの1行にする． |
| `Kakeibo.Storage` | `decodeEntry :: String -> Maybe Entry` | データファイルの1行を読み取る． |
| `Kakeibo.Storage` | `decodeEntries :: String -> Either String [Entry]` | データファイルの中身全体を読み取る．読めない行があれば`N行目を読めません`を返す． |
| `Kakeibo.Storage` | `loadEntries :: FilePath -> IO (Either String [Entry])` | データファイルを読み込む．ファイルがなければ`Right []`． |
| `Kakeibo.Storage` | `appendEntries :: FilePath -> [Entry] -> IO ()` | データファイルに支出を追記する． |
| `Kakeibo.Command` | `data Command = Add [Entry] \| List \| Summary` | サブコマンド． |
| `Kakeibo.Command` | `parseCommand :: [String] -> Either String Command` | コマンドライン引数からサブコマンドを読み取る． |
| `Kakeibo.Command` | `usage :: String` | 使い方の説明． |
| `Kakeibo.App` | `run :: FilePath -> [String] -> IO (Either String [String])` | データファイルのパスと引数を受け取り，サブコマンドを実行する．(型を変更) |

`app/Main.hs`は，環境変数からデータファイルのパスを決めて`run`に渡すように変える．

### 考えること

- 純粋な関数(`IO`の型が付かない関数)と，`IO`の関数はどれか．それぞれ，単体テストと結合テストのどちらで確かめるか．
- 既存の結合テスト(`run`の引数で支出を渡すもの)は，このIterationの`run`ではどう書き換わるか．今の`run`のテストで確かめている表示の規則は，新しいどの関数の単体テストに移せるか．
- 結合テストでは，データファイルをどこに作るか．テストどうしが同じデータファイルを使うと何が起きるか．
- 環境変数`KAKEIBO_FILE`の扱いは，自動のテストと手での確認のどちらで確かめるか．

## 演習6-4：設計書を更新する

このIterationでは，システムの外から見た形が変わるので，4つの階層すべてを更新する．
書き方は[設計書の書き方](../../../../docs/design.md)を参照する．

- `01-context.md`：利用者が`kakeibo`をどう使うか(サブコマンド)を書き直す．
- `02-container.md`：データファイルを`ContainerDb`で足し，実行ファイルとの関係を描く．データファイルのパスの決め方は，図の下に書く．
- `03-component.md`：新しいモジュール(`Kakeibo.Command`・`Kakeibo.Report`・`Kakeibo.Storage`)を足す．`IO`を行うモジュールが増えるので，どのモジュールを`IO`の境界に入れるかを考える．純粋な関数と`IO`の関数の両方を持つモジュールは，どちらの境界に入れ，説明に何を書くかを決める．データファイルは，境界の外に`ContainerDb_Ext`で描ける．
- `04-code.md`：
  - データ型の図に`Command`を足す．
  - 型と関数の流れを，サブコマンドの読み取り，`list`・`summary`，データファイルの行と支出の変換，のように観点ごとの図に分ける．
  - `IO`の順序の図を，`add`と`list`・`summary`に分けて描く．データファイルへの読み書きがどの順で起きるかがわかるようにする．

演習6-3で考えた「純粋な関数」と「`IO`の関数」の分け方が，Componentの図の境界と一致していることを確かめる．
更新したら，`mise run lint`で図の構文を確かめる．

## 演習6-5：テスト駆動で実装する

新しい純粋な関数から作り，最後に`IO`でつなぐ．
`Kakeibo.App`を書き換えるまでは，既存のコードとテストはそのまま動く．

### 1. `Kakeibo.Report`

- `src/Kakeibo/Report.hs`と単体テストを作り，`exposed-modules`と`other-modules`に追記する．
- 今の`Kakeibo.App`の`report`が参考になる．`summary`の小計の行は，字下げせず，`費目別:`の見出しも付けない．
- 支出がない場合は，パターンマッチで分ける．

### 2. `Kakeibo.Storage`の純粋な関数

- `encodeEntry`は，`display`で費目の名前を，`show`で金額の数を文字列にする．`Yen`の中の`Int`は，パターンで取り出す．文字列の中のタブは`"\t"`と書く．
- `decodeEntry`は，Iteration 2で`:`を区切りにした`break`の使い方を，タブに置き換えて使える．金額は`parseAmount`で読む．
- `decodeEntries`は，`lines`で行に分けてから1行ずつ読む．行番号は`zip [1 :: Int ..] (lines contents)`で付けられる．読めない行があれば，そこで打ち切って`Left`を返す(Iteration 4の`parseEntries`と同じ形になる)．

### 3. `Kakeibo.Command`

- `add`の後ろの引数は，`parseEntries`で読む．
- `add`の後ろに1つ以上の引数があることは，パターン`"add" : args@(_ : _)`で表せる．
- どの形にも合わない引数は，最後の定義`parseCommand _ = Left usage`でまとめて扱う．

### 4. `Kakeibo.Storage`の`IO`の関数と`Kakeibo.App`

1. `library`の`build-depends`に`directory`を，`test-suite integration`の`build-depends`に`temporary`を追記する．
2. 結合テストを書き直す．テストごとに一時ディレクトリを作り，その中のデータファイルのパスを`run`に渡す．`System.IO.Temp`の`withSystemTempDirectory`を使う．
3. `loadEntries`と`appendEntries`を実装する．`loadEntries`は，`doesFileExist`でファイルがあるかを調べ，`if`で分ける．エラーメッセージの先頭には，データファイルのパスを付ける．
4. `run`を実装する．`parseCommand`の結果を`case`で分け，サブコマンドごとにデータファイルを読み書きする．
5. 結合テストの項目を1つずつRed→Greenにする．前の結合テストのうち，新しい`run`で書き直せないものは消す(確かめていた表示の規則は，`Kakeibo.Report`の単体テストに移っている)．

### 5. `main`

- `lookupEnv "KAKEIBO_FILE"`で環境変数を読み，`Nothing`なら`kakeibo.tsv`を使う．`Data.Maybe`の`fromMaybe`が使える．
- 最後に，「このIterationで作るもの」と同じ手順で，実際にファイルが作られ，表示されることを確かめる．`KAKEIBO_FILE`を指定しないで実行し，リポジトリ直下に`kakeibo.tsv`ができることも確かめる(確かめたら消す)．

## 演習6-6：振り返る

1. 自分の`TESTLIST.md`と，解答例の[TESTLIST.md](../../solution/TESTLIST.md)を比べる．
2. `decodeEntries`を純粋な関数にしたことで，「読めない行の行番号」のテストはどう書けたか．`loadEntries`の中で行ごとに処理していたら，テストはどうなっていたか．
3. 結合テストで一時ディレクトリを使わず，すべてのテストが同じ`kakeibo.tsv`を使っていたら，どんな問題が起きるか．
4. `kakeibo add 食費:1200 交通費:abc`で「何も追記しない」ことは，`run`の中のどの順番によって保証されているか．
5. 設計書と実装を見比べる．実装してみて，設計書と違う形になったところはあるか．あれば，設計書を実装に合わせて直す．

## 演習6-7(発展)：最後の支出を取り消す

最後に追加した支出を1件取り消すサブコマンド`undo`を作る．

```console
$ kakeibo undo
取り消しました: 食費 350円
```

1. 支出がないときの振る舞いを決め，テストリストに項目を足す．
2. 1項目ずつRed→Greenを回す．データファイルの書き換えには`writeFile`が使える．

発展課題でも，テストリストを書いたあとに設計書を更新してから実装し，実装したら設計書と見比べる．
