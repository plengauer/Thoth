#!/bin/false

# curl -v https://www.google.at => curl -v https://www.google.at -H 'traceparent: 00-XXXXXX-01'

_otel_propagate_curl() {
  case "$-" in
    *m*) local job_control=1; \set +m;;
    *) local job_control=0;;
  esac
  local file=/usr/share/opentelemetry_shell/agent.instrumentation.http/"$(\arch)"/libinjecthttpheader.so
  if \[ -f "$file" ] && ! \ldd "$file" 2> /dev/null | \grep -q 'not found' && ! ( \[ "$_otel_shell" = 'busybox sh' ] && \help | \tail -n +3 | \grep -q curl ); then
    export OTEL_SHELL_INJECT_HTTP_SDK_PIPE="$_otel_remote_sdk_pipe"
    export OTEL_SHELL_INJECT_HTTP_HANDLE_FILE="$(\mktemp -u)_opentelemetry_shell_$$.curl.handle"
    local OLD_LD_PRELOAD="${LD_PRELOAD:-}"
    export LD_PRELOAD="$file"
    if \[ -n "$OLD_LD_PRELOAD" ]; then
      export LD_PRELOAD="$LD_PRELOAD:$OLD_LD_PRELOAD"
    fi
  fi
  if _otel_string_contains "$(_otel_dollar_star "$@")" " -v "; then local is_verbose=1; else local is_verbose=0; fi
  local api="$(_otel_curl_guess_api "$@")"
  if \[ -n "$api" ]; then
    local span_handle_forward="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.span_handle_forward.curl.pipe.XXXXXXXXXX)"
    local api_recording_finished="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.api.finished.curl.pipe.XXXXXXXXXX)"
    \mkfifo "$span_handle_forward" "$api_recording_finished"
  fi
  local stderr_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.stderr.curl.pipe.XXXXXXXXXX)"
  \mkfifo "$stderr_pipe"
  _otel_pipe_curl_stderr "$is_verbose" "${OTEL_SHELL_INJECT_HTTP_HANDLE_FILE:-}" "${span_handle_forward:-/dev/null}" "${api_recording_finished:-/dev/null}" < "$stderr_pipe" >&2 &
  local stderr_pid="$!"
  \set -- "$@" -H "traceparent: $TRACEPARENT" -H "tracestate: $TRACESTATE" -v --no-progress-meter
  local exit_code=0
  if \[ -n "$api" ]; then _otel_call_curl_api "$span_handle_forward" "$api_recording_finished" "$api" "$@"; else _otel_call "$@"; fi 2> "$stderr_pipe" || exit_code="$?"
  \wait "$stderr_pid"
  \rm -rf "$stderr_pipe"
  if \[ -n "$api" ]; then \rm -rf "$stderr_pipe" "$span_handle_forward" "$api_recording_finished"; fi
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

# * processing: http://www.google.at
# *   Trying 142.250.185.131:80...
# * Connected to www.google.at (142.250.185.131) port 80
# > GET / HTTP/1.1
# > Host: www.google.at
# > User-Agent: curl/8.2.1
# > Accept: */*
# > 
# < HTTP/1.1 200 OK
# < Date: Mon, 01 Apr 2024 12:07:04 GMT
# < Expires: -1
# < Cache-Control: private, max-age=0
# < Content-Type: text/html; charset=ISO-8859-1
# < Content-Security-Policy-Report-Only: object-src 'none';base-uri 'self';script-src 'nonce-XyxOUCdoVMoXXWssicVB8w' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
# < Server: gws
# < X-XSS-Protection: 0
# < X-Frame-Options: SAMEORIGIN
# < Set-Cookie: AEC=Ae3NU9Nf2b8VcyzvNeUwJ8BRqswj9ZwLzRocK-cNggFOpCvbR23FNIaZnbs; expires=Sat, 28-Sep-2024 12:07:04 GMT; path=/; domain=.google.at; Secure; HttpOnly; SameSite=lax
# < Accept-Ranges: none
# < Vary: Accept-Encoding
# < Transfer-Encoding: chunked
# < 
# { [11811 bytes data]
# * Connection #0 to host www.google.at left intact

