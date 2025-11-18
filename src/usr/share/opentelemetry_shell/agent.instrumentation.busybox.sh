#!/bin/false

_otel_inject_busybox() {
  if \[ "$#" -gt 0 ] && _otel_string_starts_with "$1" -; then
    _otel_call "$@"
    return "$?"
  fi
  local cmdline="$(_otel_dollar_star "$@")"
  local cmdline="${cmdline#\\}"
  local command="$1"; shift
  \eval OTEL_SHELL_AUTO_INSTRUMENTATION_HINT="$(_otel_escape_arg "$cmdline")" OTEL_SHELL_COMMANDLINE_OVERRIDE="$(_otel_escape_arg "$cmdline")" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE=0 OTEL_SHELL_AUTO_INJECTED=TRUE _otel_call "$(_otel_escape_args "$command" sh -c '. otel.sh
eval "$(_otel_escape_args "$@")"' sh "$@")"
}

_otel_alias_prepend busybox _otel_inject_busybox
