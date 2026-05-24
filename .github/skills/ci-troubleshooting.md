# CI Troubleshooting Skill

Apply this skill when investigating CI failures, flaky tests, or build issues in this repository.

## CI Pipeline Architecture

```
test.yml (triggers on push/PR to main, release/v*)
  └── ci.yml (workflow_call)
        ├── build.yml (15-30m)
        │   ├── verify-scripts: bash -n syntax check on all .sh files
        │   ├── build-http: C library for 6 architectures via Docker+QEMU
        │   ├── build-node: npm install for Node 16-23
        │   ├── build-python: pip install for Python 3.9-3.13
        │   ├── build-java: mvn + javac + jar
        │   ├── verify-deb-python-dependency: Python version constraint check
        │   ├── verify-deb-dependencies: shell command → package mapping check
        │   └── package-*: dpkg-deb, rpmbuild, abuild
        ├── test_shell.yml (1-2h)
        │   ├── smoke: quick test on ubuntu-latest with bash
        │   └── matrix: 100+ combinations of OS × shell × released versions
        └── test_github.yml (30-60m)
              └── GitHub Actions integration tests
```

## Common Failure Patterns

### Build Failures

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `verify-scripts` fails | Syntax error in a `.sh` file | Run `bash -n <file>` locally to find the error |
| `verify-deb-dependencies` fails | New shell command used without declaring the package | Add package to `meta/debian/control` Depends |
| `verify-deb-python-dependency` fails | Python version constraint too low for the OpenTelemetry SDK | Update `python3 (>= X.Y)` in `meta/debian/control` |
| `build-http` fails on non-amd64 | QEMU/Docker cross-compilation issue | Usually transient; re-run the job |
| `build-node` fails | npm dependency conflict | Check `package.json` version constraints |
| `package-deb` fails | Invalid `meta/debian/control` syntax | Check for trailing spaces, missing fields |

### Test Failures

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Test passes on bash but fails on dash/ash | Bash-specific syntax used in a `.sh` file | Use POSIX-only constructs or rename to `.bash` |
| `SPAN RESOLUTION ERROR` | Span was never emitted or has wrong name/attributes | Check instrumentation code for the span name |
| `ASSERT FAILED X != Y` | Span attribute has unexpected value | Check the assertion's expected value against actual output |
| Timeout (3-hour limit) | Infinite loop or deadlock in instrumentation | Check for alias recursion (missing backslash prefix) |
| Flaky test on specific OS versions | OS-specific tool behavior differences | Check if the tested command behaves differently on that OS |

### Investigating Failures

1. **Read the job logs**: Use GitHub MCP tools (`get_job_logs`) to retrieve failure logs
2. **Identify the failing test**: Look for `FAILED` in the output, preceding lines show the test file
3. **Check the span output**: Failing tests dump stdout, stderr, and OTLP output after `FAILED`
4. **Check if it's a known flaky test**: Some tests involving network calls (curl/wget to external URLs) can be flaky
5. **Check if it's OS-specific**: The matrix runs on many OS versions; if only one fails, it's likely an OS-specific issue

## Test Environment

Tests set these variables automatically (via `run_tests.sh`):
- `OTEL_EXPORT_LOCATION`: Temp file where spans/logs are written
- `OTEL_TRACES_EXPORTER=console`, `OTEL_METRICS_EXPORTER=console`, `OTEL_LOGS_EXPORTER=console`
- `OTEL_SHELL_SDK_STDOUT_REDIRECT`: Named pipe for SDK output
- `TEST_SHELL`: The shell being tested (bash, dash, ash, `busybox sh`)

Shell options applied:
- All shells: `-f -u` (no globbing, error on unset variables)
- Bash additionally: `-p -o pipefail` (privileged mode, pipefail)

## Re-running Failed Jobs

Transient failures (network timeouts, QEMU issues) can be resolved by re-running the failed job. The `autorerun.yml` workflow automatically retries some failures.
