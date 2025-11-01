# Thoth (OpenTelemetry for Shell) - Copilot Agent Instructions

## Overview
**Thoth** (aliases: `opentelemetry-bash`, `opentelemetry-shell`, `opentelemetry-github`) provides OpenTelemetry traces/metrics/logs for shell scripts and GitHub workflows. This is a **packaging project** integrating Shell, Python 3.9+, Node.js, Java 8+, and C to auto-instrument shell scripts.

**Key Facts**: 41 source files (31 .sh, 3 .py, 4 .java, 1 .c) | Package: `opentelemetry-shell` | Version: `/VERSION` file | Platforms: Debian/Ubuntu (apt), RHEL/Fedora/OpenSuse (rpm), Alpine (apk), GitHub Actions

## Structure
- **`src/`**: Package source (mirrors `/usr` and `/opt` filesystem)
  - `src/usr/bin/`: Symlinks to `otel.sh`, `otelapi.sh`
  - `src/usr/share/opentelemetry_shell/`: Core shell instrumentation (25+ .sh files)
  - `src/opt/opentelemetry_shell/`: Python SDK wrapper
- **`meta/debian/`, `meta/rpm/`, `meta/apk/`**: Package metadata, postinst/prerm scripts
- **`tests/`**: 67 tests across unit/sdk/auto/integration dirs, `run_tests.sh` runner, `assert.sh` framework
- **`actions/instrument/`**: GitHub Actions (job, workflow, deploy)
- **`.github/workflows/`**: 19 CI/CD workflows

## Build Process
**CRITICAL**: Build is **multi-stage via GitHub Actions only** (`.github/workflows/build.yml`). No local build scripts exist. Duration: 15-30 minutes.

### Build Stages
1. **C library**: `gcc -shared -fPIC -o libinjecthttpheader.so agent.injection.http_header.c -ldl` for 6 architectures (amd64, arm64, mips64le, ppc64le, riscv64, s390x) using Docker+QEMU
2. **Node.js modules**: `npm install && npm prune` for Node 16-23 → `node_modules.tar.xz`
3. **Python packages**: `python3 -m venv venv && pip3 install -r requirements.txt` for Python 3.9-3.13 → `python_site_packages.tar.xz`
4. **Java agents**: `mvn dependency:resolve && javac && jar` → `*.jar` files
5. **Packages**: `dpkg-deb` (.deb), `rpmbuild` (.rpm), `abuild` (.apk) combining all artifacts

**Dependencies**: Docker, Node 16-23, Python 3.9-3.13, Java 8+, Maven, dpkg-deb, rpmbuild, abuild
**Validation**: `verify-deb-dependencies` checks all shell commands exist in declared package dependencies

## Testing
**CRITICAL**: Tests **require package installation first**: `sudo apt-get -y install ./package.deb`

### Running Tests
```bash
cd tests && bash run_tests.sh bash  # Or dash, ash, busybox
```

**Test pipeline**: `test.yml` → `build.yml` + `test_shell.yml` (1-2h) + `test_github.yml` (30-60m)
**Test types**: unit, sdk, auto, integration (67 test files total)
**Test assertions** (from `assert.sh`): `assert_equals`, `resolve_span <jq_filter>`, `resolve_log <jq_filter>`
**Environment**: Tests use `OTEL_EXPORT_LOCATION` (temp file), `OTEL_*_EXPORTER=console`, 3-hour timeout
**Shells**: bash (`-f -u -p -o pipefail`), dash/ash/busybox (`-f -u`)

## CI/CD Workflows
**Main workflow**: `test.yml` (triggers on all pushes, **must pass for PR merge**)
- Orchestrates: `build.yml` (15-30m) → `test_shell.yml` (1-2h, 100+ OS/versions) + `test_github.yml` (30-60m)
- **Pre-merge requirements**: All tests pass, CodeQL clean

