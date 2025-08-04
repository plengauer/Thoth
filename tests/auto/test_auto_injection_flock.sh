touch .lock
if [ -x .lock ]; then exit 0; fi
# chmod +x .lock

. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

output="$(flock .lock echo hello world)"
assert_equals "hello world" "$output"
span="$(resolve_span '.name == "flock .lock echo hello world"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo hello world"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
