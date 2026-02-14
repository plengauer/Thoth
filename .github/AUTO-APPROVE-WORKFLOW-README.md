# Auto-Approve Renovate Pull Requests Workflow

## Overview

This GitHub Agentic Workflow automatically approves pull requests that only contain dependency updates or version bumps from trusted sources (Renovate bot or repository owner).

## Workflow Files

- **`.github/workflows/auto-approve-renovate-prs.md`**: The source workflow file containing the AI agent instructions
- **`.github/workflows/auto-approve-renovate-prs.lock.yml`**: The compiled GitHub Actions workflow file (auto-generated, do not edit)

## How It Works

### Trigger

The workflow runs on pull request events:
- `opened`: When a PR is first created
- `synchronize`: When new commits are pushed to the PR
- `reopened`: When a closed PR is reopened
- `ready_for_review`: When a draft PR is marked as ready for review

### Verification Process

The AI agent performs the following checks before approving a PR:

#### 1. PR Status Check
- Verifies the PR is NOT a draft

#### 2. Author Verification
- All commits must be authored by:
  - Renovate bot (username: `renovate[bot]`)
  - Repository owner: `plengauer`
- No commits from any other users are allowed

#### 3. Changes Verification
- Only the following file changes are permitted:
  - **Dependency files**:
    - `package.json` and `package-lock.json` (Node.js)
    - `requirements.txt` (Python)
    - `pom.xml` (Java/Maven)
    - `meta/debian/control` (Debian dependencies)
    - `meta/rpm/*.spec` (RPM dependencies)
    - `.github/images.json` (Docker images)
    - Other package manager lock files
  - **Version file**:
    - Root-level `VERSION` file (version bump only)
- No code logic changes are allowed
- No new functionality or configuration changes beyond dependencies

#### 4. Final Verification
- All criteria must be met beyond any reasonable doubt
- If there is ANY uncertainty, the PR will NOT be approved

### Approval Behavior

**If all criteria are met:**
- The workflow approves the PR with a comment explaining:
  - What criteria were verified
  - Summary of changes made
  - Confirmation that the PR is safe to merge

**If any criteria are not met:**
- The workflow does NOT approve the PR
- Optionally adds a comment explaining which criteria were not met
- Uses the `noop` safe output to signal completion without approval

## Security Features

1. **Strict Mode**: The workflow runs in strict mode with minimal permissions
2. **Separation of Permissions**: The main AI agent has only read permissions; PR approval is handled by a separate job with write permissions
3. **Template Injection Protection**: All GitHub context variables are passed via environment variables
4. **Conservative Approach**: When in doubt, the workflow does NOT approve

## Modifying the Workflow

To make changes to the workflow:

1. Edit `.github/workflows/auto-approve-renovate-prs.md`
2. Compile the workflow: `gh aw compile auto-approve-renovate-prs`
3. Commit both the `.md` and `.lock.yml` files

**Note**: The `.lock.yml` file is automatically generated and should not be edited directly.

## Example Scenarios

### ✅ Will Be Approved
- Renovate bot updates Node.js dependencies in `package.json`
- Repository owner bumps version in `VERSION` file
- Combined dependency updates to multiple package files

### ❌ Will NOT Be Approved
- PR contains code changes in addition to dependency updates
- PR includes commits from users other than Renovate or repository owner
- PR is still in draft status
- PR modifies files outside the allowed list
- Any uncertainty about the safety of the changes

## Troubleshooting

### Workflow Not Running
- Check that the PR is from the same repository (not from a fork)
- Ensure the PR is not in draft status (or has been marked ready for review)

### PR Not Being Approved
- Check the workflow logs to see which criteria were not met
- Verify all commits are from trusted authors
- Ensure only dependency files are modified

### Modifying the Allowed Files List
Edit the instructions in `.github/workflows/auto-approve-renovate-prs.md` under the "Changes Verification" section and recompile.
