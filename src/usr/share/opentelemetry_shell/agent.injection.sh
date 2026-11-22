#!/bin/sh
# OTEL4SH_PREFIX_COMMAND (optional) is prepended to the command, for callers that only accept an executable rather than a command string (e.g., scp -S, sftp -S)
if [ -n "${OTEL4SH_PREFIX_COMMAND:-}" ]; then set -- "$OTEL4SH_PREFIX_COMMAND" "$@"; fi
unset OTEL4SH_PREFIX_COMMAND
export OTEL_SHELL_AUTO_INJECTED=TRUE
. otel.sh
unset OTEL_SHELL_AUTO_INJECTED
\unalias env
_otel_inject_env env "$@"
