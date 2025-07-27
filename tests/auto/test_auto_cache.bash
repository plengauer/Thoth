. ./assert.sh

time bash -c '. otel.sh
bash auto/echo_arg.sh hello world 0'
time bash -c '. otel.sh
bash auto/echo_arg.sh hello world 1'
time bash -c '. otel.sh
bash auto/echo_arg.sh hello world 2'
time bash -c '. otel.sh
bash auto/echo_arg.sh hello world 3'

span="$(resolve_span '.name == "echo hello world 0"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')

span="$(resolve_span '.name == "echo hello world 1"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')

span="$(resolve_span '.name == "echo hello world 2"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')

span="$(resolve_span '.name == "echo hello world 3"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
