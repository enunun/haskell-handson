module Kakeibo.AppSpec (spec) where

import Kakeibo.App (run)
import Test.Hspec

spec :: Spec
spec = do
  describe "run" $ do
    it "引数の金額の合計を1行で表示する" $
      run ["1200", "350", "800"] `shouldBe` ["合計: 2350円"]
    it "引数がなければ合計は0円" $
      run [] `shouldBe` ["合計: 0円"]
