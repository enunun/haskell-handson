module Kakeibo.ReportSpec (spec) where

import Kakeibo.Entry (Category (..), Entry (..))
import Kakeibo.Money (Yen (..))
import Kakeibo.Report (listReport, summaryReport)
import Test.Hspec

spec :: Spec
spec = do
  describe "listReport" $ do
    it "支出がなければ，支出がないことを表示する" $
      listReport [] `shouldBe` ["支出はありません"]
    it "支出を1件ずつ表示し，最後に合計を表示する" $
      listReport [Entry Food (Yen 1200), Entry Transport (Yen 350), Entry Food (Yen 350)]
        `shouldBe` ["食費 1,200円", "交通費 350円", "食費 350円", "合計: 1,900円"]
  describe "summaryReport" $ do
    it "支出がなければ，支出がないことを表示する" $
      summaryReport [] `shouldBe` ["支出はありません"]
    it "費目ごとの小計を金額の大きい順に表示し，最後に合計を表示する" $
      summaryReport [Entry Food (Yen 350), Entry Transport (Yen 1200), Entry Food (Yen 350)]
        `shouldBe` ["交通費 1,200円", "食費 700円", "合計: 1,900円"]
