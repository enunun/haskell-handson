module Kakeibo.EntrySpec (spec) where

import Kakeibo.Entry
import Test.Hspec

spec :: Spec
spec = do
  describe "parseCategory" $ do
    it "「食費」を食費として読む" $
      parseCategory "食費" `shouldBe` Food
    it "「交通費」を交通費として読む" $
      parseCategory "交通費" `shouldBe` Transport
    it "「日用品」を日用品として読む" $
      parseCategory "日用品" `shouldBe` Daily
    it "「その他」をその他として読む" $
      parseCategory "その他" `shouldBe` Other
    it "知らない名前はその他として読む" $
      parseCategory "書籍" `shouldBe` Other
  describe "categoryName" $ do
    it "費目の名前を返す" $
      map categoryName [Food, Transport, Daily, Other] `shouldBe` ["食費", "交通費", "日用品", "その他"]
  describe "parseEntry" $ do
    it "「費目:金額」を読み取る" $
      parseEntry "食費:1200" `shouldBe` Entry {category = Food, amount = 1200}
    it "「:」がなければ，全体を金額とし，費目をその他とする" $
      parseEntry "800" `shouldBe` Entry {category = Other, amount = 800}
  describe "formatEntry" $ do
    it "費目と金額を空白で区切って表示する" $
      formatEntry (Entry {category = Transport, amount = 1200}) `shouldBe` "交通費 1,200円"
