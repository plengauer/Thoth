. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init

span_id_1="$(otel_span_start INTERNAL one)"
span_id_2="$(otel_span_start INTERNAL two)"
assert_not_equals "$span_id_1" "$span_id_2"

event_id_1="$(otel_event_create one)"
event_id_2="$(otel_event_create two)"
assert_not_equals "$event_id_1" "$event_id_2"
otel_event_add "$event_id_1" "$span_id_1"

traceparent="$(otel_span_traceparent "$span_id_1")"
link_id_1="$(otel_link_create "$traceparent" "")"
link_id_2="$(otel_link_create "$traceparent" "")"
assert_not_equals "$link_id_1" "$link_id_2"
otel_link_add "$link_id_1" "$span_id_2"

counter_id_1="$(otel_counter_create counter my.counter.one)"
counter_id_2="$(otel_counter_create counter my.counter.two)"
assert_not_equals "$counter_id_1" "$counter_id_2"

observation_id_1="$(otel_observation_create 1)"
observation_id_2="$(otel_observation_create 2)"
assert_not_equals "$observation_id_1" "$observation_id_2"
otel_counter_observe "$counter_id_1" "$observation_id_1"
otel_counter_observe "$counter_id_2" "$observation_id_2"

otel_span_end "$span_id_1"
otel_span_end "$span_id_2"
otel_shutdown

span="$(resolve_span '.name == "one"')"
assert_equals "one" "$(echo "$span" | jq -r '.events[0].name')"

span="$(resolve_span '.name == "two"')"
assert_equals "1" "$(echo "$span" | jq -r '.links | length')"
