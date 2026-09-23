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

import Kakeibo.Date (Date)
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
  { date :: Date,
    category :: Category,
    amount :: Yen
  }
  deriving (Show, Eq)

-- | 支出1件を「日付 費目 金額」という1行にする．
instance Display Entry where
  display entry = display (date entry) ++ " " ++ display (category entry) ++ " " ++ display (amount entry)

-- | 費目の名前から費目を求める．知らない名前は「その他」とする．
parseCategory :: String -> Category
parseCategory "食費" = Food
parseCategory "交通費" = Transport
parseCategory "日用品" = Daily
parseCategory _ = Other

-- | 金額を読み取る．正の整数として読めなければNothingを返す．
parseAmount :: String -> Maybe Yen
parseAmount text = do
  n <- readMaybe text
  if n > 0 then Just (Yen n) else Nothing

-- | 「費目:金額」という引数を，その日の支出として読み取る．
-- 「:」がなければ，全体を金額とし，費目を「その他」とする．
-- 金額が正の整数でなければ，引数を含むエラーメッセージを返す．
parseEntry :: Date -> String -> Either String Entry
parseEntry d arg =
  Entry d c <$> maybe (Left ("金額は正の整数で書いてください: " ++ arg)) Right (parseAmount amountText)
  where
    (c, amountText) =
      case break (== ':') arg of
        (name, _ : rest) -> (parseCategory name, rest)
        (whole, []) -> (Other, whole)

-- | 引数をすべて，その日の支出として読み取る．読み取れない引数があれば，最初のもののエラーメッセージを返す．
parseEntries :: Date -> [String] -> Either String [Entry]
parseEntries d args = traverse (parseEntry d) args
