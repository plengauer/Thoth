#!/bin/false
##################################################################################################
# This file is providing an API for creating and managing open telemetry spans.                  #
# It should be sourced at the very top of any shell script where the functions are to be used.   #
# All variables are for internal use only and therefore subject to change without notice!        #
##################################################################################################

# translate legacy config
if \[ -n "$OTEL_SHELL_TRACES_ENABLE" ] || \[ -n "$OTEL_SHELL_METRICS_ENABLE" ] || \[ -n "$OTEL_SHELL_LOGS_ENABLE" ]; then
  \[ "$OTEL_SHELL_TRACES_ENABLE" = TRUE ] && export OTEL_TRACES_EXPORTER=otlp || export OTEL_TRACES_EXPORTER=""
  \[ "$OTEL_SHELL_METRICS_ENABLE" = TRUE ] && export OTEL_METRICS_EXPORTER=otlp || export OTEL_METRICS_EXPORTER=""
  \[ "$OTEL_SHELL_LOGS_ENABLE" = TRUE ] && export OTEL_LOGS_EXPORTER=otlp || export OTEL_LOGS_EXPORTER=""
  export OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE=delta
fi
export OTEL_SHELL_CONFIG_OBSERVE_PIPES="${OTEL_SHELL_CONFIG_OBSERVE_PIPES:-${OTEL_SHELL_EXPERIMENTAL_OBSERVE_PIPES:-FALSE}}"

# basic setup
_otel_remote_sdk_pipe="${OTEL_REMOTE_SDK_PIPE:-$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.pipe}"
if \[ -z "$TMPDIR" ]; then TMPDIR=/tmp; fi
_otel_shell_pipe_dir="${OTEL_SHELL_PIPE_DIR:-$TMPDIR}"
_otel_shell="$(\readlink "/proc/$$/exe" | \rev | \cut -d / -f 1 | \rev)"
if \[ "$_otel_shell" = busybox ]; then _otel_shell="busybox sh"; fi
if \[ "$OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE" = 0 ] || \[ "$OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE" = "$PPID" ] || \[ "$PPID" = 0 ] || \[ "$(\tr '\000-\037' ' ' < /proc/$PPID/cmdline)" = "$(\tr '\000-\037' ' ' < /proc/$OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE/cmdline)" ]; then _otel_commandline_override="$OTEL_SHELL_COMMANDLINE_OVERRIDE"; fi
unset OTEL_SHELL_COMMANDLINE_OVERRIDE
unset OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE
unset OTEL_SHELL_COMMAND_TYPE_OVERRIDE
unset OTEL_SHELL_SPAN_KIND_OVERRIDE

if \[ -p "$_otel_remote_sdk_pipe" ]; then
  otel_init() {
    _otel_mkfifo_flags=--mode=666
    \exec 7> "$_otel_remote_sdk_pipe"
  }

  otel_shutdown() {
    \exec 7>&-
  }
else
  otel_init() {
    if \[ -e /dev/stderr ] && \[ -e "$(\readlink -f /dev/stderr)" ]; then local sdk_output="$(\readlink /dev/stderr)"; else local sdk_output=/dev/null; fi
    local sdk_output="${OTEL_SHELL_SDK_OUTPUT_REDIRECT:-$sdk_output}"
    \mkfifo "$_otel_remote_sdk_pipe"
    _otel_package_version opentelemetry-shell > /dev/null # to build the cache outside a subshell
    _otel_package_version "$_otel_shell" > /dev/null
    # several weird things going on in the next line, (1) using '((' fucks up the syntax highlighting in github while '( (' does not, and (2) &> causes weird buffering / late flushing behavior
    if \env --help 2>&1 | \grep -q 'ignore-signal'; then local extra_env_flags='--ignore-signal=INT --ignore-signal=HUP'; fi
    ( (\env $extra_env_flags otelsdk "shell" "$(_otel_package_version opentelemetry-shell)" < "$_otel_remote_sdk_pipe" 1> "$sdk_output" 2> "$sdk_output") &)
    \exec 7> "$_otel_remote_sdk_pipe"
    _otel_resource_attributes
    _otel_sdk_communicate "INIT"
  }

  otel_shutdown() {
    _otel_sdk_communicate "SHUTDOWN"
    \exec 7>&-
    \rm "$_otel_remote_sdk_pipe"
  }
