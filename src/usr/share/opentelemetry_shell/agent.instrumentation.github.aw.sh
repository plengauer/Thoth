#!/bin/false

if \[ "${GITHUB_ACTIONS:-false}" = true ]; then
  if \[ "${GITHUB_ACTION:-}" = github/gh-aw-actions/setup ] && \[ -z "${GH_AW_OTLP_ENDPOINTS:-}" ]; then
    if \[ -n "${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-}" ]; then
      export GH_AW_OTLP_ENDPOINTS="${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT%/v1/traces}"
    elif \[ -n "${OTEL_EXPORTER_OTLP_ENDPOINT:-}" ]; then
      export GH_AW_OTLP_ENDPOINTS="$OTEL_EXPORTER_OTLP_ENDPOINT"
    fi
  fi
  if \[ -n "${TRACEPARENT:-}" ]; then
    traceparent_stripped="$TRACEPARENT"
    traceparent_stripped="${traceparent_stripped#*-}"
    traceparent_stripped="${traceparent_stripped%-*}"
    trace_id="${traceparent_stripped%%-*}"
    span_id="${traceparent_stripped#*-}"
    if \[ "${GITHUB_ACTION:-}" = github/gh-aw-actions/setup ]; then
      export INPUT_TRACE_ID="$trace_id"
      export INPUT_PARENT_SPAN_ID="$span_id"
    elif \[ -n "${GITHUB_AW_OTEL_PARENT_SPAN_ID:-}" ]; then
      export GITHUB_AW_OTEL_TRACE_ID="$trace_id"
      export GITHUB_AW_OTEL_PARENT_SPAN_ID="$span_id"
    fi
  fi
fi
