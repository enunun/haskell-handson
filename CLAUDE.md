# haskell-handson

Haskellを初めて学ぶ人(他の言語でのプログラミング経験はある)向けのハンズオン教材．
Iterationごとに演習用(exercise)と解答例(solution)のcabalパッケージを置き，1つのcabalプロジェクトにまとめる．

# RTK (Rust Token Killer)

Prefix every shell command with `rtk`, including each command in a `&&` chain — it is always safe (a dedicated filter cuts noisy output for tests, builds, git, and more; anything without one passes through unchanged). The full command reference is in the global `~/.claude/RTK.md` (already loaded, if set up). Meta commands: `rtk gain` (savings so far), `rtk discover` (missed opportunities in past sessions), `rtk proxy <cmd>` (run unfiltered, for debugging).

## Working conventions

- 読者はHaskellを知らない前提で書く．新しい文法・概念は，初めて使うIterationの資料で説明してから使う．
- 同じIterationのexerciseとsolutionは，同じコミットでそろえて変更する．
- solutionのテストはすべて通す．exerciseは，学習者が書き足す前の状態でもビルドできるようにする．
- パッケージを追加・削除したら，`cabal.project`の`packages`も更新する(HLSはここに列挙したパッケージしか解析しない)．
- GHC・cabal・HLSの版は`mise.toml`の`[vars]`で決める．変えるときは，HLSがそのGHCに対応していることを確かめる．
- `git commit`はlefthookのフックを実行する．失敗したら指摘を直す．`--no-verify`は使わない．
- 変更後は`mise run check`を実行する．

## Code map

```
iterations/iteration-N/
  exercise/    演習用パッケージ．学習者がここに実装とテストを書き足す．
  solution/    解答例パッケージ．exerciseを完成させた状態．
docs/          Iterationをまたいで参照する資料(Haskellの文法・概念のリファレンスなど)．
cabal.project  全パッケージをまとめるcabalプロジェクト．
mise.toml      ツールの版とタスク(toolchain/install/fmt/lint/test/check/setup)．
.devcontainer/ 開発用コンテナの定義．GHC・cabal・HLSはイメージのビルド時にghcupで入る．
```

# Artifact Cleanup

## Golden Rule

**Whenever you produce an artifact, always run the `system-development-skills:finalize-artifacts` skill to clean it up before reporting the work as done.**

An artifact is any deliverable you create or substantially rewrite: documents, READMEs, code and code comments, config files, scripts, commit messages, PR descriptions, and so on.

- Invoke the skill via the Skill tool (`system-development-skills:finalize-artifacts`) after the artifact is written and before the final reply.
- The skill edits the artifact files in place. Do not append a changelog of the cleanup to the artifact; in the final reply, mention what changed in a sentence or two at most unless the user asks for a full report.
- Skip it only for replies that produce no artifact (answering questions, explaining code, running read-only commands).
- Provided by the `enunun/system-development-skills` plugin (see `extraKnownMarketplaces`/`enabledPlugins` in `.claude/settings.json`).
