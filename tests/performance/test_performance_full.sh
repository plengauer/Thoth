set -e

timeout 90s sh -c '. ${OTEL_TEST_ENTRYPOINT:-/usr/bin/opentelemetry_shell.sh}
exit 0'
