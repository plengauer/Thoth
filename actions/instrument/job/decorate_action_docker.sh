#!/bin/bash
if [ "$(cat /tmp/opentelemetry_shell_action_name 2> /dev/null)" = "$GITHUB_ACTION" ]; then exec "$@"; fi
_OTEL_GITHUB_STEP_AGENT_INSTRUMENTATION_FILE=/usr/share/opentelemetry_shell/agent.instrumentation.docker.sh
_OTEL_GITHUB_STEP_AGENT_INJECTION_FUNCTION=_otel_inject_docker
_OTEL_GITHUB_STEP_ACTION_TYPE=docker
case "$2" in
  build)
    _OTEL_GITHUB_STEP_ACTION_PHASE=pre
    for _arg in "$@"; do
      case "$_arg" in
        /_actions/*) _OTEL_GITHUB_STEP_ACTION_HINT_PATH="$_arg" ;;
      esac
    done
    printf '%s' "${_OTEL_GITHUB_STEP_ACTION_HINT_PATH:-}" > "/tmp/opentelemetry_shell_action_hint_path_${GITHUB_ACTION:-}"
    ;;
  run)
    _OTEL_GITHUB_STEP_ACTION_PHASE=main
    _OTEL_GITHUB_STEP_ACTION_HINT_PATH="$(cat "/tmp/opentelemetry_shell_action_hint_path_${GITHUB_ACTION:-}" 2>/dev/null || true)"
    ;;
  *) ;;
esac
. "${0%/*}"/decorate_action.sh
