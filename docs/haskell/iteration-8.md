# Iteration 8：プロパティベーステスト

Iteration 8で使う文法と概念をまとめる．

## 例によるテストと性質によるテスト

これまでのテストは，具体的な入力と期待する出力の組(例)を書いて確かめてきた．
例によるテストは読みやすいが，確かめられるのは書いた例だけである．

プロパティベーステストでは，「どんな入力に対しても成り立つはずの性質」を関数として書く．
テストのライブラリがランダムな入力をたくさん作って性質を確かめ，成り立たない入力(反例)が見つかったら報告する．
Haskellでは，QuickCheckというライブラリがよく使われる．

```console
ghci> import Test.QuickCheck
ghci> quickCheck (\xs -> reverse (reverse xs) == (xs :: [Int]))
+++ OK, passed 100 tests.
ghci> quickCheck (\xs -> reverse xs == (xs :: [Int]))
*** Failed! Falsified (after 3 tests and 2 shrinks):
[0,1]
```

1つ目の性質「2回逆順にすると元に戻る」は，ランダムな100個のリストで成り立った．
2つ目の性質「逆順にしても変わらない」は，3個目のリストで成り立たなかった．
QuickCheckは，見つけた反例をより小さな値に縮め(shrink)，`[0,1]`という短い反例を示している．

GHCiで試すには，`QuickCheck`を依存に持つコンポーネントを`cabal repl`で読み込む(このIterationでは`cabal repl <パッケージ名>:test:unit`)．

## hspecで性質を書く

`Test.Hspec.QuickCheck`モジュールの`prop`は，性質を1つのテストケースにする．
`it`と同じように，説明と性質を渡す．

```haskell
import Test.Hspec.QuickCheck (prop)

spec :: Spec
spec = do
  describe "Yenの性質" $ do
    prop "totalは，中の数の和になる" $ \ns ->
      total (map Yen ns) `shouldBe` Yen (sum ns)
```

ラムダ式の引数`ns`が，QuickCheckが作るランダムな値である．
`ns`の型は，`map Yen ns`から`[Int]`に決まる．
性質の本体には，`shouldBe`を書ける．
成り立たなければ，反例と，`shouldBe`の期待値と実際の値が表示される．

性質を書くには，テストスイートの`build-depends`に`QuickCheck`を追加する．

## `Arbitrary`

QuickCheckは，ランダムな値の作り方を型クラス`Arbitrary`で決めている．
`Int`，`Char`，`String`，リスト，タプル，`Maybe`など，標準の型の多くは`Arbitrary`のインスタンスである．
性質のラムダ式の引数の型が`Arbitrary`のインスタンスなら，QuickCheckはその型の値を自動で作る．

ランダムな値に条件を付けるための型も用意されている．

| 型 | 作られる値 |
|---|---|
| `Positive a` | 正の数(`Positive 5`) |
| `NonNegative a` | 0以上の数(`NonNegative 0`) |
| `Large a` | 絶対値の大きい数も含む数．ふつうに作る数は絶対値が小さいものに偏る． |

パターンで中の値を取り出して使う．

```haskell
    prop "正の整数はparseAmountで読める" $ \(Positive n) ->
      parseAmount (show n) `shouldBe` Just (Yen n)
```

QuickCheckが作る数は，ふだんは絶対値が100くらいまでに偏る．
4桁以上の数で確かめたい性質では，`Large`を組み合わせて`\(NonNegative (Large n)) -> …`のように書く．
パターンは外側から順に，`NonNegative`の中の`Large`の中の数に`n`という名前を付ける．

## ジェネレータ

`Gen a`は，`a`型のランダムな値の作り方(ジェネレータ)を表す型である．
`Test.QuickCheck`モジュールに，ジェネレータを作る関数がある．

| 関数 | 型 | 作られる値 |
|---|---|---|
| `choose` | `(a, a) -> Gen a` | 範囲の中の値．`choose (1, 12)`は1から12． |
| `elements` | `[a] -> Gen a` | リストの要素のどれか． |
| `listOf` | `Gen a -> Gen [a]` | ジェネレータで作った値のリスト(空のリストも含む)． |
| `listOf1` | `Gen a -> Gen [a]` | ジェネレータで作った値の，空でないリスト． |
| `arbitrary` | `Arbitrary a => Gen a` | `Arbitrary`のインスタンスが決める値． |

`Gen`は`Functor`・`Applicative`・`Monad`のインスタンスである．
Iteration 7で学んだ`<$>`と`<*>`で，ジェネレータを組み合わせて新しいジェネレータを作れる．

```haskell
genDate :: Gen Date
genDate = Date <$> choose (2000, 2099) <*> choose (1, 12) <*> choose (1, 28)

genEntry :: Gen Entry
genEntry = Entry <$> genDate <*> genCategory <*> genYen
```

