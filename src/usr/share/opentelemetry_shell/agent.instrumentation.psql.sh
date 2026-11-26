#!/bin/false
# shellcheck shell=bash

_otel_trace_psql() {
  case "$-" in
    *m*)
      local job_control=1
      \set +m
      ;;
    *) local job_control=0 ;;
  esac
  local host='' port='' user='' dbname='' positional1='' positional2='' has_source=0 dash_file=0 no_connection=0
  _otel_psql_walk _otel_psql_visit_connection "$@"
  if \[ "$no_connection" = 1 ]; then
    if \[ "$job_control" = 1 ]; then \set -m; fi
    _otel_call "$@"
    return "$?"
  fi
  if \[ -z "$dbname" ] && \[ -n "$positional1" ]; then
    dbname="$positional1"
    positional1="$positional2"
  fi
  if \[ -z "$user" ]; then user="$positional1"; fi
  case "$dbname" in
    *=* | postgres://* | postgresql://*)
      local conninfo="$dbname"
      dbname="$(_otel_psql_conninfo_get dbname "$conninfo")"
      host="$(_otel_psql_conninfo_get host "$conninfo" "$host")"
      port="$(_otel_psql_conninfo_get port "$conninfo" "$port")"
      user="$(_otel_psql_conninfo_get user "$conninfo" "$user")"
      local service="$(_otel_psql_conninfo_get service "$conninfo" "${PGSERVICE:-}")"
      ;;
    *) local service="${PGSERVICE:-}" ;;
  esac
  if \[ -n "$service" ]; then
    host="${host:-$(_otel_psql_service_get "$service" host)}"
    port="${port:-$(_otel_psql_service_get "$service" port)}"
    user="${user:-$(_otel_psql_service_get "$service" user)}"
    dbname="${dbname:-$(_otel_psql_service_get "$service" dbname)}"
  fi
  host="${host:-${PGHOST:-}}"
  port="${port:-${PGPORT:-}}"
  user="${user:-${PGUSER:-$(\id -un)}}"
  dbname="${dbname:-${PGDATABASE:-$user}}"

  local span_handle="$(otel_span_start CLIENT "$dbname")"
  otel_span_attribute_typed "$span_handle" string db.system.name=postgresql
  otel_span_attribute_typed "$span_handle" string db.namespace="$dbname"
  case "$host" in
    '' | /*) otel_span_attribute_typed "$span_handle" string network.transport=unix ;;
    *) otel_span_attribute_typed "$span_handle" string network.transport=tcp ;;
  esac
  if \[ -n "$host" ]; then otel_span_attribute_typed "$span_handle" string server.address="$host"; fi
  case "$host" in
    '' | /* | *,*) ;;
    *)
      case "$port" in
        '' | 5432 | *,*) ;;
        *) otel_span_attribute_typed "$span_handle" int server.port="$port" ;;
      esac
      ;;
  esac

  local uses_stdin=0
  if \[ "$has_source" = 0 ] || \[ "$dash_file" = 1 ]; then uses_stdin=1; fi
  if \[ "$uses_stdin" = 1 ] && \[ -t 0 ]; then uses_stdin=0; fi
  local analysis_pid=''
  # shellcheck disable=SC2154 # the variable is assigned by the sourced instrumentation library or provided by the environment
  local analysis_file="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.analysis.psql.XXXXXXXXXX)"
  if \[ "$has_source" = 1 ] || \[ "$uses_stdin" = 1 ]; then
    local tap_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.tap.psql.pipe.XXXXXXXXXX)"
    if \[ "$uses_stdin" = 1 ]; then
      local stdin_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.stdin.psql.pipe.XXXXXXXXXX)"
      \mkfifo "$tap_pipe" "$stdin_pipe"
    fi
    {
      _otel_psql_walk _otel_psql_visit_script "$@"
      if \[ "$uses_stdin" = 1 ]; then \cat "$tap_pipe"; fi
    } | _otel_psql_analyze >"$analysis_file" &
    analysis_pid="$!"
  fi
  local exit_code=0
  if \[ "$uses_stdin" = 1 ]; then
    { \tee "$stdin_pipe" <&3 >&4 & } 3<&0 4>"$tap_pipe"
    local tee_pid="$!"
    _otel_call "$@" <"$stdin_pipe" || exit_code="$?"
    \kill "$tee_pid" 2>/dev/null || true
    \wait "$tee_pid" 2>/dev/null || true
  else
    _otel_call "$@" || exit_code="$?"
  fi
  if \[ -n "$analysis_pid" ]; then \wait "$analysis_pid" || true; fi

  local summary='' count=0 operation='' collection='' text=''
  if \[ -r "$analysis_file" ]; then
    local line
    while IFS= \read -r line; do
      case "$line" in
        count=*) count="${line#count=}" ;;
        operation=*) operation="${line#operation=}" ;;
        collection=*) collection="${line#collection=}" ;;
        summary=*) summary="${line#summary=}" ;;
        text=*) text="${line#text=}" ;;
      esac
    done <"$analysis_file"
  fi
  \rm -f "$analysis_file" "${tap_pipe:-}" "${stdin_pipe:-}"
  if \[ "$count" -ge 2 ]; then otel_span_attribute_typed "$span_handle" int db.operation.batch.size="$count"; fi
  if \[ -n "$operation" ]; then otel_span_attribute_typed "$span_handle" string db.operation.name="$operation"; fi
  if \[ -n "$collection" ]; then otel_span_attribute_typed "$span_handle" string db.collection.name="$collection"; fi
  if \[ -n "$summary" ]; then otel_span_attribute_typed "$span_handle" string db.query.summary="$summary"; fi
  if \[ -n "$text" ]; then otel_span_attribute_typed "$span_handle" string db.query.text="$text"; fi
  otel_span_name "$span_handle" "${summary:-$dbname}"
  if \[ "$exit_code" != 0 ]; then
    otel_span_attribute_typed "$span_handle" string error.type="$exit_code"
    otel_span_error "$span_handle"
  fi
  otel_span_end "$span_handle"
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}

_otel_psql_walk() {
  local visitor="$1"
  shift
  while \[ "$#" -gt 0 ]; do
    case "$1" in
      *psql)
        shift
        break
        ;;
    esac
    shift
  done
  local pending='' options_ended=0 arg rest char letter
  for arg in "$@"; do
    if \[ -n "$pending" ]; then
      "$visitor" "$pending" "$arg"
      pending=''
    elif \[ "$options_ended" = 1 ]; then
      "$visitor" _ "$arg"
    else
      case "$arg" in
        --) options_ended=1 ;;
        --version | --help | --help=*) "$visitor" V '' ;;
        --*)
          case "$arg" in
            --host | --host=*) letter=h ;;
            --port | --port=*) letter=p ;;
            --username | --username=*) letter=U ;;
            --dbname | --dbname=*) letter=d ;;
            --command | --command=*) letter=c ;;
            --file | --file=*) letter=f ;;
            --output | --output=* | --field-separator | --field-separator=* | --log-file | --log-file=* | --pset | --pset=* | --record-separator | --record-separator=* | --table-attr | --table-attr=* | --set | --set=* | --variable | --variable=*) letter=o ;;
            *) letter='' ;;
          esac
          if \[ -n "$letter" ]; then
            case "$arg" in
              *=*) "$visitor" "$letter" "${arg#*=}" ;;
              *) pending="$letter" ;;
            esac
          fi
          ;;
        -?*)
          rest="${arg#-}"
          while \[ -n "$rest" ]; do
            char="${rest%"${rest#?}"}"
            rest="${rest#?}"
            case "$char" in
              c | d | f | h | p | U | F | L | o | P | R | T | v)
                if \[ -n "$rest" ]; then
                  "$visitor" "$char" "$rest"
                  rest=''
                else
                  pending="$char"
                fi
                ;;
              V | '?') "$visitor" V '' ;;
            esac
          done
          ;;
        *) "$visitor" _ "$arg" ;;
      esac
    fi
  done
}

_otel_psql_visit_connection() {
  case "$1" in
    h) host="$2" ;;
    p) port="$2" ;;
    U) user="$2" ;;
    d) dbname="$2" ;;
    c) has_source=1 ;;
    f) if \[ "$2" = - ]; then dash_file=1; else has_source=1; fi ;;
    V) no_connection=1 ;;
    _)
      if \[ -z "$positional1" ]; then positional1="$2"; elif \[ -z "$positional2" ]; then positional2="$2"; fi
      ;;
  esac
}

_otel_psql_visit_script() {
  case "$1" in
    c) \printf '%s\n;\n' "$2" ;;
    f) if \[ -f "$2" ]; then \cat "$2" 2>/dev/null && \printf '\n;\n'; fi ;;
  esac
}

# postgresql://user:secret@host:5432/db?sslmode=require => host
# host=localhost port=5432 dbname='my db' password=secret => localhost
_otel_psql_conninfo_get() {
  local key="$1"
  local conninfo="$2"
  local value=''
  case "$conninfo" in
    postgres://* | postgresql://*)
      local rest="${conninfo#*://}"
      local query=''
      case "$rest" in *\?*) query="${rest#*\?}" ;; esac
      rest="${rest%%\?*}"
      local authority="${rest%%/*}"
      case "$authority" in *@*) authority="${authority##*@}" ;; esac
      authority="${authority%%,*}"
      case "$key" in
        dbname)
          case "$rest" in */*) value="${rest#*/}" ;; esac
          ;;
        user)
          case "${rest%%/*}" in *@*)
            value="${rest%%@*}"
            value="${value%%:*}"
            ;;
          esac
          ;;
        host)
          case "$authority" in
            \[*)
              value="${authority#\[}"
              value="${value%%\]*}"
              ;;
            *) value="${authority%%:*}" ;;
          esac
          ;;
        port)
          case "$authority" in
            \[*\]:*) value="${authority##*\]:}" ;;
            \[*) ;;
            *:*) value="${authority#*:}" ;;
          esac
          ;;
      esac
      local parameter="$(\printf '%s' "$query" | \tr '&' '\n' | \sed -n "s/^$key=//p" | \tail -n 1)"
      if \[ -n "$parameter" ]; then value="$parameter"; fi
      ;;
    *)
      value="$(\printf '%s\n' "$conninfo" | \awk -v key="$key" -f /usr/share/opentelemetry_shell/agent.instrumentation.psql/conninfo.awk)"
      ;;
  esac
  \printf '%s\n' "${value:-${3:-}}"
}

_otel_psql_service_get() {
  local file
  for file in "${PGSERVICEFILE:-${HOME:-}/.pg_service.conf}" "${PGSYSCONFDIR:-/etc/postgresql-common}/pg_service.conf"; do
    if \[ -r "$file" ] && \awk -v service="$1" -v key="$2" -f /usr/share/opentelemetry_shell/agent.instrumentation.psql/service.awk "$file"; then
      return 0
    fi
  done
}

# SELECT * FROM users WHERE id = 42 AND name IN ('a', 'b') => count=1 operation=SELECT collection=users summary=SELECT users text=SELECT * FROM users WHERE id = ? AND name IN (?)
_otel_psql_analyze() {
  \awk -f /usr/share/opentelemetry_shell/agent.instrumentation.psql/analyze.awk
}

_otel_alias_prepend psql _otel_trace_psql
