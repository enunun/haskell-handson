# Iteration 8：プロパティベーステスト(演習)

## このIterationで作るもの

新しい機能は足さない．
これまでに作った関数が満たすべき性質を書き出し，QuickCheckでランダムに作った入力を使って確かめる．

```console
$ cabal test kakeibo-iteration8:test:unit
…
  データファイルの読み書きの性質
    encodeEntryした行をdecodeEntryで読むと，元の支出に戻る [✔]
      +++ OK, passed 100 tests.
…
```

これまでのテストは，具体的な例を1つずつ書いて確かめてきた．
このIterationでは，「どんな支出でも」「どんな日付でも」成り立つはずの性質を書き，例では試しきれない入力まで確かめる．

## 進め方

演習8-1から順に進める．
詰まったら，`../solution/docs/iteration-8.md`の同じ番号の節を読む．
コマンドはすべてリポジトリ直下で実行する．

## 演習8-1：パッケージを登録してビルドする

1. `cabal.project`の`packages`に，このパッケージのディレクトリを追記する．
2. このパッケージのテストをすべて実行し，引き継いだテストがすべて通ることを確かめる．

## 演習8-2：QuickCheckを試す

[Iteration 8で使う文法・概念](../../../../docs/haskell/iteration-8.md)を読む．

1. `test-suite unit`の`build-depends`に`QuickCheck`を追記する．
2. 単体テストのテストスイートを読み込んだGHCiを起動する．ターゲットは`パッケージ名:test:unit`の形で書く．
3. `import Test.QuickCheck`と入力し，次の性質を`quickCheck`で確かめる．成り立たないものは，反例を読み，なぜ成り立たないかを説明する．
   - `\xs -> length (reverse xs) == length (xs :: [Int])`
   - `\xs -> sum xs >= (0 :: Int)`
   - `\(NonNegative n) -> n >= (0 :: Int)`
4. `import Kakeibo.Money`と`import Kakeibo.Display`を入力し，`quickCheck (\n -> filter (/= ',') (display (Yen n)) == show n ++ "円")`を確かめる．
5. `sample (choose (1, 12) :: Gen Int)`を評価し，ジェネレータが作る値を見る．

## 演習8-3：テストリストを書く

次の要求を読み，[TESTLIST.md](../TESTLIST.md)に性質のリストを書く．

### 要求

- 新しい機能は足さず，既存の例のテストも残す．
- これまでに作った関数について，どんな入力でも成り立つはずの性質を書き出し，`prop`で確かめる．
- 少なくとも次のモジュールの関数について，性質を1つ以上書く．
  - `Kakeibo.Money`(`Yen`の`<>`・`mempty`，`total`，`display`)
  - `Kakeibo.Entry`(`parseCategory`，`parseAmount`)
  - `Kakeibo.Date`(`parseDate`，`display`，`inMonth`)
  - `Kakeibo.Storage`(`encodeEntry`，`decodeEntry`，`decodeEntries`)
  - `Kakeibo.Summary`(`summarize`)
  - `Kakeibo.Command`(`parseCommand`)
  - `Kakeibo.App`(`run`．結合テストとして)
- 自分で定義した型(`Category`・`Yen`・`Date`・`Entry`)の値は，テスト用のモジュール`Kakeibo.Generators`のジェネレータで作る．ジェネレータは，単体テストと結合テストの両方から使う．

### 作るもの

`test/common/Kakeibo/Generators.hs`に，次のジェネレータを作る．

| 関数 | 作る値 |
|---|---|
| `genCategory :: Gen Category` | すべての費目のどれか |
| `genYen :: Gen Yen` | 支出の金額として正しい金額 |
| `genDate :: Gen Date` | 存在する日付 |
| `genEntry :: Gen Entry` | 支出1件 |

### 考えること

