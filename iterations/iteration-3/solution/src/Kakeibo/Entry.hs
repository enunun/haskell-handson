-- | 支出1件の表し方と，その読み取り・表示．
module Kakeibo.Entry
  ( Category (..),
    Entry (..),
    parseCategory,
    categoryName,
    parseEntry,
    formatEntry,
  )
where

import Kakeibo.Money (formatYen)

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

-- | 「費目:金額」という引数を読み取る．
-- 「:」がなければ，全体を金額とし，費目を「その他」とする．
parseEntry :: String -> Entry
parseEntry arg =
  case break isColon arg of
    (name, _ : amountText) -> Entry (parseCategory name) (read amountText)
    (amountText, []) -> Entry Other (read amountText)
  where
    isColon c = c == ':'

-- | 支出1件を「費目 金額」という1行にする．
formatEntry :: Entry -> String
formatEntry entry = categoryName (category entry) ++ " " ++ formatYen (amount entry)
