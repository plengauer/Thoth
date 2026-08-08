. ./assert.sh
. ${OTEL_TEST_ENTRYPOINT:-/usr/bin/opentelemetry_shell.sh}

/bin/bash auto/fail_no_auto.shell
assert_equals 0 $?
sleep 3
assert_not_equals "null" $(cat $OTEL_TRACES_LOCATION | jq '.name')
/bin/bash auto/fail.shell 42
assert_equals 42 $?
