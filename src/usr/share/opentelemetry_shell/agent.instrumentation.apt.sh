#!/bin/false

_otel_monitor_apt_handles() {
  local handle_file="$1"
  while true; do
    if \[ -f "$handle_file" ]; then
      local span_handle
      span_handle="$(\cat "$handle_file" 2>/dev/null)"
      \rm -f "$handle_file" 2>/dev/null
      if \[ -n "$span_handle" ]; then
        otel_span_end "$span_handle"
      fi
    else
      \sleep 1
    fi
  done
}

_otel_propagate_apt() {
  case "$-" in
    *m*) local job_control=1; \set +m;;
    *) local job_control=0;;
  esac
  local file=/usr/share/opentelemetry_shell/agent.instrumentation.http/"$(\arch)"/libinjecthttpheader.so
  if \[ -f "$file" ] && ! \ldd "$file" 2> /dev/null | \grep -q 'not found'; then
    export OTEL_SHELL_INJECT_HTTP_SDK_PIPE="$_otel_remote_sdk_pipe"
    export OTEL_SHELL_INJECT_HTTP_HANDLE_FILE="$(\mktemp -u)_opentelemetry_shell_$$.apt.handle"
    local OLD_LD_PRELOAD="${LD_PRELOAD:-}"
    export LD_PRELOAD="$file"
    if \[ -n "$OLD_LD_PRELOAD" ]; then
      export LD_PRELOAD="$LD_PRELOAD:$OLD_LD_PRELOAD"
    fi
    _otel_monitor_apt_handles "${OTEL_SHELL_INJECT_HTTP_HANDLE_FILE}" &
    local monitor_pid="$!"
  fi
  local exit_code=0
  _otel_call "$@" -o "Acquire::http::RequestOptions::traceparent=$TRACEPARENT" -o "Acquire::http::RequestOptions::tracestate=$TRACESTATE" -o "Acquire::https::RequestOptions::traceparent=$TRACEPARENT" -o "Acquire::https::RequestOptions::tracestate=$TRACESTATE" || exit_code="$?"
  if \[ -n "${monitor_pid:-}" ]; then
    \kill "$monitor_pid" 2>/dev/null
    \wait "$monitor_pid" 2>/dev/null || true
    if \[ -f "${OTEL_SHELL_INJECT_HTTP_HANDLE_FILE:-}" ]; then
      otel_span_end "$(\cat "${OTEL_SHELL_INJECT_HTTP_HANDLE_FILE}")"
      \rm -f "${OTEL_SHELL_INJECT_HTTP_HANDLE_FILE}"
    fi
  fi
  if \[ -f "$file" ]; then
    if \[ -n "${OLD_LD_PRELOAD:-}" ]; then
      export LD_PRELOAD="$OLD_LD_PRELOAD"
    else
      unset LD_PRELOAD
    fi
    unset OTEL_SHELL_INJECT_HTTP_HANDLE_FILE
    unset OTEL_SHELL_INJECT_HTTP_SDK_PIPE
  fi
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}

_otel_propagate_dpkg() {
  case "$-" in
    *m*) local job_control=1; \set +m;;
    *) local job_control=0;;
  esac
  local file=/usr/share/opentelemetry_shell/agent.instrumentation.http/"$(\arch)"/libinjecthttpheader.so
  if \[ -f "$file" ] && ! \ldd "$file" 2> /dev/null | \grep -q 'not found'; then
    export OTEL_SHELL_INJECT_HTTP_SDK_PIPE="$_otel_remote_sdk_pipe"
    export OTEL_SHELL_INJECT_HTTP_HANDLE_FILE="$(\mktemp -u)_opentelemetry_shell_$$.dpkg.handle"
    local OLD_LD_PRELOAD="${LD_PRELOAD:-}"
    export LD_PRELOAD="$file"
    if \[ -n "$OLD_LD_PRELOAD" ]; then
      export LD_PRELOAD="$LD_PRELOAD:$OLD_LD_PRELOAD"
    fi
    _otel_monitor_apt_handles "${OTEL_SHELL_INJECT_HTTP_HANDLE_FILE}" &
    local monitor_pid="$!"
  fi
  local exit_code=0
  _otel_call "$@" || exit_code="$?"
  if \[ -n "${monitor_pid:-}" ]; then
    \kill "$monitor_pid" 2>/dev/null
    \wait "$monitor_pid" 2>/dev/null || true
    if \[ -f "${OTEL_SHELL_INJECT_HTTP_HANDLE_FILE:-}" ]; then
      otel_span_end "$(\cat "${OTEL_SHELL_INJECT_HTTP_HANDLE_FILE}")"
      \rm -f "${OTEL_SHELL_INJECT_HTTP_HANDLE_FILE}"
    fi
  fi
  if \[ -f "$file" ]; then
    if \[ -n "${OLD_LD_PRELOAD:-}" ]; then
      export LD_PRELOAD="$OLD_LD_PRELOAD"
    else
      unset LD_PRELOAD
    fi
    unset OTEL_SHELL_INJECT_HTTP_HANDLE_FILE
    unset OTEL_SHELL_INJECT_HTTP_SDK_PIPE
  fi
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}

_otel_alias_prepend apt-get _otel_propagate_apt
_otel_alias_prepend apt _otel_propagate_apt
_otel_alias_prepend dpkg _otel_propagate_dpkg
