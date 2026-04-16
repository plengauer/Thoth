#!/bin/false

if \[ "${GITHUB_ACTIONS:-false}" = true ]; then
  if \[ -n "${GITHUB_ACTION:-}" = github/gh-aw-actions/setup ] && \[ -z "${INPUT_TRACE_ID:-}" ]; then
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