`forAll`は，ジェネレータで作った値について性質を確かめる．

```haskell
    prop "encodeEntryした行をdecodeEntryで読むと，元の支出に戻る" $
      forAll genEntry $ \e ->
        decodeEntry (encodeEntry e) `shouldBe` Just e
```

### インスタンスではなくジェネレータを作る理由

`Entry`などを`Arbitrary`のインスタンスにすれば，`forAll`を書かずに`\e -> …`と書ける．
ただし，インスタンスは，型を定義したモジュールか，型クラスを定義したモジュールに書くのが慣習である．
`Entry`は`Kakeibo.Entry`で，`Arbitrary`は`QuickCheck`のモジュールで定義されているので，テストのモジュールに書いたインスタンスはどちらでもない場所のインスタンス(orphan instance)になり，`-Wall`で警告が出る．
ライブラリを`QuickCheck`に依存させないためにも，このハンズオンでは，テストのモジュールにジェネレータを関数として作り，`forAll`で使う．

## ジェネレータは，値の前提を表す

ジェネレータは，性質が成り立つための前提を表す．
たとえば，支出の金額は正の整数でなければならない．
金額を`Yen <$> arbitrary`(0や負の数も作る)で作ると，保存して読み戻す性質は成り立たない．

```
Falsifiable (after 1 test):
  Entry {date = …, category = Transport, amount = Yen 0}
expected: Just (Entry {…, amount = Yen 0})
 but got: Nothing
```

`decodeEntry`は，0円の支出を誤りとして読まない．
これは誤りではなく，「保存される支出の金額は正である」という前提を，ジェネレータが守っていなかったことを示している．
ジェネレータを`Yen <$> choose (1, 10000000)`にすると，前提を満たす値だけが作られる．
反例が見つかったら，実装の誤りなのか，性質や前提の書き方の誤りなのかを考える．

## 性質の見つけ方

性質は，次のような形で見つかることが多い．

| 形 | 例 |
|---|---|
| 変換して逆変換すると元に戻る | `decodeEntry (encodeEntry e) == Just e`，`parseDate (display d) == Just d` |
| 別の方法で計算した結果と一致する | `total (map Yen ns) == Yen (sum ns)` |
| 全体の量が変わらない | 小計の和が，すべての支出の合計に等しい |
| 結果が満たす条件 | 小計が大きい順に並んでいる，同じ費目が2度現れない |
| 型クラスの法則 | `<>`の結合法則，`mempty`が単位元 |

## `IO`の性質

`ioProperty`は，`IO`のアクションが返す`Bool`を性質にする．
ファイルを読み書きする処理の性質を確かめるときに使う．

```haskell
    prop "addした支出の合計が，listの最後の行に表示される" $
      forAll (listOf1 genEntry) $ \es -> ioProperty $
        withSystemTempDirectory "kakeibo" $ \dir -> do
          let path = dir ++ "/kakeibo.tsv"
          mapM_ (run path . addArgs) es
          result <- run path ["list"]
          pure (fmap last result == Right ("合計: " ++ display (total (map amount es))))
```

ランダムな支出の並びごとに一時ディレクトリを作るので，1つの性質で100回データファイルを作り直す．

## ライブラリの関数

| 関数 | モジュール | 意味 |
|---|---|---|
| `nub` | `Data.List` | 重複を取り除いたリストを返す． |
| `and` | Prelude | `Bool`のリストがすべて`True`なら`True`． |
| `zipWith` | Prelude | 2つのリストの要素を先頭から組にして関数を適用する．`zipWith (>=) xs (drop 1 xs)`は，隣り合う要素を比べる． |
| `last` | Prelude | リストの最後の要素．空のリストには使えない． |

## テストスイートどうしでモジュールを共有する

ジェネレータは，単体テストと結合テストの両方で使う．
`test/common/`に置き，両方のテストスイートの`hs-source-dirs`に並べて書く．

```cabal
test-suite unit
    hs-source-dirs:     test/unit test/common
    other-modules:
        Kakeibo.Generators
        …
```

hspec-discoverは`Spec.hs`があるディレクトリ(`test/unit`)の中の`〜Spec.hs`だけを集めるので，`test/common/`のモジュールはテストとしては実行されない．

## hlintの提案を止める

hlintは，`mempty <> x`を`x`に書き換えるよう提案する．
単位元の法則そのものを確かめるテストでは，その書き換えはできない．
ファイルの先頭に`{- HLINT ignore "提案の名前" -}`と書くと，そのファイルでは指定した提案をしなくなる．

```haskell
{- HLINT ignore "Monoid law, left identity" -}
module Kakeibo.MoneySpec (spec) where
```
