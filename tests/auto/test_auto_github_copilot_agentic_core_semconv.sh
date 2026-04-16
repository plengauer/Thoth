. ./assert.sh
type curl > /dev/null 2> /dev/null || exit 0

export GITHUB_ACTIONS=true
export GITHUB_EVENT_NAME=dynamic
export COPILOT_AGENT_RUNTIME_VERSION=1
export GITHUB_COPILOT_ACTION_DOWNLOAD_URL=https://example.invalid/action.tar.gz
export GITHUB_JOB=copilot

. /usr/bin/opentelemetry_shell.sh

date +%s > /dev/null
span="$(resolve_span '.name == "execute_tool date"')"
assert_equals "execute_tool date" "$(\echo "$span" | jq -r '.name')"
assert_equals "execute_tool" "$(\echo "$span" | jq -r '.attributes."gen_ai.operation.name"')"
assert_equals "date" "$(\echo "$span" | jq -r '.attributes."gen_ai.tool.name"')"
assert_equals "function" "$(\echo "$span" | jq -r '.attributes."gen_ai.tool.type"')"

curl --silent --show-error --output /dev/null --max-time 1 https://api.githubcopilot.com/responses || true
span="$(resolve_span '.attributes."shell.command.name" == "curl" and (.attributes."shell.command_line" | contains("https://api.githubcopilot.com/responses"))')"
assert_equals "chat" "$(\echo "$span" | jq -r '.attributes."gen_ai.operation.name"')"
assert_equals "openai" "$(\echo "$span" | jq -r '.attributes."gen_ai.provider.name"')"