fi

_otel_sdk_communicate() {
  if _otel_string_contains "$*" "
"; then
    _otel_sdk_communicate "$(\echo "$@" | \tr '\n' ' ')"
  else
    \echo "$@" >&7
  fi
}

_otel_resource_attributes() {
  _otel_resource_attribute string telemetry.sdk.name=opentelemetry
  _otel_resource_attribute string telemetry.sdk.language=shell
  _otel_resource_attribute string telemetry.sdk.version="$(_otel_package_version opentelemetry-shell)"

  local process_command="$(_otel_command_self)"
  local process_executable_path="$(\readlink -f "/proc/$$/exe")"
  local process_executable_name="${process_executable_path##*/}" # "$(\printf '%s' "$process_executable_path" | \rev | \cut -d / -f 1 | \rev)"
  _otel_resource_attribute int process.pid="$$"
  _otel_resource_attribute int process.parent_pid="$PPID"
  _otel_resource_attribute string process.executable.name="$process_executable_name"
  _otel_resource_attribute string process.executable.path="$process_executable_path"
  _otel_resource_attribute string process.command_line="$process_command"
  _otel_resource_attribute string process.command="${process_command%% *}" # "$(\printf '%s' "$process_command" | \cut -d ' ' -f 1)"
  _otel_resource_attribute string process.owner="$USER"
  _otel_resource_attribute string process.runtime.name="$_otel_shell"
  case "$_otel_shell" in
       sh) _otel_resource_attribute string process.runtime.description="Bourne Shell" ;;
      ash) _otel_resource_attribute string process.runtime.description="Almquist Shell" ;;
     dash) _otel_resource_attribute string process.runtime.description="Debian Almquist Shell" ;;
     bash) _otel_resource_attribute string process.runtime.description="Bourne Again Shell" ;;
      zsh) _otel_resource_attribute string process.runtime.description="Z Shell" ;;
      ksh) _otel_resource_attribute string process.runtime.description="Korn Shell" ;;
    pdksh) _otel_resource_attribute string process.runtime.description="Public Domain Korn Shell" ;;
     posh) _otel_resource_attribute string process.runtime.description="Policy-compliant Ordinary Shell" ;;
     yash) _otel_resource_attribute string process.runtime.description="Yet Another Shell" ;;
     bosh) _otel_resource_attribute string process.runtime.description="Bourne Shell" ;;
     fish) _otel_resource_attribute string process.runtime.description="Friendly Interactive Shell" ;;
     'busybox sh') _otel_resource_attribute string process.runtime.description="Busy Box" ;;
  esac
  _otel_resource_attribute string process.runtime.version="$(_otel_package_version "$process_executable_name")"
  _otel_resource_attribute string process.runtime.options="$-"

  _otel_resource_attribute string service.name="${OTEL_SERVICE_NAME:-unknown_service}"
  _otel_resource_attribute string service.version="$OTEL_SERVICE_VERSION"
  _otel_resource_attribute string service.namespace="$OTEL_SERVICE_NAMESPACE"
  _otel_resource_attribute string service.instance.id="$OTEL_SERVICE_INSTANCE_ID"
}

_otel_resource_attribute() {
  _otel_sdk_communicate RESOURCE_ATTRIBUTE "$@"
}

_otel_command_self() {
  if \[ -n "$_otel_commandline_override" ]; then
    \echo "$_otel_commandline_override" | \tr '\000-\037' ' '
  else
    _otel_resolve_command_self
  fi
}

_otel_resolve_command_self() {
  \tr '\000-\037' ' ' < "/proc/$$/cmdline"
}

if \[ "$_otel_shell" = bash ]; then
  _otel_package_version() {
    # dpkg is very expensive, lets cache and be a bit less exact in case packages get updated why children are spawned!
    local package_name="$1"
    local varname="OTEL_SHELL_PACKAGE_VERSION_CACHE_$package_name"
    local varname="${varname//-/_}"
    if \[ -n "${!varname}" ]; then \echo "${!varname}"; return 0; fi
    \export "$varname=$(_otel_resolve_package_version "$1")"
    \echo "${!varname}"
  }
else
  _otel_package_version() {
    _otel_resolve_package_version "$1"
  }
fi

