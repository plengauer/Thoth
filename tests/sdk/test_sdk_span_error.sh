. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init
span_id=$(otel_span_start PRODUCER myspan)
assert_equals 0 $?
otel_span_error $span_id
assert_equals 0 $?
otel_span_end $span_id
assert_equals 0 $?
otel_shutdown

span="$(resolve_span)"
assert_equals "myspan" $(echo "$span" | jq -r '.name')
assert_equals "SpanKind.PRODUCER" $(echo "$span" | jq -r '.kind')
assert_equals "null" $(echo "$span" | jq -r '.parent_id')
assert_equals "ERROR" $(echo "$span" | jq -r '.status.status_code')

