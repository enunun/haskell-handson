module Kakeibo.AppSpec (spec) where

import Kakeibo.App (run)
import Test.Hspec

spec :: Spec
spec = do
  describe "run" $ do
    it "支出を1件ずつ表示し，最後に合計を表示する" $
      run ["食費:1200", "交通費:350"]
        `shouldBe` ["食費 1,200円", "交通費 350円", "合計: 1,550円"]
    it "費目のない金額は，その他として表示する" $
      run ["1200", "350", "800"]
        `shouldBe` ["その他 1,200円", "その他 350円", "その他 800円", "合計: 2,350円"]
    it "引数がなければ，支出がないことを表示する" $
      run [] `shouldBe` ["支出はありません"]
