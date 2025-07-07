#!/bin/false

# time cat ./file.txt => time sh -c '. /otel.sh; cat ./file.txt "$@"' 'time'
# timeout 10s cat ./file.txt => timeout 10s time.output sh -c '. /otel.sh; cat ./file.txt "$@"' 'time'
# flock .lock npm install package => flock .lock sh -c '. /otel.sh; npm install package "$@"' 'flock'
# xargs rm -rf => xargs sh -c '. /otel.sh; rm -rf "$@"' xargs
# xargs -I {} rm -rf {} => xargs sh -c '. /otel.sh; rm -rf {} "$@"' xargs

_otel_inject_inner_command_args() {
  local IFS=' 
'
  local more_args="${OTEL_SHELL_INJECT_INNER_COMMAND_MORE_ARGS:-}"
  unset OTEL_SHELL_INJECT_INNER_COMMAND_MORE_ARGS
  _otel_escape_arg "$1"
  local command="$1"
  shift
  # options
  # -option or not executable file 
  while \[ "$#" -gt 0 ] && ( _otel_string_starts_with "$1" - || ! ( \[ -x "$1" ] || \[ -x "$(\which "$1" 2> /dev/null)" ] ) || ( \[ -x "$1" ] && _otel_string_starts_with "$(_otel_resolve_shebang "${1##*/}")" "$command " ) ); do \echo -n " "; _otel_escape_arg "$1"; shift; done
  # opt out if there is no command
  if \[ -z "$*" ]; then return 0; fi
  # more options
  for arg in $more_args; do \echo -n " ";  _otel_escape_arg "$arg"; done
  # wrap command
  \echo -n " $_otel_shell -c '. otel.sh
"
  while \[ "$#" -gt 0 ]; do \echo -n " "; no_quote=1 _otel_escape_arg "$(_otel_escape_arg "$1")"; shift; done
  \echo -n " "; no_quote=1 _otel_escape_arg '"$@"'
  \printf '%s' "' $(_otel_escape_arg "${command#\\}")"
}

_otel_inject_inner_command() {
  local cmdline="$(_otel_dollar_star "$@")"
  local cmdline="${cmdline#\\}"
  local command_string="$(_otel_inject_inner_command_args "$@")"
  unset OTEL_SHELL_INJECT_INNER_COMMAND_MORE_ARGS # unset it also here, not just in subshell above
  OTEL_SHELL_AUTO_INSTRUMENTATION_HINT="$cmdline" OTEL_SHELL_COMMANDLINE_OVERRIDE="$cmdline" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE="0" OTEL_SHELL_AUTO_INJECTED=TRUE \eval _otel_call "$command_string"
}

_otel_alias_prepend taskset _otel_inject_inner_command
_otel_alias_prepend nice _otel_inject_inner_command
_otel_alias_prepend ionice _otel_inject_inner_command
# _otel_alias_prepend stdbuf _otel_inject_inner_command # injecting via changing the command defeats the purpose of stdbuf
_otel_alias_prepend nohup _otel_inject_inner_command
# _otel_alias_prepend strace _otel_inject_inner_command # injecting via changing the command defeats the purpose of strace
_otel_alias_prepend time _otel_inject_inner_command
_otel_alias_prepend timeout _otel_inject_inner_command
_otel_alias_prepend watch _otel_inject_inner_command
_otel_alias_prepend at _otel_inject_inner_command
_otel_alias_prepend flock _otel_inject_inner_command
_otel_alias_prepend xargs _otel_inject_inner_command
_otel_alias_prepend dumb-init _otel_inject_inner_command

# sudo apt-get update => sudo sh -c '. /otel.sh; apt-get update' 'sudo'

_otel_inject_sudo() {
  OTEL_SHELL_INJECT_INNER_COMMAND_MORE_ARGS="--preserve-env=$(\printenv | \grep '^OTEL_' | \cut -d= -f1 | \sort -u | \tr '\n' ','),OTEL_SHELL_COMMANDLINE_OVERRIDE,OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE,OTEL_SHELL_AUTO_INJECTED,TRACEPARENT,TRACESTATE" _otel_inject_inner_command "$@"
}

_otel_alias_prepend sudo _otel_inject_sudo

_otel_can_inject_env() {
  while \[ "$#" -gt 0 ]; do
    if ! _otel_string_starts_with "$1" -; then return 0; fi
    if \[ "$1" = -i ]; then return 1; fi # do not inject if environment is intentionally cleared, because then also config will be missing and the inner should clearly be intentionally separated
    if _otel_string_starts_with "$1" --block-signal || _otel_string_starts_with "$1" --ignore-signal; then return 1; fi # do not inject if signals are ignored or blocked because a shell will not propagate this, however, inject if they are reset to default
    shift
  done
  return 1
}

_otel_inject_env() {
  if _otel_can_inject_env "$@"; then
    _otel_inject_inner_command "$@"
  else
    _otel_call "$@"
  fi
}

_otel_alias_prepend env _otel_inject_env
