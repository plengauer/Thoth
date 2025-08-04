#!/bin/false

_otel_inject_java() {
  local version="$(_otel_call "$1" --version | \head -n 1 | \cut -d ' ' -f 2 | \cut -d . -f 1)"
  if \[ "${OTEL_SHELL_CONFIG_INJECT_DEEP:-FALSE}" = TRUE ] && \[ -r /usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar ] && \[ -r /usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar ] && \[ -r /usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar ] && \[ "$version" -ge "$(cat /usr/share/opentelemetry_shell/agent.instrumentation.java/version)" ]; then
    local command="$1"; shift
    _otel_call "$1" -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar "$@"
  else
    _otel_call "$@"
  fi
}

_otel_alias_prepend java _otel_inject_java
