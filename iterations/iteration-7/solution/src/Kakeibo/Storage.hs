-- | データファイルへの支出の保存と読み込み．
-- データファイルは，支出1件を「日付<タブ>費目<タブ>金額」の1行で表すテキストファイルである．
module Kakeibo.Storage
  ( encodeEntry,
    decodeEntry,
    decodeEntries,
    loadEntries,
    appendEntries,
  )
where

import Kakeibo.Date (parseDate)
import Kakeibo.Display (Display (..))
import Kakeibo.Entry (Entry (..), parseAmount, parseCategory)
import Kakeibo.Money (Yen (..))
import System.Directory (doesFileExist)
import System.IO (readFile')

-- | 支出1件を，データファイルの1行にする．
encodeEntry :: Entry -> String
encodeEntry entry = display (date entry) ++ "\t" ++ display (category entry) ++ "\t" ++ show n
  where
    Yen n = amount entry

-- | データファイルの1行を読み取る．読み取れなければNothingを返す．
decodeEntry :: String -> Maybe Entry
decodeEntry line =
  case splitTabs line of
    [dateText, name, amountText] -> Entry <$> parseDate dateText <*> pure (parseCategory name) <*> parseAmount amountText
    _ -> Nothing

-- | データファイルの中身を読み取る．読み取れない行があれば，最初のものの行番号を示すエラーメッセージを返す．
decodeEntries :: String -> Either String [Entry]
decodeEntries contents = traverse decodeNumbered (zip [1 :: Int ..] (lines contents))
  where
    decodeNumbered (lineNumber, line) =
      maybe (Left (show lineNumber ++ "行目を読めません")) Right (decodeEntry line)

-- | データファイルから支出をすべて読み込む．ファイルがなければ，支出は0件とする．
loadEntries :: FilePath -> IO (Either String [Entry])
loadEntries path = do
  exists <- doesFileExist path
  if exists
    then do
      contents <- readFile' path
      pure (either (\err -> Left (path ++ ": " ++ err)) Right (decodeEntries contents))
    else pure (Right [])

-- | データファイルの末尾に支出を書き足す．ファイルがなければ作る．
appendEntries :: FilePath -> [Entry] -> IO ()
appendEntries path entries = appendFile path (unlines (map encodeEntry entries))

-- | 文字列を，タブで分ける．
splitTabs :: String -> [String]
splitTabs line =
  case break (== '\t') line of
    (field, []) -> [field]
    (field, _ : rest) -> field : splitTabs rest
