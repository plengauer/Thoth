# DISABLED because such a situation is super hard to reproduce manually
# in this case the stdin tee will try to read (maybe), process will either hang or terminate, and that will in turn then kill the tee
. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

exec 0<&-
export OTEL_SHELL_EXPERIMENTAL_OBSERVE_PIPES=TRUE
otel_init
assert_equals "" "$(otel_observe cat)"
otel_shutdown

span="$(resolve_span '.name == "cat"')"
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stdin.bytes"')
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stdin.lines"')
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stdout.bytes"')
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stdout.lines"')
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stderr.bytes"')
assert_equals "0" $(echo "$span" | jq -r '.attributes."pipe.stderr.lines"')
