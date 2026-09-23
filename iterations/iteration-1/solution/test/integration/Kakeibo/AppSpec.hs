module Kakeibo.AppSpec (spec) where

import Kakeibo.App (run)
import Test.Hspec

spec :: Spec
spec = do
  describe "run" $ do
    it "引数の金額の合計を，3桁区切りの1行で表示する" $
      run ["1200", "350", "800"] `shouldBe` ["合計: 2,350円"]
    it "引数がなければ，支出がないことを表示する" $
      run [] `shouldBe` ["支出はありません"]
