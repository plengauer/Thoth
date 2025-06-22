#!/bin/false

# wget -O - https://www.google.at => wget -O - https://www.google.at '--header=traceparent: 00-XXXXXX-01'

_otel_propagate_wget() {
  case "$-" in
    *m*) local job_control=1; \set +m;;
    *) local job_control=0;;
  esac
  if \[ -f /opt/opentelemetry_shell/libinjecthttpheader.so ] && ! ( \[ "$_otel_shell" = 'busybox sh' ] && \help | \tail -n +3 | \grep -q wget ); then
    export OTEL_SHELL_INJECT_HTTP_SDK_PIPE="$_otel_remote_sdk_pipe"
    export OTEL_SHELL_INJECT_HTTP_HANDLE_FILE="$(\mktemp -u)_opentelemetry_shell_$$.wget.handle"
    local OLD_LD_PRELOAD="${LD_PRELOAD:-}"
    export LD_PRELOAD=/usr/opentelemetry_shell/agent.instrumentation.http/"$(\arch)"/libinjecthttpheader.so
    if \[ -n "$OLD_LD_PRELOAD" ]; then
      export LD_PRELOAD="$LD_PRELOAD:$OLD_LD_PRELOAD"
    fi
  fi
  local stderr_pipe="$(\mktemp -u)_opentelemetry_shell_$$.stderr.wget.pipe"
  \mkfifo "$stderr_pipe"
  _otel_pipe_wget_stderr "${OTEL_SHELL_INJECT_HTTP_HANDLE_FILE:-}" < "$stderr_pipe" >&2 &
  local stderr_pid="$!"
  local exit_code=0
  _otel_call "$@" --header="traceparent: $TRACEPARENT" --header="tracestate: $TRACESTATE" 2> "$stderr_pipe" || exit_code="$?"
  \wait "$stderr_pid"
  \rm "$stderr_pipe"
  if \[ -f /opt/opentelemetry_shell/libinjecthttpheader.so ]; then
    if \[ -n "${OLD_LD_PRELOAD:-}" ]; then
      export LD_PRELOAD="$OLD_LD_PRELOAD"
    else
      unset LD_PRELOAD
    fi
    unset OTEL_SHELL_INJECT_HTTP_HANDLE_FILE
    unset OTEL_SHELL_INJECT_HTTP_SDK_PIPE
  fi
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}

# Resolving www.google.com (www.google.com)... 142.250.185.196, 2a00:1450:4001:809::2004
# Connecting to www.google.com (www.google.com)|142.250.185.196|:80... connected.
# Connecting to 127.0.0.1:12346... failed: Connection refused.
# HTTP request sent, awaiting response... 200 OK
# Length: unspecified [text/html]
# Saving to: ‘index.html.3’
# 
# 0K .......... .........                                   98.9M=0s
# 
# 2024-05-26 09:21:52 (98.9 MB/s) - ‘index.html.3’ saved [19975]
# 
# --2024-05-26 09:21:52--  http://www.google.com/index.html
# Reusing existing connection to www.google.com:80.
# HTTP request sent, awaiting response... 200 OK
# Length: unspecified [text/html]
# Saving to: ‘index.html.4’
# 
# 0K .......... .........                                    119M=0s
# 
# 2024-05-26 09:21:52 (119 MB/s) - ‘index.html.4’ saved [19608]

