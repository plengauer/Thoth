#!/bin/false

# parallel -j 10 rm -f -- ./file1.txt ./file2.txt ./file3.txt => parallel -j 10 sh -c '. /otel.sh; rm -f "$1"' parallel -- ./file1.txt ./file2.txt ./file3.txt
# parallel -i -j 10 rm -f {} -- ./file1.txt ./file2.txt ./file3.txt => parallel -i -j 10 sh -c '. /otel.sh; rm -f {}' parallel -- ./file1.txt ./file2.txt ./file3.txt
# parallel -j 10 -- 'rm ./file1.txt' 'rm ./file2.txt' 'rm ./file3.txt' => parallel -j 10 -- 'sh -c \'. /otel.sh; rm -f ./file1.txt\' parallel' 'sh -c \'. /otel.sh; rm -f ./file2.txt\' parallel' 'sh -c \'. /otel.sh; rm -f ./file3.txt\' parallel'

_otel_inject_parallel_moreutils_arguments() {
  _otel_escape_arg "$1"
  shift
  local in_exec=0
  local explicit_pos=0
  local inject_all_args=0
  for arg in "$@"; do
    \echo -n ' '
    if \[ "$in_exec" -eq 0 ] && ! \[ "${arg%"${arg#?}"}" = "-" ] && \[ -x "$(\which "$arg")" ]; then
      local in_exec=1
      \echo -n "sh -c '. otel.sh
$arg"
    elif \[ "$in_exec" -eq 1 ] && \[ "$arg" = "--" ]; then
      local in_exec=0
      if \[ "$explicit_pos" = 0 ]; then \echo -n '"$@"'; fi
      \echo -n "' parallel --"
    elif \[ "$in_exec" -eq 0 ] && \[ "$arg" = "--" ]; then
      local inject_all_args=1
      \echo -n "--"
    else
      if \[ "$in_exec" = 1 ]; then
        no_quote=1 _otel_escape_arg "$(_otel_escape_arg "$arg")"
      else
        if \[ "$inject_all_args" = 1 ]; then 
          \echo -n "'sh -c '\''. otel.sh
$arg'\'' parallel'"
        else
          if \[ "$arg" = "-i" ]; then local explicit_pos=1; fi
          _otel_escape_arg "$arg"
        fi
      fi
    fi
  done
}

# parallel rm -f ::: ./file1.txt ./file2.txt ./file3.txt => parallel sh -c '. ./otel.sh; rm -f "$@"' parallel ::: ./file1.txt ./file2.txt ./file3.txt
# parallel rm -f {} ::: ./file1.txt ./file2.txt ./file3.txt => parallel sh -c '. ./otel.sh; rm -f {} "$@" parallel ::: ./file1.txt ./file2.txt ./file3.txt
# parallel rm -f => parallel sh -c '. ./otel.sh; rm -f "$@"' parallel

# WARNING it looks like the command is not properly quotes when its put in a subbash. meaning, we need to do it manually
# evidence this works: parallel -v sh -c 'echo\ \$0\ A\$1O' parallel ':::' c1 c2 c3
# evidence this doesnt work: parallel -v sh -c 'echo $0 A$1O' parallel ':::' c1 c2 c3

_otel_inject_parallel_gnu_arguments() {
  if _otel_string_ends_with "$1" "/env"; then _otel_escape_arg "$1"; shift; \echo -n ' '; fi
  if _otel_string_ends_with "$1" "/perl" || \[ "$1" = perl ]; then _otel_escape_arg "$1"; shift; \echo -n ' '; fi
  _otel_escape_args "$1"; shift
  local in_exec=0
  for arg in "$@"; do
    \echo -n ' '
    if \[ "$in_exec" -eq 0 ] && ! _otel_starts_with "$arg" - && \[ -x "$(\which "$arg")" ]; then
      local in_exec=1
      \echo -n "-q $_otel_shell -c '. otel.sh
"
      no_quote=1 _otel_escape_arg "$arg"
    elif \[ "$in_exec" -eq 0 ] && ! _otel_starts_with "$arg" - && \[ "$_otel_shell" = bash ] && \type "$arg" 2> /dev/null | \head -n1 | \grep -q ' function$'; then
      local in_exec=1
      \echo -n "-q $_otel_shell -c '. otel.sh
"
      no_quote=1 _otel_escape_arg "$arg"
      # even if the command is an exported bash function, the instrumentation works properly because the function is exported with expanded aliases
      # so really the instrumentation hint is irrelevant as long as the necessary otel functions are declared
    elif \[ "$in_exec" -eq 1 ] && _otel_starts_with "$arg" ':::'; then
      local in_exec=0
      \echo -n '"$@"'"' 'parallel' '$arg'"
    else
      if \[ "$in_exec" = 1 ]; then
        no_quote=1 _otel_escape_arg "$(_otel_escape_arg "$arg")"
      else
        _otel_escape_arg "$arg"
      fi
    fi
  done
  if \[ "$in_exec" -eq 1 ]; then
    \echo -n ' "$@"'"' 'parallel'"
  fi
}

_otel_inject_parallel_arguments() {
  if _otel_string_ends_with "$1" /perl || (\[ "$#" -ge 2 ] && _otel_string_ends_with "$1" /env && \[ "$2" = perl ]); then
    _otel_inject_parallel_gnu_arguments "$@"
  else
    _otel_inject_parallel_moreutils_arguments "$@"
  fi
}

_otel_inject_parallel() {
  local cmdline="$(_otel_dollar_star "$@")"
  local cmdline="${cmdline#\\}"
  OTEL_SHELL_COMMANDLINE_OVERRIDE="$cmdline" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE="0" OTEL_SHELL_AUTO_INJECTED=TRUE \eval _otel_call "$(_otel_inject_parallel_arguments "$@")"
}

_otel_alias_prepend parallel _otel_inject_parallel
_otel_alias_prepend parallel.moreutils _otel_inject_parallel
