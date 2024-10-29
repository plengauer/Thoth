#!/bin/sh -e
if [ "$OTEL_SHELL_AUTO_INJECTED" = TRUE ]; then
  exec "$@"
else
  . otelapi.sh
  \eval "$(\grep -vh '_otel_alias_prepend ' /usr/share/opentelemetry_shell/agent.instrumentation.netcat.sh)"
  _otel_inject_netcat "$@"
fi
