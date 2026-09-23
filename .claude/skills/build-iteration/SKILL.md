---
name: build-iteration
description: Builds (or rebuilds) one Iteration of haskell-handson — the exercise and solution cabal packages, the exercise steps, walkthrough, test list and design documents (C4-model mermaid diagrams) with their model answers, and the Haskell syntax/concepts notes. Uses the matching section of docs/ROADMAP.md as the specification, verifies with builds, tests and diagram checks, then polishes with finalize-artifacts. Use when asked to "build Iteration N", "add the next Iteration", or "fix Iteration N" (e.g. 「Iteration Nを作って」「次のIterationを追加して」「Iteration Nを直して」).
---

# build-iteration

Builds one Iteration of the hands-on course that grows the household-budget program `kakeibo`.
Handle only one Iteration per run. If several are requested, finish them one at a time in ascending order.

All learner-facing material (READMEs, exercise steps, walkthroughs, test lists, design documents, Haskell notes, code comments) is written in Japanese, in the same style as the existing Iterations. Japanese strings quoted below (section labels, templates) must be used verbatim.

## Where the specification comes from

- What to build (requirements, usage, modules, what is learned, what to update in the design documents, and the cabal work the learner does) is taken only from the "Iteration N" section of `docs/ROADMAP.md`. If you want to add a feature that is not in the ROADMAP, update the ROADMAP first.
- The previous Iteration's solution package (code, tests, design documents) is the foundation carried over as is. Copy the whole directory rather than retyping it.
- Prose (README, exercise steps, walkthrough, test list) is written fresh for each Iteration. Do not copy and edit the previous Iteration's prose; this keeps topics from earlier Iterations from leaking in.

## Design principles of the material

1. **The exercise package starts from the same code and design documents as the previous solution.** The code, tests and design documents (`design/`) of Iteration N's (N ≥ 1) exercise package are identical to Iteration N-1's solution, apart from the package name. Do not add skeletons of new modules, `error "TODO"`, new tests, or this Iteration's design. Creating new module files, adding to `.cabal`, adding tests and updating the design documents are all the learner's work.
   - Iteration 0 is the only exception: the library modules are placed as skeletons containing only type signatures and `error "TODO: …"`, and the test directories contain only the hspec-discover driver (`Spec.hs`). The design documents consist of the four files with headings and an HTML comment describing which diagram to draw.
2. **The learner writes a test list instead of being given a specification.** The exercise steps contain only the requirements (「要求」), usage examples (「使い方の例」) and the type signatures of the modules to build (「作るもの」); they do not enumerate test cases. The learner writes a test list of unit and integration tests in `TESTLIST.md` and runs Red→Green one item at a time. The solution's `TESTLIST.md` is the model answer, with every item marked `- [x]`.
   - The exercise `TESTLIST.md` is a template containing only the headings (`## 単体テスト` and `## 結合テスト`).
   - At the test-list stage, the exercise steps have the learner look for existing tests whose expected values change, and add them to the test list as "change … to …" (「〜に変える」) items.
3. **Run the loop: test list → design → implementation → design review.** After writing the test list, the learner draws the types, functions and modules that realize the behavior in the design documents (`design/`), then implements them, then compares the design documents with the implementation and fixes any mismatch.
   - The design documents are split into the four levels of the C4 model (`01-context.md`, `02-container.md`, `03-component.md`, `04-code.md`). How to write them is defined in `docs/design.md`. Component shows the modules and the boundary between pure parts and parts that perform `IO`; Code shows the flow of types and functions (types as nodes, functions as arrows), the data types, and the order of `IO` (and, from Iteration 8, the properties that must hold).
   - The design step of the exercise contains only hints about which level and which part to think about, never the diagrams themselves. The solution's `design/` is the model answer, and the walkthrough describes what changed since the previous Iteration and why.
   - The solution's design documents must match the implementation. Arrows in the Component diagram must match the implementation's `import`s (checked with `check-component.sh`), and names in the Code diagram must match the implementation's names. Details such as names inside `where` go in the description below the diagram.