_otel_resolve_package_version() {
  \dpkg -s "$1" 2> /dev/null | \grep '^Version: ' | \cut -d ' ' -f 2
}

otel_span_current() {
  local response_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.span_handle.pipe"
  \mkfifo $_otel_mkfifo_flags "$response_pipe"
  _otel_sdk_communicate "SPAN_HANDLE" "$response_pipe" "$TRACEPARENT"
  \cat "$response_pipe"
  \rm "$response_pipe" 1> /dev/null 2> /dev/null
}

otel_span_start() {
  local kind="$1"
  local name="$2"
  local response_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.span_handle.pipe"
  \mkfifo $_otel_mkfifo_flags "$response_pipe"
  _otel_sdk_communicate "SPAN_START" "$response_pipe" "$TRACEPARENT" "$TRACESTATE" "$kind" "$name"
  \cat "$response_pipe"
  \rm "$response_pipe" 1> /dev/null 2> /dev/null
}

otel_span_end() {
  local span_handle="$1"
  _otel_sdk_communicate "SPAN_END" "$span_handle"
}

otel_span_name() {
  local span_handle="$1"
  local span_name="$2"
  _otel_sdk_communicate "SPAN_NAME" "$span_handle" "$span_name"
}

otel_span_error() {
  local span_handle="$1"
  _otel_sdk_communicate "SPAN_ERROR" "$span_handle"
}

otel_span_attribute() {
  local span_handle="$1"
  local kvp="$2"
  otel_span_attribute_typed "$span_handle" auto "$kvp"
}

otel_span_attribute_typed() {
  local span_handle="$1"
  local type="$2"
  local kvp="$3"
  _otel_sdk_communicate "SPAN_ATTRIBUTE" "$span_handle" "$type" "$kvp"
}

otel_span_traceparent() {
  local span_handle="$1"
  local response_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.traceparent.pipe"
  \mkfifo $_otel_mkfifo_flags "$response_pipe"
  _otel_sdk_communicate "SPAN_TRACEPARENT" "$response_pipe" "$span_handle"
  \cat "$response_pipe"
  \rm "$response_pipe" 1> /dev/null 2> /dev/null
}

otel_span_activate() {
  local span_handle="$1"
  export TRACEPARENT_STACK="$TRACEPARENT/$TRACEPARENT_STACK"
  export TRACEPARENT="$(otel_span_traceparent "$span_handle")"
  if \[ -z "$TRACESTATE" ]; then export TRACESTATE=""; fi
}

otel_span_deactivate() {
  if _otel_string_contains "$TRACEPARENT_STACK" /; then
    export TRACEPARENT="${TRACEPARENT_STACK%%/*}"
    export TRACEPARENT_STACK="${TRACEPARENT_STACK#*/}"
  else
    export TRACEPARENT="$TRACEPARENT_STACK"
    export TRACEPARENT_STACK=""
  fi
  if \[ -z "$TRACEPARENT" ]; then
    unset TRACEPARENT_STACK
    unset TRACEPARENT
    unset TRACESTATE
  fi
}

otel_event_create() {
  local event_name="$1"
  local response_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.event_handle.pipe"
  \mkfifo $_otel_mkfifo_flags "$response_pipe"
  _otel_sdk_communicate "EVENT_CREATE" "$response_pipe" "$event_name"
  \cat "$response_pipe"
  \rm "$response_pipe" 1> /dev/null 2> /dev/null
}

otel_event_attribute() {
  local event_handle="$1"
  local kvp="$2"
  otel_event_attribute_typed "$event_handle" auto "$kvp"
}

otel_event_attribute_typed() {
  local event_handle="$1"
  local type="$2"
  local kvp="$3"
  _otel_sdk_communicate "EVENT_ATTRIBUTE" "$event_handle" "$type" "$kvp"
}

otel_event_add() {
  local event_handle="$1"
  local span_handle="$2"
  _otel_sdk_communicate "EVENT_ADD" "$event_handle" "$span_handle"
}

otel_link_create() {
  local traceparent="$1"
  local tracestate="$2"
  local response_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.link_handle.pipe"
  \mkfifo $_otel_mkfifo_flags "$response_pipe"
  _otel_sdk_communicate "LINK_CREATE" "$response_pipe" "$traceparent" "$tracestate" END
  \cat "$response_pipe"
  \rm "$response_pipe" 1> /dev/null 2> /dev/null
}

