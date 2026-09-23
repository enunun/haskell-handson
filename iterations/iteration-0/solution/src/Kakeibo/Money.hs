-- | 金額の計算と表示．
module Kakeibo.Money
  ( total,
    formatYen,
  )
where

-- | 金額のリストの合計を求める．
total :: [Int] -> Int
total amounts = sum amounts

-- | 金額を「〜円」という文字列にする．
formatYen :: Int -> String
formatYen amount = show amount ++ "円"
