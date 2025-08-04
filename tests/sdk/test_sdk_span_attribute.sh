. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init
span_id=$(otel_span_start SERVER myspan)
assert_equals 0 $?
otel_span_attribute $span_id key=value
assert_equals 0 $?
otel_span_attribute $span_id foo='bar
baz'
assert_equals 0 $?
otel_span_end $span_id
assert_equals 0 $?
otel_shutdown

span="$(resolve_span)"
assert_equals "myspan" $(echo "$span" | jq -r '.name')
assert_equals "SpanKind.SERVER" $(echo "$span" | jq -r '.kind')
assert_equals "null" $(echo "$span" | jq -r '.parent_id')
assert_equals "UNSET" $(echo "$span" | jq -r '.status.status_code')
assert_equals "value" $(echo "$span" | jq -r '.attributes.key')
assert_equals "bar baz" "$(echo "$span" | jq -r '.attributes.foo')"
