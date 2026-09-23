-- | 画面に表示する行の組み立て．
module Kakeibo.Report
  ( listReport,
    summaryReport,
  )
where

import Kakeibo.Display (Display (..))
import Kakeibo.Entry (Entry (..))
import Kakeibo.Money (total)
import Kakeibo.Summary (summarize)

-- | 支出を1件ずつ1行で表示し，最後に合計を表示する．
listReport :: [Entry] -> [String]
listReport [] = ["支出はありません"]
listReport entries = map display entries ++ [totalLine entries]

-- | 費目ごとの小計を金額の大きい順に表示し，最後に合計を表示する．
summaryReport :: [Entry] -> [String]
summaryReport [] = ["支出はありません"]
summaryReport entries = map formatSubtotal (summarize entries) ++ [totalLine entries]
  where
    formatSubtotal (c, subtotal) = display c ++ " " ++ display subtotal

-- | 合計の行．
totalLine :: [Entry] -> String
totalLine entries = "合計: " ++ display (total (map amount entries))
