#!/bin/false
# shellcheck shell=bash

_otel_inject_claude() {
  local cmdline
  cmdline="$(_otel_dollar_star "$@")"
  cmdline="${cmdline#\\}"
  (
    \export CLAUDE_CODE_ENABLE_TELEMETRY="${CLAUDE_CODE_ENABLE_TELEMETRY:-1}"
    \export CLAUDE_CODE_ENHANCED_TELEMETRY_BETA="${CLAUDE_CODE_ENHANCED_TELEMETRY_BETA:-1}"
    \export OTEL_TRACES_EXPORTER="${OTEL_TRACES_EXPORTER:-otlp}"
    \export OTEL_METRICS_EXPORTER="${OTEL_METRICS_EXPORTER:-otlp}"
    \export OTEL_LOGS_EXPORTER="${OTEL_LOGS_EXPORTER:-otlp}"
    if \[ -z "${OTEL_EXPORTER_OTLP_PROTOCOL+x}${OTEL_EXPORTER_OTLP_TRACES_PROTOCOL+x}${OTEL_EXPORTER_OTLP_METRICS_PROTOCOL+x}${OTEL_EXPORTER_OTLP_LOGS_PROTOCOL+x}" ]; then
      \export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
    fi
    \export CLAUDE_CODE_PROPAGATE_TRACEPARENT="${CLAUDE_CODE_PROPAGATE_TRACEPARENT:-1}"
    if \[ "$(\printf '%s' "${OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT:-}" | \tr '[:upper:]' '[:lower:]')" = true ]; then
      \export OTEL_LOG_USER_PROMPTS="${OTEL_LOG_USER_PROMPTS:-1}"
      \export OTEL_LOG_ASSISTANT_RESPONSES="${OTEL_LOG_ASSISTANT_RESPONSES:-1}"
      \export OTEL_LOG_TOOL_DETAILS="${OTEL_LOG_TOOL_DETAILS:-1}"
      \export OTEL_LOG_TOOL_CONTENT="${OTEL_LOG_TOOL_CONTENT:-1}"
    fi
    \export CLAUDE_CODE_SHELL_PREFIX="${CLAUDE_CODE_SHELL_PREFIX:-/usr/share/opentelemetry_shell/agent.instrumentation.claude/otel4claude_code_tool.sh}"
    for _otel_var in $(\env | \cut -d= -f1 | \grep -E '^OTEL_[A-Za-z_][A-Za-z0-9_]*$'); do \eval "export __$_otel_var=\${$_otel_var}"; done
    OTEL_SHELL_COMMANDLINE_OVERRIDE="$cmdline" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE=0 OTEL_SHELL_AUTO_INJECTED=TRUE _otel_call "$@"
  ) || local exit_code="$?"
  return "${exit_code:-0}"
}

_otel_alias_prepend claude _otel_inject_claude
