. ./assert.sh
. ${OTEL_TEST_API_ENTRYPOINT:-/usr/bin/opentelemetry_shell_api.sh}

otel_init
assert_equals 0 $?
otel_shutdown
assert_equals 0 $?
