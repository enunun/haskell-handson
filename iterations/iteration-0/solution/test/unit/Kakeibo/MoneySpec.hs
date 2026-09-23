module Kakeibo.MoneySpec (spec) where

import Kakeibo.Money (formatYen, total)
import Test.Hspec

spec :: Spec
spec = do
  describe "total" $ do
    it "空のリストなら0を返す" $
      total [] `shouldBe` 0
    it "要素が1つなら，その値を返す" $
      total [1200] `shouldBe` 1200
    it "複数の金額を足し合わせる" $
      total [1200, 350, 800] `shouldBe` 2350
  describe "formatYen" $ do
    it "金額の後ろに「円」を付ける" $
      formatYen 1200 `shouldBe` "1200円"
    it "0円を表示する" $
      formatYen 0 `shouldBe` "0円"
