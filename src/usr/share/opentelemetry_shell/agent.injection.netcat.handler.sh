#!/bin/sh -e
. otelapi.sh
handler_command_string="_otel_inject $(_otel_escape_args "$@")"
netcat_command_string="$OTEL_SHELL_NETCAT_COMMAND"
unset OTEL_SHELL_NETCAT_COMMAND
export OTEL_SHELL_SDK_OUTPUT_REDIRECT="${OTEL_SHELL_SDK_OUTPUT_REDIRECT:-/dev/null}"
OTEL_SHELL_AUTO_INSTRUMENTATION_HINT="$handler_command_string"
OTEL_SHELL_AUTO_INJECTED=TRUE
. otel.sh

span_handle="$(otel_span_start CONSUMER send/receive)"
_otel_netcat_parse_args 1 "$span_handle" $netcat_command_string > /dev/null
otel_span_activate "$span_handle"

if \[ "${OTEL_SHELL_CONFIG_NETCAT_ASSUME_REQUEST_RESPONSE:-FALSE}" = TRUE ]; then
  exit_code_file="$(\mktemp)"
  \echo 0 > "$exit_code_file"
  span_handle_file_0="$(\mktemp -u)_opentelemetry_shell_$$.netcat.request.span_handle"
  span_handle_file_1="$(\mktemp -u)_opentelemetry_shell_$$.netcat.command.span_handle"
  span_handle_file_2="$(\mktemp -u)_opentelemetry_shell_$$.netcat.response.span_handle"
  \mkfifo "$span_handle_file_0" "$span_handle_file_1" "$span_handle_file_2"
  (\cat "$span_handle_file_0" | \tee "$span_handle_file_1" | \tee "$span_handle_file_2" > /dev/null &)
  export OTEL_SHELL_CONFIG_NETCAT_READ_TIMEOUT=60
  _otel_netcat_parse_request 1 "$span_handle_file_0" $netcat_command_string | { unset OTEL_SHELL_CONFIG_NETCAT_READ_TIMEOUT; otel_span_activate "$(\cat "$span_handle_file_1")"; \eval "$handler_command_string" || \echo "$?" > "$exit_code_file"; } | _otel_netcat_parse_response 1 "$span_handle_file_2"
  exit_code="$(\cat "$exit_code_file")"
  \rm "$span_handle_file_0" "$span_handle_file_1" "$span_handle_file_2" "$exit_code_file" 2> /dev/null
else
  exit_code=0
  \eval "$handler_command_string" || exit_code=$?
fi

otel_span_deactivate "$span_handle"
otel_span_end "$span_handle"
exit $exit_code
