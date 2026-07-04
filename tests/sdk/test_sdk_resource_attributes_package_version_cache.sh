. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

export OTEL_SERVICE_NAME=TEST
export OTEL_SHELL_PACKAGE_VERSION_CACHE_opentelemetry_shell=1.2.3

otel_init
span_id=$(otel_span_start INTERNAL myspan)
otel_span_end $span_id
otel_shutdown

span="$(resolve_span)"
assert_equals "1.2.3" "$(echo "$span" | jq -r '.resource.attributes."telemetry.sdk.version"')"
