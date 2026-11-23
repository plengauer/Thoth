# shellcheck shell=bash
if ! type psql; then exit 0; fi

set -e
. ./assert.sh

export PGCONNECT_TIMEOUT=5

$TEST_SHELL auto/psql.sh -h 127.0.0.1 -p 1 -U nobody -d nowhere -c 'select 1 as unreachable' || true

command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | contains("psql ")) and (.name | contains("unreachable"))')"
assert_equals "2" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"

span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.query.text" == "select ? as unreachable"')"
assert_equals "$(\echo "$command_span" | jq -r '.context.span_id')" "$(\echo "$span" | jq -r '.parent_id')"
assert_equals "SELECT" "$(\echo "$span" | jq -r '.name')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "2" "$(\echo "$span" | jq -r '.attributes."error.type"')"
assert_equals "postgresql" "$(\echo "$span" | jq -r '.attributes."db.system.name"')"
assert_equals "nowhere" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "tcp" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "127.0.0.1" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "1" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "SELECT" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "SELECT" "$(\echo "$span" | jq -r '.attributes."db.query.summary"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"

$TEST_SHELL auto/psql.sh "postgresql://alice:topsecret@127.0.0.1:1/uridb" -c 'select 2 as uri' || true

span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.query.text" == "select ? as uri"')"
assert_equals "uridb" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "127.0.0.1" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "1" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "0" "$(\echo "$span" | jq -c '[.name, .attributes]' | \grep -c topsecret || true)"

initdb="$(\find /usr/lib/postgresql -name initdb 2>/dev/null | \sort | \tail -n 1)"
if [ -z "$initdb" ]; then exit 0; fi
bin="$(\dirname "$initdb")"
dir="$(\mktemp -d)"
if [ "$(\id -u)" = 0 ]; then
  \id postgres 1>/dev/null 2>/dev/null || exit 0
  \chown postgres "$dir"
  \chmod 755 "$dir"
  run_as() { \runuser -u postgres -- "$@"; }
else
  run_as() { "$@"; }
fi
trap 'run_as "$bin/pg_ctl" -D "$dir/data" -m immediate stop 1>/dev/null 2>/dev/null || true' EXIT
run_as "$bin/initdb" -D "$dir/data" -A trust -U postgres --no-locale -E UTF8 1>/dev/null
port=$((20000 + $$ % 20000))
run_as "$bin/pg_ctl" -D "$dir/data" -o "-p $port -k $dir -c listen_addresses=127.0.0.1" -l "$dir/log" -w start 1>/dev/null

$TEST_SHELL auto/psql.sh -h 127.0.0.1 -p "$port" -U postgres -d postgres -At -c "select 'secret' as tcp, 42" >"$dir/stdout"
assert_equals "secret|42" "$(\cat "$dir/stdout")"

command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | contains("psql ")) and (.name | contains("as tcp"))')"
assert_equals "0" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"

span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.query.text" == "select ? as tcp, ?"')"
assert_equals "$(\echo "$command_span" | jq -r '.context.span_id')" "$(\echo "$span" | jq -r '.parent_id')"
assert_equals "SELECT" "$(\echo "$span" | jq -r '.name')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "postgresql" "$(\echo "$span" | jq -r '.attributes."db.system.name"')"
assert_equals "postgres" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "tcp" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "127.0.0.1" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "$port" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "SELECT" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "SELECT" "$(\echo "$span" | jq -r '.attributes."db.query.summary"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.operation.batch.size"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."error.type"')"

$TEST_SHELL auto/psql.sh -h "$dir" -p "$port" -U postgres -d postgres -q -c 'create table users (id int, name text)'

$TEST_SHELL auto/psql.sh -h "$dir" -p "$port" -U postgres -d postgres -q <<EOF
insert into users values (1, 'alice');
insert into users values (2, 'bob');
EOF

span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.query.text" == "insert into users values (?, ?)"')"
assert_equals "BATCH INSERT users" "$(\echo "$span" | jq -r '.name')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "unix" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "$dir" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "2" "$(\echo "$span" | jq -r '.attributes."db.operation.batch.size"')"
assert_equals "BATCH INSERT" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "BATCH INSERT users" "$(\echo "$span" | jq -r '.attributes."db.query.summary"')"
assert_equals "users" "$(\echo "$span" | jq -r '.attributes."db.collection.name"')"

$TEST_SHELL auto/psql.sh -h "$dir" -p "$port" -U postgres -d postgres -At -c "select count(*) from users where id in (1, 2) and name <> 'carol'" >"$dir/stdout"
assert_equals "2" "$(\cat "$dir/stdout")"

span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.query.text" == "select count(*) from users where id in (?) and name <> ?"')"
assert_equals "SELECT users" "$(\echo "$span" | jq -r '.name')"
assert_equals "users" "$(\echo "$span" | jq -r '.attributes."db.collection.name"')"

$TEST_SHELL auto/psql.sh -h "$dir" -p "$port" -U postgres -d postgres -c 'select * from missing_table' || true

span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.query.text" == "select * from missing_table"')"
assert_equals "SELECT missing_table" "$(\echo "$span" | jq -r '.name')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "1" "$(\echo "$span" | jq -r '.attributes."error.type"')"
