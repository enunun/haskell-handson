module Kakeibo.StorageSpec (spec) where

import Kakeibo.Entry (Category (..), Entry (..))
import Kakeibo.Money (Yen (..))
import Kakeibo.Storage (decodeEntries, decodeEntry, encodeEntry)
import Test.Hspec

spec :: Spec
spec = do
  describe "encodeEntry" $ do
    it "費目の名前と金額をタブで区切る" $
      encodeEntry (Entry Food (Yen 1200)) `shouldBe` "食費\t1200"
  describe "decodeEntry" $ do
    it "費目の名前と金額をタブで区切った行を読み取る" $
      decodeEntry "交通費\t350" `shouldBe` Just (Entry Transport (Yen 350))
    it "タブがなければNothingを返す" $
      decodeEntry "交通費 350" `shouldBe` Nothing
    it "金額が正の整数でなければNothingを返す" $
      decodeEntry "交通費\tabc" `shouldBe` Nothing
  describe "decodeEntries" $ do
    it "空なら支出は0件" $
      decodeEntries "" `shouldBe` Right []
    it "1行を支出1件として読み取る" $
      decodeEntries "食費\t1200\n交通費\t350\n"
        `shouldBe` Right [Entry Food (Yen 1200), Entry Transport (Yen 350)]
    it "読み取れない行があれば，その行番号を示すエラーメッセージを返す" $
      decodeEntries "食費\t1200\n壊れた行\n交通費\t350\n" `shouldBe` Left "2行目を読めません"
