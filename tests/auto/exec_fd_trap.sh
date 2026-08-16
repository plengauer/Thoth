. /usr/bin/opentelemetry_shell.sh

# An EXIT trap with an observable side effect, exactly like the pattern used by
# wrappers that start a background daemon and kill it on exit.
trap 'echo TRAP_FIRED' EXIT

file="$(\mktemp)"

echo BEFORE
# Redirection-only exec in a subshell, as used by readiness probes such as
# (exec 3<>/dev/tcp/127.0.0.1/PORT). This must not run the EXIT trap.
(exec 3<>"$file") 2>/dev/null || true
echo AFTER
