. ./assert.sh
export OTEL_SHELL_CONFIG_OBSERVE_PIPES=TRUE
export OTEL_SHELL_CONFIG_OBSERVE_PIPES_STDIN=TRUE
. /usr/bin/opentelemetry_shell_api.sh

otel_init
assert_equals "hello
world 0" "$(echo "hello
world 0" | otel_observe cat)"
assert_equals "hello
world 1" "$(echo "hello
world 1" | otel_observe sh -c 'cat >&2' 2>&1)"
foo() { myvar=myvalue; }
otel_observe foo
assert_equals "myvalue" "$myvar"
otel_observe true
assert_equals 0 "$?"
otel_observe false
assert_not_equals 0 "$?"
otel_observe false 1> /dev/null 2> /dev/null
assert_not_equals 0 "$?"
otel_observe false < /dev/null
assert_not_equals 0 "$?"
file="$(mktemp)"
exit_code=0
otel_observe false < /dev/null 1> /dev/null 2> /dev/null
assert_not_equals 0 "$(cat "$file")"
echo '{"dependencies":{}}' > "$file"
if otel_observe jq '.version' "$file"; then _if=1; else _if=0; fi
assert_equals 1 "$_if"
otel_shutdown

span="$(resolve_span '.name == "cat"')"
if [ -z "${WSL_DISTRO_NAME:-}" ]; then
  assert_equals "14" $(echo "$span" | jq -r '.attributes."pipe.stdin.bytes"')
  assert_equals "2" $(echo "$span" | jq -r '.attributes."pipe.stdin.lines"')
fi
assert_equals "14" $(echo "$span" | jq -r '.attributes."pipe.stdout.bytes"')
assert_equals "2" $(echo "$span" | jq -r '.attributes."pipe.stdout.lines"')
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stderr.bytes"')
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stderr.lines"')

span="$(resolve_span '.name == "sh -c cat >&2"')"
if [ -z "${WSL_DISTRO_NAME:-}" ]; then
  assert_equals "14" $(echo "$span" | jq -r '.attributes."pipe.stdin.bytes"')
  assert_equals "2" $(echo "$span" | jq -r '.attributes."pipe.stdin.lines"')
fi
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stdout.bytes"')
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stdout.lines"')
assert_equals "14" $(echo "$span" | jq -r '.attributes."pipe.stderr.bytes"')
assert_equals "2" $(echo "$span" | jq -r '.attributes."pipe.stderr.lines"')
