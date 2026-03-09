set -e
. ./assert.sh

if ! \type apt-get > /dev/null 2>&1; then exit 0; fi

$TEST_SHELL auto/apt_get.sh update

span="$(resolve_span '.name | startswith("apt-get update")')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
assert_equals "0" "$(\echo "$span" | jq -r '.attributes."shell.command.exit_code"')"

span="$(resolve_span '.kind == "SpanKind.CLIENT"')"
assert_equals "SpanKind.CLIENT" "$(\echo "$span" | jq -r '.kind')"
assert_not_equals "null" "$(\echo "$span" | jq -r '.parent_id')"
