# Writing Tests Skill

Apply this skill when writing or modifying tests. This covers the test framework, assertion patterns, and conventions for validating shell instrumentation, SDK functionality, and integration scenarios.

## Scope

- Writing new test files in `tests/unit/`, `tests/sdk/`, `tests/auto/`, `tests/integration/`
- Modifying existing tests to cover new functionality or fix regressions
- Using the `assert.sh` test framework correctly

## Test Structure

Tests are organized in four directories:
- **`tests/unit/`**: Test individual utility functions
- **`tests/sdk/`**: Test the OpenTelemetry SDK API (manual spans, metrics, logs)
- **`tests/auto/`**: Test automatic instrumentation of commands (curl, wget, git, docker, etc.)
- **`tests/integration/`**: Test real-world scenarios and edge cases

### File naming
- Test files MUST be named `test_<category>_<description>.sh` (runs on all shells) or `test_<category>_<description>.bash` (bash-only)
- Helper scripts (sourced by tests) should NOT start with `test_`

### Test runner
Tests are executed by `tests/run_tests.sh <shell>` which:
1. Finds all `test_*.sh` and `test_*.<shell>` files in each directory
2. Runs each with shell options `-f -u` (bash adds `-p -o pipefail`)
3. Sets up `OTEL_EXPORT_LOCATION` temp file and console exporters automatically

## Assert Framework (`assert.sh`)

Source it at the top of every test: `. ./assert.sh`

Available assertions:
- `assert_equals <expected> <actual>` - Exact string equality
- `assert_not_equals <val1> <val2>` - Strings are not equal
- `assert_ends_with <suffix> <string>` - String ends with suffix
- `resolve_span '<jq_filter>'` - Wait for and resolve a span matching the jq filter from `$OTEL_EXPORT_LOCATION`
- `resolve_log '<jq_filter>'` - Wait for and resolve a log record matching the jq filter

### Span resolution
`resolve_span` retries with exponential backoff (1, 2, 4, 8, 16, 32 seconds). Use jq filter syntax for selection:
```sh
span="$(resolve_span '.name == "my span"')"
span="$(resolve_span '.attributes."http.method" == "GET"')"
span="$(resolve_span)"  # any span
```

### Extracting span data
Use `jq` to extract fields from resolved spans:
```sh
assert_equals "myspan" "$(echo "$span" | jq -r '.name')"
assert_equals "SpanKind.CLIENT" "$(echo "$span" | jq -r '.kind')"
assert_equals "0" "$(echo "$span" | jq -r '.attributes."shell.command.exit_code"')"
```

Common span fields: `.name`, `.kind`, `.parent_id`, `.status.status_code`, `.attributes.<key>`, `.trace_id`, `.context.span_id`

## Writing SDK Tests

SDK tests use the manual API:
```sh
. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init
span_id=$(otel_span_start CONSUMER myspan)
otel_span_end $span_id
otel_shutdown

span="$(resolve_span)"
assert_equals "myspan" $(echo "$span" | jq -r '.name')
```

## Writing Auto-Instrumentation Tests

Auto tests source `otel.sh` (via the installed package) and run commands:
```sh
set -e
. ./assert.sh

$TEST_SHELL auto/helper_script.sh arg1 arg2

span="$(resolve_span '.name == "expected span name"')"
assert_equals "expected_value" "$(echo "$span" | jq -r '.attributes."attribute.name"')"
```

Helper scripts (non-test scripts) go in the same directory. The test invokes them via `$TEST_SHELL` (set by the test runner).

## Rules

1. **POSIX compliance**: Tests in `.sh` files MUST work on bash, dash, ash, and busybox. Use `.bash` extension for bash-only tests.
2. **Use backslash for commands in assertions**: When echoing span data, use `\echo` and `\jq` if the test runs in an instrumented shell context.
3. **No comments**: Keep tests minimal and self-explanatory.
4. **Use `$TEST_SHELL`**: When invoking helper scripts, use `$TEST_SHELL` not `bash` directly.
5. **set -e**: Auto and integration tests should start with `set -e` to fail fast.
6. **Variable naming**: Use lowercase with underscores.

## Testing your tests

Tests require the installed package (`sudo apt-get -y install ./package.deb`), so they cannot be run in the coding agent environment. Validate syntax with `bash -n tests/<dir>/test_*.sh`.
