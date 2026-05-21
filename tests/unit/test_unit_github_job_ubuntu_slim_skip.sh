. ./assert.sh

helper_file="$(mktemp)"
echo 1 > "$helper_file"
OTEL_SHELL_GITHUB_JOB_CONTAINER_MARKER_FILE="$helper_file"
OTEL_SHELL_GITHUB_JOB_CGROUP_FILE="$(mktemp)"
. ../actions/instrument/job/should_skip.sh
otel_github_job_should_skip

notice="$(otel_github_job_skip_notice pre)"
case "$notice" in
  "::notice::Skipping job-level instrumentation pre step because this runner appears to be a GitHub ubuntu-slim image"*network-constrained\ startup*15+\ minutes*trigger\ timeouts.) ;;
  *) echo "ASSERT FAILED $notice" 1>&2; exit 1;;
esac

rm -f "$helper_file" "$OTEL_SHELL_GITHUB_JOB_CGROUP_FILE"

OTEL_SHELL_GITHUB_JOB_CONTAINER_MARKER_FILE="$(mktemp -u)"
OTEL_SHELL_GITHUB_JOB_CGROUP_FILE="$(mktemp)"
printf '%s\n' '0::/user.slice' > "$OTEL_SHELL_GITHUB_JOB_CGROUP_FILE"
! otel_github_job_should_skip

printf '%s\n' '0::/docker/abcdef' > "$OTEL_SHELL_GITHUB_JOB_CGROUP_FILE"
otel_github_job_should_skip

rm -f "$OTEL_SHELL_GITHUB_JOB_CGROUP_FILE"
