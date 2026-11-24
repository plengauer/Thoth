# shellcheck shell=bash
if ! type mongosh; then exit 0; fi

set -e
. ./assert.sh

dir="$(\mktemp -d)"
trap 'if [ -f "$dir/mongod.pid" ]; then kill "$(\cat "$dir/mongod.pid")" 2>/dev/null || true; fi' EXIT
port=$((20000 + $$ % 20000))
closed_port=$((port + 1))

attribute() {
  \echo "$1" | jq -r ".attributes.\"$2\""
}

credentials=user:topsecret
$TEST_SHELL auto/mongosh.sh --quiet "mongodb://$credentials@127.0.0.1:$closed_port/shop" --eval 'db.orders.find({status: "open"}); db.getCollection("it-ems").insertOne({a: 1})' >"$dir/stdout" 2>"$dir/stderr" || true

command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | startswith("mongosh ")) and (.name | contains("it-ems"))')"
assert_equals "1" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"
assert_equals "MongoNetworkError: connect ECONNREFUSED 127.0.0.1:$closed_port" "$(\cat "$dir/stderr")"
span="$(resolve_span '.name == "find orders" and .kind == "SpanKind.CLIENT"')"
assert_equals "$(\echo "$command_span" | jq -r '.context.span_id')" "$(\echo "$span" | jq -r '.parent_id')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "mongodb" "$(attribute "$span" db.system.name)"
assert_equals "shop" "$(attribute "$span" db.namespace)"
assert_equals "find" "$(attribute "$span" db.operation.name)"
assert_equals "orders" "$(attribute "$span" db.collection.name)"
assert_equals "tcp" "$(attribute "$span" network.transport)"
assert_equals "127.0.0.1" "$(attribute "$span" server.address)"
assert_equals "$closed_port" "$(attribute "$span" server.port)"
assert_equals "MongoNetworkError" "$(attribute "$span" error.type)"
assert_equals "null" "$(attribute "$span" db.query.text)"
assert_equals "null" "$(attribute "$span" db.response.status_code)"
assert_equals "false" "$(\echo "$span" | jq -r '[.name, .attributes] | tostring | contains("topsecret")')"
span="$(resolve_span '.name == "insertOne it-ems" and .kind == "SpanKind.CLIENT"')"
assert_equals "$(\echo "$command_span" | jq -r '.context.span_id')" "$(\echo "$span" | jq -r '.parent_id')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "it-ems" "$(attribute "$span" db.collection.name)"
assert_equals "shop" "$(attribute "$span" db.namespace)"

$TEST_SHELL auto/mongosh.sh --quiet --host 127.0.0.1 --port "$closed_port" --eval 'db.adminCommand({ping: 1}); db.runCommand({count: "logs"}); db.getSiblingDB("other").events.deleteMany({})
use third
db.stats.aggregate([])' >/dev/null 2>&1 || true

span="$(resolve_span '.name == "ping admin" and .kind == "SpanKind.CLIENT"')"
assert_equals "ping" "$(attribute "$span" db.operation.name)"
assert_equals "admin" "$(attribute "$span" db.namespace)"
assert_equals "null" "$(attribute "$span" db.collection.name)"
assert_equals "127.0.0.1" "$(attribute "$span" server.address)"
assert_equals "$closed_port" "$(attribute "$span" server.port)"
span="$(resolve_span '.name == "count logs" and .kind == "SpanKind.CLIENT"')"
assert_equals "test" "$(attribute "$span" db.namespace)"
span="$(resolve_span '.name == "deleteMany events" and .kind == "SpanKind.CLIENT"')"
assert_equals "other" "$(attribute "$span" db.namespace)"
span="$(resolve_span '.name == "aggregate stats" and .kind == "SpanKind.CLIENT"')"
assert_equals "third" "$(attribute "$span" db.namespace)"

script="$dir/script.js"
\echo 'db.fromfile.updateMany({}, {$set: {a: 1}})' >"$script"
$TEST_SHELL auto/mongosh.sh --quiet "localhost:$closed_port/filedb" "$script" >/dev/null 2>&1 || true

