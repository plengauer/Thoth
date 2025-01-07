#!/bin/false

# /usr/bin/docker run --rm --privileged tonistiigi/binfmt:latest --install all

_otel_is_boolean_docker_option() {
  case "$1" in
    -d) return 0;;
    --detach) return 0;;
    -t) return 0;;
    --tty) return 0;;
    -rm) return 0;;
    --rm) return 0;;
    --privileged) return 0;;
    --version) return 0;;
    --help) return 0;;
    *) return 1;;
  esac
}

_otel_is_docker_image_injectable() {
  local executable="$1"
  local image="$2"
  "$executable" run --rm --entrypoint cat "$image" /etc/os-release | \grep -E '^NAME=' | \grep -qE 'Debian|Ubuntu|Alpine Linux|Fedora Linux|Red Hat Enterprise Linux|openSUSE'
}

_otel_is_docker_image_injected() {
  local executable="$1"
  local image="$2"
  "$executable" run --rm --entrypoint which "$image" otel.sh 1> /dev/null 2> /dev/null
}

_otel_inject_docker_args() {
  # docker command
  local executable="$1"
  local executable="${executable#\\}"
  _otel_escape_arg "$1"; shift
  # skip arguments
  while \[ "$#" -gt 0 ] && _otel_string_starts_with "$1" -; do
    \echo -n ' '; _otel_escape_arg "$1"
    if ! _otel_is_boolean_docker_option "$1" && ! _otel_string_contains "$1" =; then
      shift
      \echo -n ' '; _otel_escape_arg "$1"
    fi
    shift
  done
  # extract and skip command
  local command="$1"
  \echo -n ' '; _otel_escape_arg "$1"; shift
  # early abort
  if \[ "$command" != run ]; then
    while \[ "$#" -gt 0 ]; do \echo -n ' '; _otel_escape_arg "$1"; shift; done
    return 0
  fi
  # skip more arguments
  while \[ "$#" -gt 0 ] && _otel_string_starts_with "$1" -; do
    \echo -n ' '; _otel_escape_arg "$1"
    if ! _otel_is_boolean_docker_option "$1" && ! _otel_string_contains "$1" =; then
      if \[ "$1" = --entrypoint ]; then local entrypoint_override="$2"; fi
      shift
      \echo -n ' '; _otel_escape_arg "$1"
    fi
    shift
  done
  if \[ "$#" = 0 ]; then return 0; fi
  # extract image
  local image="$1"
  if _otel_is_docker_image_injectable "$executable" "$image" && ! _otel_is_docker_image_injected "$executable" "$image" && ( ! \[ "$GITHUB_ACTIONS" = true ] || ! \printenv | \cut -d = -f 1 | \grep -E '^INPUT_' | \grep -q - ); then
    \echo -n ' '; _otel_escape_args --env TRACEPARENT="$TRACEPARENT" --env TRACESTATE="$TRACESTATE"
    for file in $(\dpkg -L opentelemetry-shell | \grep -E '^/usr/bin/'); do \echo -n ' '; _otel_escape_args --mount type=bind,source="$file",target="$file",readonly; done
    \echo -n ' '; _otel_escape_args --mount type=bind,source=/usr/share/opentelemetry_shell,target=/usr/share/opentelemetry_shell
    \echo -n ' '; _otel_escape_args --mount type=bind,source=/opt/opentelemetry_shell,target=/opt/opentelemetry_shell
    for kvp in $(\printenv | \grep '^OTEL_' | \cut -d = -f 1); do \echo -n ' '; _otel_escape_args --env "$kvp"; done
    \chmod 666 "$_otel_remote_sdk_pipe"
    \echo -n ' '; _otel_escape_args --mount type=bind,source="$_otel_remote_sdk_pipe",target=/var/opentelemetry_shell"$_otel_remote_sdk_pipe"
    \echo -n ' '; _otel_escape_args --env OTEL_REMOTE_SDK_PIPE=/var/opentelemetry_shell"$_otel_remote_sdk_pipe"
    local pipes_dir="$(\mktemp -u)_opentelemetry_shell_$$.docker"; \mkdir -p "$pipes_dir"; \chmod 777 "$pipes_dir"
    \echo -n ' '; _otel_escape_args --mount type=bind,source="$pipes_dir",target="$pipes_dir"
    \echo -n ' '; _otel_escape_args --env OTEL_SHELL_PIPE_DIR="$pipes_dir"
    \echo -n ' '; _otel_escape_args --env OTEL_SHELL_AUTO_INJECTED=TRUE
    \echo -n ' '; _otel_escape_args --entrypoint /bin/sh
    \echo -n ' '; _otel_escape_arg "$1"; shift
    \echo -n ' '; _otel_escape_args -c '. otel.sh
eval _otel_inject "$(_otel_escape_args "$@")"' sh
    \echo -n ' '; if \[ -n "${entrypoint_override:-}" ]; then \echo "$entrypoint_override" | _otel_line_split; else "$executable" inspect "$image" | \jq -r '.[0].Config.Entrypoint[]?'; fi | _otel_escape_stdin
    if \[ "$#" = 0 ]; then \echo -n ' '; "$executable" inspect "$image" | \jq -r '.[0].Config.Cmd[]?' | _otel_escape_stdin; fi
  else
    \echo -n ' '; _otel_escape_args --env TRACEPARENT="$TRACEPARENT" --env TRACESTATE="$TRACESTATE"
    \echo -n ' '; _otel_escape_arg "$1"; shift
  fi
  # just skip the rest
  while \[ "$#" -gt 0 ]; do \echo -n ' '; _otel_escape_arg "$1"; shift; done
}

_otel_inject_docker() {
  # some docker commands have otel built-in and do not support console exporters. EDIT: this cannot be reproduced anymore
  # local command_string="$(_otel_inject_docker_args "$@")"
  # if _otel_string_contains "$OTEL_LOGS_EXPORTER" console; then local otel_logs_exporter="$(\echo "$OTEL_LOGS_EXPORTER" | \tr ',' '\n' | \grep -vE '^console$' | \head --lines=1)"; fi
  # if _otel_string_contains "$OTEL_METRICS_EXPORTER" console; then local otel_metrics_exporter="$(\echo "$OTEL_METRICS_EXPORTER" | \tr ',' '\n' | \grep -vE '^console$' | \head --lines=1)"; fi
  # if _otel_string_contains "$OTEL_TRACES_EXPORTER" console; then local otel_traces_exporter="$(\echo "$OTEL_TRACES_EXPORTER" | \tr ',' '\n' | \grep -vE '^console$' | \head --lines=1)"; fi
  # OTEL_LOGS_EXPORTER="$otel_logs_exporter" OTEL_METRICS_EXPORTER="$otel_metrics_exporter" OTEL_TRACES_EXPORTER="$otel_traces_exporter"
  \eval _otel_call "$(_otel_inject_docker_args "$@")"
}

_otel_alias_prepend docker _otel_inject_docker
_otel_alias_prepend podman _otel_inject_docker
