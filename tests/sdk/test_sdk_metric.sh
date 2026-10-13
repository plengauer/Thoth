# shellcheck shell=bash
set -e
. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init

counter_handle=$(otel_counter_create counter my.counter 1 'this is a description')
observation_handle=$(otel_observation_create 42)
otel_observation_attribute $observation_handle foo=bar
otel_counter_observe $counter_handle $observation_handle

counter_handle=$(otel_counter_create observable_gauge my.observable.gauge 1 'this is a description')
observation_handle=$(otel_observation_create 72 @1234567892)
otel_observation_attribute $observation_handle foo=bar
otel_counter_observe $counter_handle $observation_handle @1234567893

histogram_handle=$(otel_counter_create histogram my.histogram ms '' 'this is a histogram')
observation_handle=$(otel_observation_create 2.5)
otel_observation_attribute $observation_handle operation=test
otel_counter_observe $histogram_handle $observation_handle

histogram_handle=$(otel_counter_create histogram my.histogram.with_custom_buckets ms '0.1,0.5,1.0,5.0,10.0' 'histogram with explicit buckets')
observation_handle=$(otel_observation_create 3.7)
otel_observation_attribute $observation_handle operation=test_buckets
otel_counter_observe $histogram_handle $observation_handle

gauge_handle=$(otel_counter_create gauge my.timestamped.gauge 1 'timestamped gauge')
observation_handle=$(otel_observation_create 84 @1234567890)
otel_counter_observe "$gauge_handle" "$observation_handle"

gauge_handle=$(otel_counter_create gauge my.overridden.timestamped.gauge 1 'overridden timestamped gauge')
observation_handle=$(otel_observation_create 85)
otel_counter_observe "$gauge_handle" "$observation_handle" @1234567891

otel_shutdown

for i in 1 2 4; do
  values="$(jq -c -s '[.[].resource_metrics[].scope_metrics[].metrics[] | select(.name == "my.observable.gauge" or .name == "my.timestamped.gauge" or .name == "my.overridden.timestamped.gauge") | .data.data_points[].value] | sort' "$OTEL_EXPORT_LOCATION")"
  [ "$values" = '[72,84,85]' ] && break
  sleep "$i"
done
assert_equals '[72,84,85]' "$values"

/opt/opentelemetry_shell/venv/bin/python - "${OTEL_SHELL_SDK_PATH:-/usr/share/opentelemetry_shell/sdk.py}" <<'PY'
import importlib.util
import sys
from opentelemetry.context import get_current, get_value
from opentelemetry.sdk.metrics._internal.measurement import Measurement

spec = importlib.util.spec_from_file_location('opentelemetry_shell_sdk', sys.argv[1])
sdk = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sdk)
sdk.patch_metric_timestamps()
timestamp = sdk.parse_time('2026-10-12T10:52:27Z')
measurement = Measurement(1, 456, None, sdk.metric_context(timestamp))
assert measurement.time_unix_nano == timestamp
measurement = Measurement(1, 456, None, get_current())
assert measurement.time_unix_nano == 456
sdk.delayed_observations['timestamped'] = {'series': {'amount': 1, 'attributes': {}, 'timestamp': 123}}
observation = next(sdk.observable_counter_callback('timestamped', None))
assert get_value(sdk.metric_timestamp_context_key, observation.context) == 123
PY
