# shellcheck shell=bash
set -e
. ./assert.sh

if ! type git 1>/dev/null 2>/dev/null; then exit 0; fi

$TEST_SHELL auto/git.sh --version

span="$(resolve_span '.name == "git --version"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
assert_equals "0" "$(\echo "$span" | jq -r '.attributes."shell.command.exit_code"')"

$TEST_SHELL auto/git.sh ls-remote https://github.com/octocat/Hello-World HEAD

span="$(resolve_span '.name == "git ls-remote https://github.com/octocat/Hello-World HEAD"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
assert_equals "0" "$(\echo "$span" | jq -r '.attributes."shell.command.exit_code"')"
parent_id="$(\echo "$span" | jq -r '.context.span_id')"

span="$(resolve_span '.attributes."url.path" == "/octocat/Hello-World/info/refs"')"
assert_equals "GET" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.CLIENT" "$(\echo "$span" | jq -r '.kind')"
assert_equals "$parent_id" "$(\echo "$span" | jq -r '.parent_id')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "tcp" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "http" "$(\echo "$span" | jq -r '.attributes."network.protocol.name"')"
assert_equals "github.com" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "443" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "https://github.com:443/octocat/Hello-World/info/refs?service=git-upload-pack" "$(\echo "$span" | jq -r '.attributes."url.full"')"
assert_equals "https" "$(\echo "$span" | jq -r '.attributes."url.scheme"')"
assert_equals "service=git-upload-pack" "$(\echo "$span" | jq -r '.attributes."url.query"')"
assert_equals "GET" "$(\echo "$span" | jq -r '.attributes."http.request.method"')"
assert_not_equals "null" "$(\echo "$span" | jq -r '.attributes."user_agent.original"')"
assert_equals "200" "$(\echo "$span" | jq -r '.attributes."http.response.status_code"')"

span="$(resolve_span '.attributes."url.path" == "/octocat/Hello-World/git-upload-pack"')"
assert_equals "POST" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.CLIENT" "$(\echo "$span" | jq -r '.kind')"
assert_equals "$parent_id" "$(\echo "$span" | jq -r '.parent_id')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "POST" "$(\echo "$span" | jq -r '.attributes."http.request.method"')"
assert_equals "200" "$(\echo "$span" | jq -r '.attributes."http.response.status_code"')"
