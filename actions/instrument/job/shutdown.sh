#!/bin/sh
set -e
. ./should_skip.sh
if [ "${STATE_disabled:-}" = ubuntu_slim ] || otel_github_job_should_skip; then
  otel_github_job_skip_notice post
  exit 0
fi
if [ "$INPUT___JOB_STATUS" = failure ]; then
  touch /tmp/opentelemetry_shell.github.error
fi
root_pid="$STATE_pid"
kill -USR1 "$root_pid"
cat /tmp/opentelemetry_shell.github.debug.log
cat < "$STATE_log_file" > "$STATE_otel_shell_sdk_output_redirect"