_otel_pipe_curl_stderr() {
  local is_verbose="$1"
  local span_handle_file="$2"
  local span_handle_file_forward="${3:-/dev/null}"
  local api_recording_finished="${4:-/dev/null}"
  local span_handle=""
  local host=""
  local ip=""
  local port=""
  local is_receiving=1
  while \read -r line; do
    if _otel_string_starts_with "$line" "* Connected to "; then # * Connected to www.google.at (142.250.185.131) port 80
      local host="$(\printf '%s' "$line" | \cut -d ' ' -f 4)"
      local ip="$(\printf '%s' "$line" | \cut -d ' ' -f 5 | \tr -d '()')"
      local port="$(\printf '%s' "$line" | \cut -d ' ' -f 7)"
    elif _otel_string_starts_with "$line" "* Established connection to "; then # * Established connection to www.google.com (172.217.18.4 port 443) from 172.31.41.64 port 39476
      local host="$(\printf '%s' "$line" | \cut -d ' ' -f 5)"
      local ip="$(\printf '%s' "$line" | \cut -d ' ' -f 6 | \tr -d '()')"
      local port="$(\printf '%s' "$line" | \cut -d ' ' -f 8 | \tr -d '()')"
    fi
    if \[ -n "$span_handle" ] && _otel_string_starts_with "$line" "* shutting down connection "; then : < "$api_recording_finished"; otel_span_end "$span_handle"; local span_handle=""; fi
    if \[ -n "$span_handle" ] && _otel_string_starts_with "$line" "* closing connection "; then : < "$api_recording_finished"; otel_span_end "$span_handle"; local span_handle=""; fi
    if \[ -n "$span_handle" ] && _otel_string_starts_with "$line" "* Connection " && _otel_string_ends_with "$line" " left intact"; then : < "$api_recording_finished"; otel_span_end "$span_handle"; local span_handle=""; fi
    if \[ -n "$span_handle" ] && _otel_string_starts_with "$line" "* Connected to "; then : < "$api_recording_finished"; otel_span_end "$span_handle"; local span_handle=""; fi
    if \[ -n "$span_handle" ] && _otel_string_starts_with "$line" "* processing: "; then : < "$api_recording_finished"; otel_span_end "$span_handle"; local span_handle=""; fi
    if \[ -n "$span_handle" ] && \[ "$is_receiving" = 1 ] && _otel_string_starts_with "$line" "> "; then otel_span_end "$span_handle"; local span_handle=""; fi
    if \[ -z "$span_handle" ] && \[ -n "$host" ] && \[ -n "$ip" ] && \[ -n "$port" ] && _otel_string_starts_with "$line" "> " && \[ "$is_receiving" = 1 ]; then
      local is_receiving=0
      local protocol="$(\printf '%s' "$line" | \cut -d ' ' -f 4 | \cut -d / -f 1 | \tr '[:upper:]' '[:lower:]')"
      if \[ "$protocol" = http ] && \[ "$port" = 443 ]; then local protocol=https; fi
      local path_and_query="$(\printf '%s' "$line" | \cut -d ' ' -f 3)"
      if \[ -n "$span_handle_file" ] && \[ -f "$span_handle_file" ]; then local span_handle="$(\cat "$span_handle_file")"; \rm "$span_handle_file"; fi
      if \[ -z "$span_handle" ]; then
        local span_handle="$(otel_span_start CLIENT "$(\printf '%s' "$line" | \cut -d ' ' -f 2)")"
      else
        otel_span_name "$span_handle" "$(\printf '%s' "$line" | \cut -d ' ' -f 2)"
      fi
      \echo "$span_handle" > "$span_handle_file_forward"
      otel_span_attribute_typed "$span_handle" string network.transport=tcp
      otel_span_attribute_typed "$span_handle" string network.protocol.name="$protocol"
      otel_span_attribute_typed "$span_handle" string network.protocol.version="$(\printf '%s' "$line" | \cut -d ' ' -f 4 | \cut -d / -f 2)"
      otel_span_attribute_typed "$span_handle" string network.peer.address="$ip"
      otel_span_attribute_typed "$span_handle" int network.peer.port="$port"
      otel_span_attribute_typed "$span_handle" string server.address="$host"
      otel_span_attribute_typed "$span_handle" int server.port="$port"
      otel_span_attribute_typed "$span_handle" string url.full="$protocol://$host:$port$path_and_query"
      otel_span_attribute_typed "$span_handle" string url.path="$(\printf '%s' "$path_and_query" | \cut -d ? -f 1)"
      otel_span_attribute_typed "$span_handle" string url.query="$(\printf '%s' "$path_and_query" | \cut -sd ? -f 2-)"
      otel_span_attribute_typed "$span_handle" string url.scheme="$protocol"
      otel_span_attribute_typed "$span_handle" string http.request.method="$(\printf '%s' "$line" | \cut -d ' ' -f 2)"
      otel_span_attribute_typed "$span_handle" string user_agent.original=curl
    fi
    if \[ -n "$span_handle" ]; then
      if _otel_string_starts_with "$line" "< HTTP/"; then
        local response_code="$(\printf '%s' "$line" | \cut -d ' ' -f 3)"
        otel_span_attribute_typed "$span_handle" int http.response.status_code="$response_code"
        if \[ "$response_code" -ge 400 ]; then otel_span_error "$span_handle"; fi
#     elif _otel_string_starts_with "$line" "} [" && _otel_string_contains "bytes data]"; then
#       otel_span_attribute_typed "$span_handle" +int http.request.body.size="$(\printf '%s' "$line" | \cut -d ' ' -f 2 | \tr -d '[')"
#     elif _otel_string_starts_with "$line" "{ [" && _otel_string_contains "bytes data]"; then
#       otel_span_attribute_typed "$span_handle" +int http.response.body.size="$(\printf '%s' "$line" | \cut -d ' ' -f 2 | \tr -d '[')"
      elif _otel_string_starts_with "$(\printf '%s' "$line" | \tr '[:upper:]' '[:lower:]')" "> user-agent: "; then
        otel_span_attribute_typed "$span_handle" string user_agent.original="$(\printf '%s' "$line" | \cut -d ' ' -f 3-)"
      elif _otel_string_starts_with "$(\printf '%s' "$line" | \tr '[:upper:]' '[:lower:]')" "> content-length: "; then
        otel_span_attribute_typed "$span_handle" int http.request.body.size="$(\printf '%s' "$line" | \cut -d ' ' -f 3)"
      elif _otel_string_starts_with "$(\printf '%s' "$line" | \tr '[:upper:]' '[:lower:]')" "< content-length: "; then
        otel_span_attribute_typed "$span_handle" int http.response.body.size="$(\printf '%s' "$line" | \cut -d ' ' -f 3)"
      fi
      if _otel_string_starts_with "$line" "> " && _otel_string_contains "$line" ": " && ! _otel_string_contains "$(\printf '%s' "$line" | \tr '[:upper:]' '[:lower:]')" "authorization: " && ! _otel_string_contains "$(\printf '%s' "$line" | \tr '[:upper:]' '[:lower:]')" "token: " && ! _otel_string_contains "$(\printf '%s' "$line" | \tr '[:upper:]' '[:lower:]')" "key: "; then
        otel_span_attribute_typed "$span_handle" +string[1] http.request.header."$(\printf '%s' "$line" | \cut -d ' ' -f 2 | \tr -d ':' | \tr '[:upper:]' '[:lower:]')"="$(\printf '%s' "$line" | \cut -d ' ' -f 3-)"
      elif _otel_string_starts_with "$line" "< " && _otel_string_contains "$line" ": "; then
        otel_span_attribute_typed "$span_handle" +string[1] http.response.header."$(\printf '%s' "$line" | \cut -d ' ' -f 2 | \tr -d ':' | \tr '[:upper:]' '[:lower:]')"="$(\printf '%s' "$line" | \cut -d ' ' -f 3-)"
      fi
    fi
    if _otel_string_starts_with "$line" "< "; then local is_receiving=1; fi
    if \[ "$is_verbose" = 1 ] || ! ( _otel_string_starts_with "$line" "* " || _otel_string_starts_with "$line" "> " || _otel_string_starts_with "$line" "< " || _otel_string_starts_with "$line" "{ " || _otel_string_starts_with "$line" "} " ); then
      \echo "$line"
    fi
  done
  if \[ -n "$span_handle" ]; then : < "$api_recording_finished"; otel_span_end "$span_handle"; fi
}

