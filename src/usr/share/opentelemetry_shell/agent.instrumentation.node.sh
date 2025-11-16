#!/bin/false

_otel_is_node_injected() {
  local dir="$dir"
  if \[ -f "$dir"/package-lock.json ]; then
    \cat "$dir"/package-lock.json | \grep -q '"@opentelemetry/'
  elif \[ -d "$dir"/node_modules ]; then
    \find "$dir"/node_modules | \grep -q '/@opentelemetry/'
  elif \[ -f "$dir"/package.json ]; then
    \cat "$dir"/package.json | \grep -q '"@opentelemetry/'
  else
    return 1
  fi
}

_otel_inject_node_args() {
  while ! \[ "$1" = node ] && ! \[ "$1" = "\\node" ] && ! _otel_string_ends_with "$1" /node; do _otel_escape_arg "$1"; shift; \echo -n ' '; done # SKIP_DEPENDENCY_CHECK
  local command="$1"
  _otel_escape_arg "$1"
  shift
  local version="$("${command#\\}" --version)"
  local version="${version#v}"
  local version="${version%%.*}"
  if \[ -d /usr/share/opentelemetry_shell/agent.instrumentation.node/"$version" ]; then
    \echo -n ' '; _otel_escape_args --require /usr/share/opentelemetry_shell/agent.instrumentation.node/"$version"/deep.inject.js
  fi
  while \[ "$#" -gt 0 ]; do
    \echo -n ' '
    if \[ "$1" = -e ] || \[ "$1" = --eval ] || \[ "$1" = -p ] || \[ "$1" = --print ]; then
      _otel_escape_arg "$1"; shift; local next_is_code=TRUE
    elif \[ "$1" = -r ] || \[ "$1" = --require ]; then
      _otel_escape_arg "$1"; shift; if \[ "$#" -gt 0 ]; then \echo -n ' '; _otel_escape_arg "$1"; shift; fi
    elif _otel_string_starts_with "$1" -; then
      _otel_escape_arg "$1"; shift
    else
      if \[ "${OTEL_SHELL_CONFIG_INJECT_DEEP:-FALSE}" = TRUE ] && \[ -d /usr/share/opentelemetry_shell/agent.instrumentation.node/"$version" ]; then
        if \[ "${next_is_code:-FALSE}" = TRUE ]; then
          _otel_escape_arg "$1"; \echo -n ' '
          local base_dir="$(\echo "$1" | \rev | \cut -d / -f 2- | \rev)"
        else
          local base_dir="$(\pwd)"
        fi
        local dir="$base_dir"
        while [ -n "$dir" ] && ! \[ -d "$dir"/node_modules ] && ! \[ -f "$dir"/package.json ] && ! \[ -f "$dir"/package-lock.json ]; do
          local dir="$(\echo "$dir" | \rev | \cut -sd / -f 2- | \rev)"
        done
        if \[ -z "$dir" ]; then local dir="$base_dir"; fi
        if _otel_is_node_injected "$dir"; then
          _otel_escape_args --require /usr/share/opentelemetry_shell/agent.instrumentation.node/"$version"/deep.link.js
        elif \[ -z "${OTEL_TRACES_EXPORTER:-}" ] || \[ "${OTEL_TRACES_EXPORTER:-}" = console ] || \[ "${OTEL_TRACES_EXPORTER:-}" = otlp ]; then
          _otel_escape_args --require /usr/share/opentelemetry_shell/agent.instrumentation.node/"$version"/deep.instrument.js
        fi
        if ! \[ "${next_is_code:-FALSE}" = TRUE ]; then \echo -n ' '; _otel_escape_arg "$1"; fi
      else
        _otel_escape_arg "$1"
      fi
      shift
      break
    fi
  done
  while \[ "$#" -gt 0 ]; do \echo -n ' '; _otel_escape_arg "$1"; shift; done
}

_otel_inject_node() {
  local cmdline="$(_otel_dollar_star "$@")"
  local cmdline="${cmdline#\\}"
  \set -x
  \eval OTEL_SHELL_COMMANDLINE_OVERRIDE=\""(_otel_escape_arg "$cmdline")"\" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE="0" OTEL_SHELL_AUTO_INJECTED=TRUE _otel_call "$(_otel_inject_node_args "$@")"
  \set +x
}

_otel_alias_prepend node _otel_inject_node
_otel_alias_prepend nodejs _otel_inject_node