- [性質の見つけ方](../../../../docs/haskell/iteration-8.md#性質の見つけ方)の表のそれぞれの形に当てはまる関数の組はどれか．たとえば，「変換して逆変換すると元に戻る」組はいくつあるか．
- 性質が成り立つための前提(金額は正，日付は存在する，など)は何か．その前提は，ジェネレータと性質のどちらで表すか．
- 既存の例のテストと性質のテストは，それぞれ何を確かめているか．例のテストを消してよいか．

## 演習8-4：設計書を更新する

このIterationでは，ライブラリと実行ファイルのコードは変えない．
演習8-3で書いた性質のリストを，設計書にも描く．
書き方は[設計書の書き方](../../../../docs/design.md)の「満たすべき性質」を参照する．

- `04-code.md`に「満たすべき性質」の節を足す．
  - 変換して逆変換すると元に戻る関数の組を，行きと帰りの矢印の図で描く．
  - 集計しても全体の量が変わらない，のような性質も図にする．
  - 図にしにくい性質(並び順，型クラスの法則など)は，図の下に箇条書きで書く．
- 性質が成り立つための前提(金額や日付の範囲)を書き，テスト用のジェネレータがその前提どおりの値を作ることを表にする．
- Context・Container・Componentの図は変わらないことを確かめる．

更新したら，`mise run lint`で図の構文を確かめる．

## 演習8-5：テスト駆動で実装する

このIterationでは実装を足さないので，テストを書いた時点で通ることが多い．
そこで，Redの代わりに，性質を書いたら実装をわざと壊して，QuickCheckが反例を見つけることを確かめる．
確かめたら，実装を元に戻す．
こうすると，書いた性質が実装の誤りを見つけられることを確かめられる．

### 1. cabalの準備

- `QuickCheck`を，両方のテストスイートの`build-depends`に追記する．
- `test/common/`を，両方のテストスイートの`hs-source-dirs`に追記する．`hs-source-dirs`には，複数のディレクトリを空白で区切って並べられる．
- `Kakeibo.Generators`を作ったら，両方のテストスイートの`other-modules`に追記する．

### 2. 標準の型で書ける性質

`Yen`の法則，`total`，`display`の性質は，`Int`やそのリストを受け取るラムダ式で書ける．

- `prop`は`Test.Hspec.QuickCheck`にある．
- 0以上の数だけを使いたいときは，`\(NonNegative n) -> …`と書く．
- QuickCheckが作る数は，ふだんは絶対値が100くらいまでに偏る．3桁区切りのように大きな数で確かめたい性質では，`\(NonNegative (Large n)) -> …`と書く．
- 壊し方の例：`Yen`の`<>`の`+`を`-`に変える．`insertCommas`の`3`を`4`に変える．

### 3. ジェネレータを使う性質

- `genCategory`は`elements`と`[minBound .. maxBound]`で，`genYen`・`genDate`は`choose`と`<$>`・`<*>`で作れる．
- `genDate`がどの月にもある日だけを作るようにするには，日をどの範囲から選べばよいかを考える．
- 性質は`forAll ジェネレータ $ \値 -> …`の形で書く．支出のリストは`listOf genEntry`で作れる．
- 壊し方の例：`encodeEntry`で費目と金額の順を入れ替える．`summarize`の`Down`を外す．`parseDate`の`daysInMonth`の2月の日数を変える．

### 4. 前提を外してみる

`genYen`を，一時的に`Yen <$> arbitrary`(0や負の数も作る)に変えて，単体テストを実行する．
どの性質が，どんな反例で成り立たなくなるかを読み，その理由を説明する．
説明できたら，`genYen`を元に戻す．

### 5. 結合テストの性質

- `run`で支出を`add`してから`list`し，最後の行の合計を確かめる性質を書く．
- `IO`の結果を性質にするには`ioProperty`を使う．
- 支出ごとに`add`の引数を作る関数(支出から`["add", 日付, "費目:金額"]`を作る関数)を用意すると書きやすい．

## 演習8-6：振り返る

1. 自分の`TESTLIST.md`と，解答例の[TESTLIST.md](../../solution/TESTLIST.md)を比べる．
2. 手順4で見つかった反例は，実装の誤りだったか，前提の誤りだったか．
3. 例のテストと性質のテストで，失敗したときのわかりやすさはどう違うか．両方を残す理由を説明する．
4. これまでのIterationのテストリストの項目のうち，性質で書き直すと確かめられる範囲が広がるものはどれか．
5. 設計書と実装を見比べる．実装してみて，設計書と違う形になったところはあるか．あれば，設計書を実装に合わせて直す．

## 演習8-7(発展)：マイナスの金額の表示を確かめる

`display (Yen n)`は，`n`が負のときにどう表示されるか．
「カンマの直前と直後は数字である」という性質を，負の数も含めて書き，QuickCheckに反例を探させる．
QuickCheckが作る`Int`は，ふだんは絶対値の小さい数に偏るので，大きな数も作る`\(Large n) -> …`を使う．
反例が見つかったら，マイナスの金額の表示の規則を決め，例のテストと性質で確かめながら直す．

発展課題でも，テストリストを書いたあとに設計書を更新してから実装し，実装したら設計書と見比べる．
