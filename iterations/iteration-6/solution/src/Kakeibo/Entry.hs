-- | 支出1件の表し方と，その読み取り・表示．
module Kakeibo.Entry
  ( Category (..),
    Entry (..),
    parseCategory,
    parseAmount,
    parseEntry,
    parseEntries,
  )
where

import Kakeibo.Display (Display (..))
import Kakeibo.Money (Yen (..))
import Text.Read (readMaybe)

-- | 支出の費目．
data Category
  = Food
  | Transport
  | Daily
  | Other
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | 費目の名前．
instance Display Category where
  display Food = "食費"
  display Transport = "交通費"
  display Daily = "日用品"
  display Other = "その他"

-- | 支出1件．
data Entry = Entry
  { category :: Category,
    amount :: Yen
  }
  deriving (Show, Eq)

-- | 支出1件を「費目 金額」という1行にする．
instance Display Entry where
  display entry = display (category entry) ++ " " ++ display (amount entry)

-- | 費目の名前から費目を求める．知らない名前は「その他」とする．
parseCategory :: String -> Category
parseCategory "食費" = Food
parseCategory "交通費" = Transport
parseCategory "日用品" = Daily
parseCategory _ = Other

-- | 金額を読み取る．正の整数として読めなければNothingを返す．
parseAmount :: String -> Maybe Yen
parseAmount text =
  case readMaybe text of
    Nothing -> Nothing
    Just n
      | n > 0 -> Just (Yen n)
      | otherwise -> Nothing

-- | 「費目:金額」という引数を読み取る．
-- 「:」がなければ，全体を金額とし，費目を「その他」とする．
-- 金額が正の整数でなければ，引数を含むエラーメッセージを返す．
parseEntry :: String -> Either String Entry
parseEntry arg =
  case parseAmount amountText of
    Nothing -> Left ("金額は正の整数で書いてください: " ++ arg)
    Just yen -> Right (Entry c yen)
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
