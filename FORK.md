# Forking This Repository

## Why Forking Is Not Straightforward

This repository uses GitHub Actions that reference themselves via version tags (e.g., `@v5.36.0`). GitHub Actions require:
1. **Tags** - to resolve action references like `plengauer/opentelemetry-github/actions/instrument/job@v5.36.0`
2. **Releases** - to download packages (`.deb`, `.rpm`, `.apk`) attached as release assets

When you fork, GitHub copies the code but **not the tags or releases**. Without these, workflows fail because they cannot resolve action references or download packages.

## How to Fork

### Prerequisites
Create a **Personal Access Token (PAT)** with these scopes:
- `repo` - Full control of private repositories
- `workflow` - Update GitHub Action workflows
- `write:packages` - Upload packages to GitHub Package Registry
- `delete:packages` - Delete packages from GitHub Package Registry

### Steps

1. **Fork the repository** via GitHub's UI

2. **Add the PAT as a repository secret**:
   - Go to your fork → Settings → Secrets and variables → Actions
   - Create a new secret named `ACTIONS_GITHUB_TOKEN`
   - Paste your PAT as the value

3. **Run the "Initialize Fork" workflow**:
   - Go to Actions tab in your fork
   - Find "Initialize Fork" in the workflow list
   - Click "Run workflow" → "Run workflow"

### What the Initialize Fork Workflow Does

1. **Validates** that `ACTIONS_GITHUB_TOKEN` secret exists
2. **Enables** all workflows (forks have workflows disabled by default)
3. **Creates a version tag** (e.g., `v5.36.0`) from the current `VERSION` file
4. **Pushes the tag**, which triggers the publish workflow

The publish workflow then:
- Runs the full test suite
- Builds packages for all platforms/architectures
- Creates a GitHub Release with `.deb`, `.rpm`, and `.apk` packages attached
- Publishes container images to GitHub Container Registry

This process takes **15-60 minutes** depending on GitHub runner availability.

## After Initialization

Once the release is published, your fork is fully functional:
- Workflows can reference actions from your fork
- Users can install packages from your releases
- Container images are available from your GitHub Container Registry

To keep your fork updated, sync with upstream and run the publish workflow when the `VERSION` file changes.
