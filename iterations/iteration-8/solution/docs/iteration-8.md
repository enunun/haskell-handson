# Iteration 8：プロパティベーステスト(解説)

演習用の`docs/iteration-8.md`の各手順について，解答の例と考え方を説明する．

## 演習8-1：パッケージを登録してビルドする

`cabal.project`の`packages`に`iterations/iteration-8/exercise`を追記し，`cabal test kakeibo-iteration8`でテストを実行する．

## 演習8-2：QuickCheckを試す

`test-suite unit`の`build-depends`に`QuickCheck`を追記してから，GHCiを起動する．

```sh
cabal repl kakeibo-iteration8:test:unit
```

```console
ghci> import Test.QuickCheck
ghci> quickCheck (\xs -> length (reverse xs) == length (xs :: [Int]))
+++ OK, passed 100 tests.
ghci> quickCheck (\xs -> sum xs >= (0 :: Int))
*** Failed! Falsified (after 2 tests and 1 shrink):
[-1]
ghci> quickCheck (\(NonNegative n) -> n >= (0 :: Int))
+++ OK, passed 100 tests.
```

`sum xs >= 0`は，リストに負の数が入ると成り立たない．
QuickCheckは反例を縮め，`[-1]`という最も小さな反例を示す(反例の値と縮めた回数は，実行のたびに変わる)．

`display`の性質は，負の数も含めて成り立つ．
`display (Yen (-123))`は`"-,123円"`になるが，カンマを除くと`"-123円"`になり，`show (-123) ++ "円"`と等しいからである．
この表示の誤りは，演習8-7で扱う．

`sample (choose (1, 12) :: Gen Int)`は，1から12までのランダムな数を11個表示する．

## 演習8-3：テストリストを書く

解答例のテストリストは[TESTLIST.md](../TESTLIST.md)である．

- 「変換して逆変換すると元に戻る」組は，`display`と`parseCategory`(費目)，`display`と`parseDate`(日付)，`encodeEntry`と`decodeEntry`(データファイルの1行)，`encodeEntry`と`decodeEntries`(データファイル全体)，引数の組み立てと`parseCommand`の5つを使った．
- 金額が正であること，日付が存在することは，ジェネレータで表した．`parseAmount`の性質のように，前提そのものを確かめたいときは，`Positive`・`NonNegative`で性質の側に書いた．
- 例のテストは残す．例のテストは「この入力ならこの出力」という仕様を読める形で示し，失敗したときにどの場合が壊れたかがすぐわかる．性質のテストは，例では試しきれない入力まで確かめる．

## 演習8-4：設計書を更新する

解答例の設計書は[../design/](../design/)にある．
Iteration 7からの変更点は，`04-code.md`の「満たすべき性質」の節だけである．
ライブラリと実行ファイルは変わらないので，Context・Container・Componentの図は変わらない．

- 変換して逆変換すると元に戻る組(`encodeEntry`と`decodeEntry`，`encodeEntry`と`decodeEntries`，`display`と`parseDate`，`display`と`parseCategory`，引数の組み立てと`parseCommand`)を，行きと帰りの矢印の図で描いた．
- 小計の和が合計に等しい性質を，2つの道筋で求めた`Yen`が等しい，という図にした．
- 並び順や`Yen`の法則など，図にしにくい性質は箇条書きにした．
- 性質の前提として，ジェネレータが作る値の範囲を表にした．

性質の図と`prop`の説明の文をそろえておくと，テストが失敗したときに，設計書のどの性質が破れたのかを追える．

## 演習8-5：テスト駆動で実装する

### 1. cabalの準備

```cabal
test-suite unit
    type:               exitcode-stdio-1.0
    hs-source-dirs:     test/unit test/common
    main-is:            Spec.hs
    other-modules:
        Kakeibo.CommandSpec
        Kakeibo.DateSpec
        Kakeibo.EntrySpec
        Kakeibo.Generators
        Kakeibo.MoneySpec
        Kakeibo.ReportSpec
        Kakeibo.StorageSpec
        Kakeibo.SummarySpec
    build-depends:
        base >=4.18 && <5,
        hspec,
        QuickCheck,
        kakeibo-iteration8

test-suite integration
    type:               exitcode-stdio-1.0
    hs-source-dirs:     test/integration test/common
    main-is:            Spec.hs
    other-modules:
        Kakeibo.AppSpec
        Kakeibo.Generators
    build-depends:
        base >=4.18 && <5,
        hspec,
        QuickCheck,
        temporary,
        kakeibo-iteration8
```