**Other workflows**:
- `analyze.yml`: CodeQL security scanning (C, JS, Python, Java, Actions) with `build-mode: none`
- `publish.yml`: Triggers on `/VERSION` changes, builds artifacts, creates GitHub release with attestations
- `verify-deb-dependencies`: Auto-validates shell commands exist in declared package dependencies
- `verify-deb-python-dependency`: Validates Python version matches OpenTelemetry SDK requirements

## Installation & Usage
**Install**: `sudo apt-get -y install ./package.deb` (testing) or `wget -O - https://raw.githubusercontent.com/plengauer/opentelemetry-shell/main/INSTALL.sh | sh` (production)
**Postinst** (`meta/debian/postinst`): Creates `/opt/opentelemetry_shell/venv`, extracts Node/Python modules for detected versions
**Prerm** (`meta/debian/prerm`): Removes venv and extracted modules
**Usage**: Source `. /usr/bin/otel.sh` (auto-instrumentation) or `. /usr/bin/otelapi.sh` (manual API)

## Configuration
**Standard OpenTelemetry vars**: `OTEL_SERVICE_NAME`, `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_EXPORTER_OTLP_HEADERS`, `OTEL_TRACES/METRICS/LOGS_EXPORTER` (otlp, console, none)
**Shell-specific** (defaults for GitHub Actions):
- `OTEL_SHELL_CONFIG_OBSERVE_PIPES=TRUE`: Count stdout/stderr bytes/lines
- `OTEL_SHELL_CONFIG_MUTE_BUILTINS=TRUE`: Skip builtin spans (echo, printf)
- `OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE`: Inject into Node.js/Python/Java
- `OTEL_SHELL_CONFIG_OBSERVE_SUBPROCESSES=TRUE`: Span all subprocesses

## Making Changes

### Code Changes
- **Shell scripts** (`src/usr/share/opentelemetry_shell/*.sh`): Edit directly, no compilation
- **Python/Node.js dependencies**: Update `requirements.txt` or `package.json`, triggers full rebuild
- **Java agents** (`.java` files): Requires rebuild via GitHub Actions
- **C library** (`agent.injection.http_header.c`): Requires rebuild via GitHub Actions

### Dependency Updates
**Always update both**:
1. Language-specific: `requirements.txt`, `package.json`, `pom.xml`
2. Package metadata: `meta/debian/control` (Pre-Depends/Depends), `meta/rpm/*.spec` (Requires)

### Version Bump
Edit `/VERSION` file → commit to `main` → `publish.yml` auto-triggers → creates GitHub release

### Testing Changes
```bash
# MUST install package first
sudo apt-get -y install ./package.deb
cd tests && bash run_tests.sh bash
```

## Common Errors & Solutions
- **"command not found: opentelemetry_shell_api.sh"**: Package not installed → `sudo apt-get install ./package.deb`
- **Test failures after dependency changes**: Update `meta/debian/control` dependencies, check `verify-deb-dependencies` job
- **Build failures**: Use GitHub Actions, local builds not supported
- **Python version mismatch**: Update `meta/debian/control` Python requirement to match OpenTelemetry SDK

## Key Architecture Facts
- **Instrumentation cache**: `/tmp/opentelemetry_shell_*_instrumentation_cache_*.aliases` (invalidated on script/executable changes)
- **Multi-language**: Shell (function wrapping), Python (`opentelemetry-instrumentation`), Node.js (`@opentelemetry/auto-instrumentations-node`), Java (OpenTelemetry agent), C (HTTP header injection)
- **GitHub Actions**: Workflow-level (GitHub API, post-completion) + job-level (injected first step) can coexist without duplication
- **Shell compatibility**: All code MUST work on bash, dash, ash, busybox with POSIX compliance

## Critical Rules
1. **Always install package before tests** - tests depend on `/usr/bin/*` files
2. **Never attempt local full builds** - use GitHub Actions workflows
3. **Test on all shells** (bash, dash, ash, busybox) for core instrumentation changes
4. **Update package metadata** (`meta/debian/control`, `meta/rpm/*.spec`) when changing dependencies
5. **Follow POSIX syntax** - code must run on all supported shells

**Trust these instructions**. Only search for information if instructions are incomplete or errors occur not documented here.
