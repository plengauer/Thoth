if [ "$(readlink -f /proc/$$/exe | rev | cut -d / -f 1 | rev)" = busybox ]; then exit 0; fi

. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

eval "$TEST_SHELL -c -- 'echo hello world'"
assert_equals 0 $?
span="$(resolve_span '.resource.attributes."process.command_line" == "'"$TEST_SHELL"' -c -- echo hello world"')"
assert_equals "echo hello world" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"

assert_equals "$(eval "\\$TEST_SHELL -c 'echo $0' 'foo' 'bar baz'")" "$(eval "$TEST_SHELL -c 'echo $0' 'foo' 'bar baz'")"
assert_equals "$(eval "\\$TEST_SHELL -c 'echo $1' 'foo' 'bar baz'")" "$(eval "$TEST_SHELL -c 'echo $1' 'foo' 'bar baz'")"
assert_equals "$(eval "\\$TEST_SHELL -c 'echo $2' 'foo' 'bar baz'")" "$(eval "$TEST_SHELL -c 'echo $2' 'foo' 'bar baz'")"
