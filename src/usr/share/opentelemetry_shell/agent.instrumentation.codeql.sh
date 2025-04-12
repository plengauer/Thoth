#!/bin/false

if \[ "${GITHUB_ACTIONS:-false}" = true ] && \[ -x "$0" ] && _otel_string_ends_with "$0" /codeql && \cat "$0" | \grep -qv _otel_inject; then
  \sed -i 's~^"${CODEQL_JAVA_HOME}/bin/java"~_otel_inject "${CODEQL_JAVA_HOME}/bin/java"~g' "$0"
  \eval '"exec"' "$(\xargs -0 sh -c '. otelapi.sh; _otel_escape_args "$@"' sh < /proc/$$/cmdline)"
fi
