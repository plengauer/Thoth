. ./assert.sh

_otel_call() {
  :
}

_otel_alias_prepend() {
  :
}

copilot_instrumentation_file=../src/usr/share/opentelemetry_shell/agent.instrumentation.github.copilot.sh

unset COPILOT_OTEL_ENABLED OTEL_EXPORTER_OTLP_ENDPOINT OTEL_EXPORTER_OTLP_TRACES_ENDPOINT GH_AW_WORKFLOW_ID GH_AW_WORKFLOW_FILE GITHUB_ACTION GITHUB_WORKFLOW_REF
export GITHUB_ACTIONS=true
export GITHUB_EVENT_NAME=dynamic
export GH_AW_WORKFLOW_ID=autofix
export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=http://collector:4318/v1/traces
export GITHUB_ENV="$(mktemp)"
. "$copilot_instrumentation_file"
assert_equals true "${COPILOT_OTEL_ENABLED:-}"
assert_equals http://collector:4318 "${OTEL_EXPORTER_OTLP_ENDPOINT:-}"
\grep '^COPILOT_OTEL_ENABLED=true$' "$GITHUB_ENV" 1>/dev/null
\grep '^OTEL_EXPORTER_OTLP_ENDPOINT=http://collector:4318$' "$GITHUB_ENV" 1>/dev/null
if \grep '^OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=' "$GITHUB_ENV" 1>/dev/null 2>/dev/null; then
  exit 1
fi

unset COPILOT_OTEL_ENABLED OTEL_EXPORTER_OTLP_ENDPOINT OTEL_EXPORTER_OTLP_TRACES_ENDPOINT GH_AW_WORKFLOW_ID GH_AW_WORKFLOW_FILE GITHUB_ACTION GITHUB_WORKFLOW_REF
export GITHUB_ACTIONS=true
export GITHUB_EVENT_NAME=push
export OTEL_EXPORTER_OTLP_ENDPOINT=http://collector:4318
export GITHUB_ENV="$(mktemp)"
. "$copilot_instrumentation_file"
assert_equals "" "${COPILOT_OTEL_ENABLED:-}"
if \grep '^COPILOT_OTEL_ENABLED=' "$GITHUB_ENV" 1>/dev/null 2>/dev/null; then
  exit 1
fi

unset OTEL_EXPORTER_OTLP_ENDPOINT OTEL_EXPORTER_OTLP_TRACES_ENDPOINT GH_AW_WORKFLOW_ID GH_AW_WORKFLOW_FILE GITHUB_ACTION GITHUB_WORKFLOW_REF
export GITHUB_ACTIONS=true
export GITHUB_EVENT_NAME=dynamic
export COPILOT_OTEL_ENABLED=false
export OTEL_EXPORTER_OTLP_ENDPOINT=http://collector:4318
export GITHUB_ENV="$(mktemp)"
. "$copilot_instrumentation_file"
assert_equals false "${COPILOT_OTEL_ENABLED:-}"
if \grep '^COPILOT_OTEL_ENABLED=' "$GITHUB_ENV" 1>/dev/null 2>/dev/null; then
  exit 1
fi
