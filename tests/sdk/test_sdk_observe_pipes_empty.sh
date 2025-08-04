. ./assert.sh
export OTEL_SHELL_CONFIG_OBSERVE_PIPES=TRUE
export OTEL_SHELL_CONFIG_OBSERVE_PIPES_STDIN=TRUE
. /usr/bin/opentelemetry_shell_api.sh

otel_init
assert_equals "" "$(echo -n '' | otel_observe cat)"
otel_shutdown

span="$(resolve_span '.name == "cat"')"
if [ -z "${WSL_DISTRO_NAME:-}" ]; then
  assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stdin.bytes"')
  assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stdin.lines"')
fi
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stdout.bytes"')
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stdout.lines"')
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stderr.bytes"')
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stderr.lines"')
