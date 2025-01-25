#!/bin/false

_otel_inject_python() {
  if \[ -d "/opt/opentelemetry_shell/venv" ] && _otel_string_starts_with "$(\eval "$1 -V" | \cut -d ' ' -f 2)" "3."; then
    local cmdline="$(_otel_dollar_star "$@")"
    local cmdline="${cmdline#\\}"
    _otel_python_inject_args "$@" > /dev/null
    local python_path="${PYTHONPATH:-}"
    if _otel_can_inject_python_otel; then
      \eval "set -- $(_otel_python_inject_args "$@")"
      local python_path=/opt/opentelemetry_shell/venv/lib/"$(\ls /opt/opentelemetry_shell/venv/lib/)"/site-packages/:"$python_path"
      if \[ "${OTEL_SHELL_CONFIG_INJECT_DEEP:-FALSE}" = TRUE ]; then
        local command="$1"; shift
        set -- "$command" /opt/opentelemetry_shell/venv/bin/opentelemetry-instrument "${command#\\}" "$@"
      fi
    else
      \eval "set -- $(_otel_python_inject_args "$@")"
      local python_path="$(\printf '%s' "$python_path" | \tr ':' '\n' | \grep -vE '^/opt/opentelemetry_shell/venv/lib/' | \tr '\n' ':')"
    fi
    if \[ "${_otel_python_code_source:-}" = stdin ]; then
      { \cat /usr/share/opentelemetry_shell/agent.instrumentation.python.deep.py; \cat; } | OTEL_SHELL_COMMANDLINE_OVERRIDE="$cmdline" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE="0" OTEL_SHELL_AUTO_INJECTED=TRUE PYTHONPATH="$python_path" OTEL_BSP_MAX_EXPORT_BATCH_SIZE=1 _otel_call "$@" || local exit_code="$?"
    else
      OTEL_SHELL_COMMANDLINE_OVERRIDE="$cmdline" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE="0" OTEL_SHELL_AUTO_INJECTED=TRUE PYTHONPATH="$python_path" OTEL_BSP_MAX_EXPORT_BATCH_SIZE=1 _otel_call "$@" || local exit_code="$?"
    fi
  else
    _otel_call "$@" || local exit_code="$?"
  fi
  unset _otel_python_code_source _otel_python_file _otel_python_module
  return "${exit_code:-0}"
}

_otel_can_inject_python_otel() {
  case "$_otel_python_code_source" in
    file) ! _otel_string_ends_with "$_otel_python_file" /pip && ! _otel_string_ends_with "$_otel_python_file" /pip3 ;;
    module) \[ "$_otel_python_module" != pip ] && \[ "$_otel_python_module" != ensurepip ] ;;
    *) \true ;;
  esac
  local result="$?"
  return "$result"
}

_otel_inject_opentelemetry_instrument() {
  if \[ "$OTEL_SHELL_CONFIG_INJECT_DEEP" = TRUE ]; then
    local cmdline="$(_otel_dollar_star "$@")"
    local cmdline="${cmdline#\\}"
    \eval "set -- $(_otel_python_inject_args "$@")"
    if \[ "${_otel_python_code_source:-}" = stdin ]; then
      unset _otel_python_code_source
      { \cat /usr/share/opentelemetry_shell/agent.instrumentation.python.deep.py; \cat; } | OTEL_SHELL_COMMANDLINE_OVERRIDE="$cmdline" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE="0" OTEL_SHELL_AUTO_INJECTED=TRUE OTEL_BSP_MAX_EXPORT_BATCH_SIZE="${OTEL_BSP_MAX_EXPORT_BATCH_SIZE:-1}" _otel_call "$@"
    else
      OTEL_SHELL_COMMANDLINE_OVERRIDE="$cmdline" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE="0" OTEL_SHELL_AUTO_INJECTED=TRUE OTEL_BSP_MAX_EXPORT_BATCH_SIZE="${OTEL_BSP_MAX_EXPORT_BATCH_SIZE:-1}" _otel_call "$@"
    fi
  else
    _otel_call "$@"
  fi
}

_otel_python_inject_args() {
  if \[ "${1#\\}" = opentelemetry-instrument ] || _otel_string_ends_with "$1" /opentelemetry-instrument; then
    _otel_escape_arg "$1"; shift
    \echo -n ' '
  fi
  _otel_escape_arg "$1"; shift
  while \[ "$#" -gt 0 ]; do
    \echo -n ' '
    local arg="$1"; shift
    if \[ -n "${_otel_python_code_source:-}" ]; then
      _otel_escape_arg "$arg"
    elif \[ "$arg" = -c ]; then
      _otel_escape_arg "$arg"
      \echo -n ' '
      local arg="$1"; shift
      _otel_escape_arg "$(\cat /usr/share/opentelemetry_shell/agent.instrumentation.python.deep.py)
$arg"
      _otel_python_code_source=cmdline
    elif \[ "$arg" = -m ]; then
      _otel_escape_args -c
      \echo -n ' '
      local arg="$1"; shift
      _otel_escape_arg "$(\cat /usr/share/opentelemetry_shell/agent.instrumentation.python.deep.py)
import runpy # SKIP_DEPENDENCY_CHECK
runpy.run_module('$arg', run_name='__main__')"
      _otel_python_module="$arg"
      _otel_python_code_source=module
    elif \[ -f "$arg" ]; then
      _otel_escape_args -c "$(\cat /usr/share/opentelemetry_shell/agent.instrumentation.python.deep.py)
with open('$arg', 'r') as file: # SKIP_DEPENDENCY_CHECK
  exec(file.read())"
      _otel_python_file="$arg"
      _otel_python_code_source=file
    fi
  done
  _otel_python_code_source="${_otel_python_code_source:-stdin}"
}

_otel_alias_prepend python _otel_inject_python
_otel_alias_prepend python3 _otel_inject_python
_otel_alias_prepend opentelemetry-instrument _otel_inject_opentelemetry_instrument
