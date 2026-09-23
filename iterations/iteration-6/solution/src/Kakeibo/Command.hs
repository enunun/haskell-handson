-- | コマンドライン引数で指定する操作(サブコマンド)．
module Kakeibo.Command
  ( Command (..),
    parseCommand,
    usage,
  )
where

import Kakeibo.Entry (Entry, parseEntries)

-- | サブコマンド．
data Command
  = -- | 支出をデータファイルに追記する．
    Add [Entry]
  | -- | 明細と合計を表示する．
    List
  | -- | 費目ごとの小計と合計を表示する．
    Summary
  deriving (Show, Eq)

-- | 使い方の説明．
usage :: String
usage = "使い方: kakeibo add 費目:金額 … | kakeibo list | kakeibo summary"

-- | コマンドライン引数からサブコマンドを読み取る．
parseCommand :: [String] -> Either String Command
parseCommand ("add" : args@(_ : _)) =
  case parseEntries args of
    Left err -> Left err
    Right entries -> Right (Add entries)
parseCommand ["list"] = Right List
parseCommand ["summary"] = Right Summary
parseCommand _ = Left usage
