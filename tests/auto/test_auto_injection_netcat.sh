if ! type ncat; then exit 0; fi
[ -z "${WSL_DISTRO_NAME:-}" ] || exit 0
set -e
. ./assert.sh
. otel.sh

echo TEST 1 >&2
OTEL_SHELL_AUTO_INJECTED=FALSE \otel4netcat ncat -l -p 12346 -c cat &
pid="$!"
sleep 3
assert_equals "hello world" "$(echo -n hello world | ncat -i 10 --no-shutdown 127.0.0.1 12346)"
wait "$pid"

span="$(resolve_span '.name | endswith("cat")')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
span_id=$(\echo "$span" | jq -r '.parent_id')
span="$(resolve_span '.context.span_id == "'"$span_id"'"')"
assert_equals "send/receive" $(\echo "$span" | jq -r '.name')
assert_equals "SpanKind.CONSUMER" $(\echo "$span" | jq -r '.kind')
# span_id=$(\echo "$span" | jq -r '.parent_id')
# span="$(resolve_span '.context.span_id == "'$span_id'"')"
# assert_equals "ncat -l -p 12345 -c cat" $(\echo "$span" | jq -r '.name')
# assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')

span="$(resolve_span '.name == "ncat -i 10 --no-shutdown 127.0.0.1 12346"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
span_id=$(\echo "$span" | jq -r '.context.span_id')
span="$(resolve_span '.parent_id == "'$span_id'"')"
assert_equals "send/receive" $(\echo "$span" | jq -r '.name')
assert_equals "SpanKind.PRODUCER" $(\echo "$span" | jq -r '.kind')

echo TEST 2 >&2
OTEL_SHELL_AUTO_INJECTED=FALSE \otel4netcat_http ncat -l -p 12346 -c 'printf "HTTP/1.1 200 OK\r\n\r\nhello world"' &
pid="$!"
sleep 3
assert_equals "hello world" "$(curl http://127.0.0.1:12346/)"
wait "$pid"

span="$(resolve_span '.name == "GET") | select(.kind == "SpanKind.SERVER"')"
span_id=$(\printf '%s' "$span" | jq -r '.parent_id')
span="$(resolve_span '.context.span_id == "'"$span_id"'"')"
assert_equals "GET" "$(\printf '%s' "$span" | jq -r '.name')"
assert_equals "SpanKind.CLIENT" "$(\printf '%s' "$span" | jq -r '.kind')"
span_id=$(\printf '%s' "$span" | jq -r '.parent_id')
span="$(resolve_span '.context.span_id == "'"$span_id"'"')"
assert_equals "curl http://127.0.0.1:12346/" "$(\printf '%s' "$span" | jq -r '.name')"