4. **The learner performs the cabal operations.** The exercise steps describe the following as tasks for the learner:
   - Registering the exercise package in the `packages` of `cabal.project`. The repository's `cabal.project` lists only solution packages; exercise packages are not registered.
   - Running `cabal build`, `cabal test`, `cabal run` and `cabal repl`. In the Iteration where a command form (such as how to specify a target) first appears, show it in full. From then on, state only what to do (e.g. "run only the unit tests") and let the learner compose the command.
   - Editing the `.cabal` file (adding to `exposed-modules`, `other-modules`, `build-depends`).
5. **Separate the roles of unit tests and integration tests.** Unit tests (`test/unit/`) check the functions of a single module in isolation. Integration tests (`test/integration/`) call `Kakeibo.App.run` and check combinations of modules. From Iteration 6 on, integration tests use a data file in a temporary directory.
6. **Tests belong to features.** There is one Spec file per module (`Kakeibo/MoneySpec.hs`, etc.), and it lives as long as the module exists. In an Iteration that changes an existing feature, add tests to the existing Spec file or rewrite its expected values. Never create files such as `IterationNSpec.hs`.
7. **Do not anticipate later Iterations.** Type signatures, module structure and comments contain only what is needed at that Iteration. Do not prepare arguments or types for later use.
8. **Explain new syntax and concepts in the notes of the Iteration that first uses them, before using them.** Explanations go in `docs/haskell/iteration-N.md`. The solution code must not use syntax (language extensions, type classes, operators, etc.) that has not been explained yet.
9. **Write affirmatively.** Do not write sentences that excuse how the material is built, such as "… is not used" or "does not depend on …". Write what is built and learned in that Iteration. When referring to later Iterations, phrase it positively: "Iteration N will …".
10. **The walkthrough maps one-to-one to the exercise steps.** The headings of the solution's `docs/iteration-N.md` use the same numbers and names as the steps in the exercise's `docs/iteration-N.md`. In the TDD step, show for each item of the model test list the test and the code at that point (including its fake-it form, if at that stage).

## Package names and directories

- Directories: `iterations/iteration-N/exercise/`, `iterations/iteration-N/solution/`
- Package names: `kakeibo-iterationN` (exercise), `kakeibo-solution-iterationN` (solution). cabal does not allow a purely numeric component in a package name, so do not put a hyphen between `iteration` and the number.
- The `.cabal` file name matches the package name. The executable is named `kakeibo` in both (started with `cabal run <package name>`).
- Modules start with `Kakeibo.`. Spec files live at the same hierarchy as the module under test (`test/unit/Kakeibo/MoneySpec.hs`).

## Package contents

```
README.md             What this Iteration builds, how to proceed, directory layout
TESTLIST.md           Test list (template in exercise, model answer in solution)
design/0[1-4]-*.md    Design documents (four C4 levels; exercise keeps the previous solution's, solution has the model answer)
docs/iteration-N.md   Exercise: exercise steps / Solution: walkthrough of each step
kakeibo-…N.cabal
app/Main.hs
src/Kakeibo/*.hs
test/unit/Spec.hs, test/unit/Kakeibo/*Spec.hs
test/integration/Spec.hs, test/integration/Kakeibo/AppSpec.hs
test/common/Kakeibo/Generators.hs   (From Iteration 8. Generators shared by both test suites)
```

The exercise's `docs/iteration-N.md` follows this outline:

1. **N-1 Setup**: register the package in `cabal.project`, build it, and confirm that all carried-over tests pass. Run the current program with `cabal run`.
2. **N-2 Learn the syntax and concepts**: read `docs/haskell/iteration-N.md` and solve small tasks to try in `cabal repl`.
3. **N-3 Write the test list**: present the requirements (「要求」), usage examples (「使い方の例」) and what to build (「作るもの」: modules and type signatures), and have the learner write `TESTLIST.md`. Also have them consider the impact on existing tests and how to split between unit and integration tests.
4. **N-4 Update the design documents**: give hints about which level and part of `design/` to update (modules to add, types to draw, branch points in the flow, etc.). After updating, have the learner check the diagram syntax with `mise run lint`. In Iteration 0 this step is "write the design documents" and has the learner read `docs/design.md`.
5. **N-5 Implement test-first**: turn each test-list item Red→Green one at a time. Give per-feature hints (functions to use, common pitfalls) and the necessary cabal work. Do not write the test cases themselves.
6. **N-6 Reflect**: pose questions comparing the solution's `TESTLIST.md` with the learner's own, and questions about the roles of unit and integration tests. The last question is "compare the design documents with the implementation and fix the design documents if they diverge".
7. **N-7 Advanced exercise**: a slightly further feature for which the learner runs the same cycle on their own. End by stating that the advanced exercise also proceeds in the order test list → design documents → implementation.

