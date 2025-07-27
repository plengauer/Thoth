. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init
func_print() {
  echo "$@"
}
result=$(otel_observe func_print hello world)
assert_equals "hello world" "$result"
otel_shutdown
