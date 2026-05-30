. ./assert.sh

_otel_alias_prepended=
_otel_alias_prepend() {
  _otel_alias_prepended="$*"
}
_otel_call() {
  "$@"
}

export GITHUB_ACTIONS=true
export GITHUB_EVENT_NAME=dynamic
export COPILOT_AGENT_RUNTIME_VERSION=1
export GITHUB_COPILOT_ACTION_DOWNLOAD_URL=https://example.com/action.tar.gz
export GITHUB_JOB=copilot
export RUNNER_TEMP="$(mktemp -d)"

eval "$(cat ../src/usr/share/opentelemetry_shell/agent.instrumentation.github.copilot.sh | grep -v '_otel_alias_prepend ')"

assert_equals "tar _otel_inject_copilot" "$_otel_alias_prepended"
