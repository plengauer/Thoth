. ./assert.sh
if ! \type busybox 1> /dev/null 2> /dev/null; then exit 0; fi
busybox sh -n /usr/bin/opentelemetry_shell_api.sh
assert_equals 0 "$?"
