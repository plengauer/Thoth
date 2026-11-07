#!/bin/false
# shellcheck shell=bash

if \[ "${GITHUB_ACTIONS:-false}" = true ]; then
  # GITHUB_ACTION is the step id if the step has one (gh-aw compiles it with `id: setup`), so also identify the setup action by its repository and path
  _otel_aw_setup_action=false
  if \[ "${GITHUB_ACTION:-}" = github/gh-aw-actions/setup ]; then
    _otel_aw_setup_action=true
  elif \[ "${GITHUB_ACTION_REPOSITORY:-}" = github/gh-aw-actions ]; then
    case "${GITHUB_ACTION_PATH:-}" in
      */setup) _otel_aw_setup_action=true ;;
    esac
  fi
  if \[ "$_otel_aw_setup_action" = true ]; then
    # gh-aw compiles GH_AW_OTLP_ENDPOINTS as a JSON array even if no endpoint is configured (e.g. [{"url":"","headers":""}]), so it is never empty
    _otel_aw_otlp_endpoints_configured=false
    case "${GH_AW_OTLP_ENDPOINTS:-}" in
      '') ;;
      '['*) if printf '%s' "$GH_AW_OTLP_ENDPOINTS" | \grep -Eq '"url" *: *"[^"]'; then _otel_aw_otlp_endpoints_configured=true; fi ;;
      *) _otel_aw_otlp_endpoints_configured=true ;;
    esac
    if \[ "$_otel_aw_otlp_endpoints_configured" = false ]; then
      _otel_aw_otlp_endpoint=""
      if \[ -n "${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-}" ]; then
        _otel_aw_otlp_endpoint="${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT%/v1/traces}"
      elif \[ -n "${OTEL_EXPORTER_OTLP_ENDPOINT:-}" ]; then
        _otel_aw_otlp_endpoint="$OTEL_EXPORTER_OTLP_ENDPOINT"
      fi
      if \[ -n "$_otel_aw_otlp_endpoint" ]; then
        case "${GH_AW_OTLP_ENDPOINTS:-}" in
          '['*) export GH_AW_OTLP_ENDPOINTS="[{\"url\":\"$_otel_aw_otlp_endpoint\",\"headers\":\"\"}]" ;;
          *) export GH_AW_OTLP_ENDPOINTS="$_otel_aw_otlp_endpoint" ;;
        esac
      fi
    fi
  fi
  if \[ -n "${TRACEPARENT:-}" ]; then
    traceparent_stripped="$TRACEPARENT"
    traceparent_stripped="${traceparent_stripped#*-}"
    traceparent_stripped="${traceparent_stripped%-*}"
    trace_id="${traceparent_stripped%%-*}"
    span_id="${traceparent_stripped#*-}"
    if \[ "$_otel_aw_setup_action" = true ]; then
      export INPUT_TRACE_ID="$trace_id"
      export INPUT_PARENT_SPAN_ID="$span_id"
    elif \[ -n "${GITHUB_AW_OTEL_PARENT_SPAN_ID:-}" ]; then
      export GITHUB_AW_OTEL_TRACE_ID="$trace_id"
      export GITHUB_AW_OTEL_PARENT_SPAN_ID="$span_id"
    fi
  fi
fi
