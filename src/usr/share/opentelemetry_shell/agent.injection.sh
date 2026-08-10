#!/bin/sh
if [ $# -eq 0 ]; then
  echo "Usage: otel4sh <command> [args...]" >&2
  exit 1
fi
OTEL_SHELL_AUTO_INJECTED=TRUE . /usr/bin/otel.sh
exec env "$@"
