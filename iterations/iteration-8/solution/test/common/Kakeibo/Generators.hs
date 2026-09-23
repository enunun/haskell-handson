-- | プロパティベーステストで使う，ランダムな値のジェネレータ．
module Kakeibo.Generators
  ( genCategory,
    genYen,
    genDate,
    genEntry,
  )
where

import Kakeibo.Date (Date (..))
import Kakeibo.Entry (Category, Entry (..))
import Kakeibo.Money (Yen (..))
import Test.QuickCheck (Gen, choose, elements)

-- | すべての費目から1つ選ぶ．
genCategory :: Gen Category
genCategory = elements [minBound .. maxBound]

-- | 支出の金額として正しい，1円から1,000万円までの金額．
genYen :: Gen Yen
genYen = Yen <$> choose (1, 10000000)

-- | 2000年から2099年までの日付．日は，どの月にもある1日から28日までから選ぶ．
genDate :: Gen Date
genDate = Date <$> choose (2000, 2099) <*> choose (1, 12) <*> choose (1, 28)

-- | 支出1件．
genEntry :: Gen Entry
genEntry = Entry <$> genDate <*> genCategory <*> genYen
