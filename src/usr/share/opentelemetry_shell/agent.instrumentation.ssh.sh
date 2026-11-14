#!/bin/false
# shellcheck shell=bash

# ssh user@host.example.com uptime => ssh -E /tmp/pipe -v -o SetEnv=TRACEPARENT=00-XXXXXX-01 -o 'SetEnv=TRACESTATE=""' user@host.example.com uptime

_otel_propagate_ssh() {
  case "$-" in
    *m*)
      local job_control=1
      \set +m
      ;;
    *) local job_control=0 ;;
  esac
  local command="$1"
  shift
  case "$(_otel_call "$command" -G "$@" 2>/dev/null | \grep -i '^loglevel ')" in
    *VERBOSE | *DEBUG*) local is_verbose=1 ;;
    *) local is_verbose=0 ;;
  esac
  local log_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.log.ssh.pipe.XXXXXXXXXX)"
  \mkfifo "$log_pipe"
  _otel_pipe_ssh_log "$log_pipe" "$is_verbose" <>"$log_pipe" >&2 &
  local log_pid="$!"
  local exit_code=0
  _otel_call "$command" -E "$log_pipe" -v -o "SetEnv=TRACEPARENT=$TRACEPARENT" -o "SetEnv=TRACESTATE=\"$TRACESTATE\"" "$@" || exit_code="$?"
  \echo "$log_pipe" >"$log_pipe"
  \wait "$log_pid" || true
  \rm -f "$log_pipe"
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}

# debug1: Connecting to github.com [140.82.121.4] port 22.
# debug1: Local version string SSH-2.0-OpenSSH_9.6p1 Ubuntu-3ubuntu13.20
# debug1: Remote protocol version 2.0, remote software version OpenSSH_9.6p1 Ubuntu-3ubuntu13.20
# debug1: Authenticating to github.com:22 as 'git'
# Authenticated to github.com ([140.82.121.4]:22) using "publickey".
# debug1: Sending command: git-upload-pack 'plengauer/Thoth'
# Transferred: sent 3624, received 3536 bytes, in 0.0 seconds
# debug1: Exit status 0

_otel_pipe_ssh_log() {
  local sentinel="$1"
  local is_verbose="$2"
  local span_handle=""
  local carriage_return="$(\printf '\r')"
  while \read -r line; do
    line="${line%"$carriage_return"}" # ssh terminates its debug lines with CRLF
    if \[ "$line" = "$sentinel" ]; then break; fi
    case "$line" in
      'debug1: Connecting to '*)
        local rest="${line#'debug1: Connecting to '}"
        local host="${rest%% *}"
        local rest="${rest#* \[}"
        local ip="${rest%%\]*}"
        local port="${rest#*\] port }"
        local port="${port%.}"
        local span_handle="$(otel_span_start CLIENT ssh)"
        otel_span_attribute_typed "$span_handle" string network.transport=tcp
        otel_span_attribute_typed "$span_handle" string network.protocol.name=ssh
        otel_span_attribute_typed "$span_handle" string network.peer.address="$ip"
        otel_span_attribute_typed "$span_handle" int network.peer.port="$port"
        otel_span_attribute_typed "$span_handle" string server.address="$host"
        otel_span_attribute_typed "$span_handle" int server.port="$port"
        otel_span_attribute_typed "$span_handle" string url.full="ssh://$host:$port"
        otel_span_attribute_typed "$span_handle" string url.scheme=ssh
        ;;
    esac
    if \[ -n "$span_handle" ]; then
      case "$line" in
        'debug1: Local version string SSH-2.0-'*) otel_span_attribute_typed "$span_handle" string user_agent.original="${line#'debug1: Local version string SSH-2.0-'}" ;;
        'debug1: Remote protocol version '*)
          local rest="${line#'debug1: Remote protocol version '}"
          otel_span_attribute_typed "$span_handle" string network.protocol.version="${rest%%,*}"
          otel_span_attribute_typed "$span_handle" string ssh.server.version="${rest#*'remote software version '}"
          ;;
        'debug1: Authenticating to '*)
          local rest="${line#*' as '\'}"
          otel_span_attribute_typed "$span_handle" string ssh.user="${rest%\'}"
          ;;
        'Authenticated to '*)
          local rest="${line#*' using "'}"
          otel_span_attribute_typed "$span_handle" string ssh.auth.method="${rest%%\"*}"
          ;;
        'debug1: Sending command: '*)
          local command="${line#'debug1: Sending command: '}"
          local command="${command%% *}"
          otel_span_name "$span_handle" "$command"
          otel_span_attribute_typed "$span_handle" string ssh.command="$command"
          ;;
        'debug1: Sending subsystem: '*)
          local subsystem="${line#'debug1: Sending subsystem: '}"
          otel_span_name "$span_handle" "$subsystem"
          otel_span_attribute_typed "$span_handle" string ssh.subsystem="$subsystem"
          ;;
        'Transferred: sent '*)
          local rest="${line#'Transferred: sent '}"
          otel_span_attribute_typed "$span_handle" int ssh.bytes.sent="${rest%%,*}"
          local rest="${rest#*'received '}"
          otel_span_attribute_typed "$span_handle" int ssh.bytes.received="${rest%% *}"
          ;;
        'debug1: Exit status '*)
          local exit_status="${line#'debug1: Exit status '}"
          otel_span_attribute_typed "$span_handle" int ssh.exit_status="$exit_status"
          if \[ "$exit_status" != 0 ]; then otel_span_error "$span_handle"; fi
          otel_span_end "$span_handle"
          local span_handle=""
          ;;
      esac
    fi
    if \[ "$is_verbose" = 1 ]; then
      \echo "$line"
    else
      case "$line" in
        debug* | OpenSSH_* | 'Authenticated to '* | 'Transferred: '* | 'Bytes per second: '*) ;;
        *) \echo "$line" ;;
      esac
    fi
  done
  if \[ -n "$span_handle" ]; then
    otel_span_error "$span_handle"
    otel_span_end "$span_handle"
  fi
}

_otel_alias_prepend ssh _otel_propagate_ssh
