#!/bin/false

if \[ "${GITHUB_ACTIONS:-false}" = true ] && \[ "${GITHUB_AW:-false}" = true ] && \type yq 1> /dev/null 2> /dev/null; then
  _otel_inject_docker_compose_up() {
    local compose_file=""
    for candidate in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
      if \[ -f "$candidate" ]; then
        local compose_file="$candidate"
        break
      fi
    done
    \[ -n "$compose_file" ] || return 0
    \yq -i '.services[].volumes += [{"type": "bind", "source": "/usr/share/opentelemetry_shell", "target": "/usr/share/opentelemetry_shell", "read_only": true}]' "$compose_file" # SKIP_DEPENDENCY_CHECK
    \yq -i '.services[].volumes += [{"type": "bind", "source": "/opt/opentelemetry_shell", "target": "/opt/opentelemetry_shell", "read_only": true}]' "$compose_file" # SKIP_DEPENDENCY_CHECK
    { \find /usr/bin -executable -iname 'otel*.sh'; \find /usr/bin -executable -iname 'opentelemetry_shell*.sh'; } | while \read -r otel_file; do
      OTEL_BIND_FILE="$otel_file" \yq -i '.services[].volumes += [{"type": "bind", "source": strenv(OTEL_BIND_FILE), "target": strenv(OTEL_BIND_FILE), "read_only": true}]' "$compose_file" # SKIP_DEPENDENCY_CHECK
    done
    TRACEPARENT="$TRACEPARENT" \yq -i '.services[].environment.TRACEPARENT = strenv(TRACEPARENT)' "$compose_file" # SKIP_DEPENDENCY_CHECK
    TRACESTATE="$TRACESTATE" \yq -i '.services[].environment.TRACESTATE = strenv(TRACESTATE)' "$compose_file" # SKIP_DEPENDENCY_CHECK
    \printenv | \grep '^OTEL_' | \cut -d= -f1 | while \read -r otel_var; do
      OTEL_VAR_KEY="$otel_var" OTEL_VAR_VAL="$(\printenv "$otel_var")" \yq -i '.services[].environment[strenv(OTEL_VAR_KEY)] = strenv(OTEL_VAR_VAL)' "$compose_file" # SKIP_DEPENDENCY_CHECK
    done
    \yq '.services | keys | .[]' "$compose_file" | while \read -r service; do # SKIP_DEPENDENCY_CHECK
      ep_raw=$(\yq ".services[\"$service\"].entrypoint" "$compose_file") # SKIP_DEPENDENCY_CHECK
      ep_type=$(\yq ".services[\"$service\"].entrypoint | type" "$compose_file") # SKIP_DEPENDENCY_CHECK
      case "$ep_raw" in
        null)
          OTEL_EP_WRAP='. otel.sh; eval _otel_inject "$0" "$@"' \yq -i ".services[\"$service\"].entrypoint = [\"/bin/sh\", \"-c\", strenv(OTEL_EP_WRAP)]" "$compose_file" # SKIP_DEPENDENCY_CHECK
          ;;
        *)
          case "$ep_type" in
            *seq) ep_joined=$(\yq ".services[\"$service\"].entrypoint | join(\" \")" "$compose_file");; # SKIP_DEPENDENCY_CHECK
            *) ep_joined="$ep_raw";;
          esac
          OTEL_EP_WRAP=". otel.sh; eval _otel_inject $ep_joined \"\$@\"" \yq -i ".services[\"$service\"].entrypoint = [\"/bin/sh\", \"-c\", strenv(OTEL_EP_WRAP), \"sh\"]" "$compose_file" # SKIP_DEPENDENCY_CHECK
          ;;
      esac
    done
  }

  _otel_inject_docker_aw() {
    local cmdline="$(_otel_dollar_star "$@")"
    while _otel_string_starts_with "$cmdline" "_otel_"; do local cmdline="${cmdline#* }"; done
    local cmdline="${cmdline#\\}"
    if \[ "$cmdline" = "docker compose up -d" ]; then
      _otel_inject_docker_compose_up
    fi
    _otel_call "$@"
  }

  _otel_alias_prepend_function=_otel_alias_prepend
  $_otel_alias_prepend_function docker _otel_inject_docker_aw
fi