otel_link_attribute() {
  local link_handle="$1"
  local kvp="$2"
  otel_link_attribute_typed "$link_handle" auto "$kvp"
}

otel_link_attribute_typed() {
  local link_handle="$1"
  local type="$2"
  local kvp="$3"
  _otel_sdk_communicate "LINK_ATTRIBUTE" "$link_handle" "$type" "$kvp"
}

otel_link_add() {
  local link_handle="$1"
  local span_handle="$2"
  _otel_sdk_communicate "LINK_ADD" "$link_handle" "$span_handle"
}

otel_metric_create() {
  local metric_name="$1"
  local response_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.metric_handle.pipe"
  \mkfifo $_otel_mkfifo_flags "$response_pipe"
  _otel_sdk_communicate "METRIC_CREATE" "$response_pipe" "$metric_name"
  \cat "$response_pipe"
  \rm "$response_pipe" 1> /dev/null 2> /dev/null
}

otel_metric_attribute() {
  local metric_handle="$1"
  local kvp="$2"
  otel_metric_attribute_typed "$metric_handle" auto "$kvp"
}

otel_metric_attribute_typed() {
  local metric_handle="$1"
  local type="$2"
  local kvp="$3"
  _otel_sdk_communicate "METRIC_ATTRIBUTE" "$metric_handle" "$type" "$kvp"
}

otel_metric_add() {
  local metric_handle="$1"
  local value="$2"
  _otel_sdk_communicate "METRIC_ADD" "$metric_handle" "$value"
}

otel_observe() {
  local IFS=' 
'
  # validate and clean arguments
  local dollar_star="$(_otel_dollar_star "$@")"
  local command="$dollar_star"
  while _otel_string_starts_with "$command" "_otel_"; do local command="${command#* }"; done
  local command="${command#\\}"
  local kind="${OTEL_SHELL_SPAN_KIND_OVERRIDE:-INTERNAL}"
  local attributes="$OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE"
  local command_type="$OTEL_SHELL_COMMAND_TYPE_OVERRIDE"
  unset OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE
  unset OTEL_SHELL_COMMAND_TYPE_OVERRIDE
  
  # create span, set initial attributes
  local span_handle="$(otel_span_start "$kind" "$command")"
  otel_span_attribute_typed "$span_handle" string shell.command_line="$command"
  if _otel_string_contains "$command" " "; then local command_name="${command%% *}"; else  local command_name="$command"; fi # "$(\printf '%s' "$command" | \cut -sd ' ' -f 2-)" # this returns the command if there are no args, its the cut -s that cant be done via expansion alone
  if \[ -z "$command_type" ]; then local command_type="$(_otel_command_type "$command_name")"; fi
  otel_span_attribute_typed "$span_handle" string shell.command="$command_name"
  otel_span_attribute_typed "$span_handle" string shell.command.type="$command_type"
  if _otel_string_contains "$command_name" /; then
    otel_span_attribute_typed "$span_handle" string shell.command.name=""${command_name##*/}""
  else
    otel_span_attribute_typed "$span_handle" string shell.command.name="$command_name"
  fi
  if \[ "$command_type" = file ]; then
    local executable_path="$(_otel_string_contains "$command_name" / && \echo "$command_name" || \which "$command_name")"
    otel_span_attribute_typed "$span_handle" string subprocess.executable.path="$executable_path"
    otel_span_attribute_typed "$span_handle" string subprocess.executable.name="${executable_path##*/}" # "$(\printf '%s' "$command" | \cut -d' ' -f1 | \rev | \cut -d / -f 1 | \rev)"
  fi
  
  # run command
  otel_span_activate "$span_handle"
  local exit_code=0
  local call_command=_otel_call
  if \[ "${OTEL_SHELL_CONFIG_OBSERVE_SUBPROCESSES:-FALSE}" = TRUE ] || \[ "${OTEL_SHELL_CONFIG_OBSERVE_SIGNALS:-FALSE}" = TRUE ]; then if ! _otel_string_starts_with "$1" _otel_ && \type strace 1> /dev/null 2> /dev/null; then local call_command="_otel_call_and_record_subprocesses $span_handle $call_command"; fi; fi
  if ! \[ -t 2 ] && ! _otel_string_contains "$-" x; then local call_command="_otel_call_and_record_logs $call_command"; fi
  if ! \[ -t 0 ] && ! \[ -t 1 ] && ! \[ -t 2 ] && ! _otel_string_contains "$-" x && \[ "$OTEL_SHELL_CONFIG_OBSERVE_PIPES" = TRUE ]; then local call_command="_otel_call_and_record_pipes $span_handle $command_type $call_command"; fi
  $call_command "$@" || local exit_code="$?"
  otel_span_deactivate "$span_handle"
  
  # set custom attributes, set final attributes, finish span
  otel_span_attribute_typed "$span_handle" int shell.command.exit_code="$exit_code"
  if \[ "$exit_code" -ne 0 ]; then
    otel_span_error "$span_handle"
  fi
  if \[ -n "$attributes" ]; then
    local OLD_IFS="$IFS"
    local IFS=','
    set -- $attributes
    IFS="$OLD_IFS"
    for attribute in "$@"; do
      if \[ -n "$attribute" ]; then
        otel_span_attribute "$span_handle" "$attribute"
      fi
    done
  fi
  otel_span_end "$span_handle"
  
  return "$exit_code"
}

if \[ "$_otel_shell" = dash ] || \[ "$_otel_shell" = 'busybox sh' ]; then # TODO its only old dashes
  # old versions of dash dont set env vars properly
  # more specifically they do not make variables that are set in front of commands part of the child process env vars but only of the local execution environment
  _otel_call() {
    local command="$1"; shift
    if ! _otel_string_starts_with "$command" "\\"; then local command="$(_otel_escape_arg "$command")"; fi
    \eval "$( { \printenv; \set; } | \grep '^OTEL_' | \cut -d = -f 1 | \sort -u | \awk '{ print $1 "=\"$" $1 "\"" }' | _otel_line_join)" "$command" "$(_otel_escape_args "$@")"
  }
