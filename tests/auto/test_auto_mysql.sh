# shellcheck shell=bash
if ! type mysql || ! type mariadb || ! type mariadbd || ! type mariadb-install-db; then exit 0; fi

set -e
. ./assert.sh

dir="$(\mktemp -d)"
\chmod 755 "$dir"
trap 'kill "$(\cat "$dir/mariadbd.pid")" 2>/dev/null || true' EXIT
if \[ "$(\id -u)" = 0 ]; then server_user=--user=mysql; else server_user=--user="$(\id -un)"; fi
\mkdir "$dir/data"
\chown "${server_user#--user=}" "$dir" "$dir/data" 2>/dev/null || true
\mariadb-install-db "$server_user" --datadir="$dir/data" --auth-root-authentication-method=normal >/dev/null
port=$((30000 + $$ % 20000))
socket="$dir/mariadbd.sock"
\mariadbd "$server_user" --datadir="$dir/data" --socket="$socket" --port="$port" --bind-address=127.0.0.1 --pid-file="$dir/mariadbd.pid" >"$dir/mariadbd.log" 2>&1 &
for i in 1 2 4 8 16 32; do
  if \mariadb -S "$socket" -uroot -e 'select 1' >/dev/null 2>&1; then break; fi
  \sleep "$i"
done
\mariadb -S "$socket" -uroot -e 'create database app; create table app.users (id int, name varchar(20)); insert into app.users values (7, "bob"), (8, "alice")'

if \mysql --version | \grep -q MariaDB; then system=mariadb; else system=mysql; fi

$TEST_SHELL auto/mysql.sh -h 127.0.0.1 -P "$port" -uroot -ptopsecret -D app -e "SELECT 1 FROM denied" 2>"$dir/stderr" >"$dir/stdout" || true
\grep -q 'Access denied' "$dir/stderr"

$TEST_SHELL auto/mysql.sh -h 127.0.0.1 -P "$port" -uroot -D app -e "SELECT name FROM users WHERE id = 7 AND name = 'bob' AND id IN (6, 7, 8)" >"$dir/stdout"
assert_equals "$(printf 'name\nbob')" "$(\cat "$dir/stdout")"
assert_equals "$(\mysql -h 127.0.0.1 -P "$port" -uroot -D app -e "SELECT name FROM users WHERE id = 7 AND name = 'bob' AND id IN (6, 7, 8)")" "$(\cat "$dir/stdout")"

command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | startswith("mysql ")) and (.name | contains("SELECT name FROM users"))')"
assert_equals "0" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .name == "SELECT users" and .attributes."db.query.text" == "SELECT name FROM users WHERE id = ? AND name = ? AND id IN (?)"')"
assert_equals "$(\echo "$command_span" | jq -r '.context.span_id')" "$(\echo "$span" | jq -r '.parent_id')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "$system" "$(\echo "$span" | jq -r '.attributes."db.system.name"')"
assert_equals "app" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "SELECT" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "SELECT users" "$(\echo "$span" | jq -r '.attributes."db.query.summary"')"
assert_equals "127.0.0.1" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "$port" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "tcp" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."error.type"')"
assert_equals "" "$(\cat "$OTEL_EXPORT_LOCATION" | jq -r 'select(.kind == "SpanKind.CLIENT") | .attributes | tostring' | \grep 'topsecret' || true)"

$TEST_SHELL auto/mysql.sh -S "$socket" -uroot -e "SELECT 'unix' AS transport" >/dev/null
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.query.text" == "SELECT ? AS transport"')"
assert_equals "SELECT" "$(\echo "$span" | jq -r '.name')"
assert_equals "unix" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "$socket" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"

$TEST_SHELL auto/mysql.sh -S "$socket" -uroot app -e "SELECT 1 FROM users WHERE id = 1;
selec 2 FROM users;
SELECT 3 FROM users" >"$dir/stdout" 2>"$dir/stderr" || true
\grep -q 'ERROR 1064' "$dir/stderr"
assert_equals "$(\mysql -S "$socket" -uroot app -e "SELECT 1 FROM users WHERE id = 1;
selec 2 FROM users;
SELECT 3 FROM users" 2>&1 >/dev/null | \grep -c ERROR)" "$(\grep -c '^ERROR' "$dir/stderr")"
command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | startswith("mysql ")) and (.name | contains("selec 2 FROM users"))')"
assert_equals "1" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.query.text" == "selec ? FROM users"')"
assert_equals "selec users" "$(\echo "$span" | jq -r '.name')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "1064" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"
assert_equals "1064" "$(\echo "$span" | jq -r '.attributes."error.type"')"
assert_equals "app" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.query.text" == "SELECT ? FROM users WHERE id = ?"')"
assert_equals "SELECT users" "$(\echo "$span" | jq -r '.name')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "0" "$(\cat "$OTEL_EXPORT_LOCATION" | jq -r 'select(.kind == "SpanKind.CLIENT" and .attributes."db.query.text" == "SELECT ? FROM users") | .name' | \wc -l)"

cat >"$dir/script.sql" <<'SQL'
delimiter //
CREATE PROCEDURE app.p() BEGIN SELECT 1; SELECT 2; END//
delimiter ;
CALL app.p();
INSERT INTO app.users VALUES (9, 'carol'), (10, 'dave');
SQL
$TEST_SHELL auto/mysql.sh -S "$socket" -uroot <"$dir/script.sql" >"$dir/stdout"
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .name == "CALL app.p"')"
assert_equals "CALL" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "CALL app.p()" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .name == "INSERT app.users"')"
assert_equals "INSERT INTO app.users VALUES (?)" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"

$TEST_SHELL auto/mysql.sh -h 127.0.0.1 -P 1 -uroot -e 'SELECT 1 FROM unreachable' 2>"$dir/stderr" || true
\grep -q 'ERROR 2002' "$dir/stderr"
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .name == "SELECT unreachable"')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "2002" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"
assert_equals "2002" "$(\echo "$span" | jq -r '.attributes."error.type"')"
assert_equals "127.0.0.1" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "1" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "tcp" "$(\echo "$span" | jq -r '.attributes."network.transport"')"

$TEST_SHELL auto/mariadb.sh -S "$socket" -uroot -N -e 'SELECT id FROM app.users ORDER BY id' >"$dir/stdout"
assert_equals "$(\mariadb -S "$socket" -uroot -N -e 'SELECT id FROM app.users ORDER BY id')" "$(\cat "$dir/stdout")"
span="$(resolve_span '.kind == "SpanKind.CLIENT" and .name == "SELECT app.users"')"
assert_equals "mariadb" "$(\echo "$span" | jq -r '.attributes."db.system.name"')"

if type script; then
  SHELL=/bin/sh script -qec "$TEST_SHELL auto/mysql.sh -S '$socket' -uroot -e 'SELECT id FROM app.users WHERE id > 0 ORDER BY id /* tty */'" /dev/null >"$dir/tty"
  \grep -q '^+--' "$dir/tty"
  span="$(resolve_span '.kind == "SpanKind.CLIENT" and .attributes."db.query.text" == "SELECT id FROM app.users WHERE id > ? ORDER BY id"')"
  assert_equals "SELECT app.users" "$(\echo "$span" | jq -r '.name')"
fi
