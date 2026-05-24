# Version and Release Skill

Apply this skill when working with version bumps, release processes, or understanding the release pipeline.

## Version File

The version is stored in a single file: `VERSION` (e.g., `5.50.0`). This file drives all versioning:
- Package metadata uses `__VERSION__` placeholder, replaced at build time from this file
- Git tags are created as `vMAJOR.MINOR.PATCH` (e.g., `v5.50.0`)
- Rolling tags `vMAJOR.MINOR` and `vMAJOR` are force-updated on each release

## Release Pipeline

```
VERSION file changed on main → publish.yml triggers
  1. ci.yml runs full test suite (build + test_shell + test_github)
  2. On success: publish job creates GitHub release
     - Downloads build artifacts (.deb, .rpm, .apk, container images)
     - Creates build provenance attestations
     - Pushes container images to ghcr.io with version tags
     - Creates GitHub release with release notes and package files
     - Updates rolling git tags (vMAJOR.MINOR, vMAJOR)
```

## Versioning Scheme

- Format: `MAJOR.MINOR.PATCH` (semantic versioning)
- The `autoversion.yml` workflow automatically bumps versions based on PR content
  - Triggers: on PR close to main, monthly schedule, or manual dispatch
  - Uses the `plengauer/autoversion` action with OpenAI to analyze changes
  - Threshold: `increment_threshold: minor` (auto-bumps up to minor, major requires manual)
- The `autoversion_release.yml` workflow bumps patch version on release branches (`release/v*.*`)

## Release Branches

- `main`: Primary development branch, auto-versioned
- `release/v*.*`: Release branches (e.g., `release/v5.50`) for backport fixes
  - Pushes to these branches with changes in `meta/`, `src/`, or `actions/` auto-bump patch version
  - The version bump creates a PR that auto-merges

## How to Trigger a Release

### Automatic (normal flow)
1. Merge a PR to `main`
2. Comment `!release` on the PR (by repo owner) to trigger versioning
3. `autoversion.yml` bumps `VERSION` file via a commit
4. `publish.yml` detects the VERSION change and runs the full pipeline

### Manual version bump
1. Edit `VERSION` file directly (set new version number)
2. Commit to `main` or a `release/v*.*` branch
3. `publish.yml` triggers automatically

## Rules

1. **Never manually create git tags** — the publish workflow handles tag creation
2. **Never manually create GitHub releases** — the publish workflow handles this
3. **Use `ACTIONS_GITHUB_TOKEN` secret** — the PAT that has permissions to trigger downstream workflows
4. **Version changes on release branches** auto-create PRs via `peter-evans/create-pull-request`
5. **The publish workflow runs CI first** — a release is only created if all tests pass
