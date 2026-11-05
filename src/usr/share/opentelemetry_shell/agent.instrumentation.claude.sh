#!/bin/false
# shellcheck shell=bash

_otel_inject_claude() {
  local cmdline
  cmdline="$(_otel_dollar_star "$@")"
  cmdline="${cmdline#\\}"
  (
    \[ "${CLAUDE_CODE_ENABLE_TELEMETRY+x}" = x ] || \export CLAUDE_CODE_ENABLE_TELEMETRY=1
    \[ "${CLAUDE_CODE_ENHANCED_TELEMETRY_BETA+x}" = x ] || \export CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1
    \[ "${OTEL_TRACES_EXPORTER+x}" = x ] || \export OTEL_TRACES_EXPORTER=otlp
    \[ "${OTEL_METRICS_EXPORTER+x}" = x ] || \export OTEL_METRICS_EXPORTER=otlp
    \[ "${OTEL_LOGS_EXPORTER+x}" = x ] || \export OTEL_LOGS_EXPORTER=otlp
    if \[ -z "${OTEL_EXPORTER_OTLP_PROTOCOL+x}${OTEL_EXPORTER_OTLP_TRACES_PROTOCOL+x}${OTEL_EXPORTER_OTLP_METRICS_PROTOCOL+x}${OTEL_EXPORTER_OTLP_LOGS_PROTOCOL+x}" ]; then
      \export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
    fi
    \[ "${CLAUDE_CODE_PROPAGATE_TRACEPARENT+x}" = x ] || \export CLAUDE_CODE_PROPAGATE_TRACEPARENT=1
    if \[ "$(\printf '%s' "${OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT:-}" | \tr '[:upper:]' '[:lower:]')" = true ]; then
      \[ "${OTEL_LOG_USER_PROMPTS+x}" = x ] || \export OTEL_LOG_USER_PROMPTS=1
      \[ "${OTEL_LOG_ASSISTANT_RESPONSES+x}" = x ] || \export OTEL_LOG_ASSISTANT_RESPONSES=1
      \[ "${OTEL_LOG_TOOL_DETAILS+x}" = x ] || \export OTEL_LOG_TOOL_DETAILS=1
      \[ "${OTEL_LOG_TOOL_CONTENT+x}" = x ] || \export OTEL_LOG_TOOL_CONTENT=1
    fi
    \[ "${CLAUDE_CODE_SHELL_PREFIX+x}" = x ] || \export CLAUDE_CODE_SHELL_PREFIX=/usr/share/opentelemetry_shell/agent.instrumentation.claude/shell-prefix.sh
    for _otel_var in $(\env | \cut -d= -f1 | \grep -E '^OTEL_[A-Za-z_][A-Za-z0-9_]*$'); do \eval "export __$_otel_var=\${$_otel_var}"; done
    OTEL_SHELL_COMMANDLINE_OVERRIDE="$cmdline" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE=0 OTEL_SHELL_AUTO_INJECTED=TRUE _otel_call "$@"
  ) || local exit_code="$?"
  return "${exit_code:-0}"
}

_otel_alias_prepend claude _otel_inject_claude