else
  _otel_call() {
    local command="$1"; shift
    if ! _otel_string_starts_with "$command" "\\"; then local command="$(_otel_escape_arg "$command")"; fi
    \eval "$command" "$(_otel_escape_args "$@")"
  }
fi

_otel_call_and_record_logs() {
  local IFS=' 
'
  case "$-" in
    *m*) local job_control=1; \set +m;;
    *) local job_control=0;;
  esac
  local call_command="$1"; shift
  local traceparent="$TRACEPARENT"
  local stderr_logs="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.stderr.logs.pipe"
  \mkfifo $_otel_mkfifo_flags "$stderr_logs"
  while IFS= read -r line; do _otel_log_record "$traceparent" "$line"; \echo "$line" >&2; done < "$stderr_logs" &
  local stderr_pid="$!"
  local exit_code=0
  $call_command "$@" 2> "$stderr_logs" || local exit_code="$?"
  \wait "$stderr_pid"
  \rm "$stderr_logs" 2> /dev/null
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}

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
  if \[ "$OTEL_SHELL_CONFIG_OBSERVE_PIPES_STDIN" != TRUE ] || \[ "$(\readlink -f /proc/self/fd/0)" = /dev/null ] || \[ "$command_type" = builtin ] || \[ "$command_type" = 'function' ] || \[ "$command_type" = keyword ]; then
    local observe_stdin=FALSE
    \echo -n '' > "$stdin_bytes"
    \echo -n '' > "$stdin_lines"
    $call_command "$@" 1> "$stdout" 2> "$stderr" || local exit_code="$?"
  else
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

_otel_call_and_record_subprocesses() {
  local span_handle="$1"; shift
  local call_command="$1"; shift
  local command="$1"; shift
  local strace="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.strace.pipe"
  \mkfifo "$strace"
  _otel_record_subprocesses "$span_handle" < "$strace" &
  local parse_pid="$!"
  local exit_code=0
  $call_command \strace -f -e trace=process -o "$strace" -s 8192 "${command#\\}" "$@" || local exit_code="$?"
  \wait "$parse_pid"
  \rm "$strace" 2> /dev/null
  return "$exit_code"
}

