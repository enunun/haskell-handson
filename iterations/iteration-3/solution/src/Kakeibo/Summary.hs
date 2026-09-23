-- | 支出の集計．
module Kakeibo.Summary (summarize) where

import Kakeibo.Entry (Category, Entry (..))
import Kakeibo.Money (total)

-- | 費目ごとの小計を，費目の定義順に並べて返す．
-- 支出が1件もない費目は含めない．
summarize :: [Entry] -> [(Category, Int)]
summarize entries = map subtotal (filter hasEntries allCategories)
  where
    allCategories = [minBound .. maxBound]
    entriesOf c = filter ((== c) . category) entries
    hasEntries c = not (null (entriesOf c))
    subtotal c = (c, total (map amount (entriesOf c)))
