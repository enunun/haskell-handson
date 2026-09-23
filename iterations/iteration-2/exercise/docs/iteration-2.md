# Iteration 2：費目付きの入力と明細(演習)

## このIterationで作るもの

支出を`費目:金額`の形で入力できるようにする．
支出を1件ずつ明細として表示し，最後に合計を表示する．

```console
$ cabal run kakeibo-iteration2 -- 食費:1200 交通費:350
食費 1,200円
交通費 350円
合計: 1,550円
```

作りながら，`data`による型の定義，レコード，`deriving`，`case`式，タプルを学ぶ．

## 進め方

演習2-1から順に進める．
詰まったら，`../solution/docs/iteration-2.md`の同じ番号の節を読む．
コマンドはすべてリポジトリ直下で実行する．

## 演習2-1：パッケージを登録してビルドする

1. `cabal.project`の`packages`に，このパッケージのディレクトリを追記する．
2. このパッケージのテストをすべて実行し，引き継いだテストがすべて通ることを確かめる．
3. このパッケージの実行ファイルを，引数`食費:1200`で実行する．何が起きるかを確かめ，その理由を考える．

## 演習2-2：データ型と`case`式を試す

[Iteration 2で使う文法・概念](../../../../docs/haskell/iteration-2.md)を読み，GHCiで例を試す．
読み終えたら，GHCiで次を試す．

1. 信号の色を表す型`data Signal = Red | Yellow | Green deriving (Show, Eq)`を定義する．`Red`を評価し，`Red == Green`を評価する．
2. 定義を`data Signal = Red | Yellow | Green`(`deriving`なし)にして，もう一度`Red`を評価する．どんなエラーが出るかを読む．
3. 色から「止まれ」「注意」「進め」を返す関数を，パターンマッチで定義する．
4. `break`で`"交通費:350"`を分ける．結果のタプルの2つ目の要素から，`:`を除いた`"350"`を取り出す式を，`case`式で書く．

## 演習2-3：テストリストを書く

次の要求を読み，[TESTLIST.md](../TESTLIST.md)にテストリストを書く．

### 要求

- 支出を`費目:金額`の形の引数で入力する．
- 費目は「食費」「交通費」「日用品」「その他」の4つである．それ以外の名前は「その他」として扱う．
- `:`がない引数は，全体を金額とし，費目を「その他」とする．
- 支出を入力の順に1件ずつ`費目 金額`の形で表示し，最後に`合計: 〜円`を表示する．
- 引数がないときは，これまでどおり`支出はありません`と表示する．

### 使い方の例

```console
$ kakeibo 食費:1200 交通費:350
食費 1,200円
交通費 350円
合計: 1,550円
$ kakeibo 書籍:1500 800
その他 1,500円
その他 800円
合計: 2,300円
```

### 作るもの

新しいモジュール`Kakeibo.Entry`を作り，費目と支出を表す型を定義する．

```haskell
-- | 支出の費目．
data Category
  = Food
  | Transport
  | Daily
  | Other
  deriving (Show, Eq)

-- | 支出1件．
data Entry = Entry
  { category :: Category,
    amount :: Int
  }
  deriving (Show, Eq)
```

| モジュール | 関数 | 役割 |
|---|---|---|
| `Kakeibo.Entry` | `parseCategory :: String -> Category` | 費目の名前から費目を求める． |
| `Kakeibo.Entry` | `categoryName :: Category -> String` | 費目の名前を返す． |
| `Kakeibo.Entry` | `parseEntry :: String -> Entry` | `費目:金額`という引数を読み取る． |
| `Kakeibo.Entry` | `formatEntry :: Entry -> String` | 支出1件を`費目 金額`という1行にする． |
| `Kakeibo.App` | `run :: [String] -> [String]` | 明細と合計を表示するように変える．型は変えない． |

このIterationでも，金額は整数として読める前提でよい．

### 考えること

- 既存のテストのうち，期待値が変わるものはどれか．
- `parseCategory`と`categoryName`は，4つの費目それぞれを確かめる必要があるか．
- `parseEntry`には，引数の形が何通りあるか．
- 明細の表示の細かい形は単体テスト(`formatEntry`)で，並び順と合計は結合テスト(`run`)で確かめる，というように役割を分けられるか．

