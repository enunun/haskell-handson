module Kakeibo.SummarySpec (spec) where

import Kakeibo.Entry (Category (..), Entry (..))
import Kakeibo.Money (Yen (..))
import Kakeibo.Summary (summarize)
import Test.Hspec

spec :: Spec
spec = do
  describe "summarize" $ do
    it "支出がなければ空のリストを返す" $
      summarize [] `shouldBe` []
    it "支出が1件なら，その費目と金額だけを返す" $
      summarize [Entry Daily (Yen 500)] `shouldBe` [(Daily, Yen 500)]
    it "同じ費目の支出を足し合わせる" $
      summarize [Entry Food (Yen 1200), Entry Food (Yen 350)] `shouldBe` [(Food, Yen 1550)]
    it "小計の大きい順に並べる" $
      summarize [Entry Other (Yen 800), Entry Transport (Yen 350), Entry Food (Yen 1200)]
        `shouldBe` [(Food, Yen 1200), (Other, Yen 800), (Transport, Yen 350)]
    it "小計が同じなら，費目の定義順に並べる" $
      summarize [Entry Other (Yen 500), Entry Food (Yen 500)]
        `shouldBe` [(Food, Yen 500), (Other, Yen 500)]
