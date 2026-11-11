#!/bin/false
# shellcheck shell=bash

_otel_gh_workflow_file() {
  local ref="${3:-$(\gh api repos/"$1" --jq .default_branch 2>/dev/null)}" # SKIP_DEPENDENCY_CHECK
  local path="$(\gh api repos/"$1"/actions/workflows/"$2" --jq .path 2>/dev/null)" # SKIP_DEPENDENCY_CHECK
  \[ -n "$ref" ] && \[ -n "$path" ] || return 1
  \gh api -H 'Accept: application/vnd.github.raw' "repos/$1/contents/$path?ref=$ref" 2>/dev/null # SKIP_DEPENDENCY_CHECK
}

_otel_workflow_has_input() {
  if \type yq 1>/dev/null 2>/dev/null; then
    \yq -e "(.on // .true).workflow_dispatch.inputs | has(\"$2\")" "$1" 1>/dev/null 2>/dev/null # SKIP_DEPENDENCY_CHECK
    return "$?"
  fi
  \awk -v name="$2" '
    function indent(s) { match(s, /^ */); return RLENGTH }
    /^[ \t]*(#|$)/ { next }
    { i = indent($0); line = $0; sub(/^ */, "", line); sub(/[ \t]+#.*$/, "", line) }
    state == 2 && i <= in_i { state = 1 } # SKIP_DEPENDENCY_CHECK
    state == 1 && i <= wd { state = 0 } # SKIP_DEPENDENCY_CHECK
    state == 0 && line ~ /^["\047]?workflow_dispatch["\047]?:/ { wd = i; state = 1; next } # SKIP_DEPENDENCY_CHECK
    state == 1 && line ~ /^inputs:/ { in_i = i; child = -1; state = 2; next } # SKIP_DEPENDENCY_CHECK
    state == 2 { if (child < 0) child = i; if (i == child) { key = line; sub(/:.*$/, "", key); gsub(/["\047]/, "", key); if (key == name) found = 1 } } # SKIP_DEPENDENCY_CHECK
    END { exit !found } # SKIP_DEPENDENCY_CHECK
  ' "$1"
}

_otel_propagate_gh() {
  case "$-" in
    *m*)
      local job_control=1
      \set +m
      ;;
    *) local job_control=0 ;;
  esac
  local stderr_pipe="$(\mktemp -u)_opentelemetry_shell_$$.stderr.gh.pipe"
  \mkfifo "$stderr_pipe"
  _otel_pipe_gh_stderr <"$stderr_pipe" >&2 &
  local stderr_pid="$!"
  local is_dispatch=0
  local input=""
  local input_file=""
  local previous=""
  local keys=""
  local key
  local workflow_path=""
  local workflow_repo="${GH_REPO:-}"
  local workflow_ref=""
  local api_ref=""
  local run_keys=""
  local api_keys=""
  local is_json=0
  local stdin_file=""
  local arg
  for arg in "$@"; do
    case "$arg" in
      repos/*/actions/workflows/*/dispatches | /repos/*/actions/workflows/*/dispatches) local workflow_path="${arg#/}" ;;
      repos/*/dispatches | /repos/*/dispatches) local is_dispatch=1 ;;
      --input=*) local input="${arg#--input=}" ;;
      --repo=*) local workflow_repo="${arg#--repo=}" ;;
      --ref=*) local workflow_ref="${arg#--ref=}" ;;
      --json) local is_json=1 ;;
      ref=*) local api_ref="${arg#ref=}" ;;
      *inputs\[*)
        local key="${arg#*inputs\[}"
        local api_keys="$api_keys/${key%%]*}"
        ;;
      *client_payload\[*)
        local key="${arg#*client_payload\[}"
        local keys="$keys/${key%%]*}"
        ;;
    esac
    if \[ "$previous" = --input ]; then local input="$arg"; fi
    case "$previous" in
      -R | --repo) local workflow_repo="$arg" ;;
      -r | --ref) local workflow_ref="$arg" ;;
      -f | -F | --field | --raw-field) local run_keys="$run_keys/${arg%%=*}" ;;
    esac
    local previous="$arg"
  done
  if \[ "${2:-}" = api ] && \[ "$is_dispatch" = 1 ] && \[ -n "${TRACEPARENT:-}" ]; then
    if \[ -n "$input" ]; then
      local input_file="$(\mktemp)"
      if \[ "$input" = - ]; then
        \jq --arg traceparent "$TRACEPARENT" --arg tracestate "${TRACESTATE:-}" '(.client_payload // {} | length) as $count | if $count < 9 then .client_payload.traceparent = $traceparent | .client_payload.tracestate = $tracestate elif $count == 9 then .client_payload.traceparent = $traceparent else . end' >"$input_file"
      else
        \jq --arg traceparent "$TRACEPARENT" --arg tracestate "${TRACESTATE:-}" '(.client_payload // {} | length) as $count | if $count < 9 then .client_payload.traceparent = $traceparent | .client_payload.tracestate = $tracestate elif $count == 9 then .client_payload.traceparent = $traceparent else . end' <"$input" >"$input_file"
      fi && \set -- "$@" --input "$input_file"
    else
      local count="$(\printf '%s' "$keys" | \tr '/' '\n' | \sort -u | \grep -c . || \true)"
      if \[ "$count" -lt 9 ]; then
        \set -- "$@" -f "client_payload[traceparent]=$TRACEPARENT" -f "client_payload[tracestate]=${TRACESTATE:-}"
      elif \[ "$count" = 9 ]; then
        \set -- "$@" -f "client_payload[traceparent]=$TRACEPARENT"
      fi
    fi
  fi
  if \[ -n "${TRACEPARENT:-}" ] && { { \[ "${2:-}" = workflow ] && \[ "${3:-}" = run ] && ! _otel_string_starts_with "${4:--}" - && ! { \[ -t 0 ] && \[ -z "$run_keys" ] && \[ "$is_json" = 0 ]; }; } || { \[ "${2:-}" = api ] && \[ -n "$workflow_path" ]; }; }; then
    if \[ "$2" = api ]; then
      local workflow_repo="$(\printf '%s' "$workflow_path" | \cut -d / -f 2-3)"
      local workflow="$(\printf '%s' "$workflow_path" | \cut -d / -f 6)"
      local workflow_ref="$api_ref"
      local keys="$api_keys"
    else
      local workflow="$4"
      local keys="$run_keys"
    fi
    case "$workflow_repo" in
      '' | *\{*) local workflow_repo="$(\gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)" ;; # SKIP_DEPENDENCY_CHECK
      */*/*) local workflow_repo="${workflow_repo#*/}" ;;
    esac
    if \[ "$is_json" = 1 ] || \[ -n "$input" ]; then
      local input_file="$(\mktemp)"
      if \[ "$is_json" = 1 ] || \[ "$input" = - ]; then \cat >"$input_file"; else \cat "$input" >"$input_file"; fi
      if \[ "$is_json" = 1 ]; then
        local count="$(\jq 'length' "$input_file" 2>/dev/null || \echo 25)"
      else
        local count="$(\jq '.inputs // {} | length' "$input_file" 2>/dev/null || \echo 25)"
        local workflow_ref="$(\jq -r '.ref // empty' "$input_file" 2>/dev/null)"
      fi
    else
      local count="$(\printf '%s' "$keys" | \tr '/' '\n' | \sort -u | \grep -c . || \true)"
    fi
    local add_traceparent=false
    local add_tracestate=false
    local workflow_file="$(\mktemp)"
    if _otel_gh_workflow_file "$workflow_repo" "$workflow" "$workflow_ref" >"$workflow_file" && _otel_workflow_has_input "$workflow_file" traceparent && \[ "$count" -lt 25 ]; then
      local add_traceparent=true
      if _otel_workflow_has_input "$workflow_file" tracestate && \[ "$count" -lt 24 ]; then local add_tracestate=true; fi
    fi
    \rm -f "$workflow_file"
    if \[ -n "$input_file" ]; then
      if \[ "$is_json" = 1 ]; then local inputs_path=''; else local inputs_path='.inputs'; fi
      \jq --argjson add_traceparent "$add_traceparent" --argjson add_tracestate "$add_tracestate" --arg traceparent "$TRACEPARENT" --arg tracestate "${TRACESTATE:-}" "if \$add_traceparent then $inputs_path.traceparent = \$traceparent else . end | if \$add_tracestate then $inputs_path.tracestate = \$tracestate else . end" "$input_file" >"$input_file".tmp && \mv "$input_file".tmp "$input_file"
      if \[ "$is_json" = 1 ]; then local stdin_file="$input_file"; else \set -- "$@" --input "$input_file"; fi
    else
      if \[ "$2" = api ]; then local prefix='inputs['; local suffix=']'; else local prefix=''; local suffix=''; fi
      if \[ "$add_traceparent" = true ]; then \set -- "$@" -f "${prefix}traceparent${suffix}=$TRACEPARENT"; fi
      if \[ "$add_tracestate" = true ]; then \set -- "$@" -f "${prefix}tracestate${suffix}=${TRACESTATE:-}"; fi
    fi
  fi
  local exit_code=0
  if \[ -n "$stdin_file" ]; then
    GH_DEBUG=api _otel_call "$@" 2>"$stderr_pipe" <"$stdin_file" || exit_code="$?"
  else
    GH_DEBUG=api _otel_call "$@" 2>"$stderr_pipe" || exit_code="$?"
  fi
  \wait "$stderr_pid"
  \rm "$stderr_pipe"
  if \[ -n "$input_file" ]; then \rm -f "$input_file"; fi
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}

