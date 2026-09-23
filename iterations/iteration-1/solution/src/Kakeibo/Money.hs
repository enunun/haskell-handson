-- | 金額の計算と表示．
module Kakeibo.Money
  ( total,
    formatYen,
  )
where

-- | 金額のリストの合計を求める．
total :: [Int] -> Int
total [] = 0
total (amount : rest) = amount + total rest

-- | 金額を3桁ごとにカンマで区切り，「〜円」という文字列にする．
formatYen :: Int -> String
formatYen amount = insertCommas (show amount) ++ "円"

-- | 数字の並びに，右から3桁ごとにカンマを入れる．
insertCommas :: String -> String
insertCommas digits
  | len <= 3 = digits
  | otherwise = insertCommas (take (len - 3) digits) ++ "," ++ drop (len - 3) digits
  where
    len = length digits