_otel_curl_guess_api() {
  while \[ "$#" -gt 0 ]; do
    case "$1" in
      'https://api.openai.com/'*) \echo llm_openai; break;;
    esac
    shift
  done
}

_otel_call_curl_api() {
  local span_handle_file="$1"; shift
  local api_recording_finished="$1"; shift
  local api="$1"; shift
  local request_file="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.api.request.curl.pipe.XXXXXXXXXX)"
  case "$api" in
    llm_openai) local response_processor=_otel_curl_record_api_response_llm_openai;;
  esac
  local request="$(_otel_curl_get_input_type "$@")"
  local exit_code_file="$(\mktemp)"
  \echo 0 > "$exit_code_file"
  case "$request" in
    @-) \tee "$request_file" | { _otel_call "$@" || \echo "$?" > "$exit_code_file"; };;
    @*) \cat < "${request#@}" > "$request_file"; { _otel_call "$@" || \echo "$?" > "$exit_code_file"; };;
    *) \printf '%s' "$request" > "$request_file"; { _otel_call "$@" || \echo "$?" > "$exit_code_file"; };;
  esac | if \[ -n "${response_processor:-}" ]; then $response_processor "$request_file" "$span_handle_file" "$api_recording_finished"; else ( : > "$api_recording_finished" & ); \cat; fi
  local exit_code="$(\cat "$exit_code_file")"
  \rm -rf "$exit_code_file" "$request_file"
  return "$exit_code"
}

