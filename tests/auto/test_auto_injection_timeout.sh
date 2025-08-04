if type rpm; then exit 0; fi
. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

timeout 60s echo hello world 1
assert_equals 0 $?
span="$(resolve_span '.name == "timeout 60s echo hello world 1"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo hello world 1"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"

timeout -v 60s echo hello world 2
assert_equals 0 $?
span="$(resolve_span '.name == "timeout -v 60s echo hello world 2"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo hello world 2"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
