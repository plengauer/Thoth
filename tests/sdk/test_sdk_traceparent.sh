. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init
assert_equals "" "${TRACEPARENT:-}"

span_id=$(otel_span_start INTERNAL myspan)
assert_equals "" "${TRACEPARENT:-}"

otel_span_activate $span_id
traceparent=$TRACEPARENT
assert_not_equals "" "$TRACEPARENT"

span_id_2=$(otel_span_start INTERNAL inner)
otel_span_activate $span_id_2
assert_not_equals "" "$TRACEPARENT"
assert_not_equals "$traceparent" "$TRACEPARENT"

otel_span_deactivate $span_id_2
otel_span_end $span_id_2
assert_equals "$traceparent" "$TRACEPARENT"

otel_span_deactivate $span_id
otel_span_end $span_id
assert_equals "" "${TRACEPARENT:-}"

otel_shutdown
