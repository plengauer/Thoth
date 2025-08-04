. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init
result=$(otel_observe echo "hello world")
assert_equals "hello world" "$result"
otel_shutdown
