-- | 支出1件の表し方と，その読み取り・表示．
module Kakeibo.Entry
  ( Category (..),
    Entry (..),
    parseCategory,
    categoryName,
    parseAmount,
    parseEntry,
    parseEntries,
    formatEntry,
  )
where

import Kakeibo.Money (formatYen)
import Text.Read (readMaybe)

-- | 支出の費目．
data Category
  = Food
  | Transport
  | Daily
  | Other
  deriving (Show, Eq, Enum, Bounded)

-- | 支出1件．
data Entry = Entry
  { category :: Category,
    amount :: Int
  }
  deriving (Show, Eq)

-- | 費目の名前から費目を求める．知らない名前は「その他」とする．
parseCategory :: String -> Category
parseCategory "食費" = Food
parseCategory "交通費" = Transport
parseCategory "日用品" = Daily
parseCategory _ = Other

-- | 費目の名前．
categoryName :: Category -> String
categoryName Food = "食費"
categoryName Transport = "交通費"
categoryName Daily = "日用品"
categoryName Other = "その他"

-- | 金額を読み取る．正の整数として読めなければNothingを返す．
parseAmount :: String -> Maybe Int
parseAmount text =
  case readMaybe text of
    Nothing -> Nothing
    Just n
      | n > 0 -> Just n
      | otherwise -> Nothing

-- | 「費目:金額」という引数を読み取る．
-- 「:」がなければ，全体を金額とし，費目を「その他」とする．
-- 金額が正の整数でなければ，引数を含むエラーメッセージを返す．
parseEntry :: String -> Either String Entry
parseEntry arg =
  case parseAmount amountText of
    Nothing -> Left ("金額は正の整数で書いてください: " ++ arg)
    Just n -> Right (Entry c n)
  where
    (c, amountText) =
      case break isColon arg of
        (name, _ : rest) -> (parseCategory name, rest)
        (whole, []) -> (Other, whole)
    isColon ch = ch == ':'

-- | 引数をすべて読み取る．読み取れない引数があれば，最初のもののエラーメッセージを返す．
parseEntries :: [String] -> Either String [Entry]
parseEntries [] = Right []
parseEntries (arg : rest) =
  case parseEntry arg of
    Left err -> Left err
    Right entry ->
      case parseEntries rest of
        Left err -> Left err
        Right entries -> Right (entry : entries)

-- | 支出1件を「費目 金額」という1行にする．
formatEntry :: Entry -> String
formatEntry entry = categoryName (category entry) ++ " " ++ formatYen (amount entry)