## Steps

1. Read the Iteration N and Iteration N-1 sections of `docs/ROADMAP.md`. Read the code, tests and design documents of Iteration N-1's solution package and `docs/haskell/iteration-(N-1).md`, to understand the state being carried over and which syntax has already been explained.
2. Copy the whole solution and rename the packages. `P` is the previous number.
   ```sh
   cd iterations
   for kind in solution exercise; do
     cp -r iteration-$P/solution iteration-$N/$kind
     rm -rf iteration-$N/$kind/dist-newstyle iteration-$N/$kind/docs/iteration-$P.md
   done
   sed -e "s/kakeibo-solution-iteration$P/kakeibo-solution-iteration$N/g" -e "s/Iteration $P・解答例/Iteration $N・解答例/" \
     iteration-$N/solution/kakeibo-solution-iteration$P.cabal > iteration-$N/solution/kakeibo-solution-iteration$N.cabal
   sed -e "s/kakeibo-solution-iteration$P/kakeibo-iteration$N/g" -e "s/Iteration $P・解答例/Iteration $N・演習用/" \
     iteration-$N/exercise/kakeibo-solution-iteration$P.cabal > iteration-$N/exercise/kakeibo-iteration$N.cabal
   rm iteration-$N/*/kakeibo-solution-iteration$P.cabal
   ```
   `README.md`, `TESTLIST.md` and `docs/` are rewritten later. The design documents (`design/`) stay as they are in the exercise; the solution's are updated in step 5.
3. Reset the exercise package's `TESTLIST.md` to the template, and write `README.md` and `docs/iteration-N.md` fresh (following the outline in "Package contents"). Do not touch the code, tests or design documents.
   The `TESTLIST.md` template is:
   ```markdown
   # テストリスト(Iteration N)

   `docs/iteration-N.md`の「要求」を読み，確かめたい振る舞いを1行に1つずつ書く．
   既存のテストのうち期待値が変わるものは，「〜に変える」という項目にする．
   書き方は[テスト駆動開発とテストリスト](../../../docs/tdd.md)を参照する．

   ## 単体テスト

   ## 結合テスト
   ```
4. Write the model-answer `TESTLIST.md` for the solution package.
5. Update the solution package's design documents (`design/`) according to "what to update in the design documents" (「設計書で更新するもの」) in the ROADMAP. Follow `docs/design.md` for how to draw the diagrams.
6. In the solution package, implement the ROADMAP's features and refactorings with TDD. In the order of the test-list items, write a test and see it fail before implementing. Keep the intermediate code for use in the walkthrough.
7. Compare the solution's design documents with the implementation and fix them to match. Record decisions made during implementation (helper functions, type-class instances, etc.) in the answers of the walkthrough's reflection step.
8. Write the solution's `README.md` and `docs/iteration-N.md` (a walkthrough for each exercise step). In the walkthrough of the design step, list the changes from the previous Iteration level by level and give the reasons for the decisions.
9. Write `docs/haskell/iteration-N.md` and update the table of contents in `docs/haskell/README.md`. Explain the syntax and concepts newly used in this Iteration (language extensions, operators, type classes, library functions) based on their type signatures and actual behavior. Include examples that can be tried in GHCi.
10. Add the solution package to the `packages` of `cabal.project`. Do not add the exercise package.
11. Verify.
    ```sh
    mise run fmt
    mise run check           # formatting, hlint, mermaid diagram checks, build and test of all packages (including exercises)
    .claude/skills/build-iteration/check-component.sh iterations/iteration-N/solution
    ```
    - All solution tests pass.
    - The exercise package builds, and all carried-over tests pass.
    - The exercise package's code, tests and design documents are identical to the previous Iteration's solution.
      ```sh
      diff -r -x '*.cabal' -x README.md -x TESTLIST.md -x docs -x dist-newstyle iterations/iteration-(N-1)/solution iterations/iteration-N/exercise
      ```
    - The arrows in the solution's Component diagram match the implementation's `import`s (`check-component.sh`).
    - `cabal run kakeibo-solution-iterationN -- …` behaves as in the ROADMAP's usage examples.
    - If later Iterations already exist, also check that Iteration N+1's exercise package matches Iteration N's solution. If not, fix the exercise packages of N+1 onward (and the solutions, if affected).
