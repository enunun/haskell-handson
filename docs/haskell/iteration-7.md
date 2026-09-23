# Iteration 7：`Functor`・`Applicative`・`Monad`

Iteration 7で使う文法と概念をまとめる．

## 型を受け取る型

`Maybe`は，それだけでは値の型にならない．
`Maybe Int`や`Maybe Entry`のように，型を1つ受け取って初めて値の型になる．
`[]`(リスト)，`IO`，`Either String`も同じで，`[Int]`，`IO Int`，`Either String Int`のように型を1つ受け取る．

この章の型クラス`Functor`・`Applicative`・`Monad`は，このような「型を1つ受け取る型」についての型クラスである．
型シグネチャの`f a`は，`f`が`Maybe`なら`Maybe a`，`f`が`IO`なら`IO a`を表す．

## `Functor`と`<$>`

`Functor`は，中の値に関数を適用する`fmap`を持つ型クラスである．
`<$>`は`fmap`の演算子版で，同じ意味である．

```haskell
fmap :: Functor f => (a -> b) -> f a -> f b
(<$>) :: Functor f => (a -> b) -> f a -> f b
```

`fmap`が何をするかは，インスタンスごとに決まっている．

| 型 | `f <$> x`の意味 |
|---|---|
| `Maybe` | `Just v`なら`Just (f v)`．`Nothing`なら`Nothing`のまま． |
| `Either e` | `Right v`なら`Right (f v)`．`Left`ならそのまま． |
| `[]` | 各要素に`f`を適用する(`map`と同じ)． |
| `IO` | アクションを実行し，返した値に`f`を適用した値を返すアクション． |

```console
ghci> (+ 1) <$> Just 2
Just 3
ghci> (+ 1) <$> Nothing
Nothing
ghci> (+ 1) <$> (Right 2 :: Either String Int)
Right 3
ghci> (+ 1) <$> (Left "bad" :: Either String Int)
Left "bad"
ghci> (+ 1) <$> [1, 2, 3]
[2,3,4]
```

`case`で`Left`と`Right`を分け，`Right`のときだけ値を変える処理は，`<$>`で書ける．

```haskell
-- case で書いた場合
case parseEntries args of
  Left err -> Left err
  Right entries -> Right (Add entries)

-- <$> で書いた場合
Add <$> parseEntries args
```

データコンストラクタ`Add`も，`[Entry] -> Command`という関数なので，`<$>`に渡せる．

`IO`の`<$>`を使うと，アクションの結果を変換してから名前を付けられる．

```haskell
path <- fromMaybe defaultDataFile <$> lookupEnv "KAKEIBO_FILE"
```

`<$>`は`.`より後に結び付くので，`report . selectMonth target <$> loaded`は`(report . selectMonth target) <$> loaded`と読まれる．

## `Applicative`と`<*>`

`Applicative`は`Functor`を拡張した型クラスで，`pure`と`<*>`を持つ．

```haskell
pure :: Applicative f => a -> f a
(<*>) :: Applicative f => f (a -> b) -> f a -> f b
```

`<$>`は1引数の関数にしか使えないが，`<$>`と`<*>`を組み合わせると，複数の引数を取る関数に，`Maybe`などに入った値を順に渡せる．

```console
ghci> (+) <$> Just 1 <*> Just 2
Just 3
ghci> (+) <$> Just 1 <*> Nothing
Nothing
```

`Maybe`では，引数のどれか1つでも`Nothing`なら，結果は`Nothing`になる．
`Either e`では，最初の`Left`が結果になる．

```haskell
decodeEntry :: String -> Maybe Entry
decodeEntry line =
  case splitTabs line of
    [dateText, name, amountText] ->
      Entry <$> parseDate dateText <*> pure (parseCategory name) <*> parseAmount amountText
    _ -> Nothing
```

- `parseDate dateText`は`Maybe Date`，`parseAmount amountText`は`Maybe Yen`である．
- `parseCategory name`は失敗しない関数なので，`Category`をそのまま返す．`pure`で`Maybe Category`(`Just …`)にしてから渡す．
- `Entry <$> … <*> … <*> …`は，3つがすべて`Just`なら`Just (Entry …)`，どれかが`Nothing`なら`Nothing`になる．

`pure`は，Iteration 6で`IO`のアクションを作るのに使った関数と同じものである．
`Maybe`の`pure`は`Just`，`Either e`の`pure`は`Right`になる．

## `Monad`と`do`記法

`Monad`は`Applicative`を拡張した型クラスで，`>>=`を持つ．

```haskell
(>>=) :: Monad m => m a -> (a -> m b) -> m b
```

`x >>= f`は，`x`の中の値を取り出して`f`に渡す．
`Maybe`では，`x`が`Nothing`なら`f`を呼ばずに`Nothing`になる．
`Either e`では，`x`が`Left`なら`f`を呼ばずにその`Left`になる．

