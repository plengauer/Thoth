. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

eval "$SHELL auto/fail_no_auto.sh"
assert_equals 0 $?
span="$(resolve_span '.resource.attributes."process.command_line" == "bash auto/fail_no_auto.sh"')"
assert_equals "myspan" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')

eval "$SHELL auto/fail.sh 42"
assert_equals 42 $?

if [ "$SHELL" = bash ]; then
  bash auto/echo.sh
  assert_equals 0 $?
  span="$(resolve_span '.resource.attributes."process.command_line" == "bash auto/echo.sh"')"
  assert_equals "echo hello world" "$(\echo "$span" | jq -r '.name')"
  assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
fi
