#!/bin/false
# shellcheck shell=bash

_otel_inject_java() {
  local version="$(_otel_call "$1" -cp /usr/share/opentelemetry_shell/agent.instrumentation.java SystemPropertiesPrinter | \grep '^java.version=' | \cut -d = -f 2 | \cut -d . -f 1)"
  if \[ "${OTEL_SHELL_CONFIG_INJECT_DEEP:-FALSE}" = TRUE ] && \[ -r /usr/share/opentelemetry_shell/agent.instrumentation.java/gradlehttppropagationagent.jar ] && \[ -r /usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar ] && \[ -r /usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar ] && \[ -r /usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar ] && \[ "$version" -ge "$(cat /usr/share/opentelemetry_shell/agent.instrumentation.java/version)" ]; then
    local command="$1"
    shift
    if \[ "${OTEL_DISABLE_RESOURCE_DETECTION:-FALSE}" = TRUE ]; then
      local disabled_resource_providers="${OTEL_JAVA_DISABLED_RESOURCE_PROVIDERS:+$OTEL_JAVA_DISABLED_RESOURCE_PROVIDERS,}io.opentelemetry.instrumentation.resources.ContainerResourceProvider,io.opentelemetry.instrumentation.resources.HostIdResourceProvider,io.opentelemetry.instrumentation.resources.HostResourceProvider,io.opentelemetry.instrumentation.resources.OsResourceProvider"
      OTEL_JAVA_DISABLED_RESOURCE_PROVIDERS="$disabled_resource_providers" OTEL_BSP_MAX_EXPORT_BATCH_SIZE=1 _otel_call "$command" -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/gradlehttppropagationagent.jar "$@"
    else
      OTEL_BSP_MAX_EXPORT_BATCH_SIZE=1 _otel_call "$command" -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar -javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/gradlehttppropagationagent.jar "$@"
    fi
  else
    _otel_call "$@"
  fi
}

_otel_alias_prepend java _otel_inject_java
