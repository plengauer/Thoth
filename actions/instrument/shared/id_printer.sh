#!/bin/false
# shellcheck shell=bash

print_trace_link() {
  local endpoint="${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}}"
  case "$endpoint" in
    *dynatrace*) echo "$(echo "$endpoint" | cut -d / -f -3 | rev | cut -d . -f 3- | rev)".apps."$(echo "$endpoint" | cut -d / -f -3 | rev | cut -d . -f -2 | rev)"/ui/apps/dynatrace.distributedtracing/explorer'?sidebar=u%2Cfalse&'traceId="$(echo "$TRACEPARENT" | cut -d - -f 2)"'&'spanId="$(echo "$TRACEPARENT" | cut -d - -f 3)" ;;
    *) false ;;
  esac
}

import_trace_context() {
  local key value
  while IFS='=' read -r key value; do
    case "$key" in TRACEPARENT|TRACESTATE|B3) export "$key=$value" ;; esac
  done <"$1"
}
