# shellcheck shell=bash
if ! type sqlcmd; then exit 0; fi

set -e
. ./assert.sh

dir="$(\mktemp -d)"
trap '\rm -rf "$dir"' EXIT
arguments='-S tcp:127.0.0.1,1 -d mydb -U sa -P s3cret -l 1 -Q'
query="SELECT * FROM users WHERE id = 5 AND name = 'x'"

# shellcheck disable=SC2086 # the arguments are a list of words that must be split
sqlcmd $arguments "$query" >"$dir/expected.out" 2>"$dir/expected.err" </dev/null || expected_exit_code="$?"
# shellcheck disable=SC2086
$TEST_SHELL auto/sqlcmd.sh $arguments "$query" >"$dir/actual.out" 2>"$dir/actual.err" </dev/null || actual_exit_code="$?"
\cmp "$dir/expected.out" "$dir/actual.out"
\cmp "$dir/expected.err" "$dir/actual.err"

command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | startswith("sqlcmd -S tcp:127.0.0.1,1 "))')"
assert_equals "${expected_exit_code:-0}" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"
assert_equals "${expected_exit_code:-0}" "${actual_exit_code:-0}"

span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.system.name" == "microsoft.sql_server"')"
assert_equals "$(\echo "$command_span" | jq -r '.context.span_id')" "$(\echo "$span" | jq -r '.parent_id')"
assert_equals "SELECT users" "$(\echo "$span" | jq -r '.name')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "127.0.0.1" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "1" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "tcp" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "mydb" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "SELECT" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "users" "$(\echo "$span" | jq -r '.attributes."db.collection.name"')"
assert_equals "SELECT users" "$(\echo "$span" | jq -r '.attributes."db.query.summary"')"
assert_equals "SELECT * FROM users WHERE id = ? AND name = ?" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"
assert_equals "_OTHER" "$(\echo "$span" | jq -r '.attributes."error.type"')"
assert_equals "false" "$(\echo "$span" | jq -r '[.attributes[] | tostring | contains("s3cret")] | any')"
