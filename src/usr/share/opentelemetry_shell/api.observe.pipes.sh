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
  case "$-" in
    *m*) local job_control=1; \set +m;;
    *) local job_control=0;;
  esac
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
  if \[ "$OTEL_SHELL_CONFIG_OBSERVE_PIPES_STDIN" != TRUE ] || \[ "$(\readlink -f /proc/self/fd/0)" = /dev/null ] || \[ "$command_type" = builtin ] || \[ "$command_type" = 'function' ] || \[ "$command_type" = keyword ] || \[ -n "${WSL_DISTRO_NAME:-}" ]; then
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
      local stdin_pid="$(\ps -o 'pid,command' | \grep -F "tee $stdin_bytes $stdin_lines" | \grep -vF grep | \awk '{ print $1 }')"
      if \[ -n "$stdin_pid" ]; then \kill -2 "$stdin_pid" 2> /dev/null || \true; fi
      \echo -n "$inner_exit_code" > "$exit_code_file"
    } 1> "$stdout" 2> "$stderr" || \true
    local exit_code="$(\cat "$exit_code_file")"
    \rm "$exit_code_file" 2> /dev/null
  fi
  \wait "$stdin_bytes_pid" "$stdin_lines_pid" "$stdout_bytes_pid" "$stdout_lines_pid" "$stderr_bytes_pid" "$stderr_lines_pid" "$stdout_pid" "$stderr_pid"
  \rm "$stdout" "$stderr" "$stdin_bytes" "$stdin_lines" "$stdout_bytes" "$stdout_lines" "$stderr_bytes" "$stderr_lines" 2> /dev/null
  if \[ "$observe_stdin" = TRUE ]; then
    otel_span_attribute_typed "$span_handle" int pipe.stdin.bytes="$(\cat "$stdin_bytes_result")"
    otel_span_attribute_typed "$span_handle" int pipe.stdin.lines="$(\cat "$stdin_lines_result")"
  fi
  otel_span_attribute_typed "$span_handle" int pipe.stdout.bytes="$(\cat "$stdout_bytes_result")"
  otel_span_attribute_typed "$span_handle" int pipe.stdout.lines="$(\cat "$stdout_lines_result")"
  otel_span_attribute_typed "$span_handle" int pipe.stderr.bytes="$(\cat "$stderr_bytes_result")"
  otel_span_attribute_typed "$span_handle" int pipe.stderr.lines="$(\cat "$stderr_lines_result")"
  \rm "$stdin_bytes_result" "$stdin_lines_result" "$stdout_bytes_result" "$stdout_lines_result" "$stderr_bytes_result" "$stderr_lines_result" 2> /dev/null
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}