span="$(resolve_span '.name == "updateMany fromfile" and .kind == "SpanKind.CLIENT"')"
assert_equals "filedb" "$(attribute "$span" db.namespace)"
assert_equals "localhost" "$(attribute "$span" server.address)"
assert_equals "$closed_port" "$(attribute "$span" server.port)"

$TEST_SHELL auto/mongosh.sh --quiet "mongodb://user:topsecret@127.0.0.1:$closed_port,127.0.0.1:$((closed_port + 1))/multi" --eval 'print(1)' >/dev/null 2>&1 || true

span="$(resolve_span '.name == "mongodb" and .kind == "SpanKind.CLIENT" and .attributes."db.namespace" == "multi"')"
assert_equals "null" "$(attribute "$span" server.address)"
assert_equals "null" "$(attribute "$span" server.port)"
assert_equals "null" "$(attribute "$span" db.operation.name)"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"

$TEST_SHELL auto/mongosh.sh --nodb --quiet --eval 'db.nodbmarker.find()' >/dev/null 2>&1 || true

resolve_span '.kind == "SpanKind.INTERNAL" and (.name | startswith("mongosh ")) and (.name | contains("nodbmarker"))' >/dev/null
assert_equals "0" "$(\cat "$OTEL_EXPORT_LOCATION" | jq -r 'select(.kind == "SpanKind.CLIENT" and .attributes."db.collection.name" == "nodbmarker") | .name' | \wc -l)"

if ! type mongod; then exit 0; fi

mongod --dbpath "$dir" --port "$port" --bind_ip 127.0.0.1 --fork --logpath "$dir/mongod.log" --pidfilepath "$dir/mongod.pid" >/dev/null
for i in 1 2 3 4 5 6 7 8 9 10; do
  if mongosh --quiet --port "$port" --eval 'db.runCommand({ping: 1}).ok' 2>/dev/null | grep -q 1; then break; fi
  sleep 1
done

$TEST_SHELL auto/mongosh.sh --quiet --port "$port" --eval 'db.items.insertOne({_id: 1}); db.items.find({_id: 1})' >"$dir/stdout" 2>"$dir/stderr"

assert_equals "$(\mongosh --quiet --port "$port" --eval 'db.items.find({_id: 1})')" "$(\cat "$dir/stdout")"
assert_equals "" "$(\cat "$dir/stderr")"
span="$(resolve_span '.name == "insertOne items" and .kind == "SpanKind.CLIENT" and .attributes."server.port" == '"$port")"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "test" "$(attribute "$span" db.namespace)"
assert_equals "null" "$(attribute "$span" error.type)"
span="$(resolve_span '.name == "find items" and .kind == "SpanKind.CLIENT" and .attributes."server.port" == '"$port")"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"

\mongosh "127.0.0.1:$port/shop2" --quiet --eval 'db.items.insertOne({_id: 1})'
exit_code=0
$TEST_SHELL auto/mongosh.sh "127.0.0.1:$port/shop2" --quiet --eval 'db.items.insertOne({_id: 1})' >"$dir/stdout" 2>"$dir/stderr" || exit_code="$?"
expected_exit_code=0
\mongosh "127.0.0.1:$port/shop2" --quiet --eval 'db.items.insertOne({_id: 1})' >"$dir/expected_stdout" 2>"$dir/expected_stderr" || expected_exit_code="$?"

assert_equals "$expected_exit_code" "$exit_code"
assert_equals "$(\cat "$dir/expected_stdout")" "$(\cat "$dir/stdout")"
assert_equals "$(\cat "$dir/expected_stderr")" "$(\cat "$dir/stderr")"
span="$(resolve_span '.name == "insertOne items" and .kind == "SpanKind.CLIENT" and .attributes."db.namespace" == "shop2"')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "11000" "$(attribute "$span" error.type)"
assert_equals "11000" "$(attribute "$span" db.response.status_code)"
