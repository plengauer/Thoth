#!/bin/false

print_trace_id() {
  case "${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}}" in
    *dynatrace*) echo "<a href=\"$(print_dynatrace_link)\">$(echo "$TRACEPARENT" | cut -d - -f 2)</a>";;
    *) echo "$TRACEPARENT" | cut -d - -f 2;;
  esac
}

print_span_id() {
  case "${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}}" in
    *dynatrace*) echo "<a href=\"$(print_dynatrace_link)\">$(echo "$TRACEPARENT" | cut -d - -f 3)</a>";;
    *) echo "$TRACEPARENT" | cut -d - -f 3;;
  esac
}

print_dynatrace_link() {
  local endpoint="${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}}"
  local trace_id="$(echo "$TRACEPARENT" | cut -d - -f 2)"
  local span_id="$(echo "$TRACEPARENT" | cut -d - -f 3)"
  echo "$(echo "$endpoint" | cut -d / -f -3 | rev | cut -d . -f 3- | rev)".apps."$(echo "$endpoint" | cut -d / -f -3 | rev | cut -d . -f -2 | rev)"/ui/apps/dynatrace.distributedtracing/explorer'?sidebar=u%2Cfalse&tf=now-14d%3Bnow&'traceId="$trace_id"'&'spanId="$span_id";;
}
