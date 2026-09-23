# Component：モジュール

実行ファイル`kakeibo`を構成するモジュールと，その依存関係を示す．

```mermaid
C4Component
  title kakeibo実行ファイルのコンポーネント
  Container_Boundary(cli, "kakeibo実行ファイル") {
    Boundary(io, "IOを行う部分") {
      Component(main, "Main", "app/Main.hs", "引数と環境変数を読み，runが返した行かエラーメッセージを表示する")
      Component(app, "Kakeibo.App", "src/Kakeibo/App.hs", "サブコマンドを実行する")
      Component(storage, "Kakeibo.Storage", "src/Kakeibo/Storage.hs", "データファイルの読み書き．行と支出の変換は純粋な関数")
    }
    Boundary(pure, "純粋な部分") {
      Component(command, "Kakeibo.Command", "src/Kakeibo/Command.hs", "引数からサブコマンドを読み取る")
      Component(report, "Kakeibo.Report", "src/Kakeibo/Report.hs", "list・summaryで表示する行を作る")
      Component(summary, "Kakeibo.Summary", "src/Kakeibo/Summary.hs", "費目ごとの小計を求め，金額の大きい順に並べる")
      Component(entry, "Kakeibo.Entry", "src/Kakeibo/Entry.hs", "費目と支出の型と，引数の読み取り")
      Component(money, "Kakeibo.Money", "src/Kakeibo/Money.hs", "金額の型Yenと合計")
      Component(display, "Kakeibo.Display", "src/Kakeibo/Display.hs", "表示のための型クラスDisplay")
    }
  }
  ContainerDb_Ext(file, "データファイル", "TSV", "支出を1行1件で保存する")
  Rel(main, app, "run")
  Rel(app, command, "parseCommand")
  Rel(app, storage, "loadEntries, appendEntries")
  Rel(app, report, "listReport, summaryReport")
  Rel(storage, file, "readFile', appendFile")
  Rel(storage, entry, "parseCategory, parseAmount")
  Rel(command, entry, "parseEntries")
  Rel(report, summary, "summarize")
  Rel(report, money, "total")
  Rel(summary, entry, "Category, Entry")
  Rel(entry, money, "Yen")
  Rel(report, display, "display")
  Rel(app, entry, "Entry")
  Rel(app, display, "display")
  Rel(report, entry, "Entry")
  Rel(storage, money, "Yen")
  Rel(storage, display, "display")
  Rel(summary, money, "Yen")
  Rel(entry, display, "instance Display")
  Rel(money, display, "instance Display")
```

- `IO`を行うのは`Main`，`Kakeibo.App`の`run`，`Kakeibo.Storage`の`loadEntries`と`appendEntries`である．
- 引数の読み取り，データファイルの行の変換(`encodeEntry`・`decodeEntry`・`decodeEntries`)，表示する行の組み立ては，すべて純粋な関数にし，単体テストで確かめる．
- `IO`の関数は，「読む」「純粋な関数に渡す」「書く」をつなぐだけにし，結合テストで確かめる．
- `Kakeibo.Summary`は`Data.Map.Strict`(`containers`パッケージ)を，`Kakeibo.Storage`は`System.Directory`(`directory`パッケージ)を使う．
