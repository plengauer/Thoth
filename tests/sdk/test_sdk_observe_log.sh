. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init
otel_observe $TEST_SHELL sdk/log.sh
otel_shutdown

log="$(resolve_log '.body == "my log"')"
assert_equals "my log" "$(echo "$log" | jq -r '.body')"
