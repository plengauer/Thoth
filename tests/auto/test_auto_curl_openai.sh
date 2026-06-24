if [ -z "${OPENAI_TOKEN:-}" ]; then exit 0; fi
set -e
. ./assert.sh

$TEST_SHELL auto/curl.sh -X POST https://api.openai.com/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer $OPENAI_TOKEN" -d '{"model":"gpt-4.1-nano","messages":[{"role":"user","content":"say hello"}],"max_tokens":16}'

span="$(resolve_span '.attributes."gen_ai.request.model" == "gpt-4.1-nano"')"
assert_equals "SpanKind.CLIENT" "$(echo "$span" | jq -r '.kind')"
assert_equals "openai" "$(echo "$span" | jq -r '.attributes."gen_ai.provider.name"')"
assert_not_equals "null" "$(echo "$span" | jq -r '.attributes."gen_ai.response.model"')"
assert_not_equals "null" "$(echo "$span" | jq -r '.attributes."gen_ai.usage.input_tokens"')"
assert_not_equals "null" "$(echo "$span" | jq -r '.attributes."gen_ai.usage.output_tokens"')"
