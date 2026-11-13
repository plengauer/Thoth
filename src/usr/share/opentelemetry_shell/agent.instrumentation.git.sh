#!/bin/false
# shellcheck shell=bash

# git submodule [--quiet] foreach [--recursive] <command>

_otel_inject_git_arguments() {
  local IFS=' 
'
  local executable="$1"
  _otel_escape_arg "$1"
  shift
  local inject=1
  if \[ "$inject" = 1 ]; then
    if \[ "$1" = submodule ]; then
      \echo -n ' '
      _otel_escape_arg "$1"
      shift
    else local inject=0; fi
  fi
  if \[ "$inject" = 1 ]; then
    if \[ "$1" = --quiet ]; then
      \echo -n ' '
      _otel_escape_arg "$1"
      shift
    fi
    if \[ "$1" = foreach ]; then
      \echo -n ' '
      _otel_escape_arg "$1"
      shift
    else local inject=0; fi
  fi
  if \[ "$inject" = 1 ]; then
    if \[ "$1" = --recursive ]; then
      \echo -n ' '
      _otel_escape_arg "$1"
      shift
    fi
  fi
  if \[ "$inject" = 1 ]; then
    \echo -n ' '
    # shellcheck disable=SC2086 # the shell may be a command with arguments such as busybox sh and must be split into words
    _otel_escape_args $_otel_shell -c '. otel.sh
'"$1" "$executable"
    shift
  fi
  while \[ "$#" -gt 0 ]; do
    \echo -n ' '
    _otel_escape_arg "$1"
    shift
  done
}

_otel_inject_git() {
  case "$-" in
    *m*)
      local job_control=1
      \set +m
      ;;
    *) local job_control=0 ;;
  esac
  local cmdline="$(_otel_dollar_star "$@")"
  local cmdline="${cmdline#\\}"
  if \[ -z "${GIT_TRACE_CURL:-}" ]; then
    local trace_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.trace.git.pipe.XXXXXXXXXX)"
    \mkfifo "$trace_pipe"
    _otel_pipe_git_trace "$trace_pipe" <>"$trace_pipe" &
    local trace_pid="$!"
    export GIT_TRACE_CURL="$trace_pipe"
    export GIT_TRACE_CURL_NO_DATA=1
  fi
  local ssh_command="${GIT_SSH_COMMAND:-$(\git config core.sshCommand 2>/dev/null || true)}"
  case "$1:${ssh_command:-ssh}" in
    -c* | -C*) local ssh_assignment="" ;; # the ssh command may be overridden for this invocation only, which we cannot see
    *:ssh | *:'ssh '*) local ssh_assignment="GIT_SSH_COMMAND=$(_otel_escape_arg "otel4sh ${ssh_command:-ssh}")" ;;
    *) local ssh_assignment="" ;;
  esac
  local exit_code=0
  \eval OTEL_SHELL_COMMANDLINE_OVERRIDE="$(_otel_escape_arg "$cmdline")" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE=0 OTEL_SHELL_AUTO_INJECTED=TRUE $ssh_assignment _otel_call "$(_otel_inject_git_arguments "$@")" || exit_code="$?"
  if \[ -n "${trace_pid:-}" ]; then
    unset GIT_TRACE_CURL
    unset GIT_TRACE_CURL_NO_DATA
    \echo "$trace_pipe" >"$trace_pipe"
    \wait "$trace_pid" || true
    \rm -f "$trace_pipe"
  fi
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}

_otel_pipe_git_trace() {
  local sentinel="$1"
  local span_handle=""
  local host=""
  local ip=""
  local port=""
  local scheme=http
  while \read -r line; do
    if \[ "$line" = "$sentinel" ]; then break; fi
    case "$line" in
      *'== Info: Connected to '* | *'== Info: Established connection to '* | *'== Info: Closing connection'* | *'== Info: closing connection'* | *'== Info: shutting down connection'* | *'== Info: Connection #'*' left intact')
        if \[ -n "$span_handle" ]; then
          otel_span_end "$span_handle"
          local span_handle=""
        fi
        ;;
    esac
    case "$line" in
      *'== Info: Connected to '*)
        local rest="${line#*'== Info: Connected to '}"
        local host="${rest%% *}"
        local rest="${rest#* (}"
        local ip="${rest%%)*}"
        local port="${rest#*) port }"
        local port="${port%% *}"
        local scheme=http
        ;;
      *'== Info: Established connection to '*)
        local rest="${line#*'== Info: Established connection to '}"
        local host="${rest%% *}"
        local rest="${rest#* (}"
        local ip="${rest%% *}"
        local port="${rest#* port }"
        local port="${port%%)*}"
        local scheme=http
        ;;
      *'== Info: Establish HTTP proxy tunnel to '*)
        local rest="${line#*'== Info: Establish HTTP proxy tunnel to '}"
        local host="${rest%:*}"
        local port="${rest##*:}"
        local ip=""
        ;;
      *'== Info: SSL connection using '*) local scheme=https ;;
      *'=> Send header:'*)
        local message="${line#*'=> Send header:'}"
        local message="${message# }"
        local method="${message%% *}"
        case "$method" in
          '' | CONNECT) ;;
          [Uu]ser-[Aa]gent:)
            if \[ -n "$span_handle" ]; then otel_span_attribute_typed "$span_handle" string user_agent.original="${message#* }"; fi
            ;;
          *:) ;;
          *)
            if \[ -n "$span_handle" ]; then otel_span_end "$span_handle"; fi
            local target="${message#* }"
            local target="${target%% *}"
            local url_path="${target%%\?*}"
            local query="${target#"$url_path"}"
            local query="${query#\?}"
            local span_handle="$(otel_span_start CLIENT "$method")"
            otel_span_attribute_typed "$span_handle" string network.transport=tcp
            otel_span_attribute_typed "$span_handle" string network.protocol.name=http
            otel_span_attribute_typed "$span_handle" string network.protocol.version="${message##*HTTP/}"
            otel_span_attribute_typed "$span_handle" string server.address="$host"
            otel_span_attribute_typed "$span_handle" int server.port="$port"
            if \[ -n "$ip" ]; then
              otel_span_attribute_typed "$span_handle" string network.peer.address="$ip"
              otel_span_attribute_typed "$span_handle" int network.peer.port="$port"
            fi
            otel_span_attribute_typed "$span_handle" string url.full="$scheme://$host:$port$target"
            otel_span_attribute_typed "$span_handle" string url.path="$url_path"
            otel_span_attribute_typed "$span_handle" string url.query="$query"
            otel_span_attribute_typed "$span_handle" string url.scheme="$scheme"
            otel_span_attribute_typed "$span_handle" string http.request.method="$method"
            ;;
        esac
        ;;
      *'<= Recv header: HTTP/'*)
        if \[ -n "$span_handle" ]; then
          local message="${line#*'<= Recv header: '}"
          local response_code="${message#* }"
          local response_code="${response_code%% *}"
          otel_span_attribute_typed "$span_handle" int http.response.status_code="$response_code"
          if \[ "$response_code" -ge 400 ]; then otel_span_error "$span_handle"; fi
        fi
        ;;
    esac
  done
  if \[ -n "$span_handle" ]; then otel_span_end "$span_handle"; fi
}

_otel_alias_prepend git _otel_inject_git
