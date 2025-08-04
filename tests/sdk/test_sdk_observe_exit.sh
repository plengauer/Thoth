. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init
func_fail() {
  return $1
}
otel_observe func_fail 0
assert_equals 0 $?
otel_observe func_fail 1
assert_equals 1 $?
otel_observe func_fail 42
assert_equals 42 $?
otel_shutdown
