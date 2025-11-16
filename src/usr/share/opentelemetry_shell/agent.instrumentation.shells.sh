#!/bin/false

# sh => sh
# sh -E => sh -E
# sh -x ./script.sh foo bar => ... its complicated ...
# bash -x -c 'echo hello world' => ... its complicated ...
# bash -x -c 'echo $0 $1 $2' bash foo bar => ... its complicated ...

_otel_inject_shell_args_with_copy() {
  local temporary_script="$1"
  shift
  # command
  local shell="${1#\\}"
  _otel_escape_arg "$1"; \echo -n " "
  shift
  # options and script or command string
  while \[ "$#" -gt 0 ]; do
    if \[ "${no_more_options:-0}" != 1 ] && _otel_string_starts_with "$1" -; then
      case "$1" in
        --) local no_more_options=1;;
        --*) _otel_escape_arg "$1"; \echo -n " ";;
        -*file) _otel_escape_arg "$1"; \echo -n " "; shift; _otel_escape_arg "$1"; \echo -n " ";;
        -o) _otel_escape_arg "$1"; \echo -n " "; shift; _otel_escape_arg "$1"; \echo -n " ";;
        -c) local is_script=0;;
        -*c*) local is_script=0; _otel_escape_arg "$(\printf '%s' "$1" | \sed 's/c//g')"; \echo -n " ";;
        *) _otel_escape_arg "$1"; \echo -n " ";;
      esac
      shift
    else
      local is_script="${is_script:-1}"
      break
    fi
  done
  # abort in case its interactive or invalid aguments
  if \[ "$#" = 0 ]; then return 0; fi
  # save command
  local command="$1"
  shift
  # finish command
  _otel_escape_arg "-c"
  \echo -n " "
  _otel_escape_arg ". '$temporary_script'"
  \echo -n " "
  if \[ "$is_script" -eq 1 ]; then _otel_escape_arg "$command"; elif \[ "$#" -gt 0 ]; then _otel_escape_arg "$1"; shift; else _otel_escape_arg "$shell"; fi
  # setup temporary script
  \touch "$temporary_script"
  \chmod +x "$temporary_script"
  # doing the following in several lines in theory offsets the observed linenumbers, however, they are not available anyway in these shells
  \echo "OTEL_SHELL_AUTO_INSTRUMENTATION_HINT='$temporary_script'" >> "$temporary_script"
  \echo ". otel.sh" >> "$temporary_script"
  \echo "\set -- $(_otel_escape_args "$@")" >> "$temporary_script"
  if \[ "$is_script" -eq 1 ]; then \cat "$command"; else \echo "$command"; fi | if \[ "${OTEL_SHELL_CONFIG_INSTRUMENT_ABSOLUTE_PATHS:-FALSE}" = TRUE ]; then \awk '{
      gsub(/^[ \t]+/, "", $0);
      if ($1 ~ /^\//) {
        print "_otel_inject " $0;
      } else {
        print $0;
      }
    }'; else \cat; fi >> "$temporary_script"
}

_otel_inject_shell_with_copy() {
  local cmdline="$(_otel_dollar_star "$@")"
  local cmdline="${cmdline#\\}"
  local temporary_script="$(\mktemp -u)"
  local injected_command_string="$(_otel_inject_shell_args_with_copy "$temporary_script" "$@")"
  local exit_code=0
  if ! \[ -f "$temporary_script" ] && ! [ -t 0 ]; then
    { \echo ". otel.sh"; \cat; } | \eval OTEL_SHELL_IS_DYNAMIC=TRUE OTEL_SHELL_COMMANDLINE_OVERRIDE=\""$(_otel_escape_arg "$cmdline")"\" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE=$$ OTEL_SHELL_AUTO_INJECTED=TRUE _otel_call "$injected_command_string" || local exit_code=$?
  else
    \eval OTEL_SHELL_COMMANDLINE_OVERRIDE=\""$(_otel_escape_arg "$cmdline")"\" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE=$$ OTEL_SHELL_AUTO_INJECTED=TRUE _otel_call "$injected_command_string" || local exit_code=$?
  fi
  \rm "$temporary_script" 2> /dev/null || true
  return $exit_code
}

_otel_alias_prepend sh _otel_inject_shell_with_copy # cant really know what kind of shell it actually is, so lets play it safe
_otel_alias_prepend ash _otel_inject_shell_with_copy # sourced files do not support arguments
_otel_alias_prepend dash _otel_inject_shell_with_copy # sourced files do not support arguments