### 2. 標準の型で書ける性質

```haskell
-- test/unit/Kakeibo/MoneySpec.hs
{- HLINT ignore "Monoid law, left identity" -}
{- HLINT ignore "Monoid law, right identity" -}
module Kakeibo.MoneySpec (spec) where

import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (Large (..), NonNegative (..))

  describe "Yenの性質" $ do
    prop "<>は，まとめる順番によらない(結合法則)" $ \a b c ->
      (Yen a <> Yen b) <> Yen c `shouldBe` Yen a <> (Yen b <> Yen c)
    prop "memptyは，<>の相手を変えない(単位元)" $ \a ->
      (mempty <> Yen a, Yen a <> mempty) `shouldBe` (Yen a, Yen a)
    prop "totalは，中の数の和になる" $ \ns ->
      total (map Yen ns) `shouldBe` Yen (sum ns)
    prop "0以上の金額のdisplayからカンマを除くと，数字の後ろに「円」を付けたものになる" $ \(NonNegative (Large n)) ->
      filter (/= ',') (display (Yen n)) `shouldBe` show n ++ "円"
    prop "0以上の金額のdisplayには，桁数に応じた数のカンマが入る" $ \(NonNegative (Large n)) ->
      length (filter (== ',') (display (Yen n))) `shouldBe` (length (show n) - 1) `div` 3
```

`display`の性質では，`\(NonNegative (Large n))`で0以上の大きな数も作る．
QuickCheckが作る数はふだん絶対値が100くらいまでに偏るので，`\(NonNegative n)`と書くと，カンマが入る4桁以上の数がほとんど作られず，3桁区切りの誤りを見つけられない．

単位元の性質は，2つの等式をタプルにまとめて1つの`shouldBe`で確かめている．
hlintは`mempty <> Yen a`を`Yen a`に書き換えるよう提案するが，法則そのものを確かめるテストなので，ファイルの先頭でその提案を止めた．

`Yen`の`<>`を`Yen a <> Yen b = Yen (a - b)`に壊すと，結合法則と単位元の性質が反例を示して失敗する．

```
Falsifiable (after 2 tests and 4 shrinks):
  0
  0
  1
```

反例の3つの数は`a`・`b`・`c`で，`(0 - 0) - 1`と`0 - (0 - 1)`が等しくないことを示している．
`total`は`mconcat`(つまり`<>`)で計算しているので，`total`の性質も失敗する．
反例が見つかるまでの回数と縮めた回数は，実行のたびに変わる．

`insertCommas`の`3`を`4`に変えると，カンマの数の性質が失敗する．
カンマを除く性質は，カンマの位置が変わっても成り立つので失敗しない．
1つの性質だけでは確かめきれないことがあり，性質を組み合わせて振る舞いを押さえる．

`parseAmount`の性質では，`NonNegative n`から作った`negate n`の型が決まらないので，`:: Int`で型を指定した．

```haskell
    prop "正の整数はparseAmountで読める" $ \(Positive n) ->
      parseAmount (show n) `shouldBe` Just (Yen n)
    prop "0以下の整数はparseAmountで読めない" $ \(NonNegative n) ->
      parseAmount (show (negate n :: Int)) `shouldBe` Nothing
```

### 3. ジェネレータを使う性質

```haskell
-- test/common/Kakeibo/Generators.hs
genCategory :: Gen Category
genCategory = elements [minBound .. maxBound]

genYen :: Gen Yen
genYen = Yen <$> choose (1, 10000000)

genDate :: Gen Date
genDate = Date <$> choose (2000, 2099) <*> choose (1, 12) <*> choose (1, 28)

genEntry :: Gen Entry
genEntry = Entry <$> genDate <*> genCategory <*> genYen
```

