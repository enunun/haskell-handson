module Kakeibo.CommandSpec (spec) where

import Kakeibo.Command (Command (..), parseCommand, usage)
import Kakeibo.Date (Date (..), YearMonth (..))
import Kakeibo.Entry (Category (..), Entry (..))
import Kakeibo.Money (Yen (..))
import Test.Hspec

spec :: Spec
spec = do
  describe "parseCommand" $ do
    it "addの後ろの日付と支出を読み取る" $
      parseCommand ["add", "2026-09-01", "食費:1200"]
        `shouldBe` Right (Add [Entry (Date 2026 9 1) Food (Yen 1200)])
    it "addの後ろに，同じ日の支出を複数並べられる" $
      parseCommand ["add", "2026-09-01", "食費:1200", "交通費:350"]
        `shouldBe` Right (Add [Entry (Date 2026 9 1) Food (Yen 1200), Entry (Date 2026 9 1) Transport (Yen 350)])
    it "addの後ろの日付が読み取れなければ，エラーメッセージを返す" $
      parseCommand ["add", "2026-13-01", "食費:1200"]
        `shouldBe` Left "存在する日付をYYYY-MM-DDの形で書いてください: 2026-13-01"
    it "addの後ろの支出が読み取れなければ，そのエラーメッセージを返す" $
      parseCommand ["add", "2026-09-01", "食費:abc"] `shouldBe` Left "金額は正の整数で書いてください: 食費:abc"
    it "addの後ろに支出がなければ，使い方を返す" $
      parseCommand ["add", "2026-09-01"] `shouldBe` Left usage
    it "listを読み取る" $
      parseCommand ["list"] `shouldBe` Right (List Nothing)
    it "listの後ろの年月を読み取る" $
      parseCommand ["list", "2026-09"] `shouldBe` Right (List (Just (YearMonth 2026 9)))
    it "listの後ろの年月が読み取れなければ，エラーメッセージを返す" $
      parseCommand ["list", "2026-9"] `shouldBe` Left "年月はYYYY-MMの形で書いてください: 2026-9"
    it "summaryを読み取る" $
      parseCommand ["summary"] `shouldBe` Right (Summary Nothing)
    it "summaryの後ろの年月を読み取る" $
      parseCommand ["summary", "2026-09"] `shouldBe` Right (Summary (Just (YearMonth 2026 9)))
    it "引数がなければ，使い方を返す" $
      parseCommand [] `shouldBe` Left usage
    it "知らないサブコマンドなら，使い方を返す" $
      parseCommand ["delete"] `shouldBe` Left usage
    it "listの後ろに余分な引数があれば，使い方を返す" $
      parseCommand ["list", "2026-09", "食費"] `shouldBe` Left usage
