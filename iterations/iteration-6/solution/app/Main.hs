module Main (main) where

import Data.Maybe (fromMaybe)
import Kakeibo.App (defaultDataFile, run)
import System.Environment (getArgs, lookupEnv)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)

-- | コマンドライン引数と環境変数KAKEIBO_FILEを読んでrunに渡し，返ってきた行を1行ずつ表示する．
-- runがエラーを返したら，エラーメッセージを標準エラー出力に表示し，終了コード1で終わる．
main :: IO ()
main = do
  args <- getArgs
  maybePath <- lookupEnv "KAKEIBO_FILE"
  let path = fromMaybe defaultDataFile maybePath
  result <- run path args
  case result of
    Left err -> do
      hPutStrLn stderr err
      exitFailure
    Right outputLines -> putStr (unlines outputLines)
