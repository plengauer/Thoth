# shellcheck shell=bash
. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

# shellcheck disable=SC2153 # TRACEPARENT is a different variable than the lowercase local
traceparent=$TRACEPARENT
assert_not_equals "" "$TRACEPARENT"

span_id=$(otel_span_start INTERNAL inner)
otel_span_activate "$span_id"
assert_not_equals "" "$TRACEPARENT"
assert_not_equals "$traceparent" "$TRACEPARENT"

otel_span_deactivate "$span_id"
otel_span_end "$span_id"
assert_equals "$traceparent" "$TRACEPARENT"
