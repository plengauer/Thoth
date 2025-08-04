. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

assert_equals 0 $(eval "$TEST_SHELL auto/count_fail_no_auto.sh")
assert_equals 1 $(eval "$TEST_SHELL auto/count_fail_no_auto.sh foo")
assert_equals 2 $(eval "$TEST_SHELL auto/count_fail_no_auto.sh foo bar")
assert_equals 1 $(eval "$TEST_SHELL auto/count_fail_no_auto.sh 'foo bar'")
