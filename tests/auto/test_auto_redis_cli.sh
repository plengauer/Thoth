# shellcheck shell=bash
if ! type redis-cli || ! type redis-server; then exit 0; fi

set -e
. ./assert.sh

dir="$(\mktemp -d)"
trap 'kill "$(\cat "$dir/redis.pid")" 2>/dev/null || true' EXIT
port=$((20000 + $$ % 20000))
\redis-server --port "$port" --bind 127.0.0.1 --unixsocket "$dir/redis.sock" --unixsocketperm 700 --save '' --appendonly no --daemonize yes --pidfile "$dir/redis.pid" --dir "$dir" --logfile "$dir/redis.log"
for i in 1 2 4 8; do
  if \redis-cli -p "$port" PING >/dev/null 2>&1; then break; fi
  \sleep "$i"
done
\redis-cli -p "$port" PING >/dev/null

$TEST_SHELL auto/redis-cli.sh -p "$port" -n 2 SET greeting hello >"$dir/stdout"
assert_equals "OK" "$(\cat "$dir/stdout")"

command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | startswith("redis-cli ")) and (.name | contains("SET greeting hello"))')"
assert_equals "0" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"

span="$(resolve_span '.name == "SET" and .kind == "SpanKind.CLIENT"')"
assert_equals "$(\echo "$command_span" | jq -r '.context.span_id')" "$(\echo "$span" | jq -r '.parent_id')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "redis" "$(\echo "$span" | jq -r '.attributes."db.system.name"')"
assert_equals "2" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "SET" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "SET ? ?" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"
assert_equals "tcp" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "127.0.0.1" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "$port" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.operation.batch.size"')"

$TEST_SHELL auto/redis-cli.sh -p "$port" -n 2 GET greeting >"$dir/stdout"
assert_equals "hello" "$(\cat "$dir/stdout")"

$TEST_SHELL auto/redis-cli.sh -p "$port" -n 2 LPUSH greeting item >"$dir/stdout"
assert_equals "WRONGTYPE Operation against a key holding the wrong kind of value" "$(\cat "$dir/stdout")"

span="$(resolve_span '.name == "LPUSH" and .kind == "SpanKind.CLIENT"')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "WRONGTYPE" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"
assert_equals "WRONGTYPE" "$(\echo "$span" | jq -r '.attributes."error.type"')"
assert_equals "LPUSH ? ?" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"

$TEST_SHELL auto/redis-cli.sh -p "$port" -e FOO bar >"$dir/stdout" 2>"$dir/stderr" || true
assert_equals "" "$(\cat "$dir/stdout")"
assert_equals "ERR unknown command 'FOO', with args beginning with: 'bar' " "$(\cat "$dir/stderr")"

command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | startswith("redis-cli ")) and (.name | contains("-e FOO bar"))')"
assert_equals "1" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"
span="$(resolve_span '.name == "FOO" and .kind == "SpanKind.CLIENT"')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "_OTHER" "$(\echo "$span" | jq -r '.attributes."error.type"')"

$TEST_SHELL auto/redis-cli.sh -p "$port" NOSUCHCOMMAND >"$dir/stdout"
assert_equals "ERR unknown command 'NOSUCHCOMMAND', with args beginning with: " "$(\cat "$dir/stdout" | \head -n 1)"

span="$(resolve_span '.name == "NOSUCHCOMMAND" and .kind == "SpanKind.CLIENT"')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "ERR" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"
assert_equals "ERR" "$(\echo "$span" | jq -r '.attributes."error.type"')"

$TEST_SHELL auto/redis-cli.sh -p "$port" -r 3 -i 0 PING >"$dir/stdout"
assert_equals "3" "$(\grep -c '^PONG$' "$dir/stdout")"

span="$(resolve_span '.name == "BATCH PING" and .kind == "SpanKind.CLIENT"')"
assert_equals "BATCH PING" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "PING" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"
assert_equals "3" "$(\echo "$span" | jq -r '.attributes."db.operation.batch.size"')"

$TEST_SHELL auto/redis-cli.sh -s "$dir/redis.sock" -n 15 ECHO unixsocket >"$dir/stdout"
assert_equals "unixsocket" "$(\cat "$dir/stdout")"

span="$(resolve_span '.name == "ECHO" and .kind == "SpanKind.CLIENT"')"
assert_equals "unix" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "$dir/redis.sock" "$(\echo "$span" | jq -r '.attributes."network.peer.address"')"
assert_equals "15" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."server.port"')"

REDISCLI_AUTH=envsecret $TEST_SHELL auto/redis-cli.sh -u "redis://someuser:uripassword@127.0.0.1:$port/3" --no-auth-warning -a argsecret EXISTS uri_key >"$dir/stdout" 2>/dev/null
assert_equals "0" "$(\cat "$dir/stdout")"

span="$(resolve_span '.name == "EXISTS" and .kind == "SpanKind.CLIENT"')"
assert_equals "3" "$(\echo "$span" | jq -r '.attributes."db.namespace"')"
assert_equals "127.0.0.1" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "$port" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "EXISTS ?" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"
assert_equals "0" "$(\echo "$span" | jq -c .attributes | \grep -c -e envsecret -e uripassword -e argsecret -e someuser -e uri_key || true)"

echo PING | $TEST_SHELL auto/redis-cli.sh -p "$port" >"$dir/stdout"
assert_equals "PONG" "$(\cat "$dir/stdout")"

span="$(resolve_span '.name == "redis" and .kind == "SpanKind.CLIENT"')"
assert_equals "redis" "$(\echo "$span" | jq -r '.attributes."db.system.name"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.operation.name"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"

$TEST_SHELL auto/redis-cli.sh -h localhost -p 1 DBSIZE >"$dir/stdout" 2>"$dir/stderr" || true
assert_equals "" "$(\cat "$dir/stdout")"
assert_equals "Could not connect to Redis at localhost:1: Connection refused" "$(\cat "$dir/stderr")"

command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | startswith("redis-cli ")) and (.name | contains("DBSIZE"))')"
assert_equals "1" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"
span="$(resolve_span '.name == "DBSIZE" and .kind == "SpanKind.CLIENT"')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "_OTHER" "$(\echo "$span" | jq -r '.attributes."error.type"')"
assert_equals "localhost" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "1" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "null" "$(\echo "$span" | jq -r '.attributes."db.response.status_code"')"

$TEST_SHELL auto/redis-cli.sh -p "$port" SUBSCRIBE channel >"$dir/stdout" 2>/dev/null &
subscriber="$!"
for i in 1 2 4 8; do
  if [ "$(\redis-cli -p "$port" PUBSUB NUMSUB channel | \tail -n 1)" = 1 ]; then break; fi
  \sleep "$i"
done
\redis-cli -p "$port" PUBLISH channel streamed >/dev/null
for i in 1 2 4 8; do
  if \grep -q streamed "$dir/stdout"; then break; fi
  \sleep "$i"
done
\grep -q streamed "$dir/stdout"
\redis-cli -p "$port" CLIENT KILL TYPE pubsub >/dev/null
wait "$subscriber" || true

span="$(resolve_span '.name == "SUBSCRIBE" and .kind == "SpanKind.CLIENT"')"
assert_equals "SUBSCRIBE ?" "$(\echo "$span" | jq -r '.attributes."db.query.text"')"
