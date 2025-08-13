#!/bin/false

print_trace_id() {
  local trace_id="$(echo "$TRACEPARENT" | cut -d - -f 2)"
  case "${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}}" in
    *dynatrace*) echo "[$trade_id]($(print_dynatrace_link))";;
    *) echo "$trace_id";;
  esac
}

print_span_id() {
  local span_id="$("$TRACEPARENT" | cut -d - -f 3)"
  case "${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}}" in
    *dynatrace*) echo "[$span_id]($(print_dynatrace_link))";;
    *) echo "$span_id";;
  esac
}

print_dynatrace_link() {
  local endpoint="${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}}"
  echo "$(echo "$endpoint" | cut -d / -f -3 | rev | cut -d . -f 3- | rev)".apps."$(echo "$endpoint" | cut -d / -f -3 | rev | cut -d . -f -2 | rev)"/ui/apps/dynatrace.distributedtracing/explorer'?sidebar=u%2Cfalse&tf=now-14d%3Bnow&'traceId="$(echo "$TRACEPARENT" | cut -d - -f 2)"'&'spanId="$(echo "$TRACEPARENT" | cut -d - -f 3)"
}
