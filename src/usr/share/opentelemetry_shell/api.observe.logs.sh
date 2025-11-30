#!/bin/false

_otel_call_and_record_logs() {
  local call_command="$1"; shift
  local traceparent="$TRACEPARENT"
  local stderr_logs="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stderr.logs.pipe.XXXXXXXXXX)"
  \mkfifo "$stderr_logs"
  while IFS=$'\n' \read -r line; do _otel_log_record "$traceparent" auto 0 "$line"; \printf '%s\n' "$line" >&2; done < "$stderr_logs" 1> /dev/null &
  local exit_code=0
  $call_command "$@" 2> "$stderr_logs" || local exit_code="$?"
  # we accept, by not waiting for the background job above, that there is slight chance of the last few lines of stderr may be interleaved with the next few lines of the parent.
  # alternatively, we would have to wait, but we do not know if the stderr stream is not opened by a background job of the child and will never close
  # the control flow of this must continue when the command terminates, which is not the same as when the stream closes (the stream may be inherited to others)
  \rm "$stderr_logs" 2> /dev/null
  return "$exit_code"
}

_otel_log_record() {
  local traceparent="$1"; shift
  local time="$1"; shift
  local severity="$1"; shift
  local line="$(_otel_dollar_star "$@")"
  _otel_sdk_communicate "LOG_RECORD" "$traceparent" "$time" "$severity" "$line"
}