# * Request at 2025-07-06 12:14:59.947451832 +0000 UTC m=+0.127444188
# * Request to https://api.github.com/graphql
# > POST /graphql HTTP/1.1
# > Host: api.github.com
# > Accept: application/vnd.github.merge-info-preview+json, application/vnd.github.nebula-preview
# > Authorization: token ...
# > Content-Length: 527
# > Content-Type: application/json; charset=utf-8
# > Graphql-Features: merge_queue
# > Time-Zone: Etc/UTC
# > User-Agent: GitHub CLI v2.74.0-19-gea8fc856e
#
# < HTTP/2.0 200 OK
# < Access-Control-Allow-Origin: *
# < Access-Control-Expose-Headers: ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset
# < Content-Security-Policy: default-src 'none'
# < Content-Type: application/json; charset=utf-8
# < Date: Sun, 06 Jul 2025 12:15:00 GMT
# < Referrer-Policy: origin-when-cross-origin, strict-origin-when-cross-origin
# < Server: github.com
# < Strict-Transport-Security: max-age=31536000; includeSubdomains; preload
# < Vary: Accept-Encoding, Accept, X-Requested-With
# < X-Accepted-Oauth-Scopes: repo
# < X-Content-Type-Options: nosniff
# < X-Frame-Options: deny
# < X-Github-Media-Type: github.v4; param=merge-info-preview.nebula-preview; format=json
# < X-Github-Request-Id: B7FE:6162E:9A5A59A:9F4E62B:686A68C3
# < X-Oauth-Scopes: repo, workflow
# < X-Ratelimit-Limit: 5000
# < X-Ratelimit-Remaining: 4870
# < X-Ratelimit-Reset: 1751805068
# < X-Ratelimit-Resource: graphql
# < X-Ratelimit-Used: 130
# < X-Xss-Protection: 0

