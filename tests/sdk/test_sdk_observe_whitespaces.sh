. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init
func_count() {
  echo $#
}
assert_equals 0 $(otel_observe func_count)
assert_equals 1 $(otel_observe func_count foo)
assert_equals 2 $(otel_observe func_count foo bar)
assert_equals 1 $(otel_observe func_count "foo bar")
assert_equals 3 $(otel_observe func_count foo "foo bar" foo)
otel_shutdown
