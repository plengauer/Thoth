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
  local stdin_bytes_result="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stdin.bytes.result.XXXXXXXXXX)"
  local stdin_lines_result="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stdin.lines.result.XXXXXXXXXX)"
  local stdout_bytes_result="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stdout.bytes.result.XXXXXXXXXX)"
  local stdout_lines_result="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stdout.lines.result.XXXXXXXXXX)"
  local stderr_bytes_result="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stderr.bytes.result.XXXXXXXXXX)"
  local stderr_lines_result="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stderr.lines.result.XXXXXXXXXX)"
  local stdout="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stdout.pipe.XXXXXXXXXX)"
  local stderr="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stderr.pipe.XXXXXXXXXX)"
  local stdin_bytes="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stdin.bytes.pipe.XXXXXXXXXX)"
  local stdin_lines="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stdin.lines.pipe.XXXXXXXXXX)"
  local stdout_bytes="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stdout.bytes.pipe.XXXXXXXXXX)"
  local stdout_lines="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stdout.lines.pipe.XXXXXXXXXX)"
  local stderr_bytes="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stderr.bytes.pipe.XXXXXXXXXX)"
  local stderr_lines="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell.$$.stderr.lines.pipe.XXXXXXXXXX)"
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
  if \[ "$observe_stdin" = TRUE ]; then
    \wait "$stdin_bytes_pid" "$stdin_lines_pid"
    _otel_record_pipes "$span_handle" stdin 0 "$stdin_bytes_result" "$stdin_lines_result"
  fi
  if ! _otel_is_stream_open "$stdout_pid" 0; then
    \wait "$stdout_bytes_pid" "$stdout_lines_pid"
    _otel_record_pipes "$span_handle" stdout 1 "$stdout_bytes_result" "$stdout_lines_result"
  fi
  if ! _otel_is_stream_open "$stderr_pid" 0; then
    \wait "$stderr_bytes_pid" "$stderr_lines_pid"
    _otel_record_pipes "$span_handle" stderr 2 "$stderr_bytes_result" "$stderr_lines_result"
  fi
  \rm "$stdout" "$stderr" "$stdin_bytes" "$stdin_lines" "$stdout_bytes" "$stdout_lines" "$stderr_bytes" "$stderr_lines" "$stdin_bytes_result" "$stdin_lines_result" "$stdout_bytes_result" "$stdout_lines_result" "$stderr_bytes_result" "$stderr_lines_result" 2> /dev/null
  return "$exit_code"
}

if \type lsof 1> /dev/null 2> /dev/null; then
  _otel_is_stream_open() {
    \lsof -p "$1" -ad "$2" -O -b -t 2> /dev/null | \grep -qF -- "$1"
  }
elif \[ -d /proc ]; then
  # this is hacky!
  # the fd's in the proc file system are always symbolic links.
  # in our case, the fd is either pointing to a pipe, or nothing.
  # so, a quick -p check will identify whether the fd is still open or not
  \[ -p /proc/"$1"/fd/"$2" ]
else
  _otel_is_stream_open() {
    \kill -0 "$1" 1> /dev/null 2> /dev/null
  }
fi

_otel_record_pipes() {
     ( \[ -t "$3" ]      && otel_span_attribute_typed "$1" string pipe."$2".type=tty    ) \
  || ( \[ -p /dev/"$2" ] && otel_span_attribute_typed "$1" string pipe."$2".type=pipe   ) \
  || ( \[ -f /dev/"$2" ] && otel_span_attribute_typed "$1" string pipe."$2".type=file   ) \
  || ( \[ -c /dev/"$2" ] && otel_span_attribute_typed "$1" string pipe."$2".type=device ) \
  || ( \[ -b /dev/"$2" ] && otel_span_attribute_typed "$1" string pipe."$2".type=block  ) \
  || otel_span_attribute_typed "$1" string pipe."$2".type=unknown
  local bytes lines
  \read bytes < "$4"
  \read lines < "$5"
  otel_span_attribute_typed "$1" int pipe."$2".bytes="$bytes"
  otel_span_attribute_typed "$1" int pipe."$2".lines="$lines"
}
