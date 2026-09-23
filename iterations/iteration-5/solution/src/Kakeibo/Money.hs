-- | 金額の表し方と計算．
module Kakeibo.Money
  ( Yen (..),
    total,
  )
where

import Kakeibo.Display (Display (..))

-- | 円単位の金額．
newtype Yen = Yen Int
  deriving (Show, Eq, Ord)

-- | 金額どうしの<>は足し算である．
instance Semigroup Yen where
  Yen a <> Yen b = Yen (a + b)

-- | 足し算の単位元は0円である．
instance Monoid Yen where
  mempty = Yen 0

-- | 金額を3桁ごとにカンマで区切り，「〜円」という文字列にする．
instance Display Yen where
  display (Yen n) = insertCommas (show n) ++ "円"

-- | 金額のリストの合計を求める．
total :: [Yen] -> Yen
total amounts = mconcat amounts

-- | 数字の並びに，右から3桁ごとにカンマを入れる．
insertCommas :: String -> String
insertCommas digits
  | len <= 3 = digits
  | otherwise = insertCommas (take (len - 3) digits) ++ "," ++ drop (len - 3) digits
  where
    len = length digits
