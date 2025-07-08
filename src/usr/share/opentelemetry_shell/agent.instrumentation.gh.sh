#!/bin/false

_otel_propagate_gh() {
  case "$-" in
    *m*) local job_control=1; \set +m;;
    *) local job_control=0;;
  esac
  local stderr_pipe="$(\mktemp -u)_opentelemetry_shell_$$.stderr.gh.pipe"
  \mkfifo "$stderr_pipe"
  _otel_pipe_gh_stderr < "$stderr_pipe" >&2 &
  local stderr_pid="$!"
  local exit_code=0
  GH_DEBUG=api _otel_call "$@" 2> "$stderr_pipe" || exit_code="$?"
  \wait "$stderr_pid"
  \rm "$stderr_pipe"
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
    true) is_verbose=1;;
    yes) is_verbose=1;;
    on) is_verbose=1;;
    api) is_verbose=1;;
    *) is_verbose=0;;
  esac
  local span_handle=""
  local host="api.github.com"
  local ip=""
  local port=""
  local is_receiving=1
  while \read -r line; do
    if _otel_string_starts_with "$line" "* Request to "; then
      local host="$(\printf '%s' "$line" | \cut -d ' ' -f 4 | \cut -d / -f 3)"
      local ip=""
      local port="443"
    fi
    if \[ -n "$span_handle" ] && \[ "$is_receiving" = 1 ] && _otel_string_starts_with "$line" "> "; then otel_span_end "$span_handle"; local span_handle=""; fi
    if \[ -z "$span_handle" ] && _otel_string_starts_with "$line" "> " && \[ "$is_receiving" = 1 ]; then
      local is_receiving=0
      local protocol="$(\printf '%s' "$line" | \cut -d ' ' -f 4 | \cut -d / -f 1 | \tr '[:upper:]' '[:lower:]')"
      if \[ "$protocol" = http ] && \[ "$port" = 443 ]; then local protocol=https; fi
      local path_and_query="$(\printf '%s' "$line" | \cut -d ' ' -f 3)"
      local span_handle="$(otel_span_start CLIENT "$(\printf '%s' "$line" | \cut -d ' ' -f 2)")"
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
    if \[ "$is_verbose" = 1 ]; then
      \echo "$line"
    fi
  done
  if \[ -n "$span_handle" ]; then otel_span_end "$span_handle"; fi
}

_otel_alias_prepend gh _otel_propagate_gh