`>>=`を直接書くことは少なく，ふつうは`do`記法を使う．
`do`記法は，`IO`だけでなく，`Monad`のインスタンスならどの型でも使える．

```haskell
parseAmount :: String -> Maybe Yen
parseAmount text = do
  n <- readMaybe text
  if n > 0 then Just (Yen n) else Nothing
```

`Maybe`の`do`では，`<-`の右辺が`Nothing`なら，そこで`do`全体が`Nothing`になる．
`Just v`なら，`v`に名前を付けて次の行に進む．
Iteration 4で書いた`case readMaybe text of Nothing -> Nothing; Just n -> …`を，`<-`の1行で書ける．

`Either String`の`do`も同じで，`<-`の右辺が`Left`なら，そこで`do`全体がその`Left`になる．

```haskell
parseCommand ("add" : dateText : args@(_ : _)) = do
  d <- maybe (Left ("存在する日付をYYYY-MM-DDの形で書いてください: " ++ dateText)) Right (parseDate dateText)
  entries <- parseEntries d args
  pure (Add entries)
```

日付が読めなければ日付のエラーが，支出が読めなければ支出のエラーが，`parseCommand`の結果になる．
両方読めたときだけ，`pure (Add entries)`(`Right (Add entries)`)になる．

`<$>`・`<*>`と`do`記法の使い分けは次のとおり．

- 値どうしが互いに関係しない(どれも前の結果を使わずに読める)なら，`<$>`と`<*>`で書ける．
- 前の結果を使って次の処理を決める(日付を読んでから，その日付で支出を読む)なら，`do`記法で書く．

## `traverse`

`traverse`は，リストの各要素に「失敗しうる関数」を適用し，すべて成功したら結果のリストを，1つでも失敗したら最初の失敗を返す．

```haskell
traverse :: Applicative f => (a -> f b) -> [a] -> f [b]
```

(GHCiの`:t traverse`は，リスト以外にも使える，もっと一般的な型を表示する．)

```console
ghci> readInt s = readMaybe s :: Maybe Int
ghci> traverse readInt ["1", "2", "3"]
Just [1,2,3]
ghci> traverse readInt ["1", "x", "3"]
Nothing
ghci> check n = if n > 0 then Right n else Left ("not positive: " ++ show n)
ghci> traverse check [1, -2, -3]
Left "not positive: -2"
```

Iteration 4で`case`の入れ子と再帰で書いた`parseEntries`は，`traverse`の1行になる．

```haskell
parseEntries :: Date -> [String] -> Either String [Entry]
parseEntries d args = traverse (parseEntry d) args
```

`parseEntry d`は，`parseEntry`に日付だけを渡した部分適用で，`String -> Either String Entry`の関数である．

## `mapM_`

`mapM_`は，リストの各要素にアクションを返す関数を適用し，順に実行する．
結果の値は捨てる．

```haskell
mapM_ :: (a -> IO ()) -> [a] -> IO ()
```

```haskell
Right outputLines -> mapM_ putStrLn outputLines
```

`putStr (unlines outputLines)`と同じく，1行ずつ表示する．

## `maybe`と`either`

`maybe`と`either`は，`case`で`Maybe`や`Either`を分ける処理を1つの関数にしたものである．

```haskell
maybe :: b -> (a -> b) -> Maybe a -> b
either :: (a -> c) -> (b -> c) -> Either a b -> c
```

- `maybe d f m`は，`m`が`Nothing`なら`d`，`Just v`なら`f v`．
- `either f g e`は，`e`が`Left x`なら`f x`，`Right y`なら`g y`．

```console
ghci> maybe 0 (+ 1) (Just 5)
6
ghci> maybe 0 (+ 1) Nothing
0
ghci> either length (* 2) (Left "abc" :: Either String Int)
3
```

`maybe (Left メッセージ) Right m`は，`Maybe`を`Either`に変える決まった書き方である．
`Nothing`ならメッセージを持つ`Left`に，`Just v`なら`Right v`になる．

```haskell
readYearMonth :: String -> Either String YearMonth
readYearMonth text = maybe (Left ("年月はYYYY-MMの形で書いてください: " ++ text)) Right (parseYearMonth text)
```

`either (\err -> Left (path ++ ": " ++ err)) Right e`は，`Left`のメッセージだけを変え，`Right`はそのまま返す．

## 論理演算と`elem`

| 演算子・関数 | 意味 | 例 |
|---|---|---|
| `&&` | かつ | `m >= 1 && m <= 12` |
| `\|\|` | または | `m == 1 \|\| m == 12` |
| `not` | 否定 | `not True`は`False` |
| `elem` | リストに含まれるか | ``m `elem` [4, 6, 9, 11]`` |

`&&`は`||`より先に結び付く．
混ぜて使うときは，括弧で意図をはっきりさせる．
