#!/bin/false

# find . => find .
# find . -iname "*.txt" => find . -iname "*.txt"
# find . -exec rm {} ';' -iname "*.txt" => find . -exec sh -c '. /otel.sh; rm "$@"' find {} ';' -iname "*.txt"
# find . -exec rm {} + -iname "*.txt" => find . -exec sh -c '. /otel.sh; rm "$@"' find {} + -iname "*.txt"
# find . -execdir rm {} ';' -iname "*.txt" => find . -execdir sh -c '. /otel.sh; rm "$@"' find {} ';' -iname "*.txt"
# find . -execdir rm {} + -iname "*.txt" => find . -execdir sh -c '. /otel.sh; rm "$@"' find {} + -iname "*.txt"

_otel_inject_find_arguments() {
  local IFS=' 
'
  _otel_escape_arg "$1"
  shift
  local in_exec=0
  for arg in "$@"; do
    \echo -n ' '
    if \[ "$in_exec" -eq 0 ] && (\[ "$arg" = "-exec" ] || \[ "$arg" = "-execdir" ]); then
      local in_exec=1
      \echo -n "$arg $_otel_shell -c '. otel.sh
_otel_inject "
    elif \[ "$in_exec" -eq 1 ] && \[ "$arg" = "{}" ]; then
      \echo -n '"$@"'
    elif \[ "$in_exec" -eq 1 ] && (\[ "$arg" = ";" ] || \[ "$arg" = "+" ]); then
      local in_exec=0
      \echo -n "' find {} ';'" # intentionally do not support + due to too long commandlines
    else
      if \[ "$in_exec" = 1 ]; then
        no_quote=1 _otel_escape_arg "$(_otel_escape_arg "$arg")"
      else
        _otel_escape_arg "$arg"
      fi
    fi
  done
}

_otel_inject_find() {
  if \[ "$(\expr "$*" : ".* -exec .*")" -gt 0 ] || \[ "$(\expr "$*" : ".* -execdir .*")" -gt 0 ]; then
    local cmdline="$(_otel_dollar_star "$@")"
    local cmdline="${cmdline#\\}"
    OTEL_SHELL_AUTO_INSTRUMENTATION_HINT="$cmdline" OTEL_SHELL_COMMANDLINE_OVERRIDE="$cmdline" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE="0" OTEL_SHELL_AUTO_INJECTED=TRUE \eval _otel_call "$(_otel_inject_find_arguments "$@")"
  else
    _otel_call "$@"
  fi
}

_otel_alias_prepend find _otel_inject_find
