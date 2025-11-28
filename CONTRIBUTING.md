# Contributing to Thoth

Thank you for your interest in contributing to Thoth (also known as `opentelemetry-bash`, `opentelemetry-shell`, and `opentelemetry-github`)! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Development Environment](#development-environment)
- [Building the Project](#building-the-project)
- [Testing](#testing)
- [Code Style Guidelines](#code-style-guidelines)
- [Submitting Changes](#submitting-changes)
- [Release Process](#release-process)
- [Getting Help](#getting-help)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors. Please be kind, constructive, and professional in all interactions.

## Getting Started

Before contributing, please:

1. **Read the [README.md](README.md)** to understand what the project does
2. **Review existing issues and PRs** to avoid duplicating work
3. **Open an issue first** for significant changes to discuss your approach
4. **Fork the repository** and create a branch for your changes

## Project Structure

```
.
├── src/                           # Package source code
│   ├── usr/bin/                   # Symlinks to main scripts (otel.sh, otelapi.sh)
│   ├── usr/share/opentelemetry_shell/  # Core shell instrumentation (25+ .sh files)
│   │   ├── agent.*.sh             # Instrumentation agents for various tools
│   │   ├── api.*.sh               # API implementations
│   │   └── agent.instrumentation.*/  # Language-specific instrumentation (node, python, java)
│   └── opt/opentelemetry_shell/   # Python SDK requirements
├── meta/                          # Package metadata
│   ├── debian/                    # Debian package files (control, postinst, prerm, triggers)
│   ├── rpm/                       # RPM package specification
│   └── apk/                       # Alpine package files
├── tests/                         # Test suite
│   ├── run_tests.sh               # Test runner script
│   ├── assert.sh                  # Test assertion framework
│   ├── unit/                      # Unit tests
│   ├── sdk/                       # SDK functionality tests
│   ├── auto/                      # Auto-instrumentation tests
│   └── integration/               # Integration tests
├── actions/                       # GitHub Actions
│   └── instrument/
│       ├── job/                   # Job-level instrumentation action
│       ├── workflow/              # Workflow-level instrumentation action
│       ├── deploy/                # Automatic deployment action
│       └── shared/                # Shared action components
├── demos/                         # Example scripts and their traces
├── .github/workflows/             # CI/CD workflows
├── VERSION                        # Current version number
├── LICENSE                        # Apache 2.0 License
└── README.md                      # Main documentation
```

## Development Environment

### Prerequisites

For shell script development:
- Linux-based operating system (Debian/Ubuntu, RHEL/Fedora/OpenSuse, or Alpine)
- Shell interpreters: `bash`, `dash`, `ash`, `busybox`
- Tools: `jq`, `curl` or `wget`, `strace` (recommended)

For testing:
- The `opentelemetry-shell` package must be installed first
- Test dependencies are declared in `meta/debian/control`

### Setting Up for Testing

Tests require the package to be installed. During development:

1. Build the package via GitHub Actions (see [Building the Project](#building-the-project))
2. Download the built artifact
3. Install it:
   ```bash
   sudo apt-get -y install ./package.deb  # Debian/Ubuntu
   # or
   sudo rpm -i ./package.rpm              # RHEL/Fedora
   # or
   sudo apk add --allow-untrusted ./package.apk  # Alpine
   ```

## Building the Project

> **CRITICAL**: The build process is **multi-stage and runs via GitHub Actions only**. There are no local build scripts. Build duration is approximately 15-30 minutes.

### Build Stages

1. **C library**: Compiles `libinjecthttpheader.so` for 6 architectures using Docker+QEMU
2. **Node.js modules**: Installs dependencies for Node.js 16-23
3. **Python packages**: Installs OpenTelemetry packages for Python 3.9-3.13
4. **Java agents**: Compiles Java agents using Maven
5. **Packages**: Creates `.deb`, `.rpm`, and `.apk` packages

### Triggering a Build

Builds are automatically triggered:
- On push to `main` or `release/v*` branches
- On pull requests to `main` or `release/v*` branches

To test your changes:
1. Push your changes to a branch
2. Open a PR to trigger the CI pipeline
3. The `test.yml` workflow will build and test your changes

## Testing

### Test Structure

- **Unit tests** (`tests/unit/`): Test individual functions and utilities
- **SDK tests** (`tests/sdk/`): Test SDK functionality (spans, metrics, etc.)
- **Auto tests** (`tests/auto/`): Test automatic instrumentation
- **Integration tests** (`tests/integration/`): Test real-world scenarios

### Running Tests

> **Important**: Tests require the package to be installed first!

```bash
cd tests
bash run_tests.sh bash    # Test with bash
bash run_tests.sh dash    # Test with dash
bash run_tests.sh ash     # Test with ash
bash run_tests.sh busybox # Test with busybox
```

### Writing Tests

1. Create a test file in the appropriate directory (e.g., `tests/auto/test_auto_yourfeature.sh`)
2. Use the assertion framework from `assert.sh`:
   ```bash
   . ./assert.sh
   
   # Your test code here
   
   span="$(resolve_span '.name == "your span name"')"
   assert_equals "expected" "$(echo "$span" | jq -r '.attributes.key')"
   ```
3. Test files must work on all supported shells

### Test Environment Variables

- `OTEL_EXPORT_LOCATION`: Temporary file for OTLP output
- `OTEL_TRACES_EXPORTER=console`: Export traces to console
- `OTEL_METRICS_EXPORTER=console`: Export metrics to console
- `OTEL_LOGS_EXPORTER=console`: Export logs to console

## Code Style Guidelines

### Shell Compatibility

**All shell code MUST work on bash, dash, ash, and busybox.** This means:

- Use POSIX-compliant syntax only
- Avoid bash-specific features (arrays, `[[`, `+=`, etc.) unless in bash-specific files
- Use `[ ]` instead of `[[ ]]`
- Use backticks or `$()` for command substitution
- Test on multiple shells before submitting

### Avoiding Alias Recursion

When writing instrumentation code:

- Use backslash before commands to bypass alias resolution (e.g., `\echo`, `\cat`)
- This prevents infinite recursion when commands are aliased for instrumentation

### Naming Conventions

- Internal functions: Prefix with `_otel_` (e.g., `_otel_helper_function`)
- Public API functions: Prefix with `otel_` (e.g., `otel_span_start`)
- Environment variables: Prefix with `OTEL_` or `OTEL_SHELL_`

### Comments

- Use comments sparingly and only when necessary to explain complex logic
- Follow the existing style in the file you're editing

### Dependencies

When adding new dependencies:

1. Update the language-specific configuration file:
   - Python: `src/usr/share/opentelemetry_shell/agent.instrumentation.python/requirements.txt`
   - Node.js: `src/usr/share/opentelemetry_shell/agent.instrumentation.node/package.json`
   - Java: `src/usr/share/opentelemetry_shell/agent.instrumentation.java/pom.xml`
   - SDK Python wrapper: `src/opt/opentelemetry_shell/requirements.txt`

2. Update package metadata:
   - Debian: `meta/debian/control` (Pre-Depends, Depends, Recommends, Suggests)
   - RPM: `meta/rpm/opentelemetry-shell.spec` (Requires)
   - Alpine: `meta/apk/APKBUILD` (depends)

3. The `verify-deb-dependencies` workflow will automatically validate that shell commands are available via declared dependencies

## Submitting Changes

### Pull Request Process

1. **Create a descriptive PR title** that summarizes the change
2. **Fill out the PR description** with:
   - What the change does
   - Why it's needed
   - How to test it
3. **Ensure CI passes**:
   - Main test workflow (`test.yml`) which orchestrates build and all tests
   - CodeQL analysis (`analyze.yml`)
4. **Address review feedback** promptly
5. **Squash commits** if requested

### PR Requirements

- [ ] Code follows the style guidelines
- [ ] Tests are added for new functionality
- [ ] Tests pass on all supported shells (bash, dash, ash, busybox)
- [ ] Documentation is updated if needed
- [ ] Package dependencies are updated if needed
- [ ] CI pipeline passes

### Commit Messages

Use clear, concise commit messages:
- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Fix bug" not "Fixes bug")
- Keep the first line under 72 characters
- Add details in the body if needed

## Release Process

Releases are automated via the `publish.yml` workflow:

1. **Version bump**: Update the `VERSION` file on the `main` branch
2. **Automatic trigger**: The workflow triggers on pushes to `main` that change `VERSION`
3. **Build and test**: Full test suite runs before publishing
4. **Release creation**: GitHub release is created with `.deb`, `.rpm`, and `.apk` packages
5. **Attestations**: Build provenance attestations are generated for supply chain security

### Version Format

The project uses semantic versioning: `MAJOR.MINOR.PATCH` (e.g., `5.36.0`)

## Getting Help

- **Issues**: Open a [GitHub issue](https://github.com/plengauer/opentelemetry-shell/issues) for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check the [README.md](README.md) and [demos](demos/) for examples

## License

By contributing to Thoth, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).

---

Thank you for contributing to Thoth! Your efforts help make shell script observability better for everyone.
