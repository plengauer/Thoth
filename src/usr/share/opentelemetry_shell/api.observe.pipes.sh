#!/bin/false

_otel_call_and_record_pipes() {
  local IFS=' 
'
  # some notes about this function
  # (*) we have to wait for the background processes because otherwise the span_id may not be valid anymore
  # (*) waiting for the processes only works when its not a subshell so we can access the last process id
  # (*) not using a subshell means we have to disable job control, otherwise we get unwanted output
  # (*) we can only directly tee stdin, otherwise the exit code cannot be captured propely if we pipe stdout directly
  # (*) tee for stdin does ONLY terminate when it writes something and realizes the process has terminated
  # (**) so in cases where stdin is open but nobody every writes to it and the process doesnt expect input, tee hangs forever
  # (**) this is different to output streams, because they get properly terminated with SIGPIPE on read
  local span_handle="$1"; shift
  local command_type="$1"; shift
  local call_command="$1"; shift
  local stdin_bytes_result="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stdin.bytes.result"
  local stdin_lines_result="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stdin.lines.result"
  local stdout_bytes_result="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stdout.bytes.result"
  local stdout_lines_result="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stdout.lines.result"
  local stderr_bytes_result="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stderr.bytes.result"
  local stderr_lines_result="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stderr.lines.result"
  local stdout="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stdout.pipe"
  local stderr="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stderr.pipe"
  local stdin_bytes="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stdin.bytes.pipe"
  local stdin_lines="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stdin.lines.pipe"
  local stdout_bytes="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stdout.bytes.pipe"
  local stdout_lines="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stdout.lines.pipe"
  local stderr_bytes="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stderr.bytes.pipe"
  local stderr_lines="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stderr.lines.pipe"
  local exit_code=0
  \mkfifo "$stdout" "$stderr" "$stdin_bytes" "$stdin_lines" "$stdout_bytes" "$stdout_lines" "$stderr_bytes" "$stderr_lines"
  \wc -c < "$stdin_bytes" > "$stdin_bytes_result" &
  local stdin_bytes_pid="$!"
  \wc -l < "$stdin_lines" > "$stdin_lines_result" &
  local stdin_lines_pid="$!"
  \wc -c < "$stdout_bytes" > "$stdout_bytes_result" &
  local stdout_bytes_pid="$!"
  \wc -l < "$stdout_lines" > "$stdout_lines_result" &
  local stdout_lines_pid="$!"
  \wc -c < "$stderr_bytes" > "$stderr_bytes_result" &
  local stderr_bytes_pid="$!"
  \wc -l < "$stderr_lines" > "$stderr_lines_result" &
  local stderr_lines_pid="$!"
  \tee "$stdout_bytes" "$stdout_lines" < "$stdout" 2> /dev/null &
  local stdout_pid="$!"
  \tee "$stderr_bytes" "$stderr_lines" < "$stderr" >&2 2> /dev/null &
  local stderr_pid="$!"
  if \[ "${OTEL_SHELL_CONFIG_OBSERVE_PIPES_STDIN:-FALSE}" != TRUE ] || \[ "$(\readlink -f /proc/self/fd/0)" = /dev/null ] || \[ "$command_type" = builtin ] || \[ "$command_type" = 'function' ] || \[ "$command_type" = keyword ] || \[ -n "${WSL_DISTRO_NAME:-}" ]; then
    local observe_stdin=FALSE
    \echo -n '' > "$stdin_bytes"
    \echo -n '' > "$stdin_lines"
    $call_command "$@" 1> "$stdout" 2> "$stderr" || local exit_code="$?"
  else
    # this is inherently unsafe because tee will consume stdin even when command never reads from it, so killing it will eventually cause data to be lost
    # this ONLY ever works when the actual command guarantees by definiton to consume all of stdin, like simple invocations of grep
    local observe_stdin=TRUE
    local exit_code_file="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.exit_code"
    \tee "$stdin_bytes" "$stdin_lines" 2> /dev/null | {
      local inner_exit_code=0
      $call_command "$@" || local inner_exit_code="$?"
      local stdin_pid="$(\ps -o 'pid,comm' | \grep -F "tee $stdin_bytes $stdin_lines" | \grep -vF grep | \awk '{ print $1 }')"
      if \[ -n "$stdin_pid" ]; then \kill -2 "$stdin_pid" 2> /dev/null || \true; fi
      \echo -n "$inner_exit_code" > "$exit_code_file"
    } 1> "$stdout" 2> "$stderr" || \true
    local exit_code="$(\cat "$exit_code_file")"
    \rm "$exit_code_file" 2> /dev/null
  fi
  if _otel_wait_for_process_with_timeout 200 "$stdout_pid" && _otel_wait_for_process_with_timeout 100 "$stderr_pid"; then
    # similar to logs, we cannot just blindly wait, the control flow must continue when the command terminates, not when the streams close (they may be inherited to grandchildren that havent terminated yet
    # so we wait for a short moment, and then simply move on in case the streams have closed
    \wait "$stdin_bytes_pid" "$stdin_lines_pid" "$stdout_bytes_pid" "$stdout_lines_pid" "$stderr_bytes_pid" "$stderr_lines_pid" "$stdout_pid" "$stderr_pid"
    if \[ "$observe_stdin" = TRUE ]; then
      _otel_record_pipes "$span_handle" stdin 0 "$stdin_bytes_result" "$stdin_lines_result"
    fi
    _otel_record_pipes "$span_handle" stdout 1 "$stdout_bytes_result" "$stdout_lines_result"
    _otel_record_pipes "$span_handle" stderr 2 "$stderr_bytes_result" "$stderr_lines_result"
  fi
  \rm "$stdout" "$stderr" "$stdin_bytes" "$stdin_lines" "$stdout_bytes" "$stdout_lines" "$stderr_bytes" "$stderr_lines" "$stdin_bytes_result" "$stdin_lines_result" "$stdout_bytes_result" "$stdout_lines_result" "$stderr_bytes_result" "$stderr_lines_result" 2> /dev/null
  return "$exit_code"
}

_otel_record_pipes() {
     ( \[ -t "$3" ]      && otel_span_attribute_typed "$1" string pipe."$2".type=tty    ) \
  || ( \[ -p /dev/"$2" ] && otel_span_attribute_typed "$1" string pipe."$2".type=pipe   ) \
  || ( \[ -f /dev/"$2" ] && otel_span_attribute_typed "$1" string pipe."$2".type=file   ) \
  || ( \[ -c /dev/"$2" ] && otel_span_attribute_typed "$1" string pipe."$2".type=device ) \
  || ( \[ -b /dev/"$2" ] && otel_span_attribute_typed "$1" string pipe."$2".type=block  ) \
  || otel_span_attribute_typed "$1" string pipe."$2".type=unknown
  otel_span_attribute_typed "$1" int pipe."$2".bytes="$(\cat "$4")"
  otel_span_attribute_typed "$1" int pipe."$2".lines="$(\cat "$5")"
}
