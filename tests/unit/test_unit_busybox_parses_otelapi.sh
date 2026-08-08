. ./assert.sh
if ! \type busybox 1> /dev/null 2> /dev/null; then exit 0; fi
busybox sh -n ${OTEL_TEST_API_ENTRYPOINT:-/usr/bin/opentelemetry_shell_api.sh}
assert_equals 0 "$?"
