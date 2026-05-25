#!/bin/bash
if [ "$(cat /tmp/opentelemetry_shell_action_name 2> /dev/null)" = "$GITHUB_ACTION" ]; then exec "$@"; fi
_OTEL_GITHUB_STEP_AGENT_INSTRUMENTATION_FILE=/usr/share/opentelemetry_shell/agent.instrumentation.node.sh
_OTEL_GITHUB_STEP_AGENT_INJECTION_FUNCTION=_otel_inject_node
_OTEL_GITHUB_STEP_ACTION_TYPE=javascript
# _OTEL_GITHUB_STEP_ACTION_PHASE=main # TODO
_OTEL_GITHUB_STEP_ACTION_HINT_PATH="${2:-}"
. "${0%/*}"/decorate_action.sh
