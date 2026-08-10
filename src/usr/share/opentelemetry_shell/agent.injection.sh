#!/bin/sh
export OTEL_SHELL_AUTO_INJECTED=TRUE
. otel.sh
unset OTEL_SHELL_AUTO_INJECTED
\unalias env
_otel_inject_env env "$@"