## 演習2-4：設計書を更新する

`design/`の設計書を，このIterationの要求に合わせて更新する．
書き方は[設計書の書き方](../../../../docs/design.md)を参照する．

- Context・Containerの図の説明を，「費目付きの支出」「明細」が伝わるように直す．
- `03-component.md`に，新しいモジュール`Kakeibo.Entry`を足す．どのモジュールがどのモジュールを使うかを考え，矢印を引く．
- `04-code.md`に「データ型」の節を足し，`Category`と`Entry`を`classDiagram`で描く．
- 型と関数の流れを，`Entry`を通る形に描き直す．明細の行と合計の行がどこで分かれ，どこでつながるかがわかるようにする．
- `parseEntry`の中の場合分け(`:`があるかどうか)を，別の図として描く．

更新したら，`mise run lint`で図の構文を確かめる．

## 演習2-5：テスト駆動で実装する

テストリストの項目を1つずつRed→Greenにする．

### モジュールを作る

1. `src/Kakeibo/Entry.hs`を作る．モジュールの宣言と，「作るもの」の2つの型の定義だけを書く．エクスポートリストでは，型とデータコンストラクタ・フィールド名を`Category (..)`，`Entry (..)`の形で公開する．
2. このパッケージの`.cabal`ファイルの`library`の`exposed-modules`に，`Kakeibo.Entry`を追記する．
3. パッケージをビルドし，コンパイルが通ることを確かめる．
4. `test/unit/Kakeibo/EntrySpec.hs`を作り，`test-suite unit`の`other-modules`に追記する．`other-modules`に複数のモジュールを書くときは，1行に1つずつ並べる．

   ```cabal
       other-modules:
           Kakeibo.EntrySpec
           Kakeibo.MoneySpec
   ```

まだない関数をテストで呼ぶと，テストのコンパイルが`Variable not in scope`で失敗する．
そのときは，関数の型シグネチャと`error "TODO"`だけを`Kakeibo.Entry`に書き，エクスポートリストに足してから，テストの失敗(Red)を確かめる．

### 各関数のヒント

- `parseCategory`は，文字列のリテラルのパターンで定義を分けられる．
- `parseEntry`は，`break`で`:`の手前と後ろに分け，`case`式で`:`があった場合となかった場合を分ける．金額は`read`で読む．
- `formatEntry`は，`Kakeibo.Money`の`formatYen`を使う．フィールドの値は，フィールド名の関数で取り出す．
- テストで`Entry`の値を作るときは，`Entry {category = Food, amount = 1200}`のようにフィールド名を書くと読みやすい．

### `run`

- 引数のリストを`map parseEntry`で`Entry`のリストにする．
- 明細の行は`map formatEntry`で作れる．合計の行を後ろにつなげるには`++`を使う．
- 合計を計算する`total`は`[Int]`を受け取るので，`Entry`のリストから金額のリストを作る．

## 演習2-6：振り返る

1. 自分の`TESTLIST.md`と，解答例の[TESTLIST.md](../../solution/TESTLIST.md)を比べる．
2. `Entry`の定義から`deriving (Show, Eq)`を消すと，テストのコンパイルはどうなるか．エラーメッセージを読み，なぜ必要なのかを説明する．
3. `Category`に新しい費目`Entertainment`を足すと，コンパイル時にどんな警告が出るか．試してから元に戻す．
4. Iteration 1の`run ["1200", "350", "800"]`の結合テストは，このIterationでどう変わったか．振る舞いが変わった理由を，要求のどの項目から説明できるか．
5. 設計書と実装を見比べる．実装してみて，設計書と違う形になったところはあるか．あれば，設計書を実装に合わせて直す．

## 演習2-7(発展)：費目「娯楽」を足す

費目に「娯楽」を足す．

```console
$ kakeibo 娯楽:3000
娯楽 3,000円
合計: 3,000円
```

1. テストリストに項目を足してから，1項目ずつRed→Greenを回す．
2. `Category`にデータコンストラクタを足したときの警告を手がかりに，直す場所を探す．

発展課題でも，テストリストを書いたあとに設計書を更新してから実装し，実装したら設計書と見比べる．
