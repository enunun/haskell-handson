module Main (main) where

import Kakeibo.App (run)
import System.Environment (getArgs)

-- | コマンドライン引数を読み，runが返した行を1行ずつ表示する．
main :: IO ()
main = do
  args <- getArgs
  putStr (unlines (run args))
