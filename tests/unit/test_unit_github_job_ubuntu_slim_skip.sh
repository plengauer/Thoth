. ./assert.sh

helper_file="$(mktemp)"
echo 1 > "$helper_file"
OTEL_SHELL_GITHUB_JOB_CONTAINER_MARKER_FILE="$helper_file"
OTEL_SHELL_GITHUB_JOB_CGROUP_FILE="$(mktemp)"
. ../actions/instrument/job/should_skip.sh
otel_github_job_should_skip

notice="$(otel_github_job_skip_notice pre)"
expected_notice="::notice::Skipping job-level instrumentation pre step because this runner appears to be a GitHub ubuntu-slim image with network-constrained startup that can take 2 seconds to 15+ minutes and trigger timeouts."
assert_equals "$expected_notice" "$notice"
assert_equals "${expected_notice/ pre step/ post step}" "$(otel_github_job_skip_notice post)"

rm -f "$helper_file" "$OTEL_SHELL_GITHUB_JOB_CGROUP_FILE"

OTEL_SHELL_GITHUB_JOB_CONTAINER_MARKER_FILE="$(mktemp -u)"
OTEL_SHELL_GITHUB_JOB_CGROUP_FILE="$(mktemp)"
printf '%s\n' '0::/user.slice' > "$OTEL_SHELL_GITHUB_JOB_CGROUP_FILE"
! otel_github_job_should_skip

printf '%s\n' '0::/docker/abcdef' > "$OTEL_SHELL_GITHUB_JOB_CGROUP_FILE"
otel_github_job_should_skip

rm -f "$OTEL_SHELL_GITHUB_JOB_CGROUP_FILE"
