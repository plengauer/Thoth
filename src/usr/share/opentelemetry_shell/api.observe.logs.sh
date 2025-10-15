#!/bin/false

_otel_call_and_record_logs() {
  case "$-" in
    *m*) local job_control=1; \set +m;;
    *) local job_control=0;;
  esac
  local call_command="$1"; shift
  local traceparent="$TRACEPARENT"
  local stderr_logs="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stderr.logs.pipe"
  \mkfifo ${_otel_mkfifo_flags:-} "$stderr_logs"
  while IFS=$'\n' \read -r line; do _otel_log_record "$traceparent" auto 0 "$line"; \printf '%s\n' "$line" >&2; done < "$stderr_logs" &
  local stderr_pid="$!"
  local exit_code=0
  $call_command "$@" 2> "$stderr_logs" || local exit_code="$?"
  \wait "$stderr_pid"
  \rm "$stderr_logs" 2> /dev/null
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}

_otel_log_record() {
  local traceparent="$1"; shift
  local time="$1"; shift
  local severity="$1"; shift
  local line="$(_otel_dollar_star "$@")"
  _otel_sdk_communicate "LOG_RECORD" "$traceparent" "$time" "$severity" "$line"
}
