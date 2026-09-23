-- | プログラムの入口．コマンドライン引数に従ってデータファイルを読み書きし，画面に表示する行を作る．
module Kakeibo.App
  ( run,
    defaultDataFile,
  )
where

import Kakeibo.Command (Command (..), parseCommand)
import Kakeibo.Date (YearMonth, inMonth)
import Kakeibo.Display (Display (..))
import Kakeibo.Entry (Entry (..))
import Kakeibo.Report (listReport, summaryReport)
import Kakeibo.Storage (appendEntries, loadEntries)

-- | 環境変数KAKEIBO_FILEがないときに使うデータファイル．
defaultDataFile :: FilePath
defaultDataFile = "kakeibo.tsv"

-- | データファイルのパスとコマンドライン引数を受け取り，サブコマンドを実行して，表示する行のリストを返す．
-- 引数やデータファイルに誤りがあれば，エラーメッセージを返す．
run :: FilePath -> [String] -> IO (Either String [String])
run path args =
  case parseCommand args of
    Left err -> pure (Left err)
    Right (Add entries) -> do
      appendEntries path entries
      pure (Right (map addedLine entries))
    Right (List target) -> withEntries target listReport
    Right (Summary target) -> withEntries target summaryReport
  where
    withEntries target report = do
      loaded <- loadEntries path
      pure (report . selectMonth target <$> loaded)

-- | 年月の指定があれば，その月の支出だけを選ぶ．
selectMonth :: Maybe YearMonth -> [Entry] -> [Entry]
selectMonth Nothing entries = entries
selectMonth (Just target) entries = filter (inMonth target . date) entries

-- | 追加した支出を知らせる行．
addedLine :: Entry -> String
addedLine entry = "追加しました: " ++ display entry
