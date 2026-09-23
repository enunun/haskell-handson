# PROJECT_NAME

TODO: 1-2文でプロジェクトの概要を書く．

# RTK (Rust Token Killer)

Prefix every shell command with `rtk`, including each command in a `&&` chain — it is always safe (a dedicated filter cuts noisy output for tests, builds, git, and more; anything without one passes through unchanged). The full command reference is in the global `~/.claude/RTK.md` (already loaded, if set up). Meta commands: `rtk gain` (savings so far), `rtk discover` (missed opportunities in past sessions), `rtk proxy <cmd>` (run unfiltered, for debugging).

## Working conventions

TODO: このプロジェクトの開発方針(ブランチ運用，コミットの粒度，レビューの要否など)を書く．

- `git commit`はlefthookのフックを実行する．失敗したら指摘を直す．`--no-verify`は使わない．
- 変更後は`mise run check`を実行する．

## Code map

TODO: 主要なディレクトリ構成とその役割を書く．

# Artifact Cleanup

## Golden Rule

**Whenever you produce an artifact, always run the `system-development-skills:finalize-artifacts` skill to clean it up before reporting the work as done.**

An artifact is any deliverable you create or substantially rewrite: documents, READMEs, code and code comments, config files, scripts, commit messages, PR descriptions, and so on.

- Invoke the skill via the Skill tool (`system-development-skills:finalize-artifacts`) after the artifact is written and before the final reply.
- The skill edits the artifact files in place. Do not append a changelog of the cleanup to the artifact; in the final reply, mention what changed in a sentence or two at most unless the user asks for a full report.
- Skip it only for replies that produce no artifact (answering questions, explaining code, running read-only commands).
- Provided by the `enunun/system-development-skills` plugin (see `extraKnownMarketplaces`/`enabledPlugins` in `.claude/settings.json`).
