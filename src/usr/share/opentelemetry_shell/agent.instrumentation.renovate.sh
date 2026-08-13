#!/bin/false

if _otel_string_contains "$(_otel_resolve_command_self)" /usr/local/bin/renovate || _otel_string_contains "$(_otel_resolve_command_self)" /usr/local/sbin/renovate; then # renovate looks at some very specific env vars to enable tracing
  \export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE
  \export OTEL_SHELL_CONFIG_INSTRUMENT_ABSOLUTE_PATHS=TRUE
  \export OTEL_BSP_MAX_EXPORT_BATCH_SIZE=1
  if _otel_string_contains "${OTEL_TRACES_EXPORTER:-}" console; then \export RENOVATE_TRACING_CONSOLE_EXPORTER=true; fi
  if \[ -z "${OTEL_EXPORTER_OTLP_ENDPOINT:-}" ] && (_otel_string_contains "${OTEL_TRACES_EXPORTER:-}" otlp || \[ -z "${OTEL_TRACES_EXPORTER:-}" ]); then
    if \[ -n "${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-}" ]; then
      if _otel_string_ends_with "$OTEL_EXPORTER_OTLP_TRACES_ENDPOINT" /v1/traces; then
        \export OTEL_EXPORTER_OTLP_ENDPOINT="${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT%/v1/traces}"
      fi
    else
      \export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
    fi
  fi
fi
