module Kakeibo.CommandSpec (spec) where

import Kakeibo.Command (Command (..), parseCommand, usage)
import Kakeibo.Entry (Category (..), Entry (..))
import Kakeibo.Money (Yen (..))
import Test.Hspec

spec :: Spec
spec = do
  describe "parseCommand" $ do
    it "addの後ろの支出を読み取る" $
      parseCommand ["add", "食費:1200"] `shouldBe` Right (Add [Entry Food (Yen 1200)])
    it "addの後ろに支出を複数並べられる" $
      parseCommand ["add", "食費:1200", "交通費:350"]
        `shouldBe` Right (Add [Entry Food (Yen 1200), Entry Transport (Yen 350)])
    it "addの後ろの支出が読み取れなければ，そのエラーメッセージを返す" $
      parseCommand ["add", "食費:abc"] `shouldBe` Left "金額は正の整数で書いてください: 食費:abc"
    it "addの後ろに支出がなければ，使い方を返す" $
      parseCommand ["add"] `shouldBe` Left usage
    it "listを読み取る" $
      parseCommand ["list"] `shouldBe` Right List
    it "summaryを読み取る" $
      parseCommand ["summary"] `shouldBe` Right Summary
    it "引数がなければ，使い方を返す" $
      parseCommand [] `shouldBe` Left usage
    it "知らないサブコマンドなら，使い方を返す" $
      parseCommand ["delete"] `shouldBe` Left usage
    it "listの後ろに余分な引数があれば，使い方を返す" $
      parseCommand ["list", "食費"] `shouldBe` Left usage