- 日は1日から28日までから選ぶ．28日まではどの月にもあるので，月と日を別々に選んでも，必ず存在する日付になる．29日から31日は，例のテスト(`parseDate`のうるう年や4月31日のテスト)で確かめている．
- 年は2000年から2099年にした．`display`は年を`show`で表示するので，4桁の年でないと`parseDate`で読み戻せない．家計簿の日付として十分な範囲である．

```haskell
-- test/unit/Kakeibo/StorageSpec.hs
  describe "データファイルの読み書きの性質" $ do
    prop "encodeEntryした行をdecodeEntryで読むと，元の支出に戻る" $
      forAll genEntry $ \e ->
        decodeEntry (encodeEntry e) `shouldBe` Just e
    prop "支出の並びを書いた中身をdecodeEntriesで読むと，元の並びに戻る" $
      forAll (listOf genEntry) $ \es ->
        decodeEntries (unlines (map encodeEntry es)) `shouldBe` Right es
```

```haskell
-- test/unit/Kakeibo/SummarySpec.hs
  describe "summarizeの性質" $ do
    prop "小計の和は，すべての支出の合計に等しい" $
      forAll (listOf genEntry) $ \es ->
        total (map snd (summarize es)) `shouldBe` total (map amount es)
    prop "同じ費目は1度しか現れない" $
      forAll (listOf genEntry) $ \es ->
        let categories = map fst (summarize es)
         in length (nub categories) `shouldBe` length categories
    prop "小計は，大きい順に並ぶ" $
      forAll (listOf genEntry) $ \es ->
        let subtotals = map snd (summarize es)
         in and (zipWith (>=) subtotals (drop 1 subtotals)) `shouldBe` True
```

`summarize`の`sortOn (Down . snd)`を`sortOn snd`に壊すと，「大きい順に並ぶ」性質が，2つ以上の費目を含む反例で失敗する．

`Kakeibo.Entry`・`Kakeibo.Date`・`Kakeibo.Command`の性質も同じ形で書いた．

```haskell
    prop "費目の名前をparseCategoryで読むと，元の費目に戻る" $
      forAll genCategory $ \c ->
        parseCategory (display c) `shouldBe` c

    prop "表示した日付をparseDateで読むと，元の日付に戻る" $
      forAll genDate $ \d ->
        parseDate (display d) `shouldBe` Just d

    prop "支出を表す引数をaddで読むと，元の支出になる" $
      forAll genEntry $ \e ->
        let Yen n = amount e
         in parseCommand ["add", display (date e), display (category e) ++ ":" ++ show n]
              `shouldBe` Right (Add [e])
```

### 4. 前提を外してみる

`genYen`を`Yen <$> arbitrary`にすると，3つの性質が失敗する．

```
  1) Kakeibo.Command.parseCommandの性質 支出を表す引数をaddで読むと，元の支出になる
       Falsifiable (after 1 test):
         Entry {date = Date {year = 2013, month = 8, day = 13}, category = Transport, amount = Yen 0}
       …
        but got: Left "金額は正の整数で書いてください: 交通費:0"

  2) Kakeibo.Storage.データファイルの読み書きの性質 encodeEntryした行をdecodeEntryで読むと，元の支出に戻る
       Falsifiable (after 1 test):
         Entry {date = Date {year = 2013, month = 8, day = 13}, category = Transport, amount = Yen 0}
       …
        but got: Nothing

  3) Kakeibo.Storage.データファイルの読み書きの性質 支出の並びを書いた中身をdecodeEntriesで読むと，元の並びに戻る
       Falsifiable (after 2 tests):
         [Entry {date = Date {year = 2020, month = 4, day = 7}, category = Transport, amount = Yen (-1)}]
```

0円や負の金額の支出は，`parseAmount`が誤りとして読まない．
Iteration 4で決めた「金額は正の整数」という要求どおりの振る舞いであり，実装の誤りではない．
ジェネレータが，要求の前提を満たさない支出を作っていたことが原因である．

