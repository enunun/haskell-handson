module Main (main) where

import Kakeibo.App (run)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)

-- | コマンドライン引数を読み，runが返した行を1行ずつ表示する．
-- runがエラーを返したら，エラーメッセージを標準エラー出力に表示し，終了コード1で終わる．
main :: IO ()
main = do
  args <- getArgs
  case run args of
    Left err -> do
      hPutStrLn stderr err
      exitFailure
    Right outputLines -> putStr (unlines outputLines)
