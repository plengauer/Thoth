#!/bin/false

# git submodule [--quiet] foreach [--recursive] <command>

_otel_inject_git_arguments() {
  local IFS=' 
'
  local executable="$1"
  _otel_escape_arg "$1"; shift
  local inject=1
  if \[ "$inject" = 1 ]; then
    if \[ "$1" = submodule ]; then \echo -n ' '; _otel_escape_arg "$1"; shift; else local inject=0; fi
  fi
  if \[ "$inject" = 1 ]; then
    if \[ "$1" = --quiet ]; then \echo -n ' '; _otel_escape_arg "$1"; shift; fi
    if \[ "$1" = foreach ]; then \echo -n ' '; _otel_escape_arg "$1"; shift; else local inject=0; fi
  fi
  if \[ "$inject" = 1 ]; then
    if \[ "$1" = --recursive ]; then \echo -n ' '; _otel_escape_arg "$1"; shift; fi
  fi
  if \[ "$inject" = 1 ]; then
    \echo -n ' '; _otel_escape_args $_otel_shell -c '. otel.sh
set -x
eval "$(_otel_escape_args "$@")"' "$executable"
  fi
  while \[ "$#" -gt 0 ]; do \echo -n ' '; _otel_escape_arg "$1"; shift; done
}

_otel_inject_git() {
  local cmdline="$(_otel_dollar_star "$@")"
  local cmdline="${cmdline#\\}"
  \eval OTEL_SHELL_COMMANDLINE_OVERRIDE="$(_otel_escape_arg "$cmdline")" OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE=0 OTEL_SHELL_AUTO_INJECTED=TRUE _otel_call "$(_otel_inject_git_arguments "$@")"
}

_otel_alias_prepend git _otel_inject_git