`forAll`に自分で作ったジェネレータを渡した性質では，反例は縮められずにそのまま表示される．
`Positive`などの`Arbitrary`のインスタンスを使った性質では，QuickCheckが反例を縮める．

### 5. 結合テストの性質

```haskell
-- test/integration/Kakeibo/AppSpec.hs
  describe "runの性質" $ do
    prop "addした支出の合計が，listの最後の行に表示される" $
      forAll (listOf1 genEntry) $ \es -> ioProperty $
        withSystemTempDirectory "kakeibo" $ \dir -> do
          let path = dir ++ "/kakeibo.tsv"
          mapM_ (run path . addArgs) es
          result <- run path ["list"]
          pure (fmap last result == Right ("合計: " ++ display (total (map amount es))))
  where
    addArgs e = ["add", display (date e), display (category e) ++ ":" ++ show n]
      where
        Yen n = amount e
```

- `listOf1`で，支出が1件以上ある並びを作る．支出がなければ`list`は`支出はありません`の1行になり，合計の行がない．
- `fmap last result`は，`result`が`Right`なら最後の行を取り出す．`Left`ならそのまま`Left`になり，等式は成り立たない．
- `mapM_ (run path . addArgs) es`は，支出を1件ずつ`add`する．`run`の結果は使わないので`mapM_`で捨てる．

## 演習8-6：振り返る

1. 性質は人によって見つけ方が違う．`Report`の性質(「`listReport`の行数は支出の件数より1多い」など)を書いた人もいるだろう．
2. 前提の誤りだった．反例の`Yen 0`や`Yen (-1)`は，`add`の引数としても，データファイルの行としても，要求で誤りと決めた値である．
3. 例のテストが失敗すると，テストの説明と期待値から，どの場合が壊れたかがすぐわかる．性質のテストが失敗すると，反例を読んで原因を考える必要がある．その代わり，性質は例として思いつかなかった入力で誤りを見つける．両方を残し，仕様の説明は例で，広い確認は性質で受け持つ．
4. Iteration 1の3桁区切りの例(3桁，4桁，6桁，7桁)は，カンマの数の性質で，すべての桁数に広げて確かめられる．Iteration 6の`encodeEntry`・`decodeEntry`の例は，往復の性質で，すべての費目と金額に広げて確かめられる．
5. ジェネレータの年の範囲(2000年から2099年)は，`display`が年を`show`で表示するので4桁の年でないと読み戻せない，ということに実装で気付いて決めた．設計書の「性質の前提」を実装に合わせた．

## 演習8-7(発展)：マイナスの金額の表示を確かめる

「カンマの直前と直後は数字である」を性質にすると，負の金額で反例が見つかる．

```haskell
import Data.Char (isDigit)
import Test.QuickCheck (Large (..))

    prop "カンマの直前と直後は数字である" $ \(Large n) ->
      let s = display (Yen n)
          aroundCommas = [(a, b) | (a, ',', b) <- zip3 s (drop 1 s) (drop 2 s)]
       in all (\(a, b) -> isDigit a && isDigit b) aroundCommas `shouldBe` True
```

```
Falsifiable (after 11 tests and 3 shrinks):
  Large {getLarge = -100}
```

`\n -> …`と書くと，QuickCheckは絶対値の小さい数(-100から100くらい)ばかりを作るので，100回試しても反例の`-100`にほとんど当たらない．
`Large`を使うと，絶対値の大きい数も作られ，負の4桁・7桁の数などで反例が見つかる．
反例は縮められて，いちばん小さい`-100`が示される．

`display (Yen (-100))`は`"-,100円"`で，カンマの直前が`-`になる．
`show (-100)`の`-`も1桁として数えて3桁ごとに区切っているからである．
Iteration 1の発展課題と同じく，負の数は絶対値に3桁区切りを入れてから`-`を付ける．

```haskell
instance Display Yen where
  display (Yen n)
    | n < 0 = "-" ++ display (Yen (negate n))
    | otherwise = insertCommas (show n) ++ "円"
```

`[(a, b) | (a, ',', b) <- …]`はリスト内包表記で，右側のリストの要素のうちパターンに合うものから，左側の値のリストを作る．
