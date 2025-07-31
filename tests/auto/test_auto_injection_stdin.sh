. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

cat auto/fail_no_auto.sh | eval "$TEST_SHELL"
assert_equals 0 $?
span="$(resolve_span '.resource.attributes."process.command_line" == "'"$TEST_SHELL"'"')"
assert_equals "myspan" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
