. ./assert.sh

source_file=../src/usr/share/opentelemetry_shell/agent.instrumentation.github.copilot.sh
cache_loaded_file="$(mktemp)"
\grep -vh '_otel_alias_prepend ' "$source_file" > "$cache_loaded_file"

GITHUB_ACTIONS=true
GITHUB_EVENT_NAME=dynamic
COPILOT_AGENT_RUNTIME_VERSION=runtime
GITHUB_COPILOT_ACTION_DOWNLOAD_URL=https://example.com
GITHUB_JOB=copilot

called=
_otel_alias_prepend() {
  called="$*"
}

. "$cache_loaded_file"

assert_equals "tar _otel_inject_copilot" "$called"
