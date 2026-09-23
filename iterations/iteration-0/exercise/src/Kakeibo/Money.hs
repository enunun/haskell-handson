-- | 金額の計算と表示．
module Kakeibo.Money
  ( total,
    formatYen,
  )
where

-- | 金額のリストの合計を求める．
total :: [Int] -> Int
total _ = error "TODO: 金額のリストの合計を返す"

-- | 金額を「〜円」という文字列にする．
formatYen :: Int -> String
formatYen _ = error "TODO: 金額の後ろに「円」を付けた文字列を返す"
