#!/bin/sh -e
if [ "${OTEL_SHELL_AUTO_INJECTED:-FALSE}" = TRUE ]; then
  exec "$@"
else
  . otelapi.sh
  \eval "$(\grep -vh '_otel_alias_prepend ' "$_otel_shell_home"/agent.instrumentation.netcat.sh)"
  _otel_inject_netcat "$@"
fi
