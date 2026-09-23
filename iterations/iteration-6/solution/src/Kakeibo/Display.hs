-- | 値を画面に表示する文字列にする型クラス．
module Kakeibo.Display (Display (..)) where

-- | 画面に表示できる型．
-- Showは値をHaskellの式の形で表すのに対し，Displayは利用者向けの表記にする．
class Display a where
  display :: a -> String
