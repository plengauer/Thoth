if [ "$(readlink -f /proc/$$/exe | rev | cut -d / -f 1 | rev)" = busybox ]; then exit 0; fi

. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

eval "$TEST_SHELL auto/fail_no_auto.sh"
assert_equals 0 $?
span="$(resolve_span '.resource.attributes."process.command_line" == "'"$TEST_SHELL"' auto/fail_no_auto.sh"')"
assert_equals "myspan" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')

eval "$TEST_SHELL auto/fail.sh 42"
assert_equals 42 $?

if [ "$TEST_SHELL" = bash ]; then
  bash auto/echo.sh
  assert_equals 0 $?
  span="$(resolve_span '.resource.attributes."process.command_line" == "bash auto/echo.sh"')"
  assert_equals "echo hello world" "$(\echo "$span" | jq -r '.name')"
  assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
fi
