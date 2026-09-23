-- | 支出の集計．
module Kakeibo.Summary (summarize) where

import Data.List (sortOn)
import Data.Map.Strict qualified as Map
import Data.Ord (Down (..))
import Kakeibo.Entry (Category, Entry (..))
import Kakeibo.Money (Yen)

-- | 費目ごとの小計を，金額の大きい順に並べて返す．
-- 金額が同じなら，費目の定義順に並べる．支出が1件もない費目は含めない．
summarize :: [Entry] -> [(Category, Yen)]
summarize entries = sortOn (Down . snd) (Map.toList subtotals)
  where
    subtotals = Map.fromListWith (<>) (map (\e -> (category e, amount e)) entries)
