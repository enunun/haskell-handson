# Component：モジュール

実行ファイル`kakeibo`を構成するモジュールと，その依存関係を示す．

```mermaid
C4Component
  title kakeibo実行ファイルのコンポーネント
  Container_Boundary(cli, "kakeibo実行ファイル") {
    Boundary(io, "IOを行う部分") {
      Component(main, "Main", "app/Main.hs", "コマンドライン引数を読み，runが返した行かエラーメッセージを表示する")
    }
    Boundary(pure, "純粋な部分") {
      Component(app, "Kakeibo.App", "src/Kakeibo/App.hs", "コマンドライン引数から，表示する行を作る")
      Component(summary, "Kakeibo.Summary", "src/Kakeibo/Summary.hs", "費目ごとの小計を求め，金額の大きい順に並べる")
      Component(entry, "Kakeibo.Entry", "src/Kakeibo/Entry.hs", "費目と支出の型と，引数の読み取り")
      Component(money, "Kakeibo.Money", "src/Kakeibo/Money.hs", "金額の型Yenと合計")
      Component(display, "Kakeibo.Display", "src/Kakeibo/Display.hs", "表示のための型クラスDisplay")
    }
  }
  Component_Ext(map, "Data.Map.Strict", "containersパッケージ", "キーから値を引ける表")
  Rel(main, app, "run")
  Rel(app, entry, "parseEntries")
  Rel(app, summary, "summarize")
  Rel(app, money, "total")
  Rel(app, display, "display")
  Rel(summary, entry, "Category, Entry")
  Rel(summary, money, "Yen")
  Rel(summary, map, "fromListWith, toList")
  Rel(entry, money, "Yen")
  Rel(entry, display, "instance Display")
  Rel(money, display, "instance Display")
```

- `IO`を行うのは`Main`だけである．計算はすべて純粋な関数にし，単体テストと結合テストから直接呼べるようにする．
- 表示の規則は，各型の`Display`のインスタンスに置く．表示する側は，型によらず`display`を呼ぶ．
