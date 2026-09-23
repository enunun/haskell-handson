-- 単位元の法則そのものを確かめるテストがあるので，hlintの「mempty <> xはxに書き換えられる」という提案は使わない．
{- HLINT ignore "Monoid law, left identity" -}
{- HLINT ignore "Monoid law, right identity" -}
module Kakeibo.MoneySpec (spec) where

import Kakeibo.Display (Display (..))
import Kakeibo.Money (Yen (..), total)
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (Large (..), NonNegative (..))

spec :: Spec
spec = do
  describe "Yen" $ do
    it "<>で金額を足し合わせる" $
      Yen 1200 <> Yen 350 `shouldBe` Yen 1550
    it "memptyは0円" $
      (mempty :: Yen) `shouldBe` Yen 0
  describe "total" $ do
    it "空のリストなら0円を返す" $
      total [] `shouldBe` Yen 0
    it "要素が1つなら，その値を返す" $
      total [Yen 1200] `shouldBe` Yen 1200
    it "複数の金額を足し合わせる" $
      total [Yen 1200, Yen 350, Yen 800] `shouldBe` Yen 2350
  describe "display" $ do
    it "金額の後ろに「円」を付ける" $
      display (Yen 350) `shouldBe` "350円"
    it "0円を表示する" $
      display (Yen 0) `shouldBe` "0円"
    it "4桁の金額は，上から1桁目の後ろにカンマを入れる" $
      display (Yen 1200) `shouldBe` "1,200円"
    it "3桁の金額にはカンマを入れない" $
      display (Yen 999) `shouldBe` "999円"
    it "6桁の金額は，上から3桁目の後ろにカンマを入れる" $
      display (Yen 123456) `shouldBe` "123,456円"
    it "7桁の金額は，3桁ごとにカンマを2つ入れる" $
      display (Yen 1234567) `shouldBe` "1,234,567円"
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
