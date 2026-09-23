-- | 日付と年月．
module Kakeibo.Date
  ( Date (..),
    YearMonth (..),
    parseDate,
    parseYearMonth,
    inMonth,
  )
where

import Kakeibo.Display (Display (..))
import Text.Read (readMaybe)

-- | 日付．
data Date = Date
  { year :: Int,
    month :: Int,
    day :: Int
  }
  deriving (Show, Eq, Ord)

-- | 「2026-09-01」の形で表示する．
instance Display Date where
  display (Date y m d) = show y ++ "-" ++ twoDigits m ++ "-" ++ twoDigits d

-- | 年と月．
data YearMonth = YearMonth Int Int
  deriving (Show, Eq)

-- | 「YYYY-MM-DD」の形の日付を読み取る．存在しない日付ならNothingを返す．
parseDate :: String -> Maybe Date
parseDate text =
  case splitOn '-' text of
    [y, m, d]
      | map length [y, m, d] == [4, 2, 2] -> do
          yearNumber <- readMaybe y
          monthNumber <- readMaybe m
          dayNumber <- readMaybe d
          if validMonth monthNumber && dayNumber >= 1 && dayNumber <= daysInMonth yearNumber monthNumber
            then Just (Date yearNumber monthNumber dayNumber)
            else Nothing
    _ -> Nothing

-- | 「YYYY-MM」の形の年月を読み取る．
parseYearMonth :: String -> Maybe YearMonth
parseYearMonth text =
  case splitOn '-' text of
    [y, m]
      | map length [y, m] == [4, 2] -> do
          yearNumber <- readMaybe y
          monthNumber <- readMaybe m
          if validMonth monthNumber
            then Just (YearMonth yearNumber monthNumber)
            else Nothing
    _ -> Nothing

-- | 日付がその年月に含まれるか．
inMonth :: YearMonth -> Date -> Bool
inMonth (YearMonth y m) d = year d == y && month d == m

-- | 月の番号が1から12のあいだにあるか．
validMonth :: Int -> Bool
validMonth m = m >= 1 && m <= 12

-- | その月の日数．
daysInMonth :: Int -> Int -> Int
daysInMonth y m
  | m == 2 = if isLeapYear y then 29 else 28
  | m `elem` [4, 6, 9, 11] = 30
  | otherwise = 31

-- | うるう年か．
isLeapYear :: Int -> Bool
isLeapYear y = (y `mod` 4 == 0 && y `mod` 100 /= 0) || y `mod` 400 == 0

-- | 1桁の数の前に0を付けて，2桁の文字列にする．
twoDigits :: Int -> String
twoDigits n
  | n < 10 = "0" ++ show n
  | otherwise = show n

-- | 文字列を，区切りの文字で分ける．
splitOn :: Char -> String -> [String]
splitOn separator text =
  case break (== separator) text of
    (chunk, []) -> [chunk]
    (chunk, _ : rest) -> chunk : splitOn separator rest
