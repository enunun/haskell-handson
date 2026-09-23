# haskell-handson

Haskellを初めて学ぶ人(他の言語でのプログラミング経験はある)向けのハンズオン教材．
Iterationごとに演習用(exercise)と解答例(solution)のcabalパッケージを置き，1つのcabalプロジェクトにまとめる．

# RTK (Rust Token Killer)

Prefix every shell command with `rtk`, including each command in a `&&` chain — it is always safe (a dedicated filter cuts noisy output for tests, builds, git, and more; anything without one passes through unchanged). The full command reference is in the global `~/.claude/RTK.md` (already loaded, if set up). Meta commands: `rtk gain` (savings so far), `rtk discover` (missed opportunities in past sessions), `rtk proxy <cmd>` (run unfiltered, for debugging).

## Working conventions

- Iterationを作る・直すときは，`build-iteration`スキル(`.claude/skills/build-iteration/SKILL.md`)の手順に従う．各Iterationの内容は`docs/ROADMAP.md`で決める．
- 読者はHaskellを知らない前提で書く．新しい文法・概念は，初めて使うIterationの資料(`docs/haskell/iteration-N.md`)で説明してから使う．
- 同じIterationのexerciseとsolutionは，同じコミットでそろえて変更する．
- solutionのテストはすべて通す．exerciseは，学習者が書き足す前の状態でもビルドできるようにする．
- Iteration N(N ≥ 1)のexerciseのコード・テスト・設計書(`design/`)は，Iteration N-1のsolutionと同じにする．新しいモジュール，テスト，`.cabal`への追記，設計書の更新は学習者の作業として残す．
- 設計書は，C4モデルの4階層(`design/01-context.md`〜`04-code.md`)のmermaidの図で書く(`docs/design.md`)．Componentの図の矢印は実装の`import`と，Codeの図の名前は実装の名前と一致させる．
- `cabal.project`の`packages`には，solutionのパッケージだけを列挙する(HLSはここに列挙したパッケージしか解析しない)．exerciseのパッケージは，学習者が各Iterationの最初に自分で追記する．
- GHC・cabal・HLSの版は`mise.toml`の`[vars]`で決める．変えるときは，HLSがそのGHCに対応していることを確かめる．
- `git commit`はlefthookのフックを実行する．失敗したら指摘を直す．`--no-verify`は使わない．
- 変更後は`mise run check`を実行する．exerciseを含むすべてのパッケージを，一時的なプロジェクトファイル(`cabal.project.all`)でビルドしてテストする．
- 日本語を含むHaskellのコードは，ロケールがUTF-8でないとGHCが扱えない．開発用コンテナは`LANG=C.UTF-8`を設定している．

## Code map

```
iterations/iteration-N/
  exercise/    演習用パッケージ．学習者がここに実装とテストを書き足す．
               docs/iteration-N.md(演習の手順)，TESTLIST.md(テストリストのひな形)，design/(設計書)を含む．
  solution/    解答例パッケージ．exerciseを完成させた状態．
               docs/iteration-N.md(各手順の解説)，TESTLIST.md・design/(模範解答)を含む．
docs/
  ROADMAP.md   各Iterationの要求・モジュール・学ぶこと．Iterationの内容はここで決める．
  tdd.md       テスト駆動開発とテストリストの書き方．
  design.md    設計書(C4モデル・mermaid)の書き方．
  cabal.md     cabalの使い方．
  haskell/     Iterationごとの，Haskellの文法・概念の資料．
cabal.project  solutionのパッケージをまとめるcabalプロジェクト．
.hlint.yaml    hlintの設定．
tools/mermaid/ Markdownの中のmermaidの図の構文を検査するスクリプト(Node)．
mise.toml      ツールの版とタスク(toolchain/install/fmt/lint/test/test-all/check/setup)．
.devcontainer/ 開発用コンテナの定義．GHC・cabal・HLSはイメージのビルド時にghcupで入る．
.claude/skills/build-iteration/  Iterationを作る手順のスキル．
```

# Artifact Cleanup

## Golden Rule

**Whenever you produce an artifact, always run the `system-development-skills:finalize-artifacts` skill to clean it up before reporting the work as done.**

An artifact is any deliverable you create or substantially rewrite: documents, READMEs, code and code comments, config files, scripts, commit messages, PR descriptions, and so on.

- Invoke the skill via the Skill tool (`system-development-skills:finalize-artifacts`) after the artifact is written and before the final reply.
- The skill edits the artifact files in place. Do not append a changelog of the cleanup to the artifact; in the final reply, mention what changed in a sentence or two at most unless the user asks for a full report.
- Skip it only for replies that produce no artifact (answering questions, explaining code, running read-only commands).
- Provided by the `enunun/system-development-skills` plugin (see `extraKnownMarketplaces`/`enabledPlugins` in `.claude/settings.json`).
