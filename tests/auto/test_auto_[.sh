# shellcheck shell=bash
. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

# shellcheck disable=SC2157 # the constant expression is intentional, the test exercises the instrumented test command
if [ -n "hello world if" ]; then
  echo hello world
else
  exit 1
fi

# shellcheck disable=SC2157 # the constant expression is intentional, the test exercises the instrumented test command
while [ -z "hello world while" ]; do
  exit 1
done

span="$(resolve_span '.name == "[ -n hello world if ]"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "[ -z hello world while ]"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
