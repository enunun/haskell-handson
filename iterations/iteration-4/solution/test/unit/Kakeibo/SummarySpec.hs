module Kakeibo.SummarySpec (spec) where

import Kakeibo.Entry (Category (..), Entry (..))
import Kakeibo.Summary (summarize)
import Test.Hspec

spec :: Spec
spec = do
  describe "summarize" $ do
    it "支出がなければ空のリストを返す" $
      summarize [] `shouldBe` []
    it "支出が1件なら，その費目と金額だけを返す" $
      summarize [Entry Daily 500] `shouldBe` [(Daily, 500)]
    it "同じ費目の支出を足し合わせる" $
      summarize [Entry Food 1200, Entry Food 350] `shouldBe` [(Food, 1550)]
    it "費目の定義順に並べる" $
      summarize [Entry Other 800, Entry Transport 350, Entry Food 1200]
        `shouldBe` [(Food, 1200), (Transport, 350), (Other, 800)]
