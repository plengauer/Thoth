. ./assert.sh
. otel.sh

MY_ENV_VAR=testvalue printenv MY_ENV_VAR
assert_equals 0 $?
span="$(resolve_span '.name == "printenv MY_ENV_VAR"')"
assert_not_equals "" "$span"

if type timeout 1>/dev/null 2>&1; then
  MY_ENV_VAR=testvalue timeout 5 printenv MY_ENV_VAR
  assert_equals 0 $?
fi
