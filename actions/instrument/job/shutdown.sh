#!/bin/sh
set -e
if [ "$INPUT___JOB_STATUS" = failure ]; then
  touch /tmp/opentelemetry_shell.github.error
fi
root_pid="$STATE_pid"
kill -USR1 "$root_pid"
cat /tmp/opentelemetry_shell.github.debug.log
cat < "$STATE_log_file" > "$STATE_otel_shell_sdk_output_redirect"
