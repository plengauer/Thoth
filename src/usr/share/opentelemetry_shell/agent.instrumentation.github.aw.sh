#!/bin/false

if \[ "${GITHUB_ACTIONS:-false}" = true ]; then
  if \[ "${GITHUB_ACTION:-}" = github/gh-aw-actions/setup ] && \[ -z "${GH_AW_OTLP_ENDPOINTS:-}" ]; then
    if \[ -n "${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-}" ]; then
      export GH_AW_OTLP_ENDPOINTS="${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT%/v1/traces}"
    elif \[ -n "${OTEL_EXPORTER_OTLP_ENDPOINT:-}" ]; then
      export GH_AW_OTLP_ENDPOINTS="$OTEL_EXPORTER_OTLP_ENDPOINT"
    fi
  fi
  if \[ "${GITHUB_ACTION:-}" = github/gh-aw-actions/setup ] && \[ -z "${INPUT_TRACE_ID:-}" ]; then
    traceparent_stripped="$TRACEPARENT"
    traceparent_stripped="${traceparent_stripped#*-}"
    traceparent_stripped="${traceparent_stripped%-*}"
    export INPUT_TRACE_ID="${traceparent_stripped%%-*}"
  elif \[ -n "${GITHUB_AW_OTEL_PARENT_SPAN_ID:-}" ]; then
    traceparent_stripped="$TRACEPARENT"
    traceparent_stripped="${traceparent_stripped#*-}"
    traceparent_stripped="${traceparent_stripped%-*}"
    export GITHUB_AW_OTEL_PARENT_SPAN_ID="${traceparent_stripped%%-*}"
  fi
fi