12. Polish the prose written for this Iteration (both packages' `README.md`, `TESTLIST.md` and `docs/iteration-N.md`, the solution's design documents, source-code comments, and `docs/haskell/iteration-N.md`) with the `system-development-skills:finalize-artifacts` skill. Pay particular attention to leftover excuse-like sentences that violate design principle 9.

## Adding an Iteration

To add a new Iteration at the end of the ROADMAP, first add its section (including 「設計書で更新するもの」) and its row in the overview table to `docs/ROADMAP.md`, update the Iteration list in the root `README.md`, and then build it with the steps above.

## Output shown in the material must come from actually running it

GHCi evaluation results, compile error and warning messages, hspec failure messages, QuickCheck counterexamples and program output must be copied from real runs, never guessed.

- Get GHCi output by writing the input to a file and running `ghci -v0 < input-file` (when using the package's modules, `cabal repl -v0 <target> < input-file`).
- Exercise packages are not registered in `cabal.project`, so use the `cabal.project.all` generated by `mise run test-all` (`cabal build --project-file=cabal.project.all --builddir=dist-newstyle/all <target>`). After creating a new Iteration, run `mise run test-all` once to regenerate `cabal.project.all`.
- To break an implementation in order to capture failure output, copy the package into the scratchpad and break it there. Never break files in the repository.

## Pitfalls

- GHC cannot handle strings containing Japanese unless the locale is UTF-8. The dev container sets `LANG=C.UTF-8`. When running outside the container, prefix commands with `LANG=C.UTF-8`.
- GHCi displays evaluation results with `show`, so Japanese appears as code points such as `"\20870"` (hspec failure messages show it as is). In GHCi examples in the material, use alphanumeric values so no Japanese strings appear in the output, or display with `putStrLn`.
- Piping GHCi output into `head` or similar can leave GHCi running and consuming memory after the pipe closes. Write the output to a file and then read it.
- `Int`s generated by QuickCheck are usually biased toward absolute values up to about 100. For properties that should be checked with numbers of four or more digits, use `Large` (`\(NonNegative (Large n)) -> …`).
- hlint suggests rewriting recursion as `foldr`, `foldr (+) 0` as `sum`, and eta-reducing arguments. To preserve intermediate forms in the material, these suggestions are disabled in `.hlint.yaml`.
- `-Wall` warns about orphan instances for `Arbitrary` instances written in test modules. In tests, build generators as functions and use them with `forAll`.
- Right after editing a `.cabal` file, `cabal test <package name>` may fail with `Ambiguous target`. This is caused by a stale build plan in `dist-newstyle`; run `cabal clean` and try again.
- hspec-discover collects modules whose file names match `*Spec.hs`. When adding a Spec file, also add it to the test suite's `other-modules` (otherwise cabal warns).
- `<`, `>` and `&lt;` inside a mermaid diagram may be treated as HTML and break the rendering. Inside diagrams, describe them in words (e.g. 「タブで区切った行」). To use `"` inside a label, wrap the whole label in `"…"` and replace the inner `"` with 「」.
- Mermaid C4 diagrams can draw things outside the boundary (external libraries, data files) with `Component_Ext` and `ContainerDb_Ext`. `Boundary` can be nested inside `Container_Boundary`.
- `mise run test-all` sometimes fails during parallel builds with a `ghc-pkg` error `getModificationTime … does not exist`. It is a race over the package database files; just run it again.
