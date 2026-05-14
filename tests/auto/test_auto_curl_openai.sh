set -e
. ./assert.sh

if [ -z "${OPENAI_TOKEN:-}" ]; then exit 0; fi

$TEST_SHELL auto/curl_openai.sh

span="$(resolve_span '.attributes."gen_ai.request.model" == "gpt-4o-mini"')"
assert_equals "chat gpt-4o-mini" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.CLIENT" "$(\echo "$span" | jq -r '.kind')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "openai" "$(\echo "$span" | jq -r '.attributes."gen_ai.provider.name"')"
assert_equals "chat" "$(\echo "$span" | jq -r '.attributes."gen_ai.operation.name"')"
assert_equals "gpt-4o-mini" "$(\echo "$span" | jq -r '.attributes."gen_ai.request.model"')"
assert_not_equals "null" "$(\echo "$span" | jq -r '.attributes."gen_ai.response.model"')"
assert_not_equals "null" "$(\echo "$span" | jq -r '.attributes."gen_ai.usage.input_tokens"')"
assert_not_equals "null" "$(\echo "$span" | jq -r '.attributes."gen_ai.usage.output_tokens"')"
assert_equals "200" "$(\echo "$span" | jq -r '.attributes."http.response.status_code"')"
assert_equals "text" "$(\echo "$span" | jq -r '.attributes."gen_ai.output.type"')"