# 582398 execve("/usr/bin/apt-get", ["apt-get", "update"], 0x7fff13614290 /* 35 vars */) = 0
# 582398 clone(child_stack=NULL, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0x7ae277075b50) = 582399
# 582399 execve("/usr/bin/dpkg", ["/usr/bin/dpkg", "--print-foreign-architectures"], 0x7fff7b7e0180 /* 35 vars */) = 0
# 582399 exit_group(0)                    = ?
# 582399 +++ exited with 0 +++
# 582398 --- SIGCHLD {si_signo=SIGCHLD, si_code=CLD_EXITED, si_pid=582399, si_uid=0, si_status=0, si_utime=0, si_stime=0} ---
# 582398 wait4(582399, [{WIFEXITED(s) && WEXITSTATUS(s) == 0}], 0, NULL) = 582399
# 582398 clone(child_stack=NULL, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0x7ae277075b50) = 582400
# 582400 execve("/usr/lib/apt/methods/http", ["/usr/lib/apt/methods/http"], 0x7fff7b7e0180 /* 35 vars */) = 0
# 582398 kill(582400, SIGINT)             = 0
# 582400 --- SIGINT {si_signo=SIGINT, si_code=SI_USER, si_pid=582398, si_uid=0} ---
# 582398 wait4(582400,  <unfinished ...>
# 582400 +++ killed by SIGINT +++
_otel_record_subprocesses() {
  local root_span_handle="$1"
  while read -r line; do
    local operation=""
    case "$line" in
      *' '*' (To be restarted)') ;;
      *' clone'*'('*' <unfinished ...>') ;;
      *' '*'fork('*' <unfinished ...>') ;;
      *' clone'*'('*) local operation=fork;;
      *' '*'fork('*) local operation=fork;;
      *' <... clone'*' resumed>'*) local operation=fork;;
      *' <... '*'fork resumed>'*) local operation=fork;;
      *' execve('*) local operation=exec;;
      *' +++ '*) local operation=exit;;
      *' --- '*) local operation=signal;;
      *) ;;
    esac
    local pid="$(\printf '%s' "$line" | \cut -d ' ' -f 1)"
    \eval "local parent_pid=\$parent_pid_$pid"
    \eval "local span_handle=\$span_handle_$pid"
    \eval "local parent_span_handle=\$span_handle_$parent_pid"
    case "$operation" in
      fork)
        if \[ "${OTEL_SHELL_CONFIG_OBSERVE_SUBPROCESSES:-FALSE}" != TRUE ]; then continue; fi
        local new_pid="$(\printf '%s' "$line" | \rev | \cut -d ' ' -f 1 | \rev)";
        \eval "local parent_pid_$new_pid=$pid"
        \eval "local span_name=\"\$span_name_$new_pid\""
        if \[ -z "${span_name:-}" ]; then \eval "local span_name=\"\$span_name_$pid\""; fi
        if \[ -z "${span_name:-}" ]; then \eval "local span_name=\"\$span_name_$parent_pid\""; fi
        local span_name="${span_name:-<unknown>}"
        otel_span_activate "${parent_span_handle:-$root_span_handle}"
        local span_handle="$(otel_span_start INTERNAL "$span_name")"
        otel_span_deactivate
        \eval "local span_handle_$new_pid=$span_handle"
        \eval "local span_name_$new_pid=\"\$span_name\""
        # TODO immediately end span if stored due to very fast exit (faster than the fork syscall of the parent can actually be finished) 
        ;;
      exec)
        local name="$(\printf '%s' "$line" | \cut -sd '[' -f 2- | \rev | \cut -sd ']' -f 2- | \rev | \sed 's/", "/ /g')"
        local name="${name#\"}"
        local name="${name%\"}"
        local name="${name:-<unknown>}"
        \eval "local span_name_$pid=\"\$name\""
        if \[ -n "${span_handle:-}" ]; then
          otel_span_name "$span_handle" "$name"
        fi
        ;;
      exit)
        if \[ -z "${span_handle:-}" ]; then continue; fi
        if _otel_string_contains "$line" " +++ killed by " || (_otel_string_contains "$line" " +++ exited with " && ! _otel_string_contains "$line" " +++ exited with 0 +++"); then
          otel_span_error "$span_handle"
        fi
        otel_span_end "$span_handle"
        ;;
      signal)
        if \[ "${OTEL_SHELL_CONFIG_OBSERVE_SIGNALS:-FALSE}" != TRUE ]; then continue; fi
        local event_handle="$(otel_event_create "$(\printf '%s' "$line" | \awk '{ print $3 }')")"
        \printf '%s' "$line" | \cut -d '{' -f 2- | \rev | \cut -d '}' -f 2- | \rev | \tr ',' '\n' | \tr -d ' ' | \tr '_' '.' | while read -r kvp; do otel_event_attribute "$event_handle" "$kvp"; done
        otel_event_add "$event_handle" "${span_handle:-$root_span_handle}"
        ;;
      *) ;;
    esac
  done
}

