. ./assert.sh

# Regression test: a script's EXIT trap must fire exactly once, at the real end of the
# script, and never as a side effect of exec instrumentation.
#
# The exec here has an argument. A redirection-only exec (e.g. exec 3<>file) would also
# exercise this, but it is currently misread as a bare exec and re-runs the whole script,
# so it cannot be asserted on until that is fixed separately.
output="$(eval "timeout 60 $TEST_SHELL auto/exec_subshell_trap.sh")"
assert_equals 0 $?
assert_equals 1 "$(\echo "$output" | \grep -c '^INNER$')"
assert_equals 1 "$(\echo "$output" | \grep -c '^TRAP_FIRED$')"
assert_ends_with "TRAP_FIRED" "$output"
