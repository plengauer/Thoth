#!/bin/false
# shellcheck shell=bash

# sftp user@host.example.com => OTEL4SH_PREFIX_COMMAND=ssh sftp -S otel4sh user@host.example.com
# sftp -S /opt/ssh host => OTEL4SH_PREFIX_COMMAND=/opt/ssh sftp -S otel4sh host
# sftp only accepts an executable (not a command string) via -S and has no environment variable to override it,
# so otel4sh is used as the executable and the actual ssh program is passed via OTEL4SH_PREFIX_COMMAND.
# The ssh process itself is then instrumented by the ssh instrumentation.

_otel_inject_sftp_arguments() {
  local IFS=' 
'
  local program=ssh
  local arguments="$(_otel_escape_arg "$1") -S otel4sh"
  shift
  while \[ "$#" -gt 0 ]; do
    case "$1" in
      --) break ;;
      -?*)
        local rest="${1#-}"
        shift
        while \[ -n "$rest" ]; do
          local option="${rest%"${rest#?}"}"
          local rest="${rest#?}"
          case "$option" in
            [bBcDFiJloPRsS])
              if \[ -n "$rest" ]; then
                local value="$rest"
                local rest=""
              elif \[ "$#" -gt 0 ]; then
                local value="$1"
                shift
              else
                local arguments="$arguments $(_otel_escape_arg "-$option")"
                break
              fi
              if \[ "$option" = S ]; then
                if \[ "$value" != otel4sh ]; then local program="$value"; fi
                local value=otel4sh
              fi
              local arguments="$arguments $(_otel_escape_arg "-$option") $(_otel_escape_arg "$value")"
              ;;
            *) local arguments="$arguments $(_otel_escape_arg "-$option")" ;;
          esac
        done
        ;;
      *) break ;;
    esac
  done
  while \[ "$#" -gt 0 ]; do
    local arguments="$arguments $(_otel_escape_arg "$1")"
    shift
  done
  \echo "OTEL4SH_PREFIX_COMMAND=$(_otel_escape_arg "$program") _otel_call $arguments"
}

_otel_inject_sftp() {
  \eval "$(_otel_inject_sftp_arguments "$@")"
}

_otel_alias_prepend sftp _otel_inject_sftp
