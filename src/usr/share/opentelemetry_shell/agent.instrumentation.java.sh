#!/bin/false

_otel_inject_java() {
  local version="$(_otel_call "$1" -cp "$_otel_shell_home"/agent.instrumentation.java SystemPropertiesPrinter | \grep '^java.version=' | \cut -d = -f 2 | \cut -d . -f 1)"
  if \[ "${OTEL_SHELL_CONFIG_INJECT_DEEP:-FALSE}" = TRUE ] && \[ -r "$_otel_shell_home"/agent.instrumentation.java/gradlehttppropagationagent.jar ] && \[ -r "$_otel_shell_home"/agent.instrumentation.java/subprocessinjectionagent.jar ] && \[ -r "$_otel_shell_home"/agent.instrumentation.java/rootcontextagent.jar ] && \[ -r "$_otel_shell_home"/agent.instrumentation.java/opentelemetry-javaagent.jar ] && \[ "$version" -ge "$(cat "$_otel_shell_home"/agent.instrumentation.java/version)" ]; then
    local command="$1"; shift
    OTEL_BSP_MAX_EXPORT_BATCH_SIZE=1 _otel_call "$command" -javaagent:"$_otel_shell_home"/agent.instrumentation.java/opentelemetry-javaagent.jar -javaagent:"$_otel_shell_home"/agent.instrumentation.java/rootcontextagent.jar -javaagent:"$_otel_shell_home"/agent.instrumentation.java/subprocessinjectionagent.jar -javaagent:"$_otel_shell_home"/agent.instrumentation.java/gradlehttppropagationagent.jar "$@"
  else
    _otel_call "$@"
  fi
}

_otel_alias_prepend java _otel_inject_java
