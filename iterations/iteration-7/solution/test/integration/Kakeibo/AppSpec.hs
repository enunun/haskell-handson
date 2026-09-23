module Kakeibo.AppSpec (spec) where

import Kakeibo.App (run)
import Kakeibo.Command (usage)
import System.IO.Temp (withSystemTempDirectory)
import Test.Hspec

-- | 空の一時ディレクトリの中のデータファイルのパスを受け取るテストを実行する．
-- 一時ディレクトリは，テストが終わると消える．
withDataFile :: (FilePath -> IO ()) -> IO ()
withDataFile test = withSystemTempDirectory "kakeibo" (\dir -> test (dir ++ "/kakeibo.tsv"))

spec :: Spec
spec = do
  describe "run" $ do
    it "addで追加した支出を，日付付きで知らせる" $
      withDataFile $ \path -> do
        result <- run path ["add", "2026-09-01", "食費:1200", "交通費:350"]
        result `shouldBe` Right ["追加しました: 2026-09-01 食費 1,200円", "追加しました: 2026-09-01 交通費 350円"]
    it "addで追加した支出を，listで表示する" $
      withDataFile $ \path -> do
        _ <- run path ["add", "2026-09-01", "食費:1200", "交通費:350"]
        _ <- run path ["add", "2026-09-03", "食費:350"]
        result <- run path ["list"]
        result
          `shouldBe` Right
            [ "2026-09-01 食費 1,200円",
              "2026-09-01 交通費 350円",
              "2026-09-03 食費 350円",
              "合計: 1,900円"
            ]
    it "addで追加した支出の費目ごとの小計を，summaryで表示する" $
      withDataFile $ \path -> do
        _ <- run path ["add", "2026-09-01", "食費:350", "交通費:1200"]
        _ <- run path ["add", "2026-09-02", "食費:350"]
        result <- run path ["summary"]
        result `shouldBe` Right ["交通費 1,200円", "食費 700円", "合計: 1,900円"]
    it "listに年月を指定すると，その月の支出だけを表示する" $
      withDataFile $ \path -> do
        _ <- run path ["add", "2026-08-31", "食費:500"]
        _ <- run path ["add", "2026-09-01", "食費:1200"]
        _ <- run path ["add", "2026-10-01", "交通費:350"]
        result <- run path ["list", "2026-09"]
        result `shouldBe` Right ["2026-09-01 食費 1,200円", "合計: 1,200円"]
    it "summaryに年月を指定すると，その月の支出だけを集計する" $
      withDataFile $ \path -> do
        _ <- run path ["add", "2026-08-31", "食費:500"]
        _ <- run path ["add", "2026-09-01", "食費:1200", "交通費:350"]
        result <- run path ["summary", "2026-09"]
        result `shouldBe` Right ["食費 1,200円", "交通費 350円", "合計: 1,550円"]
    it "指定した年月に支出がなければ，支出がないことを表示する" $
      withDataFile $ \path -> do
        _ <- run path ["add", "2026-09-01", "食費:1200"]
        result <- run path ["list", "2026-10"]
        result `shouldBe` Right ["支出はありません"]
    it "データファイルがなければ，支出がないことを表示する" $
      withDataFile $ \path -> do
        result <- run path ["list"]
        result `shouldBe` Right ["支出はありません"]
    it "addの支出に誤りがあれば，エラーメッセージを返し，何も追加しない" $
      withDataFile $ \path -> do
        added <- run path ["add", "2026-09-01", "食費:1200", "交通費:abc"]
        added `shouldBe` Left "金額は正の整数で書いてください: 交通費:abc"
        listed <- run path ["list"]
        listed `shouldBe` Right ["支出はありません"]
    it "データファイルに読めない行があれば，ファイル名と行番号を示すエラーメッセージを返す" $
      withDataFile $ \path -> do
        writeFile path "2026-09-01\t食費\t1200\n食費\t1200\n"
        result <- run path ["list"]
        result `shouldBe` Left (path ++ ": 2行目を読めません")
    it "知らないサブコマンドなら，使い方を返す" $
      withDataFile $ \path -> do
        result <- run path ["delete"]
        result `shouldBe` Left usage
