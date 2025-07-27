if ! type which; then exit 0; fi
# which is really a shell script with a shebang and it does some IFS magic
. ./assert.sh
. /usr/bin/opentelemetry_shell.sh
assert_equals "$(\which flock)" "$(which flock)"
span="$(resolve_span '.name | endswith("which flock")')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
