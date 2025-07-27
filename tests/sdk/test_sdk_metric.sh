set -e
. /usr/bin/opentelemetry_shell_api.sh

otel_init

counter_handle=$(otel_counter_create counter my.counter 1 'this is a description')
observation_handle=$(otel_observation_create 42)
otel_observation_attribute $observation_handle foo=bar
otel_counter_observe $counter_handle $observation_handle

counter_handle=$(otel_counter_create observable_gauge my.observable.gauge 1 'this is a description')
observation_handle=$(otel_observation_create 72)
otel_observation_attribute $observation_handle foo=bar
otel_counter_observe $counter_handle $observation_handle

otel_shutdown
