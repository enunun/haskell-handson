-- | データファイルへの支出の保存と読み込み．
-- データファイルは，支出1件を「費目<タブ>金額」の1行で表すテキストファイルである．
module Kakeibo.Storage
  ( encodeEntry,
    decodeEntry,
    decodeEntries,
    loadEntries,
    appendEntries,
  )
where

import Kakeibo.Display (Display (..))
import Kakeibo.Entry (Entry (..), parseAmount, parseCategory)
import Kakeibo.Money (Yen (..))
import System.Directory (doesFileExist)
import System.IO (readFile')

-- | 支出1件を，データファイルの1行にする．
encodeEntry :: Entry -> String
encodeEntry entry = display (category entry) ++ "\t" ++ show n
  where
    Yen n = amount entry

-- | データファイルの1行を読み取る．読み取れなければNothingを返す．
decodeEntry :: String -> Maybe Entry
decodeEntry line =
  case break isTab line of
    (name, _ : amountText) ->
      case parseAmount amountText of
        Nothing -> Nothing
        Just yen -> Just (Entry (parseCategory name) yen)
    (_, []) -> Nothing
  where
    isTab c = c == '\t'

-- | データファイルの中身を読み取る．読み取れない行があれば，最初のものの行番号を示すエラーメッセージを返す．
decodeEntries :: String -> Either String [Entry]
decodeEntries contents = decodeLines (zip [1 :: Int ..] (lines contents))
  where
    decodeLines [] = Right []
    decodeLines ((lineNumber, line) : rest) =
      case decodeEntry line of
        Nothing -> Left (show lineNumber ++ "行目を読めません")
        Just entry ->
          case decodeLines rest of
            Left err -> Left err
            Right entries -> Right (entry : entries)

-- | データファイルから支出をすべて読み込む．ファイルがなければ，支出は0件とする．
loadEntries :: FilePath -> IO (Either String [Entry])
loadEntries path = do
  exists <- doesFileExist path
  if exists
    then do
      contents <- readFile' path
      case decodeEntries contents of
        Left err -> pure (Left (path ++ ": " ++ err))
        Right entries -> pure (Right entries)
    else pure (Right [])

-- | データファイルの末尾に支出を書き足す．ファイルがなければ作る．
appendEntries :: FilePath -> [Entry] -> IO ()
appendEntries path entries = appendFile path (unlines (map encodeEntry entries))
