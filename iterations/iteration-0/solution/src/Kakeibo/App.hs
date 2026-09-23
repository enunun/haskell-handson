-- | プログラムの入口．コマンドライン引数から，画面に表示する行を作る．
module Kakeibo.App (run) where

import Kakeibo.Money (formatYen, total)

-- | コマンドライン引数(金額の並び)を受け取り，表示する行のリストを返す．
run :: [String] -> [String]
run args = ["合計: " ++ formatYen (total (map read args))]
