if [ "$SHELL" = sh ] && type rpm; then exit 0; fi

. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

time echo hello world
assert_equals 0 $?
span="$(resolve_span '.name == "time echo hello world"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo hello world"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"

time -p echo hello world 2
assert_equals 0 $?
span="$(resolve_span '.name == "time -p echo hello world 2"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo hello world 2"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"

file=$(mktemp)
time -o $file echo hello world 3
assert_equals 0 $?
span="$(resolve_span '.name == "'"time -o $file echo hello world 3"'"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo hello world 3"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
