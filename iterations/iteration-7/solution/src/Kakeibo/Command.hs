-- | コマンドライン引数で指定する操作(サブコマンド)．
module Kakeibo.Command
  ( Command (..),
    parseCommand,
    usage,
  )
where

import Kakeibo.Date (YearMonth, parseDate, parseYearMonth)
import Kakeibo.Entry (Entry, parseEntries)

-- | サブコマンド．
data Command
  = -- | 支出をデータファイルに追記する．
    Add [Entry]
  | -- | 明細と合計を表示する．年月を指定すると，その月の支出だけを対象にする．
    List (Maybe YearMonth)
  | -- | 費目ごとの小計と合計を表示する．年月を指定すると，その月の支出だけを対象にする．
    Summary (Maybe YearMonth)
  deriving (Show, Eq)

-- | 使い方の説明．
usage :: String
usage = "使い方: kakeibo add YYYY-MM-DD 費目:金額 … | kakeibo list [YYYY-MM] | kakeibo summary [YYYY-MM]"

-- | コマンドライン引数からサブコマンドを読み取る．
parseCommand :: [String] -> Either String Command
parseCommand ("add" : dateText : args@(_ : _)) = do
  d <- maybe (Left ("存在する日付をYYYY-MM-DDの形で書いてください: " ++ dateText)) Right (parseDate dateText)
  entries <- parseEntries d args
  pure (Add entries)
parseCommand ["list"] = Right (List Nothing)
parseCommand ["list", monthText] = List . Just <$> readYearMonth monthText
parseCommand ["summary"] = Right (Summary Nothing)
parseCommand ["summary", monthText] = Summary . Just <$> readYearMonth monthText
parseCommand _ = Left usage

-- | 年月の引数を読み取る．
readYearMonth :: String -> Either String YearMonth
readYearMonth text = maybe (Left ("年月はYYYY-MMの形で書いてください: " ++ text)) Right (parseYearMonth text)
