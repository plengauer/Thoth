. /usr/bin/opentelemetry_shell.sh

# An EXIT trap with an observable side effect, like a wrapper that starts a
# background daemon and kills it on exit.
trap 'echo TRAP_FIRED' EXIT

echo BEFORE
# exec inside a subshell replaces the subshell's process image, so bash never runs
# an EXIT trap for it. Instrumentation must not run the script's EXIT handler here.
(exec echo INNER)
echo AFTER
