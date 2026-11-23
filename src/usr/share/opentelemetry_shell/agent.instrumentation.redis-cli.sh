#!/bin/false
# shellcheck shell=bash

# ERR unknown command 'FOO', with args beginning with: 'bar'
# WRONGTYPE Operation against a key holding the wrong kind of value

_otel_instrument_redis_cli() {
  local command="$1"
  shift
  local arg
  for arg in "$@"; do
    case "$arg" in
      --version | -v | --help)
        _otel_call "$command" "$@"
        return "$?"
        ;;
    esac
  done
  case "$-" in
    *m*)
      local job_control=1
      \set +m
      ;;
    *) local job_control=0 ;;
  esac
  local host=127.0.0.1
  local port=6379
  local socket=""
  local db=0
  local repeat=1
  local special=0
  local expect=""
  local operation=""
  local query_text=""
  for arg in "$@"; do
    if \[ -n "$operation" ]; then
      if \[ "${#query_text}" -lt 1024 ]; then query_text="$query_text ?"; fi
    elif \[ -n "$expect" ]; then
      case "$expect" in
        -h) host="$arg" ;;
        -p) port="${arg%%[!0-9]*}" ;;
        -s) socket="$arg" ;;
        -n) db="${arg%%[!0-9]*}" ;;
        -r) repeat="${arg%%[!0-9]*}" ;;
        -u)
          arg="${arg#*://}"
          arg="${arg##*@}"
          host="${arg%%[:/]*}"
          case "$arg" in
            *:*) port="${arg#*:}" && port="${port%%[!0-9]*}" ;;
          esac
          case "$arg" in
            */*) db="${arg#*/}" && db="${db%%[!0-9]*}" ;;
          esac
          ;;
      esac
      expect=""
    else
      case "$arg" in
        -h | -p | -s | -n | -r | -u | -a | --user | --pass | -i | -d | -D | -X | --sni | --cacert | --cacertdir | --cert | --key | --tls-ciphers | --tls-ciphersuites | --show-pushes | --memkeys-samples | --pattern | --quoted-pattern | --pipe-timeout) expect="$arg" ;;
        --cluster | --lru-test | --rdb | --functions-rdb | --eval | --intrinsic-latency)
          special=1
          expect="$arg"
          ;;
        --scan | --pipe | --bigkeys | --memkeys | --hotkeys | --stat | --latency | --latency-history | --latency-dist | --replica) special=1 ;;
        -*) ;;
        *)
          operation="$arg"
          query_text="$arg"
          ;;
      esac
    fi
  done
  if \[ "$special" = 1 ]; then
    operation=""
    query_text=""
  fi
  local name="${operation:-redis}"
  if \[ -n "$operation" ] && \[ "${repeat:-1}" -ge 2 ]; then name="BATCH $operation"; fi
  local span_handle="$(otel_span_start CLIENT "$name")"
  otel_span_attribute_typed "$span_handle" string db.system.name=redis
  otel_span_attribute_typed "$span_handle" string db.namespace="${db:-0}"
  if \[ -n "$operation" ]; then
    otel_span_attribute_typed "$span_handle" string db.operation.name="$name"
    otel_span_attribute_typed "$span_handle" string db.query.text="$query_text"
    if \[ "${repeat:-1}" -ge 2 ]; then otel_span_attribute_typed "$span_handle" int db.operation.batch.size="$repeat"; fi
  fi
  if \[ -n "$socket" ]; then
    otel_span_attribute_typed "$span_handle" string network.transport=unix
    otel_span_attribute_typed "$span_handle" string network.peer.address="$socket"
  else
    otel_span_attribute_typed "$span_handle" string network.transport=tcp
    if \[ -n "$host" ]; then otel_span_attribute_typed "$span_handle" string server.address="$host"; fi
    if \[ -n "$port" ] && \[ "$port" != 6379 ]; then otel_span_attribute_typed "$span_handle" int server.port="$port"; fi
  fi
  local exit_code=0
  local status_code=""
  if \[ -t 1 ] || \[ -z "$operation" ]; then
    _otel_call "$command" "$@" || exit_code="$?"
  else
    local stdout_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.stdout.redis_cli.pipe.XXXXXXXXXX)"
    local sample_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.sample.redis_cli.pipe.XXXXXXXXXX)"
    local sample_file="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.sample.redis_cli.file.XXXXXXXXXX)"
    \mkfifo "$stdout_pipe" "$sample_pipe"
    \tee "$sample_pipe" <"$stdout_pipe" &
    local tee_pid="$!"
    {
      \head -c 64
      \cat >/dev/null
    } <"$sample_pipe" >"$sample_file" &
    local sample_pid="$!"
    _otel_call "$command" "$@" >"$stdout_pipe" || exit_code="$?"
    \wait "$tee_pid" "$sample_pid" || \true
    if \[ -n "$operation" ]; then
      local line=""
      \read -r line <"$sample_file" || \true
      line="${line#'(error) '}"
      case "${line%% *}" in
        'ERR' | WRONGTYPE | WRONGPASS | NOAUTH | NOPERM | NOSCRIPT | NOGROUP | BUSY | BUSYGROUP | BUSYKEY | EXECABORT | LOADING | MASTERDOWN | MISCONF | MOVED | ASK | CLUSTERDOWN | CROSSSLOT | READONLY | TRYAGAIN | UNBLOCKED | OOM | NOREPLICAS | NOPROTO) status_code="${line%% *}" ;;
      esac
    fi
    \rm -f "$stdout_pipe" "$sample_pipe" "$sample_file"
  fi
  if \[ -n "$status_code" ]; then
    otel_span_attribute_typed "$span_handle" string db.response.status_code="$status_code"
    otel_span_attribute_typed "$span_handle" string error.type="$status_code"
    otel_span_error "$span_handle"
  elif \[ "$exit_code" != 0 ]; then
    otel_span_attribute_typed "$span_handle" string error.type=_OTHER
    otel_span_error "$span_handle"
  fi
  otel_span_end "$span_handle"
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}

_otel_alias_prepend redis-cli _otel_instrument_redis_cli
