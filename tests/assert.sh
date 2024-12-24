#!/bin/bash

assert_equals() {
  if [ "${1:-}" != "${2:-}" ]; then
    \echo "ASSERT FAILED ${1:-} != ${2:-}" 1>&2
    exit 1
  fi
}

assert_not_equals() {
  if [ "$1" = "$2" ]; then
    \echo "ASSERT FAILED $1 == $2" 1>&2
    exit 1
  fi
}

assert_ends_with() {
  reverse_string=$(\echo "$2" | \rev)
  reverse_suffix=$(\echo "$1" | \rev)
  if [ "${reverse_string#"$reverse_suffix"}" = "$reverse_string" ] ; then
    \echo "ASSERT FAILED $1 !~= $2" 1>&2
    exit 1
  fi
}

resolve_span() {
  local selector="${1:-}"
  if [ -n "$selector" ]; then
    local selector=' | select('"$selector"')'
  fi
  for i in 1 2 4 8 16 32; do
    local span="$(\cat $OTEL_EXPORT_LOCATION | \jq ". | select(.name != null)$selector")"
    if [ -n "$span" ]; then
      \echo "$span"
      return 0
    fi
    \sleep $i
  done
  \echo "SPAN RESOLUTION ERROR ($selector)" 1>&2
  exit 1
}

resolve_log() {
  local selector="$1"
  if [ -n "$selector" ]; then
    local selector=' | select('"$selector"')'
  fi
  for i in 1 2 4 8 16 32; do
    local log="$(\cat $OTEL_EXPORT_LOCATION | \jq ". | select(.body != null)$selector")"
    if [ -n "$log" ]; then
      \echo "$log"
      return 0
    fi
    \sleep $i
  done
  \echo "LOG RESOLUTION ERROR ($selector)" 1>&2
  exit 1
}

resolve_log() {
  local selector="$1"
  if [ -n "$selector" ]; then
    local selector=' | select('"$selector"')'
  fi
  for i in 1 2 4 8 16 32; do
    local log="$(\cat $OTEL_EXPORT_LOCATION | \jq ". | select(.body != null)$selector")"
    if [ -n "$log" ]; then
      \echo "$log"
      return 0
    fi
    \sleep $i
  done
  \echo "could not resolve log!" 1>&2
  exit 1
}
