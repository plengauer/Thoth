# shellcheck shell=bash
if ! type sqlite3; then exit 0; fi

set -e
. ./assert.sh

dir="$(\mktemp -d)"
db="$dir/test.db"

assert_db_span() {
  local span="$1"
  local command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | startswith("sqlite3 ")) and (.name | contains("'"$2"'"))')"
  assert_equals "$(\echo "$command_span" | jq -r '.context.span_id')" "$(\echo "$span" | jq -r '.parent_id')"
  assert_equals "sqlite" "$(\echo "$span" | jq -r '.attributes."db.system.name"')"
  assert_equals "null" "$(\echo "$span" | jq -r '.attributes."server.address"')"
  assert_equals "null" "$(\echo "$span" | jq -r '.attributes."server.port"')"
}

$TEST_SHELL auto/sqlite3.sh :memory: 'select 1 as answer, 42 where 7 = 7' >"$dir/stdout"
assert_equals "1|42" "$(\cat "$dir/stdout")"
span="$(resolve_span '.attributes."db.query.text" == "select ? as answer, ? where ? = ?"')"
assert_db_span "$span" 'where 7 = 7'
assert_equals "SELECT" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals ":memory:" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "SELECT" "$(\echo "$span" | jq -r '.attributes."db.query.summary"')"
assert_equals "SELECT" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.collection.name"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.operation.batch.size"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."error.type"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"

$TEST_SHELL auto/sqlite3.sh "$db" "create table items(id integer primary key, name text); insert into items(name) values ('secret1'), ('secret2'); update items set name = 'secret3' where id = 1"
assert_equals "secret3|secret2" "$(\sqlite3 "$db" "select group_concat(name, '|') from (select name from items order by id)")"
span="$(resolve_span '.attributes."db.operation.batch.size" == 3')"
assert_db_span "$span" 'create table items'
assert_equals "BATCH" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.CLIENT" "$(\echo "$span" | jq -r '.kind')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "$db" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "BATCH" "$(\echo "$span" | jq -r '.attributes."db.query.summary"')"
assert_equals "BATCH" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "items" "$(\echo "$span" | jq -r '.attributes."db.collection.name"')"
assert_equals "create table items(id integer primary key, name text); insert into items(name) values (?), (?); update items set name = ? where id = ?" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"
assert_equals "false" "$(\echo "$span" | jq -r '.attributes."db.query.text" | contains("secret")')"

$TEST_SHELL auto/sqlite3.sh "$db" "insert into items(name) values ('secret4')"
span="$(resolve_span '.name == "INSERT items"')"
assert_db_span "$span" "secret4"
assert_equals "SpanKind.CLIENT" "$(\echo "$span" | jq -r '.kind')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "$db" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "INSERT items" "$(\echo "$span" | jq -r '.attributes."db.query.summary"')"
assert_equals "INSERT" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "items" "$(\echo "$span" | jq -r '.attributes."db.collection.name"')"
assert_equals "insert into items(name) values (?)" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.operation.batch.size"')"

$TEST_SHELL auto/sqlite3.sh "$db" "update items set name = 'secret5' where id in (1, 2, 3)"
span="$(resolve_span '.name == "UPDATE items"')"
assert_equals "UPDATE" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "items" "$(\echo "$span" | jq -r '.attributes."db.collection.name"')"
assert_equals "update items set name = ? where id IN (?)" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"

$TEST_SHELL auto/sqlite3.sh -header -csv "$db" 'select id, name from items where id <= 2 order by id' >"$dir/stdout"
assert_equals "id,name
1,secret5
2,secret5" "$(\tr -d '\r' <"$dir/stdout")"
span="$(resolve_span '.attributes."db.query.text" == "select id, name from items where id <= ? order by id"')"
assert_equals "SELECT items" "$(\echo "$span" | jq -r '.name')"
assert_equals "items" "$(\echo "$span" | jq -r '.attributes."db.collection.name"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.response.returned_rows"')"

$TEST_SHELL auto/sqlite3.sh "$db" 'insert into items(name) values (1)' 'insert into items(name) values (2)'
span="$(resolve_span '.name == "BATCH INSERT items"')"
assert_equals "2" "$(\echo "$span" | jq -r '.attributes."db.operation.batch.size"')"
assert_equals "BATCH INSERT" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "BATCH INSERT items" "$(\echo "$span" | jq -r '.attributes."db.query.summary"')"
assert_equals "items" "$(\echo "$span" | jq -r '.attributes."db.collection.name"')"
assert_equals "insert into items(name) values (?)" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"

exit_code=0
$TEST_SHELL auto/sqlite3.sh "$db" 'selec 1 from syntax_error_marker' 2>"$dir/stderr" || exit_code="$?"
assert_equals "1" "$exit_code"
assert_equals "true" "$(\head -n 1 "$dir/stderr" | \grep -q '^Error: in prepare, near "selec": syntax error' && \echo true || \echo false)"
\sqlite3 "$db" 'selec 1 from syntax_error_marker' 2>"$dir/stderr.expected" || true
assert_equals "$(\cat "$dir/stderr.expected")" "$(\cat "$dir/stderr")"
span="$(resolve_span '.attributes."db.query.text" == "selec ? from syntax_error_marker"')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "_OTHER" "$(\echo "$span" | jq -r '.attributes."error.type"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"
command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | startswith("sqlite3 ")) and (.name | contains("syntax_error_marker"))')"
assert_equals "1" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"

