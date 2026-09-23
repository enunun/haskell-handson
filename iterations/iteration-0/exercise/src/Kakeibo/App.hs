-- | プログラムの入口．コマンドライン引数から，画面に表示する行を作る．
module Kakeibo.App (run) where

-- | コマンドライン引数(金額の並び)を受け取り，表示する行のリストを返す．
run :: [String] -> [String]
run _ = error "TODO: 「合計: 〜円」という1行だけのリストを返す"
