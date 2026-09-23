module Kakeibo.SummarySpec (spec) where

import Data.List (nub)
import Kakeibo.Date (Date (..))
import Kakeibo.Entry (Category (..), Entry (..))
import Kakeibo.Generators (genEntry)
import Kakeibo.Money (Yen (..), total)
import Kakeibo.Summary (summarize)
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (forAll, listOf)

-- | 日付を問わない支出．
entry :: Category -> Int -> Entry
entry c n = Entry (Date 2026 9 1) c (Yen n)

spec :: Spec
spec = do
  describe "summarize" $ do
    it "支出がなければ空のリストを返す" $
      summarize [] `shouldBe` []
    it "支出が1件なら，その費目と金額だけを返す" $
      summarize [entry Daily 500] `shouldBe` [(Daily, Yen 500)]
    it "同じ費目の支出を足し合わせる" $
      summarize [entry Food 1200, entry Food 350] `shouldBe` [(Food, Yen 1550)]
    it "小計の大きい順に並べる" $
      summarize [entry Other 800, entry Transport 350, entry Food 1200]
        `shouldBe` [(Food, Yen 1200), (Other, Yen 800), (Transport, Yen 350)]
    it "小計が同じなら，費目の定義順に並べる" $
      summarize [entry Other 500, entry Food 500]
        `shouldBe` [(Food, Yen 500), (Other, Yen 500)]
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
