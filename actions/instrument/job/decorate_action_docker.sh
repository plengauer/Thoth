#!/bin/bash
if [ "$(cat /tmp/opentelemetry_shell_action_name 2>/dev/null)" = "$GITHUB_ACTION" ]; then exec "$@"; fi
_OTEL_GITHUB_STEP_AGENT_INSTRUMENTATION_FILE=/usr/share/opentelemetry_shell/agent.instrumentation.docker.sh
_OTEL_GITHUB_STEP_AGENT_INJECTION_FUNCTION=_otel_inject_docker
_OTEL_GITHUB_STEP_ACTION_TYPE=docker
case "$2" in
  build) _OTEL_GITHUB_STEP_ACTION_PHASE=pre ;;
  run) _OTEL_GITHUB_STEP_ACTION_PHASE=main ;;
  *) ;;
esac
. "${0%/*}"/decorate_action.sh
