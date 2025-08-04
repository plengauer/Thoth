. ./assert.sh
. otel.sh

env echo hello world
assert_equals 0 $?
span="$(resolve_span '.name == "echo hello world"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
