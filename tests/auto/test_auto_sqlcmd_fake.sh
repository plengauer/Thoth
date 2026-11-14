# shellcheck shell=bash
set -e
. ./assert.sh

dir="$(\mktemp -d)"
trap '\rm -rf "$dir"' EXIT
\cat >"$dir/sqlcmd" <<'FAKE'
#!/bin/sh
query=''
file=''
to_stderr=0
fail=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    -Q | -q) query="$2"; shift ;;
    -i) file="$2"; shift ;;
    -S | -d | -U | -P | -l | -c) shift ;;
    -r*) to_stderr=1 ;;
    -b) fail=1 ;;
  esac
  shift
done
if [ -n "$query" ]; then text="$query"; elif [ -n "$file" ]; then text="$(cat "$file")"; else text="$(cat)"; fi
message() { if [ "$to_stderr" = 1 ]; then printf '%s\n' "$1" >&2; else printf '%s\n' "$1"; fi; }
exit_code=0
case "$text" in
  *BADSYNTAX*)
    message "Msg 102, Level 15, State 1, Server FAKE, Line 1"
    message "Incorrect syntax near 'BADSYNTAX'."
    if [ "$fail" = 1 ]; then exit_code=1; fi
    ;;
  *missing_table*)
    message "Msg 208, Level 16, State 1, Server FAKE, Line 1"
    message "Invalid object name 'missing_table'."
    if [ "$fail" = 1 ]; then exit_code=1; fi
    ;;
  *warn_table*)
    message "Msg 50000, Level 10, State 1, Server FAKE, Line 1"
    message "just a warning"
    printf 'id\n--\n1\n\n(1 row affected)\n'
    ;;
  *NONEWLINE*) printf 'tail without newline' ;;
  *SELECT*) printf 'id\n--\n1\n2\n\n(2 rows affected)\n' ;;
  *) printf '(1 row affected)\n' ;;
esac
exit "$exit_code"
FAKE
\chmod +x "$dir/sqlcmd"
export PATH="$dir:$PATH"

run_compared() {
  local name="$1"
  shift
  "$dir/sqlcmd" "$@" >"$dir/$name.expected.out" 2>"$dir/$name.expected.err" </dev/null || \echo "$?" >"$dir/$name.expected.exit"
  $TEST_SHELL auto/sqlcmd.sh "$@" >"$dir/$name.actual.out" 2>"$dir/$name.actual.err" </dev/null || \echo "$?" >"$dir/$name.actual.exit"
  \cmp "$dir/$name.expected.out" "$dir/$name.actual.out"
  \cmp "$dir/$name.expected.err" "$dir/$name.actual.err"
  assert_equals "$(\cat "$dir/$name.expected.exit" 2>/dev/null || \echo 0)" "$(\cat "$dir/$name.actual.exit" 2>/dev/null || \echo 0)"
}

export SQLCMDSERVER='tcp:db.example.com\inst1,1444'
export SQLCMDDBNAME=prod
run_compared select -U sa -P topsecret -Q 'SELECT * FROM users WHERE id IN (1,2,3)'
unset SQLCMDSERVER SQLCMDDBNAME

command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | contains("-P topsecret -Q SELECT * FROM users"))')"
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .name == "SELECT users"')"
assert_equals "$(\echo "$command_span" | jq -r '.context.span_id')" "$(\echo "$span" | jq -r '.parent_id')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "microsoft.sql_server" "$(\echo "$span" | jq -r '.attributes."db.system.name"')"
assert_equals "inst1|prod" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "db.example.com" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "1444" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "tcp" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "SELECT" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "users" "$(\echo "$span" | jq -r '.attributes."db.collection.name"')"
assert_equals "SELECT users" "$(\echo "$span" | jq -r '.attributes."db.query.summary"')"
assert_equals "SELECT * FROM users WHERE id IN (?)" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"
assert_equals "2" "$(\echo "$span" | jq -r '.attributes."db.response.returned_rows"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."error.type"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"
assert_equals "false" "$(\echo "$span" | jq -r '[.attributes[] | tostring | contains("topsecret")] | any')"

run_compared error -S tcp:h,1 -Q 'SELECT * FROM missing_table'
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.collection.name" == "missing_table"')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "208" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"
assert_equals "208" "$(\echo "$span" | jq -r '.attributes."error.type"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.response.returned_rows"')"

run_compared warning -S tcp:h,1 -Q 'SELECT * FROM warn_table'
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.collection.name" == "warn_table"')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "50000" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."error.type"')"
assert_equals "1" "$(\echo "$span" | jq -r '.attributes."db.response.returned_rows"')"

run_compared stderr -S tcp:h,1 -r -b -Q 'SELECT BADSYNTAX'
command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | contains("BADSYNTAX"))')"
assert_equals "1" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.query.text" == "SELECT BADSYNTAX"')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "102" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"
assert_equals "102" "$(\echo "$span" | jq -r '.attributes."error.type"')"

run_compared noeol -S tcp:h,1 -Q 'SELECT NONEWLINE'

printf 'INSERT INTO items VALUES (1)\nGO 3\nINSERT INTO items VALUES (2)\nGO\n' >"$dir/batches.sql"
run_compared file -S h -i "$dir/batches.sql"
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .name == "BATCH INSERT items"')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "4" "$(\echo "$span" | jq -r '.attributes."db.operation.batch.size"')"
assert_equals "BATCH INSERT" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "items" "$(\echo "$span" | jq -r '.attributes."db.collection.name"')"
assert_equals "INSERT INTO items VALUES (?); INSERT INTO items VALUES (?)" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"
assert_equals "h" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "1433" "$(\echo "$span" | jq -r '.attributes."server.port"')"

printf 'SELECT * FROM stdin_table WHERE a = 1\nGO\n' >"$dir/stdin.sql"
"$dir/sqlcmd" -S h -d stdb <"$dir/stdin.sql" >"$dir/stdin.expected"
$TEST_SHELL auto/sqlcmd.sh -S h -d stdb <"$dir/stdin.sql" >"$dir/stdin.actual"
\cmp "$dir/stdin.expected" "$dir/stdin.actual"
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .name == "SELECT stdin_table"')"
assert_equals "stdb" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "SELECT * FROM stdin_table WHERE a = ?" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"
assert_equals "2" "$(\echo "$span" | jq -r '.attributes."db.response.returned_rows"')"

$TEST_SHELL auto/sqlcmd.sh -D -S somedsn -Q 'SELECT * FROM dsn_table' >/dev/null
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .name == "SELECT dsn_table"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."server.address"')"
