# Shell Instrumentation Skill

Apply this skill when writing or modifying POSIX-compatible shell instrumentation code. This covers the core instrumentation scripts in `src/usr/share/opentelemetry_shell/`.

## Scope

- Adding, modifying, or fixing shell instrumentation agents (`agent.*.sh`)
- Modifying the API layer (`api.sh`, `api.observe.*.sh`)
- Working with the SDK layer (`opentelemetry_shell.sh`, `opentelemetry_shell_api.sh`)
- Adding instrumentation for new commands or tools

## Architecture

Instrumentation works by **aliasing commands**. An alias redirects to a function that starts/stops OpenTelemetry spans and then forwards to the original command. To avoid infinite recursion, all internal commands must be prefixed with a backslash (`\echo`, `\cat`, `\grep`, etc.) to bypass alias resolution.

Key files:
- `agent.sh`: Main auto-instrumentation entry point, sources `api.sh` and sets up agents
- `api.sh`: Core API (span start/end, attributes, events, metrics, resource attributes)
- `opentelemetry_shell.sh` / `opentelemetry_shell_api.sh`: Entry points sourced by users (`. /usr/bin/otel.sh`)
- `agent.instrumentation.*.sh`: Per-command instrumentation (curl, wget, git, docker, etc.)
- `agent.injection.*.sh`: Cross-process context propagation (netcat, HTTP headers)
- `agent.instrumentation.deep.sh`: Deep injection into Node.js, Python, Java subprocesses
- `api.observe.*.sh`: Observability for pipes, subprocesses, and logs

## Rules

1. **POSIX compliance**: All code MUST work on bash, dash, ash, and busybox. No bash-specific features (no arrays, no `[[`, no `+=`, no `${var,,}`, no process substitution `<()`) unless the file is bash-specific (`.bash` extension).
2. **Backslash prefix**: Every command used internally MUST use `\command` to avoid alias recursion (e.g., `\echo`, `\cat`, `\sed`, `\grep`, `\printf`, `\jq`, `\readlink`).
3. **No comments**: Keep code minimal and self-explanatory. Do not add comments.
4. **Naming conventions**: Use `_otel_` prefix for internal functions, `otel_` for public API functions. Variables use lowercase with underscores.
5. **Variable safety**: Always use `${var:-}` for potentially unset variables to avoid errors under `set -u`.
6. **Dependencies**: If your code uses a new external command, it MUST be declared in `meta/debian/control` (Depends/Pre-Depends) and `meta/rpm/opentelemetry-shell.spec` (Requires).
7. **No local builds**: The project builds via GitHub Actions only. Shell scripts need no compilation.

## Patterns

### Adding a new command instrumentation

Create `agent.instrumentation.<command>.sh` following this pattern:
- Define `_otel_inject_<command>()` that sets up aliases/functions
- The function should alias the command to a wrapper that: starts a span, runs the original command, captures exit code, sets span attributes, ends the span
- Register the agent in `agent.sh` by sourcing it

### Modifying span attributes

Use the API functions: `_otel_span_attribute`, `_otel_span_event`, `_otel_span_error`. Follow OpenTelemetry semantic conventions for attribute names.

## Testing

After making changes, tests in `tests/` validate behavior. Tests require the package to be installed first (`sudo apt-get -y install ./package.deb`), so you cannot run them locally in the coding agent. Instead, ensure your code is syntactically valid:
```bash
bash -n src/usr/share/opentelemetry_shell/your_file.sh
dash -n src/usr/share/opentelemetry_shell/your_file.sh  # if dash is available
```
