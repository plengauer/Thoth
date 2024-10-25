#!/bin/false

_otel_call_and_record_subprocesses() {
  case "$-" in
    *m*) local job_control=1; \set +m;;
    *) local job_control=0;;
  esac
  local span_handle="$1"; shift
  local call_command="$1"; shift
  local command="$1"; shift
  local strace="$(\mktemp -u -p "$_otel_shell_pipe_dir")_opentelemetry_shell_$$.strace.pipe"
  \mkfifo "$strace"
  _otel_record_subprocesses "$span_handle" < "$strace" &
  local parse_pid="$!"
  local exit_code=0
  $call_command '\strace' -D -f -e trace=process -o "$strace" -s 8192 "${command#\\}" "$@" || local exit_code="$?"
  \wait "$parse_pid"
  \rm "$strace" 2> /dev/null
  if \[ "$job_control" = 1 ]; then \set -m; fi
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
    local pid="${line%% *}"
    \eval "local parent_pid=\$parent_pid_$pid"
    \eval "local span_handle=\$span_handle_$pid"
    \eval "local parent_span_handle=\$span_handle_$parent_pid"
    case "$operation" in
      fork)
        if \[ "${OTEL_SHELL_CONFIG_OBSERVE_SUBPROCESSES:-FALSE}" != TRUE ]; then continue; fi
        local new_pid="${line##* }"
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
        case "$line" in
          *'['*']'*)
            local name="$line"
            local name="${name%\]*}"
            local name="${name#*\[}"
            if \[ "$_otel_shell" = bash ]; then
              local name="${name//\", \"/ }"
            else
              local name="$(\printf '%s' "$name" | \sed 's/", "/ /g')"  
            fi
            local name="${name#\"}"
            local name="${name%\"}"
            ;;
          *) local name="<unknown>";;
        esac
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
        if \[ "$_otel_shell" = bash ]; then
          local name="$line"
          local name=SIG"${name#* --- SIG}"
          local name="${name%% *}"
        else
          local name="$(\printf '%s' "$line" | \awk '{ print $3 }')"
        fi
        local event_handle="$(otel_event_create "$name")"
        local kvps="$line"
        local kvps="${kvps%\}*}"
        local kvps="${kvps#*\{}"
        if \[ "$_otel_shell" = bash ]; then
          local kvps="${kvps// /}"
          local kvps="${kvps//_/.}"
          local kvps="${kvps//,/
}"
          \printf '%s' "$kvps"
        else
          \printf '%s' "$kvps" | \tr -d ' ' | \tr '_' '.' | \tr ',' '\n'
        fi | while read -r kvp; do otel_event_attribute "$event_handle" "$kvp"; done
        otel_event_add "$event_handle" "${span_handle:-$root_span_handle}"
        ;;
      *) ;;
    esac
  done
}