_otel_pipe_gh_stderr() {
  case "${GH_DEBUG:-false}" in
    true) is_verbose=1 ;;
    yes) is_verbose=1 ;;
    on) is_verbose=1 ;;
    api) is_verbose=1 ;;
    *) is_verbose=0 ;;
  esac
  local span_handle=""
  local host="api.github.com"
  local ip=""
  local port=""
  local protocol=""
  local version=""
  local method=""
  local response_code=""
  local time_start=""
  local is_receiving=1
  local http_client_request_duration_handle="$(otel_counter_create histogram http.client.request.duration s '0.005,0.01,0.025,0.05,0.075,0.1,0.25,0.5,0.75,1,2.5,5,7.5,10' 'Duration of HTTP client requests')"
  local http_client_request_body_size_handle="$(otel_counter_create histogram http.client.request.body.size By '' 'Size of HTTP client request bodies')"
  local http_client_response_body_size_handle="$(otel_counter_create histogram http.client.response.body.size By '' 'Size of HTTP client response bodies')"
  local http_client_open_connections_handle="$(otel_counter_create up_down_counter http.client.open_connections '{connection}' 'Number of outbound HTTP connections that are currently active or idle on the client')"
  local http_client_connection_duration_handle="$(otel_counter_create histogram http.client.connection.duration s '0.01,0.02,0.05,0.1,0.2,0.5,1,2,5,10,30,60,120,300' 'The duration of the successfully established outbound HTTP connections')"
  local http_client_active_requests_handle="$(otel_counter_create up_down_counter http.client.active_requests '{request}' 'Number of active HTTP requests')"
  while \read -r line; do
    if _otel_string_starts_with "$line" "* Request to "; then
      local host="$(\printf '%s' "$line" | \cut -d ' ' -f 4 | \cut -d / -f 3)"
      local ip=""
      local port="443"
    fi
    if \[ -n "$span_handle" ] && \[ "$is_receiving" = 1 ] && _otel_string_starts_with "$line" "> "; then
      local time_end="$(\date +%s.%N)"
      otel_span_end "$span_handle"
      local span_handle=""
      local observation_handle="$(otel_observation_create "$(\python3 -c "print(str($time_end - $time_start))")")"
      otel_observation_attribute_typed "$observation_handle" string network.protocol.name="$protocol"
      otel_observation_attribute_typed "$observation_handle" string network.protocol.version="$version"
      otel_observation_attribute_typed "$observation_handle" string server.address="$host"
      otel_observation_attribute_typed "$observation_handle" int server.port="$port"
      otel_observation_attribute_typed "$observation_handle" string url.scheme="$protocol"
      otel_observation_attribute_typed "$observation_handle" string http.request.method="$method"
      otel_observation_attribute_typed "$observation_handle" int http.response.status_code="$response_code"
      otel_counter_observe "$http_client_request_duration_handle" "$observation_handle"
      local observation_handle="$(otel_observation_create "$(\python3 -c "print(str($time_end - $time_start))")")"
      otel_observation_attribute_typed "$observation_handle" string network.protocol.name="$protocol"
      otel_observation_attribute_typed "$observation_handle" string network.protocol.version="$version"
      otel_observation_attribute_typed "$observation_handle" string server.address="$host"
      otel_observation_attribute_typed "$observation_handle" int server.port="$port"
      otel_observation_attribute_typed "$observation_handle" string url.scheme="$protocol"
      otel_counter_observe "$http_client_connection_duration_handle" "$observation_handle"
      local observation_handle="$(otel_observation_create -1)"
      otel_observation_attribute_typed "$observation_handle" string server.address="$host"
      otel_observation_attribute_typed "$observation_handle" int server.port="$port"
      otel_observation_attribute_typed "$observation_handle" string url.scheme="$protocol"
      otel_observation_attribute_typed "$observation_handle" string http.request.method="$method"
      otel_counter_observe "$http_client_active_requests_handle" "$observation_handle"
      local observation_handle="$(otel_observation_create -1)"
      otel_observation_attribute_typed "$observation_handle" string network.protocol.name="$protocol"
      otel_observation_attribute_typed "$observation_handle" string network.protocol.version="$version"
      otel_observation_attribute_typed "$observation_handle" string network.peer.address="$ip"
      otel_observation_attribute_typed "$observation_handle" string server.address="$host"
      otel_observation_attribute_typed "$observation_handle" int server.port="$port"
      otel_observation_attribute_typed "$observation_handle" string url.scheme="$protocol"
      otel_observation_attribute_typed "$observation_handle" string http.connection.state=active
      otel_counter_observe "$http_client_open_connections_handle" "$observation_handle"
    fi
    if \[ -z "$span_handle" ] && _otel_string_starts_with "$line" "> " && \[ "$is_receiving" = 1 ]; then
      local is_receiving=0
      local protocol="$(\printf '%s' "$line" | \cut -d ' ' -f 4 | \cut -d / -f 1 | \tr '[:upper:]' '[:lower:]')"
      if \[ "$protocol" = http ] && \[ "$port" = 443 ]; then local protocol=https; fi
      local version="$(\printf '%s' "$line" | \cut -d ' ' -f 4 | \cut -d / -f 2)"
      local method="$(\printf '%s' "$line" | \cut -d ' ' -f 2)"
      local response_code=""
      local path_and_query="$(\printf '%s' "$line" | \cut -d ' ' -f 3)"
      local observation_handle="$(otel_observation_create 1)"
      otel_observation_attribute_typed "$observation_handle" string network.protocol.name="$protocol"
      otel_observation_attribute_typed "$observation_handle" string network.protocol.version="$version"
      otel_observation_attribute_typed "$observation_handle" string network.peer.address="$ip"
      otel_observation_attribute_typed "$observation_handle" string server.address="$host"
      otel_observation_attribute_typed "$observation_handle" int server.port="$port"
      otel_observation_attribute_typed "$observation_handle" string url.scheme="$protocol"
      otel_observation_attribute_typed "$observation_handle" string http.connection.state=active
      otel_counter_observe "$http_client_open_connections_handle" "$observation_handle"
      local observation_handle="$(otel_observation_create 1)"
      otel_observation_attribute_typed "$observation_handle" string server.address="$host"
      otel_observation_attribute_typed "$observation_handle" int server.port="$port"
      otel_observation_attribute_typed "$observation_handle" string url.scheme="$protocol"
      otel_observation_attribute_typed "$observation_handle" string http.request.method="$method"
      otel_counter_observe "$http_client_active_requests_handle" "$observation_handle"
      local span_handle="$(otel_span_start CLIENT "$method")"
      local time_start="$(\date +%s.%N)"
      otel_span_attribute_typed "$span_handle" string network.transport=tcp
      otel_span_attribute_typed "$span_handle" string network.protocol.name="$protocol"
      otel_span_attribute_typed "$span_handle" string network.protocol.version="$version"
      otel_span_attribute_typed "$span_handle" string network.peer.address="$ip"
      otel_span_attribute_typed "$span_handle" int network.peer.port="$port"
      otel_span_attribute_typed "$span_handle" string server.address="$host"
      otel_span_attribute_typed "$span_handle" int server.port="$port"
      otel_span_attribute_typed "$span_handle" string url.full="$protocol://$host:$port$path_and_query"
      otel_span_attribute_typed "$span_handle" string url.path="$(\printf '%s' "$path_and_query" | \cut -d ? -f 1)"
      otel_span_attribute_typed "$span_handle" string url.query="$(\printf '%s' "$path_and_query" | \cut -sd ? -f 2-)"
      otel_span_attribute_typed "$span_handle" string url.scheme="$protocol"
      otel_span_attribute_typed "$span_handle" string http.request.method="$method"
      otel_span_attribute_typed "$span_handle" string user_agent.original=curl
    fi
    if \[ -n "$span_handle" ]; then
      if _otel_string_starts_with "$line" "< HTTP/"; then
        local response_code="$(\printf '%s' "$line" | \cut -d ' ' -f 3)"
        otel_span_attribute_typed "$span_handle" int http.response.status_code="$response_code"
        if \[ "$response_code" -ge 400 ]; then otel_span_error "$span_handle"; fi
      elif _otel_string_starts_with "$(\printf '%s' "$line" | \tr '[:upper:]' '[:lower:]')" "> user-agent: "; then
        otel_span_attribute_typed "$span_handle" string user_agent.original="$(\printf '%s' "$line" | \cut -d ' ' -f 3-)"
      elif _otel_string_starts_with "$(\printf '%s' "$line" | \tr '[:upper:]' '[:lower:]')" "> content-length: "; then
        otel_span_attribute_typed "$span_handle" int http.request.body.size="$(\printf '%s' "$line" | \cut -d ' ' -f 3)"
        local observation_handle="$(otel_observation_create "$(\printf '%s' "$line" | \cut -d ' ' -f 3)")"
        otel_observation_attribute_typed "$observation_handle" string network.protocol.name="$protocol"
        otel_observation_attribute_typed "$observation_handle" string network.protocol.version="$version"
        otel_observation_attribute_typed "$observation_handle" string server.address="$host"
        otel_observation_attribute_typed "$observation_handle" int server.port="$port"
        otel_observation_attribute_typed "$observation_handle" string url.scheme="$protocol"
        otel_observation_attribute_typed "$observation_handle" string http.request.method="$method"
        otel_observation_attribute_typed "$observation_handle" int http.response.status_code="$response_code"
        otel_counter_observe "$http_client_request_body_size_handle" "$observation_handle"
      elif _otel_string_starts_with "$(\printf '%s' "$line" | \tr '[:upper:]' '[:lower:]')" "< content-length: "; then
        otel_span_attribute_typed "$span_handle" int http.response.body.size="$(\printf '%s' "$line" | \cut -d ' ' -f 3)"
        local observation_handle="$(otel_observation_create "$(\printf '%s' "$line" | \cut -d ' ' -f 3)")"
        otel_observation_attribute_typed "$observation_handle" string network.protocol.name="$protocol"
        otel_observation_attribute_typed "$observation_handle" string network.protocol.version="$version"
        otel_observation_attribute_typed "$observation_handle" string server.address="$host"
        otel_observation_attribute_typed "$observation_handle" int server.port="$port"
        otel_observation_attribute_typed "$observation_handle" string url.scheme="$protocol"
        otel_observation_attribute_typed "$observation_handle" string http.request.method="$method"
        otel_observation_attribute_typed "$observation_handle" int http.response.status_code="$response_code"
        otel_counter_observe "$http_client_response_body_size_handle" "$observation_handle"
      fi
      if _otel_string_starts_with "$line" "> " && _otel_string_contains "$line" ": " && ! _otel_string_contains "$(\printf '%s' "$line" | \tr '[:upper:]' '[:lower:]')" "authorization: " && ! _otel_string_contains "$(\printf '%s' "$line" | \tr '[:upper:]' '[:lower:]')" "token: " && ! _otel_string_contains "$(\printf '%s' "$line" | \tr '[:upper:]' '[:lower:]')" "key: "; then
        otel_span_attribute_typed "$span_handle" +string[1] http.request.header."$(\printf '%s' "$line" | \cut -d ' ' -f 2 | \tr -d ':' | \tr '[:upper:]' '[:lower:]')"="$(\printf '%s' "$line" | \cut -d ' ' -f 3-)"
      elif _otel_string_starts_with "$line" "< " && _otel_string_contains "$line" ": "; then
        otel_span_attribute_typed "$span_handle" +string[1] http.response.header."$(\printf '%s' "$line" | \cut -d ' ' -f 2 | \tr -d ':' | \tr '[:upper:]' '[:lower:]')"="$(\printf '%s' "$line" | \cut -d ' ' -f 3-)"
      fi
    fi
    if _otel_string_starts_with "$line" "< "; then local is_receiving=1; fi
    if \[ "$is_verbose" = 1 ]; then
      \echo "$line"
    fi
  done
  if \[ -n "$span_handle" ]; then
    local time_end="$(\date +%s.%N)"
    otel_span_end "$span_handle"
    local observation_handle="$(otel_observation_create "$(\python3 -c "print(str($time_end - $time_start))")")"
    otel_observation_attribute_typed "$observation_handle" string network.protocol.name="$protocol"
    otel_observation_attribute_typed "$observation_handle" string network.protocol.version="$version"
    otel_observation_attribute_typed "$observation_handle" string server.address="$host"
    otel_observation_attribute_typed "$observation_handle" int server.port="$port"
    otel_observation_attribute_typed "$observation_handle" string url.scheme="$protocol"
    otel_observation_attribute_typed "$observation_handle" string http.request.method="$method"
    otel_observation_attribute_typed "$observation_handle" int http.response.status_code="$response_code"
    otel_counter_observe "$http_client_request_duration_handle" "$observation_handle"
    local observation_handle="$(otel_observation_create "$(\python3 -c "print(str($time_end - $time_start))")")"
    otel_observation_attribute_typed "$observation_handle" string network.protocol.name="$protocol"
    otel_observation_attribute_typed "$observation_handle" string network.protocol.version="$version"
    otel_observation_attribute_typed "$observation_handle" string server.address="$host"
    otel_observation_attribute_typed "$observation_handle" int server.port="$port"
    otel_observation_attribute_typed "$observation_handle" string url.scheme="$protocol"
    otel_counter_observe "$http_client_connection_duration_handle" "$observation_handle"
    local observation_handle="$(otel_observation_create -1)"
    otel_observation_attribute_typed "$observation_handle" string server.address="$host"
    otel_observation_attribute_typed "$observation_handle" int server.port="$port"
    otel_observation_attribute_typed "$observation_handle" string url.scheme="$protocol"
    otel_observation_attribute_typed "$observation_handle" string http.request.method="$method"
    otel_counter_observe "$http_client_active_requests_handle" "$observation_handle"
    local observation_handle="$(otel_observation_create -1)"
    otel_observation_attribute_typed "$observation_handle" string network.protocol.name="$protocol"
    otel_observation_attribute_typed "$observation_handle" string network.protocol.version="$version"
    otel_observation_attribute_typed "$observation_handle" string network.peer.address="$ip"
    otel_observation_attribute_typed "$observation_handle" string server.address="$host"
    otel_observation_attribute_typed "$observation_handle" int server.port="$port"
    otel_observation_attribute_typed "$observation_handle" string url.scheme="$protocol"
    otel_observation_attribute_typed "$observation_handle" string http.connection.state=active
    otel_counter_observe "$http_client_open_connections_handle" "$observation_handle"
  fi
}

_otel_alias_prepend gh _otel_propagate_gh
