. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init
otel_observe cat FILE_THAT_DOES_NOT_EXIST
assert_not_equals 0 $?
otel_shutdown

span="$(resolve_span)"
assert_equals "cat FILE_THAT_DOES_NOT_EXIST" "$(echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" $(echo "$span" | jq -r '.kind')
assert_equals "null" $(echo "$span" | jq -r '.parent_id')
assert_equals "ERROR" $(echo "$span" | jq -r '.status.status_code')
assert_equals "cat FILE_THAT_DOES_NOT_EXIST" "$(echo "$span" | jq -r '.attributes."shell.command_line"')"
assert_not_equals "0" $(echo "$span" | jq -r '.attributes."subprocess.exit_code"')
