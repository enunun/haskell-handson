module Kakeibo.DateSpec (spec) where

import Kakeibo.Date
import Kakeibo.Display (Display (..))
import Kakeibo.Generators (genDate)
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (forAll)

spec :: Spec
spec = do
  describe "parseDate" $ do
    it "YYYY-MM-DDの形の日付を読み取る" $
      parseDate "2026-09-01" `shouldBe` Just (Date 2026 9 1)
    it "区切りが「-」でなければNothingを返す" $
      parseDate "2026/09/01" `shouldBe` Nothing
    it "月と日が2桁でなければNothingを返す" $
      parseDate "2026-9-1" `shouldBe` Nothing
    it "数でなければNothingを返す" $
      parseDate "2026-ab-01" `shouldBe` Nothing
    it "13月はNothingを返す" $
      parseDate "2026-13-01" `shouldBe` Nothing
    it "その月にない日はNothingを返す" $
      parseDate "2026-04-31" `shouldBe` Nothing
    it "うるう年の2月29日を読み取る" $
      parseDate "2028-02-29" `shouldBe` Just (Date 2028 2 29)
    it "うるう年でない年の2月29日はNothingを返す" $
      parseDate "2026-02-29" `shouldBe` Nothing
  describe "display(Date)" $ do
    it "月と日を2桁にして表示する" $
      display (Date 2026 9 1) `shouldBe` "2026-09-01"
    it "2桁の月と日はそのまま表示する" $
      display (Date 2026 12 31) `shouldBe` "2026-12-31"
  describe "parseYearMonth" $ do
    it "YYYY-MMの形の年月を読み取る" $
      parseYearMonth "2026-09" `shouldBe` Just (YearMonth 2026 9)
    it "月が2桁でなければNothingを返す" $
      parseYearMonth "2026-9" `shouldBe` Nothing
    it "13月はNothingを返す" $
      parseYearMonth "2026-13" `shouldBe` Nothing
  describe "inMonth" $ do
    it "同じ年月の日付ならTrueを返す" $
      inMonth (YearMonth 2026 9) (Date 2026 9 30) `shouldBe` True
    it "月が違えばFalseを返す" $
      inMonth (YearMonth 2026 9) (Date 2026 10 1) `shouldBe` False
    it "年が違えばFalseを返す" $
      inMonth (YearMonth 2026 9) (Date 2025 9 1) `shouldBe` False
  describe "Dateの性質" $ do
    prop "表示した日付をparseDateで読むと，元の日付に戻る" $
      forAll genDate $ \d ->
        parseDate (display d) `shouldBe` Just d
    prop "日付は，その日付の年月に含まれる" $
      forAll genDate $ \d ->
        inMonth (YearMonth (year d) (month d)) d `shouldBe` True
