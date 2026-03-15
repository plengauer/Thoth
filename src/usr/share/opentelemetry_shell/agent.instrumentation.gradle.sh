#!/bin/false

_otel_inject_gradle() {
  local version="$(_otel_call java -cp /usr/share/opentelemetry_shell/agent.instrumentation.java SystemPropertiesPrinter | \grep '^java.version=' | \cut -d = -f 2 | \cut -d . -f 1)"
  if \[ "${OTEL_SHELL_CONFIG_INJECT_DEEP:-FALSE}" = TRUE ] && \[ -r /usr/share/opentelemetry_shell/agent.instrumentation.java/gradlehttppropagationagent.jar ] && \[ -r /usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar ] && \[ -r /usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar ] && \[ -r /usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar ] && \[ "$version" -ge "$(cat /usr/share/opentelemetry_shell/agent.instrumentation.java/version)" ]; then
    local old_gradle_opts="${GRADLE_OPTS:-}"
    export GRADLE_OPTS="${GRADLE_OPTS:-} -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/gradlehttppropagationagent.jar"
    _otel_call "$@"
    export GRADLE_OPTS="$old_gradle_opts"
  else
    _otel_call "$@"
  fi
}

_otel_alias_prepend gradle _otel_inject_gradle
_otel_alias_prepend gradlew _otel_inject_gradle
