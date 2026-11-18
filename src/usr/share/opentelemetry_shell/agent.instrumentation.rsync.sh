#!/bin/false
# shellcheck shell=bash

# rsync -a ./dir user@host.example.com:/tmp/ => RSYNC_RSH='otel4sh ssh' rsync -a ./dir user@host.example.com:/tmp/
# rsync -a -e 'ssh -p 2222' ./dir host:/tmp/ => RSYNC_RSH='otel4sh ssh' rsync -a -e 'otel4sh ssh -p 2222' ./dir host:/tmp/
# rsync accepts a command string for the remote shell, either via RSYNC_RSH or via -e/--rsh (which takes precedence),
# so the remote shell command is wrapped with otel4sh. The ssh process itself is then instrumented by the ssh instrumentation.

_otel_inject_rsync_rsh() {
  case "$1" in
    otel4sh | 'otel4sh '*) \echo "$1" ;;
    *) \echo "otel4sh $1" ;;
  esac
}

_otel_inject_rsync_arguments() {
  local IFS=' 
'
  local arguments="$(_otel_escape_arg "$1")"
  shift
  while \[ "$#" -gt 0 ]; do
    case "$1" in
      --)
        break
        ;;
      --rsh=*)
        local arguments="$arguments $(_otel_escape_arg "--rsh=$(_otel_inject_rsync_rsh "${1#--rsh=}")")"
        shift
        ;;
      --rsh)
        local arguments="$arguments $(_otel_escape_arg "$1")"
        shift
        if \[ "$#" -gt 0 ]; then
          local arguments="$arguments $(_otel_escape_arg "$(_otel_inject_rsync_rsh "$1")")"
          shift
        fi
        ;;
      --*)
        local arguments="$arguments $(_otel_escape_arg "$1")"
        shift
        ;;
      -?*)
        local rest="${1#-}"
        shift
        local cluster=-
        while \[ -n "$rest" ]; do
          local option="${rest%"${rest#?}"}"
          local rest="${rest#?}"
          local cluster="$cluster$option"
          case "$option" in
            e)
              if \[ -n "$rest" ]; then
                local cluster="$cluster$(_otel_inject_rsync_rsh "$rest")"
              elif \[ "$#" -gt 0 ]; then
                local arguments="$arguments $(_otel_escape_arg "$cluster")"
                local cluster="$(_otel_inject_rsync_rsh "$1")"
                shift
              fi
              break
              ;;
            [BfTM@])
              local cluster="$cluster$rest"
              if \[ -z "$rest" ] && \[ "$#" -gt 0 ]; then
                local arguments="$arguments $(_otel_escape_arg "$cluster")"
                local cluster="$1"
                shift
              fi
              break
              ;;
          esac
        done
        local arguments="$arguments $(_otel_escape_arg "$cluster")"
        ;;
      *)
        local arguments="$arguments $(_otel_escape_arg "$1")"
        shift
        ;;
    esac
  done
  while \[ "$#" -gt 0 ]; do
    local arguments="$arguments $(_otel_escape_arg "$1")"
    shift
  done
  \echo "RSYNC_RSH=$(_otel_escape_arg "$(_otel_inject_rsync_rsh "${RSYNC_RSH:-ssh}")") _otel_call $arguments"
}

_otel_inject_rsync() {
  \eval "$(_otel_inject_rsync_arguments "$@")"
}

_otel_alias_prepend rsync _otel_inject_rsync
