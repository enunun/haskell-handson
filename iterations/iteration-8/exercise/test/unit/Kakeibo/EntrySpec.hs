module Kakeibo.EntrySpec (spec) where

import Kakeibo.Date (Date (..))
import Kakeibo.Display (Display (..))
import Kakeibo.Entry
import Kakeibo.Money (Yen (..))
import Test.Hspec

sep1 :: Date
sep1 = Date 2026 9 1

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
  describe "display(Category)" $ do
    it "費目の名前を返す" $
      map display [Food, Transport, Daily, Other] `shouldBe` ["食費", "交通費", "日用品", "その他"]
  describe "parseAmount" $ do
    it "正の整数を読み取る" $
      parseAmount "1200" `shouldBe` Just (Yen 1200)
    it "数として読めなければNothingを返す" $
      parseAmount "abc" `shouldBe` Nothing
    it "空文字列ならNothingを返す" $
      parseAmount "" `shouldBe` Nothing
    it "小数ならNothingを返す" $
      parseAmount "1.5" `shouldBe` Nothing
    it "0ならNothingを返す" $
      parseAmount "0" `shouldBe` Nothing
    it "負の数ならNothingを返す" $
      parseAmount "-5" `shouldBe` Nothing
  describe "parseEntry" $ do
    it "「費目:金額」を，その日の支出として読み取る" $
      parseEntry sep1 "食費:1200" `shouldBe` Right (Entry {date = sep1, category = Food, amount = Yen 1200})
    it "「:」がなければ，全体を金額とし，費目をその他とする" $
      parseEntry sep1 "800" `shouldBe` Right (Entry {date = sep1, category = Other, amount = Yen 800})
    it "金額が正の整数でなければ，引数を含むエラーメッセージを返す" $
      parseEntry sep1 "食費:abc" `shouldBe` Left "金額は正の整数で書いてください: 食費:abc"
    it "「:」がなく，全体が正の整数でなければ，エラーメッセージを返す" $
      parseEntry sep1 "abc" `shouldBe` Left "金額は正の整数で書いてください: abc"
  describe "parseEntries" $ do
    it "空のリストなら空のリストを返す" $
      parseEntries sep1 [] `shouldBe` Right []
    it "すべての引数を読み取り，同じ順に並べる" $
      parseEntries sep1 ["食費:1200", "交通費:350"]
        `shouldBe` Right [Entry sep1 Food (Yen 1200), Entry sep1 Transport (Yen 350)]
    it "読み取れない引数があれば，そのエラーメッセージを返す" $
      parseEntries sep1 ["食費:1200", "交通費:abc"]
        `shouldBe` Left "金額は正の整数で書いてください: 交通費:abc"
    it "読み取れない引数が複数あれば，最初のもののエラーメッセージを返す" $
      parseEntries sep1 ["食費:0", "交通費:abc"]
        `shouldBe` Left "金額は正の整数で書いてください: 食費:0"
  describe "display(Entry)" $ do
    it "日付と費目と金額を空白で区切って表示する" $
      display (Entry {date = sep1, category = Transport, amount = Yen 1200}) `shouldBe` "2026-09-01 交通費 1,200円"
