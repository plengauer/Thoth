#!/bin/sh

otel_github_job_should_skip() {
  container_marker_file="${OTEL_SHELL_GITHUB_JOB_CONTAINER_MARKER_FILE:-/.dockerenv}"
  cgroup_file="${OTEL_SHELL_GITHUB_JOB_CGROUP_FILE:-/proc/1/cgroup}"
  if [ -f "$container_marker_file" ]; then
    return 0
  fi
  if [ -r "$cgroup_file" ] && grep -qE '(docker|containerd|kubepods|podman)' "$cgroup_file"; then
    return 0
  fi
  return 1
}

otel_github_job_skip_notice() {
  step_name="${1:-step}"
  echo "::notice::Skipping job-level instrumentation ${step_name} step because this runner appears to be a GitHub ubuntu-slim image. We currently assume containerized GitHub-hosted runners are ubuntu-slim, and their network-constrained startup can take anywhere from seconds to 15+ minutes and trigger timeouts."
}