_otel_pipe_wget_stderr() {
  local span_handle_file="$1"
  local span_handle=""
  while \read -r line; do
    \echo "$line"
    if _otel_string_starts_with "$line" --; then
      case "$line" in
        --****-**-**' '**:**:**--'  '*)
          local url="$(\printf '%s' "$line" | \cut -d ' ' -f 4-)"
          local protocol="$(\printf '%s' "$url" | \cut -d : -f 1)"
          local path_and_query="/$(\printf '%s' "$url" | \cut -sd / -f 4-)"
          ;;
      esac
    fi
    if _otel_string_starts_with "$line" 'Connecting to '; then
      if _otel_string_contains "$(\printf '%s', "$line" | \cut -sd ' ' -f 4)" '|'; then
        local host="$(\printf '%s' "$line" | \cut -d ' ' -f 4 | \cut -d '|' -f 1 | \tr -d '()')"
        local ip="$(\printf '%s' "$line" | \cut -d ' ' -f 4 | \cut -d '|' -f 2)"
        local port="$(\printf '%s' "$line" | \cut -d ' ' -f 4 | \cut -d '|' -f 3 | \tr -d ':.')"
      else
        local ip="$(\printf '%s' "$line" | \cut -d ' ' -f 3 | \cut -d ':' -f 1)"
        local host="$ip"
        local port="$(\printf '%s' "$line" | \cut -d ' ' -f 3 | \cut -d ':' -f 2 | \tr -d '.')"
      fi
    fi
    # Connecting to www.google.at (www.google.at)|142.250.185.131|:80... connected.
    if _otel_string_starts_with "$line" 'Connecting to ' || _otel_string_starts_with "$line" 'Reusing existing connection to '; then
      if \[ -n "$span_handle" ]; then otel_span_end "$span_handle"; local span_handle=""; fi
      if \[ -n "$span_handle_file" ]; then while ! \[ -f "$span_handle_file" ]; do \sleep 1; done; local span_handle="$(\cat "$span_handle_file")"; \rm "$span_handle_file"; fi
      if \[ -z "$span_handle" ]; then
        local span_handle="$(otel_span_start CLIENT GET)"
      else
        otel_span_name "$span_handle" GET
      fi
      otel_span_attribute_typed "$span_handle" string network.protocol.name="$protocol"
      otel_span_attribute_typed "$span_handle" string network.transport=tcp
      otel_span_attribute_typed "$span_handle" string network.peer.address="$ip"
      otel_span_attribute_typed "$span_handle" int network.peer.port="$port"
      otel_span_attribute_typed "$span_handle" string server.address="$host"
      otel_span_attribute_typed "$span_handle" int server.port="$port"
      otel_span_attribute_typed "$span_handle" string url.full="$url"
      otel_span_attribute_typed "$span_handle" string url.path="$(\printf '%s' "$path_and_query" | \cut -d ? -f 1)"
      otel_span_attribute_typed "$span_handle" string url.query="$(\printf '%s' "$path_and_query" | \cut -sd ? -f 2-)"
      otel_span_attribute_typed "$span_handle" string url.scheme="$protocol"
      otel_span_attribute_typed "$span_handle" string user_agent.original=wget
      otel_span_attribute_typed "$span_handle" string http.request.method=GET
    fi
    if \[ -n "$span_handle" ]; then
      if _otel_string_starts_with "$line" "HTTP request sent, awaiting response... "; then
        # HTTP request sent, awaiting response... 301 Moved Permanently
        # HTTP request sent, awaiting response... 200 OK
        local response_code="$(\printf '%s' "$line" | \cut -d ' ' -f 6)"
        otel_span_attribute_typed "$span_handle" int http.response.status_code="$response_code"
        if \[ "$response_code" -ge 400 ]; then otel_span_error "$span_handle"; fi
      elif _otel_string_starts_with "$line" "Length: "; then
        # Length: unspecified [text/html]
        # Length: 17826 (17K) [application/octet-stream]
        otel_span_attribute_typed "$span_handle" string[1] http.response.header.content-type="$(\printf '%s' "$line" | \cut -d '[' -f 2 | \tr -d '[]')"
        otel_span_attribute_typed "$span_handle" string[1] http.response.header.content-length="$(\printf '%s' "$line" | \cut -d ' ' -f 2)"
      elif _otel_string_contains "$line" " written to " || _otel_string_contains "$line" " saved "; then
        # 2024-04-01 11:32:28 (12.3 MB/s) - written to stdout [128]
        # 2024-04-01 11:23:16 (18.4 MB/s) - ‘index.html’ saved [18739]
        # 2024-04-06 17:37:30 (102 MB/s) - written to stdout [17826/17826]
        otel_span_attribute_typed "$span_handle" string[1] http.response.header.content-length="$(\printf '%s' "$line" | \cut -d '[' -f 2 | \tr -d '[]' | \cut -d / -f 1)"
      elif _otel_string_starts_with "$line" "HTTP/"; then # only available in debug mode, but splits up the usual response code line
        local response_code="$(\printf '%s' "$line" | \cut -d ' ' -f 2)"
        otel_span_attribute_typed "$span_handle" int http.response.status_code="$response_code"
        if \[ "$response_code" -ge 300 ]; then otel_span_error "$span_handle"; fi
      elif _otel_string_starts_with "$line" "User-Agent: "; then # only available in debug mode
        otel_span_attribute_typed "$span_handle" string user_agent.original="$(\printf '%s' "$line" | \cut -d ' ' -f 2)"
      elif _otel_string_starts_with "$line" "Content-Length: "; then # only available in debug mode
        otel_span_attribute_typed "$span_handle" int http.response.body.size="$(\printf '%s' "$line" | \cut -d ' ' -f 2)"
      fi
    fi
  done
  if \[ -n "$span_handle" ]; then otel_span_end "$span_handle"; fi
}

_otel_alias_prepend wget _otel_propagate_wget
_otel_alias_prepend wget2 _otel_propagate_wget
