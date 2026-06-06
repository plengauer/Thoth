. ./assert.sh
. otel.sh

output="$(MY_ENV_VAR=testvalue printenv MY_ENV_VAR)"
assert_equals 0 $?
assert_equals "testvalue" "$output"
