# Build Packages Skill

Apply this skill when you need to build project artifacts (especially `.deb` for tests) or when build behavior is part of the task.

## Source of Truth

- Use `.github/workflows/build.yml` as the canonical build definition.
- Do not duplicate job commands in instructions. Read the workflow and follow its current steps.
- Derive what to run from the target job and its `needs` graph.

## How to Plan a Build

1. Identify your target output (`build-deb`, `build-rpm`, `build-apk`, or `build-workflow-image`).
2. Read that job's `needs` list in `.github/workflows/build.yml`.
3. Include all required upstream jobs for a faithful build.
4. Reuse workflow commands directly (same order and tools) instead of inventing new build scripts.

## Tradeoffs for Faster Task Iteration

- If a task only touches shell logic that does not involve deep injections, prefer the minimal path needed to validate that change.
- Skip rebuilding language bundles that are out of scope:
  - No Node.js changes: skip Node module rebuild work.
  - No Python changes: skip Python site-package rebuild work.
  - No Java changes: skip Java agent rebuild work.
  - No HTTP C injection changes: skip cross-arch HTTP library rebuild work.
- Keep in mind: official CI package jobs depend on these stages, so run full workflow-equivalent builds when validating release-quality packaging changes.

## Practical Guidance for Test Preparation

- For local/agent validation before shell tests, focus on producing a `.deb` suitable for the task scope.
- For full parity with CI artifacts, follow `build-deb` plus all of its `needs` from `.github/workflows/build.yml`.
