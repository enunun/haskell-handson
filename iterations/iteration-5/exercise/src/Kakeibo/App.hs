-- | プログラムの入口．コマンドライン引数から，画面に表示する行を作る．
module Kakeibo.App (run) where

import Kakeibo.Entry (Category, Entry (..), categoryName, formatEntry, parseEntries)
import Kakeibo.Money (formatYen, total)
import Kakeibo.Summary (summarize)

-- | コマンドライン引数(支出の並び)を受け取り，表示する行のリストを返す．
-- 支出を1件ずつ1行で表示し，費目ごとの小計，合計の順に表示する．
-- 読み取れない引数があれば，エラーメッセージを返す．
run :: [String] -> Either String [String]
run [] = Right ["支出はありません"]
run args =
  case parseEntries args of
    Left err -> Left err
    Right entries -> Right (report entries)

-- | 支出の明細，費目ごとの小計，合計を表示する行を作る．
report :: [Entry] -> [String]
report entries =
  map formatEntry entries
    ++ ["費目別:"]
    ++ map formatSubtotal (summarize entries)
    ++ ["合計: " ++ formatYen (total (map amount entries))]

-- | 費目ごとの小計を，字下げした1行にする．
formatSubtotal :: (Category, Int) -> String
formatSubtotal (c, subtotal) = "  " ++ categoryName c ++ " " ++ formatYen subtotal