exit_code=0
$TEST_SHELL auto/sqlite3.sh "$db" 'select * from table_that_does_not_exist' 2>"$dir/stderr" || exit_code="$?"
assert_equals "1" "$exit_code"
assert_equals "Error: in prepare, no such table: table_that_does_not_exist" "$(\head -n 1 "$dir/stderr")"
span="$(resolve_span '.name == "SELECT table_that_does_not_exist"')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "table_that_does_not_exist" "$(\echo "$span" | jq -r '.attributes."db.collection.name"')"
assert_equals "_OTHER" "$(\echo "$span" | jq -r '.attributes."error.type"')"

exit_code=0
$TEST_SHELL auto/sqlite3.sh "$db" "insert into items(id, name) values (1, 'constraint_marker')" 2>"$dir/stderr" || exit_code="$?"
assert_equals "19" "$exit_code"
span="$(resolve_span '.attributes."db.query.text" == "insert into items(id, name) values (?, ?)"')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "SQLITE_CONSTRAINT" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"
assert_equals "SQLITE_CONSTRAINT" "$(\echo "$span" | jq -r '.attributes."error.type"')"

exit_code=0
$TEST_SHELL auto/sqlite3.sh "file:$db?mode=ro" "select count(*) from items where name = 'readonly_marker'" >"$dir/stdout" || exit_code="$?"
assert_equals "0" "$exit_code"
exit_code=0
$TEST_SHELL auto/sqlite3.sh "file:$db?mode=ro" "update items set name = 'readonly_marker'" 2>"$dir/stderr" || exit_code="$?"
assert_equals "8" "$exit_code"
span="$(resolve_span '.attributes."db.query.text" == "update items set name = ?" and .status.status_code == "ERROR"')"
assert_equals "$db" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "SpanKind.CLIENT" "$(\echo "$span" | jq -r '.kind')"
assert_equals "SQLITE_READONLY" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"

printf '%s\n' 'create table from_stdin(a);' "insert into from_stdin values ('stdin_marker');" '.print dot_marker' 'select a from from_stdin;' >"$dir/script.sql"
$TEST_SHELL auto/sqlite3.sh "$db" <"$dir/script.sql" >"$dir/stdout"
assert_equals "dot_marker
stdin_marker" "$(\cat "$dir/stdout")"
span="$(resolve_span '.attributes."db.query.text" == "create table from_stdin(a); insert into from_stdin values (?); select a from from_stdin"')"
assert_equals "3" "$(\echo "$span" | jq -r '.attributes."db.operation.batch.size"')"
assert_equals "BATCH" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.CLIENT" "$(\echo "$span" | jq -r '.kind')"
assert_equals "$db" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"

\echo "select 'pipe_marker';" | $TEST_SHELL auto/sqlite3.sh "$db" >"$dir/stdout"
assert_equals "pipe_marker" "$(\cat "$dir/stdout")"
span="$(resolve_span '.name == "'"$db"'" and .attributes."db.system.name" == "sqlite"')"
assert_equals "SpanKind.CLIENT" "$(\echo "$span" | jq -r '.kind')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.query.summary"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.operation.batch.size"')"

printf '%s\n' 'create table read_table(a);' "select a from read_table where a = 'read_marker';" >"$dir/read.sql"
$TEST_SHELL auto/sqlite3.sh -cmd 'select 11' :memory: ".read $dir/read.sql" >"$dir/stdout"
assert_equals "11" "$(\cat "$dir/stdout")"
span="$(resolve_span '.attributes."db.query.text" == "select ?; create table read_table(a); select a from read_table where a = ?"')"
assert_equals "3" "$(\echo "$span" | jq -r '.attributes."db.operation.batch.size"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
assert_equals ":memory:" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"

$TEST_SHELL auto/sqlite3.sh -init "$dir/read.sql" 'file::memory:' 'select 22' >"$dir/stdout"
assert_equals "22" "$(\cat "$dir/stdout")"
span="$(resolve_span '.attributes."db.query.text" == "create table read_table(a); select a from read_table where a = ?; select ?"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
assert_equals ":memory:" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"

$TEST_SHELL auto/sqlite3.sh "$dir/dot.db" '.tables' '.mode csv' >"$dir/stdout"
command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | startswith("sqlite3 ")) and (.name | contains("dot.db"))')"
assert_equals "0" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"
assert_equals "" "$(\cat "$OTEL_EXPORT_LOCATION" | jq -r 'select(.attributes."db.namespace" == "'"$dir/dot.db"'") | .name')"

$TEST_SHELL auto/sqlite3.sh -version >"$dir/stdout"
assert_equals "$(\sqlite3 -version)" "$(\cat "$dir/stdout")"