_otel_curl_get_input_type() {
  while \[ "$#" -ge 2 ]; do
    case "$1" in
      -d|--data|--data-*) \echo "$2"; break;;
    esac
    shift
  done
}

_otel_curl_record_api_response_llm_openai() {
  local request_file="$1"
  local span_handle_file="$2"
  local api_recording_finished="$3"
  # local time_start="$(\date +%s.%N)"
  # local gen_ai_client_operation_duration_handle="$(otel_counter_create histogram gen_ai.client.operation.duration s 'GenAI operation duration')"
  local gen_ai_client_token_usage_handle="$(otel_counter_create counter gen_ai.client.token.usage '{token}' 'Number of input and output tokens used')"
  local span_handle="$(\cat "$span_handle_file")"
  otel_span_attribute_typed "$span_handle" string gen_ai.provider.name=openai
  \jq < "$request_file" '[ .model // "null", .service_tier // "null", .seed // "null", .n // "null", .max_completion_tokens // .max_tokens // "null", .temperature // "null", .top_k // "null", .top_p // "null", .frequency_penalty // "null", .presence_penalty // "null", ( . | tostring ) ] | @tsv' -c -r --unbuffered | while IFS="$(\printf '\t')" read -r model service_tier seed n max_tokens temperature top_k top_p frequency_penalty presence_penalty json; do
    \[ "$model" = null ] || otel_span_name "$span_handle" "generate_content $(\jq < "$request_file" .model -r)"
    \[ "$model" = null ] || otel_span_attribute_typed "$span_handle" string gen_ai.request.model="$model"    
    \[ "$service_tier" = null ] || otel_span_attribute_typed "$span_handle" string openai.request.service_tier="$service_tier"
    \[ "$seed" = null ] || otel_span_attribute_typed "$span_handle" int gen_ai.request.seed="$seed"
    \[ "$n" = null ] || otel_span_attribute_typed "$span_handle" int gen_ai.request.choice.count="$n"
    \[ "$max_tokens" = null ] || otel_span_attribute_typed "$span_handle" int gen_ai.request.max_tokens="$max_tokens"
    \[ "$temperature" = null ] || otel_span_attribute_typed "$span_handle" float gen_ai.request.temperature="$temperature"
    \[ "$top_k" = null ] || otel_span_attribute_typed "$span_handle" float gen_ai.request.top_k="$top_k"
    \[ "$top_p" = null ] || otel_span_attribute_typed "$span_handle" float gen_ai.request.top_p="$top_p"
    \[ "$frequency_penalty" = null ] || otel_span_attribute_typed "$span_handle" float gen_ai.request.frequency_penalty="$frequency_penalty"
    \[ "$presence_penalty" = null ] || otel_span_attribute_typed "$span_handle" float gen_ai.request.presence_penalty="$presence_penalty"
  done
  \jq '[ .object // "null", .id // "null", .model // "null", .system_fingerprint // "null", .service_tier // "null", .usage.prompt_tokens // .usage.input_tokens // "null", .usage.completion_tokens // .usage.output_tokens // "null", ( . | tostring ) ] | @tsv' -c -r --unbuffered | while IFS="$(\printf '\t')" read -r object id model system_fingerprint service_tier prompt_tokens completion_tokens json; do
    \[ "$id" = null ] || otel_span_attribute_typed "$span_handle" string gen_ai.response.id="$id"
    \[ "$model" = null ] || otel_span_attribute_typed "$span_handle" string gen_ai.response.model="$model"
    \[ "$system_fingerprint" = null ] || otel_span_attribute_typed "$span_handle" string openai.response.system_fingerprint="$system_fingerprint"
    \[ "$service_tier" = null ] || otel_span_attribute_typed "$span_handle" string openai.response.service_tier="$service_tier"
    if \[ "$prompt_tokens" != null ]; then
      otel_span_attribute_typed "$span_handle" int gen_ai.usage.input_tokens="$prompt_tokens"
      local observation_handle="$(otel_observation_create $prompt_tokens)"
      otel_observation_attribute_typed "$observation_handle" string gen_ai.provider.name=openai
      otel_observation_attribute_typed "$observation_handle" string gen_ai.operation.name=chat
      \[ "$system_fingerprint" = null ] || otel_observation_attribute_typed "$observation_handle" string openai.response.system_fingerprint="$system_fingerprint"
      \[ "$service_tier" = null ] || otel_observation_attribute_typed "$observation_handle" string openai.response.service_tier="$service_tier"
      otel_observation_attribute_typed "$observation_handle" string gen_ai.token.type=input
      \[ "$model" = null ] || otel_observation_attribute_typed "$observation_handle" string gen_ai.response.model="$model"
      otel_counter_observe "$gen_ai_client_token_usage_handle" "$observation_handle"
    fi
    if \[ "$completion_tokens" != null ]; then
      otel_span_attribute_typed "$span_handle" int gen_ai.usage.output_tokens="$completion_tokens"
      local observation_handle="$(otel_observation_create $completion_tokens)"
      otel_observation_attribute_typed "$observation_handle" string gen_ai.provider.name=openai
      otel_observation_attribute_typed "$observation_handle" string gen_ai.operation.name=chat
      \[ "$system_fingerprint" = null ] || otel_observation_attribute_typed "$observation_handle" string openai.response.system_fingerprint="$system_fingerprint"
      \[ "$service_tier" = null ] || otel_observation_attribute_typed "$observation_handle" string openai.response.service_tier="$service_tier"
      otel_observation_attribute_typed "$observation_handle" string gen_ai.token.type=output
      \[ "$model" = null ] || otel_observation_attribute_typed "$observation_handle" string gen_ai.response.model="$model"
      otel_counter_observe "$gen_ai_client_token_usage_handle" "$observation_handle"
    fi
    if \[ "$prompt_tokens" != null ] || \[ "$completion_tokens" != null ]; then
      local time_end="$(\date +%s.%N)"
      local observation_handle="$(otel_observation_create "$(\python3 -c "print(str($time_end - $time_start))")")"
      otel_observation_attribute_typed "$observation_handle" string gen_ai.provider.name=openai
      otel_observation_attribute_typed "$observation_handle" string gen_ai.operation.name=chat
      \[ "$system_fingerprint" = null ] || otel_observation_attribute_typed "$observation_handle" string openai.response.system_fingerprint="$system_fingerprint"
      \[ "$service_tier" = null ] || otel_observation_attribute_typed "$observation_handle" string openai.response.service_tier="$service_tier"
      \[ "$model" = null ] || otel_observation_attribute_typed "$observation_handle" string gen_ai.response.model="$model"
      otel_counter_observe "$gen_ai_client_operation_duration_handle" "$observation_handle"
    fi
    case "$object" in
      'response')
        otel_span_attribute_typed "$span_handle" string gen_ai.operation.name=generate_content
        otel_span_attribute_typed "$span_handle" string gen_ai.output.type=text
        ;;
      'chat.completion'|'chat.completion.chunk')
        otel_span_name "$span_handle" "chat $(\jq < "$request_file" .model -r)"
        otel_span_attribute_typed "$span_handle" string gen_ai.operation.name=chat
        otel_span_attribute_typed "$span_handle" string gen_ai.output.type=text
        \printf '%s' "$json" |  \jq '.choices[] | select(.finish_reason != null) | .finish_reason' -r | while \read -r finish_reason; do otel_span_attribute_typed "$span_handle" +string[1] gen_ai.response.finish_reasons="$finish_reason"; done
        ;;
      *) ;;
    esac
    \printf '%s\n' "$json"
  done
  : > "$api_recording_finished"
}

_otel_alias_prepend curl _otel_propagate_curl
