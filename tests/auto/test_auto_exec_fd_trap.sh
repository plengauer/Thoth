. ./assert.sh

# Regression test: a script's EXIT trap must fire exactly once, at the real end of the
# script, and never as a side effect of exec instrumentation.
output="$(eval "timeout 60 $TEST_SHELL auto/exec_fd_trap.sh")"
assert_equals 0 $?
assert_equals 1 "$(\echo "$output" | \grep -c '^TRAP_FIRED$')"
assert_ends_with "TRAP_FIRED" "$output"
