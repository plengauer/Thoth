. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init
span_id=$(otel_span_start PRODUCER myspan)
assert_equals 0 $?
event_id="$(otel_event_create "myevent")"
otel_event_attribute "$event_id" foo=bar
otel_event_add "$event_id" "$span_id"
otel_span_end $span_id
otel_shutdown

span="$(resolve_span)"
assert_equals "myspan" $(echo "$span" | jq -r '.name')
assert_equals "myevent" "$(echo "$span" | jq -r '.events[0].name')"
assert_equals "bar" "$(echo "$span" | jq -r '.events[0].attributes.foo')"
