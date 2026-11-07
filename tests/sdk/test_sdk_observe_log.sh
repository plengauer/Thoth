# shellcheck shell=bash
. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init
# shellcheck disable=SC2086 # TEST_SHELL and options may be a command with arguments such as busybox sh and must be split into words
otel_observe $TEST_SHELL sdk/log.sh
otel_shutdown

log="$(resolve_log '.body == "my log"')"
assert_equals "my log" "$(echo "$log" | jq -r '.body')"
