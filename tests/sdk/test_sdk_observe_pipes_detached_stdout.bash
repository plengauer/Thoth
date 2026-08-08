# disabled for non bash be ause dash has very weird (buggy) behavior for commands that follow closing stdout
. ./assert.sh
export OTEL_SHELL_CONFIG_OBSERVE_PIPES=TRUE
export OTEL_SHELL_CONFIG_OBSERVE_PIPES_STDIN=TRUE
. ${OTEL_TEST_API_ENTRYPOINT:-/usr/bin/opentelemetry_shell_api.sh}

exec 1>&-
otel_init
echo "hello world" | otel_observe cat
otel_shutdown

span="$(resolve_span '.name == "cat"')"
if [ -z "${WSL_DISTRO_NAME:-}" ]; then
  assert_equals "12" $(echo "$span" | jq -r '.attributes."pipe.stdin.bytes"')
  assert_equals "1" $(echo "$span" | jq -r '.attributes."pipe.stdin.lines"')
fi
assert_equals "12" $(echo "$span" | jq -r '.attributes."pipe.stdout.bytes"')
assert_equals "1" $(echo "$span" | jq -r '.attributes."pipe.stdout.lines"')
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stderr.bytes"')
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stderr.lines"')
