-- | プログラムの入口．コマンドライン引数から，画面に表示する行を作る．
module Kakeibo.App (run) where

import Kakeibo.Entry (Entry (..), formatEntry, parseEntry)
import Kakeibo.Money (formatYen, total)

-- | コマンドライン引数(支出の並び)を受け取り，表示する行のリストを返す．
-- 支出を1件ずつ1行で表示し，最後に合計を表示する．
run :: [String] -> [String]
run [] = ["支出はありません"]
run args = map formatEntry entries ++ ["合計: " ++ formatYen (total (map amount entries))]
  where
    entries = map parseEntry args
