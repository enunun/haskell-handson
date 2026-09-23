# haskell-handson

Hands-on material for people learning Haskell for the first time (who already have programming experience in other languages).
Each Iteration has an exercise package and a solution package (cabal packages), all combined into a single cabal project.
The learner-facing material is written in Japanese.

# RTK (Rust Token Killer)

Prefix every shell command with `rtk`, including each command in a `&&` chain — it is always safe (a dedicated filter cuts noisy output for tests, builds, git, and more; anything without one passes through unchanged). The full command reference is in the global `~/.claude/RTK.md` (already loaded, if set up). Meta commands: `rtk gain` (savings so far), `rtk discover` (missed opportunities in past sessions), `rtk proxy <cmd>` (run unfiltered, for debugging).

## Working conventions

- When creating or fixing an Iteration, follow the `build-iteration` skill (`.claude/skills/build-iteration/SKILL.md`). The content of each Iteration is defined in `docs/ROADMAP.md`.
- Write for readers who do not know Haskell. Explain new syntax and concepts in the notes of the Iteration that first uses them (`docs/haskell/iteration-N.md`) before using them.
- Change the exercise and solution of the same Iteration together in the same commit.
- All solution tests must pass. Exercises must build even before the learner adds anything.
- The code, tests and design documents (`design/`) of Iteration N's (N ≥ 1) exercise are identical to Iteration N-1's solution. New modules, tests, additions to `.cabal` and design-document updates are left as the learner's work.
- Design documents are mermaid diagrams at the four levels of the C4 model (`design/01-context.md` to `04-code.md`; see `docs/design.md`). Arrows in the Component diagram must match the implementation's `import`s, and names in the Code diagram must match the implementation's names.
- The `packages` of `cabal.project` lists only solution packages (HLS analyzes only the packages listed there). Learners add the exercise package themselves at the start of each Iteration.
- The versions of GHC, cabal and HLS are set in `[vars]` of `mise.toml`. When changing them, make sure HLS supports that GHC.
- `git commit` runs lefthook hooks. If they fail, fix the reported issues. Do not use `--no-verify`.
- After making changes, run `mise run check`. It builds and tests every package, including exercises, using a temporary project file (`cabal.project.all`).
- GHC cannot handle Haskell code containing Japanese unless the locale is UTF-8. The dev container sets `LANG=C.UTF-8`.

## Code map

```
iterations/iteration-N/
  exercise/    Exercise package. The learner adds implementation and tests here.
               Contains docs/iteration-N.md (exercise steps), TESTLIST.md (test-list template) and design/ (design documents).
  solution/    Solution package: the exercise in its completed state.
               Contains docs/iteration-N.md (walkthrough of each step), TESTLIST.md and design/ (model answers).
docs/
  ROADMAP.md   Requirements, modules and learning topics of each Iteration. The content of Iterations is decided here.
  tdd.md       Test-driven development and how to write test lists.
  design.md    How to write design documents (C4 model, mermaid).
  cabal.md     How to use cabal.
  haskell/     Per-Iteration notes on Haskell syntax and concepts.
cabal.project  cabal project bundling the solution packages.
.hlint.yaml    hlint configuration.
tools/mermaid/ Script (Node) that checks the syntax of mermaid diagrams in Markdown.
mise.toml      Tool versions and tasks (toolchain/install/fmt/lint/test/test-all/check/setup).
.devcontainer/ Dev container definition. GHC, cabal and HLS are installed with ghcup when the image is built.
.claude/skills/build-iteration/  Skill describing how to build an Iteration.
```

# Artifact Cleanup

## Golden Rule

**Whenever you produce an artifact, always run the `system-development-skills:finalize-artifacts` skill to clean it up before reporting the work as done.**

An artifact is any deliverable you create or substantially rewrite: documents, READMEs, code and code comments, config files, scripts, commit messages, PR descriptions, and so on.

- Invoke the skill via the Skill tool (`system-development-skills:finalize-artifacts`) after the artifact is written and before the final reply.
- The skill edits the artifact files in place. Do not append a changelog of the cleanup to the artifact; in the final reply, mention what changed in a sentence or two at most unless the user asks for a full report.
- Skip it only for replies that produce no artifact (answering questions, explaining code, running read-only commands).
- Provided by the `enunun/system-development-skills` plugin (see `extraKnownMarketplaces`/`enabledPlugins` in `.claude/settings.json`).
