# Haskellの文法・概念

各Iterationで新しく使う文法と概念を，Iterationごとにまとめた資料．
演習の手順から，そのIterationの資料を読むように案内している．
あとから文法を調べ直すときは，下の目次から探す．

| 資料 | 主な内容 |
|---|---|
| [Iteration 0：式・型・関数・モジュール](iteration-0.md) | GHCi，式と型，関数の定義と呼び出し，`show`・`read`，リスト，モジュール，`error`，`main`と`IO`の概要，hspec |
| [Iteration 1：パターンマッチ・再帰・ガード](iteration-1.md) | パターンマッチ，リストのパターン，パターンの漏れの警告，再帰，ガード，`where`，`let`，型変数 |
| [Iteration 2：データ型・`case`式・タプル](iteration-2.md) | `data`，レコード構文，`deriving`，`case`式，タプル，`break`，型のエクスポート |
| [Iteration 3：高階関数](iteration-3.md) | `map`・`filter`・`foldr`，ラムダ式，部分適用，セクション，関数合成，`Enum`・`Bounded` |
| [Iteration 4：`Maybe`と`Either`](iteration-4.md) | 部分関数と全域関数，`Maybe`，`readMaybe`，`case`のガード，`Either`，エラーの受け渡し，標準エラー出力と終了コード |
| [Iteration 5：型クラス・`newtype`・`Data.Map`](iteration-5.md) | 型クラスの定義とインスタンス，型クラス制約，`newtype`，`Semigroup`・`Monoid`，`Ord`と並べ替え，`Data.Map`，qualified import |
| [Iteration 6：`IO`と`do`記法](iteration-6.md) | `IO`型，`do`記法，`pure`，`if`式，純粋な関数と副作用の分離，hspecでの`IO`のテスト，一時ディレクトリ，as-パターン |
| [Iteration 7：`Functor`・`Applicative`・`Monad`](iteration-7.md) | `<$>`，`<*>`，`Maybe`・`Either`の`do`記法，`traverse`，`mapM_`，`maybe`・`either` |
| [Iteration 8：プロパティベーステスト](iteration-8.md) | QuickCheck，`prop`，`Arbitrary`，ジェネレータ，`forAll`，性質の見つけ方，`ioProperty` |

テスト駆動開発とテストリストの書き方は[tdd.md](../tdd.md)に，cabalの使い方は[cabal.md](../cabal.md)にまとめている．
