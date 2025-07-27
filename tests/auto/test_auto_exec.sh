. ./assert.sh

eval "$SHELL auto/exec.sh hello world 0"
assert_equals 0 $?
span="$(resolve_span '.name == "echo hello world 0"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')

SOURCE=TRUE eval "$SHELL auto/exec.sh hello world 1"
assert_equals 0 $?
span="$(resolve_span '.name == "echo hello world 1"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')

if [ "$SHELL" = bash ]; then
  OPEN_FD=TRUE eval "$SHELL auto/exec.sh hello world 2"
  assert_equals 0 $?
  span="$(resolve_span '.name == "echo hello world 2"')"
  assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')

  SOURCE=TRUE OPEN_FD=TRUE eval "$SHELL auto/exec.sh hello world 3"
  assert_equals 0 $?
  span="$(resolve_span '.name == "echo hello world 3"')"
  assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
fi
