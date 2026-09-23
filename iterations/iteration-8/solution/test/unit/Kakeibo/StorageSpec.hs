module Kakeibo.StorageSpec (spec) where

import Kakeibo.Date (Date (..))
import Kakeibo.Entry (Category (..), Entry (..))
import Kakeibo.Generators (genEntry)
import Kakeibo.Money (Yen (..))
import Kakeibo.Storage (decodeEntries, decodeEntry, encodeEntry)
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (forAll, listOf)

spec :: Spec
spec = do
  describe "encodeEntry" $ do
    it "日付と費目の名前と金額をタブで区切る" $
      encodeEntry (Entry (Date 2026 9 1) Food (Yen 1200)) `shouldBe` "2026-09-01\t食費\t1200"
  describe "decodeEntry" $ do
    it "日付と費目の名前と金額をタブで区切った行を読み取る" $
      decodeEntry "2026-09-03\t交通費\t350" `shouldBe` Just (Entry (Date 2026 9 3) Transport (Yen 350))
    it "項目が3つでなければNothingを返す" $
      decodeEntry "交通費\t350" `shouldBe` Nothing
    it "日付が読み取れなければNothingを返す" $
      decodeEntry "2026-13-03\t交通費\t350" `shouldBe` Nothing
    it "金額が正の整数でなければNothingを返す" $
      decodeEntry "2026-09-03\t交通費\tabc" `shouldBe` Nothing
  describe "decodeEntries" $ do
    it "空なら支出は0件" $
      decodeEntries "" `shouldBe` Right []
    it "1行を支出1件として読み取る" $
      decodeEntries "2026-09-01\t食費\t1200\n2026-09-03\t交通費\t350\n"
        `shouldBe` Right [Entry (Date 2026 9 1) Food (Yen 1200), Entry (Date 2026 9 3) Transport (Yen 350)]
    it "読み取れない行があれば，その行番号を示すエラーメッセージを返す" $
      decodeEntries "2026-09-01\t食費\t1200\n壊れた行\n2026-09-03\t交通費\t350\n"
        `shouldBe` Left "2行目を読めません"
  describe "データファイルの読み書きの性質" $ do
    prop "encodeEntryした行をdecodeEntryで読むと，元の支出に戻る" $
      forAll genEntry $ \e ->
        decodeEntry (encodeEntry e) `shouldBe` Just e
    prop "支出の並びを書いた中身をdecodeEntriesで読むと，元の並びに戻る" $
      forAll (listOf genEntry) $ \es ->
        decodeEntries (unlines (map encodeEntry es)) `shouldBe` Right es
