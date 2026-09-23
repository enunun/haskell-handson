-- | プログラムの入口．コマンドライン引数から，画面に表示する行を作る．
module Kakeibo.App (run) where

import Kakeibo.Entry (Category, Entry (..), categoryName, formatEntry, parseEntry)
import Kakeibo.Money (formatYen, total)
import Kakeibo.Summary (summarize)

-- | コマンドライン引数(支出の並び)を受け取り，表示する行のリストを返す．
-- 支出を1件ずつ1行で表示し，費目ごとの小計，合計の順に表示する．
run :: [String] -> [String]
run [] = ["支出はありません"]
run args =
  map formatEntry entries
    ++ ["費目別:"]
    ++ map formatSubtotal (summarize entries)
    ++ ["合計: " ++ formatYen (total (map amount entries))]
  where
    entries = map parseEntry args

-- | 費目ごとの小計を，字下げした1行にする．
formatSubtotal :: (Category, Int) -> String
formatSubtotal (c, subtotal) = "  " ++ categoryName c ++ " " ++ formatYen subtotal
