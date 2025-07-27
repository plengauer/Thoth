. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

assert_equals "hello" "$(_otel_escape_arg "hello")"
assert_equals "'hello world'" "$(_otel_escape_arg "hello world")"
assert_equals "'hello;world'" "$(_otel_escape_arg "hello;world")"
assert_equals "'hello
world'" "$(_otel_escape_arg "hello
world")"
assert_equals "'hello'\\''world'" "$(_otel_escape_arg "hello'world")"
assert_equals "'hello\\world'" "$(_otel_escape_arg "hello\\world")"
