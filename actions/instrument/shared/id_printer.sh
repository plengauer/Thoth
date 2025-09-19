#!/bin/false

print_trace_link() {
  local endpoint="${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}}"
  case "$endpoint" in
    *dynatrace*) echo "$(echo "$endpoint" | cut -d / -f -3 | rev | cut -d . -f 3- | rev)".apps."$(echo "$endpoint" | cut -d / -f -3 | rev | cut -d . -f -2 | rev)"/ui/apps/dynatrace.distributedtracing/explorer'?sidebar=u%2Cfalse&tf=now-7d%3Bnow&'traceId="$(echo "$TRACEPARENT" | cut -d - -f 2)"'&'spanId="$(echo "$TRACEPARENT" | cut -d - -f 3)"'&'"tt=$1";;
    *) false;;
  esac
}
