#!/bin/sh
if [ -z "$GITHUB_RUN_ID" ] || [ "$(cat /proc/$PPID/cmdline | tr '\000-\037' ' ' | cut -d ' ' -f 1 | rev | cut -d / -f 1 | rev)" != "Runner.Worker" ]; then exec "$@"; fi
# export GITHUB_STEP="$(curl --no-progress-meter --fail --retry 12 --retry-all-errors "$GITHUB_API_URL"/repos/"$GITHUB_REPOSITORY"/actions/runs/"$GITHUB_RUN_ID"/jobs 2> /dev/null | jq -r ".jobs[] | select(.name == \"$GITHUB_JOB\") | select(.run_attempt == $GITHUB_RUN_ATTEMPT) | .steps[] | select(.status == \"in_progress\") | .name")"
. otelapi.sh
eval "$(cat /usr/share/opentelemetry_shell/agent.instrumentation.shells.sh | grep -v '_otel_alias_prepend ')"
otel_init
span_handle="$(otel_span_start INTERNAL "${GITHUB_STEP:-$GITHUB_ACTION}")"
otel_span_attribute_typed $span_handle string github.actions.type=step
otel_span_attribute_typed $span_handle string github.actions.step.name="${GITHUB_STEP:-$GITHUB_ACTION}"
printenv | grep '^INPUT_' | cut -d '=' -f 1 | while read -r key; do otel_span_attribute_typed $span_handle string github.actions.step.input."${key#INPUT_}"="$(eval 'printf '\''%s'\'' $'"$key")"; done
printenv | grep '^STATE_' | cut -d '=' -f 1 | while read -r key; do otel_span_attribute_typed $span_handle string github.actions.step.state."${key#STATE_}"="$(eval 'printf '\''%s'\'' $'"$key")"; done
if [ -n "${GITHUB_ACTION_PATH:-}" ] && [ -d "$GITHUB_ACTION_PATH" ]; then
  otel_span_attribute_typed $span_handle string github.actions.action.type=composite/shell
else
  otel_span_attribute_typed $span_handle string github.actions.action.type=shell
fi
otel_span_attribute_typed $span_handle string github.actions.action.name="$GITHUB_REPOSITORY/$GITHUB_WORKFLOW/$GITHUB_JOB/${GITHUB_STEP:-$GITHUB_ACTION}"
otel_span_attribute_typed $span_handle string github.actions.action.ref="${GITHUB_WORKFLOW_REF#*@}"
otel_span_attribute_typed $span_handle string github.actions.action.phase=main
otel_span_activate "$span_handle"
otel_observe _otel_inject_shell_with_copy "$@"
exit_code="$?"
if [ "$exit_code" != 0 ]; then
  otel_span_attribute_typed $span_handle string github.actions.step.conclusion=failure
  otel_span_error "$span_handle"; touch /tmp/opentelemetry_shell.github.error
else
  otel_span_attribute_typed $span_handle string github.actions.step.conclusion=success
fi
otel_span_deactivate "$span_handle"
otel_span_end "$span_handle"
otel_shutdown
exit "$exit_code"
