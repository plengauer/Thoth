. ./assert.sh

. ../actions/instrument/shared/github.sh

GITHUB_REPOSITORY=owner/repo
traceparent_1="$(gh_workflow_run_traceparent 123 1)"
traceparent_2="$(gh_workflow_run_traceparent 123 1)"
traceparent_3="$(gh_workflow_run_traceparent 123 2)"

assert_equals "$traceparent_1" "$traceparent_2"
assert_not_equals "$traceparent_1" "$traceparent_3"
assert_equals 55 "$(printf '%s' "$traceparent_1" | wc -c | tr -d ' ')"
assert_equals 00 "$(printf '%s' "$traceparent_1" | cut -d - -f 1)"
assert_equals 32 "$(printf '%s' "$traceparent_1" | cut -d - -f 2 | tr -d '\n' | wc -c | tr -d ' ')"
assert_equals 16 "$(printf '%s' "$traceparent_1" | cut -d - -f 3 | tr -d '\n' | wc -c | tr -d ' ')"
assert_equals 01 "$(printf '%s' "$traceparent_1" | cut -d - -f 4)"