if \[ "$_otel_shell" = bash ]; then
  _otel_command_type() {
    \type -t "$1" || \echo file
  }
else
  _otel_command_type() {
    case "$(\type "$1")" in
      "$1 is a shell keyword") \echo keyword;;
      "$1 is a shell alias for "*) \echo alias;;
      "$1 is an alias for "*) \echo alias;;
      "$1 is a shell function") \echo 'function';;
      "$1 is a function") \echo 'function';;
      "$1 is a shell builtin") \echo builtin;;
      "$1 is $1") \echo file;;
      *) \echo file;;
    esac
  }
fi

_otel_log_record() {
  local traceparent="$1"
  shift
  local line="$(_otel_dollar_star "$@")"
  _otel_sdk_communicate "LOG_RECORD" "$traceparent" "$line"
}

_otel_escape_stdin() {
  local first=1
  while IFS= read -r line; do
    if \[ "$first" = 1 ]; then local first=0; else \echo -n " "; fi
    _otel_escape_arg "$line"
  done
}

_otel_escape_args() {
  # for arg in "$@"; do \echo "$arg"; done | _otel_escape_in # this may seem correct, but it doesnt handle linefeeds in arguments correctly
  local first=1
  for arg in "$@"; do
    if \[ "$first" = 1 ]; then local first=0; else \echo -n " "; fi
    _otel_escape_arg "$arg"
  done
}

_otel_escape_arg() {
   # that SO article shows why this is extra fun! https://stackoverflow.com/questions/16991270/newlines-at-the-end-get-removed-in-shell-scripts-why
  local do_escape=0
  if \[ -z "$1" ]; then
    local do_escape=1
  elif \[ "$1X" != "$(\echo "$1")"X ]; then # fancy check for "contains linefeed"
    local do_escape=1
  else
    case "$1X" in
      *[[:space:]\&\<\>\|\'\"\(\)\`!\$\;\\\*]*) local do_escape=1 ;;
      *) local do_escape=0 ;;
    esac
  fi
  if \[ "$do_escape" = 1 ]; then
    if \[ "$no_quote" = 1 ]; then local format_string='%s'; else local format_string="'%s'"; fi
    _otel_escape_arg_format "$format_string" "$1"
  else
    \printf '%s' "$1"
  fi
}

if \[ "$_otel_shell" = bash ]; then
  _otel_escape_arg_format() {
    \printf "$1" "${2//\'/\'\\\'\'}"
  }
else
  _otel_escape_arg_format() {
    local escaped="$(\printf '%s' "$2X" | \sed "s/'/'\\\\''/g")" # need the extra X to preserve trailing linefeeds (yay)
    \printf "$1" "${escaped%X}"
  }
fi

_otel_line_join() {
  \sed '/^$/d' | \tr '\n' ' ' | \sed 's/ $//'
}

_otel_line_split() {
  \tr ' ' '\n'
}

# this is functionally equivalent with "$*" but does not require IFS to be set properly
_otel_dollar_star() {
  # \echo "$*" # dont do this because it uses the IFS which may not be set properly (and we dont wanna reset and cause a sideeffect, especially because we would have to set empty and unset state of IFS properly)
  # \echo "$@" # dont do this because it starts interpreting backslashes
  local IFS=' '
  \printf '%s' "$*"
}

_otel_string_contains() {
  case "$1" in
    *"$2"*) return 0;;
    *) return 1;;
  esac
}

_otel_string_starts_with() {
  case "$1" in
    "$2"*) return 0;;
    *) return 1;;
  esac
}

_otel_string_ends_with() {
  case "$1" in
    *"$2") return 0;;
    *) return 1;;
  esac
}
