#!/bin/sh
if [ "$(cat /tmp/opentelemetry_shell_action_name 2> /dev/null)" = "$GITHUB_ACTION" ]; then exec "$@"; fi
unset OTEL_SHELL_COMMAND_OVERRIDE
_OTEL_GITHUB_STEP_AGENT_INSTRUMENTATION_FILE=/usr/share/opentelemetry_shell/agent.instrumentation.shells.sh
_OTEL_GITHUB_STEP_AGENT_INJECTION_FUNCTION=_otel_inject_shell_with_copy
_OTEL_GITHUB_STEP_ACTION_TYPE=shell
_OTEL_GITHUB_STEP_ACTION_PHASE=main
. "${0%/*}"/decorate_action.sh
