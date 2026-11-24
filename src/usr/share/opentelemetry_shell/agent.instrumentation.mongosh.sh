#!/bin/false
# shellcheck shell=bash

# mongosh mongodb://db.example.com/shop --eval 'db.orders.find({status: "open"})' => span "find orders" (CLIENT, db.system.name=mongodb, server.address=db.example.com)

_otel_trace_mongosh() {
  local command="$1"
  shift
  local span_handles="$(_otel_mongosh_start_spans "$@")"
  local exit_code=0
  if \[ -z "$span_handles" ]; then
    _otel_call "$command" "$@" || exit_code="$?"
    return "$exit_code"
  fi
  case "$-" in
    *m*)
      local job_control=1
      \set +m
      ;;
    *) local job_control=0 ;;
  esac
  local stderr_file=''
  if \[ -t 2 ]; then
    _otel_call "$command" "$@" || exit_code="$?"
  else
    # shellcheck disable=SC2154 # the variable is assigned by the sourced instrumentation library or provided by the environment
    stderr_file="$(\mktemp -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.stderr.mongosh.XXXXXXXXXX)"
    local stderr_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.stderr.mongosh.pipe.XXXXXXXXXX)"
    \mkfifo "$stderr_pipe"
    \tee "$stderr_file" <"$stderr_pipe" >&2 &
    local stderr_pid="$!"
    _otel_call "$command" "$@" 2>"$stderr_pipe" || exit_code="$?"
    \wait "$stderr_pid" || true
    \rm -f "$stderr_pipe"
  fi
  local error_type=''
  local status_code=''
  if \[ "$exit_code" != 0 ]; then
    local error_line=''
    if \[ -n "$stderr_file" ]; then error_line="$(\grep -m1 '^Mongo[A-Za-z]*Error' "$stderr_file" || true)"; fi
    error_type="${error_line%%:*}"
    error_type="${error_type%%\[*}"
    case "${error_line#*: }" in
      E[0-9]*)
        status_code="${error_line#*: E}"
        status_code="${status_code%% *}"
        ;;
    esac
    error_type="${status_code:-${error_type:-_OTHER}}"
  fi
  if \[ -n "$stderr_file" ]; then \rm -f "$stderr_file"; fi
  local span_handle
  for span_handle in $span_handles; do
    if \[ "$exit_code" != 0 ]; then
      otel_span_error "$span_handle"
      otel_span_attribute_typed "$span_handle" string error.type="$error_type"
      if \[ -n "$status_code" ]; then otel_span_attribute_typed "$span_handle" string db.response.status_code="$status_code"; fi
    fi
    otel_span_end "$span_handle"
  done
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}

# mongosh --nodb | --version | --help => no span
# mongosh 'mongodb://user:secret@h1:27017,h2:27017/shop?replicaSet=rs' => no server.address (multiple endpoints), db.namespace=shop
# mongosh myhost.example.com:27018/shop => server.address=myhost.example.com, server.port=27018, db.namespace=shop
# mongosh shop => server.address=127.0.0.1, server.port=27017, db.namespace=shop
# mongosh --host h --port 1 => server.address=h, server.port=1, db.namespace=test

_otel_mongosh_start_spans() {
  local newline='
'
  local host=''
  local port=''
  local spec=''
  local scripts=''
  local expect=''
  local positionals=0
  local option value
  local arg
  for arg in "$@"; do
    if \[ -n "$expect" ]; then
      option="$expect"
      value="$arg"
      expect=''
    else
      case "$arg" in
        --nodb | --version | --help | -h | --build-info) return 0 ;;
        --*=*)
          option="${arg%%=*}"
          value="${arg#*=}"
          ;;
        --host | --port | --eval | --file | -f | --username | -u | --password | -p | --db | --apiVersion | --authentication* | --aws* | --*LibraryPath | --gssapi* | --sspi* | --jsContext | --keyVaultNamespace | --kmsURL | --locale | --oidcFlows | --oidcRedirectUri | --tls*File | --tls*Password | --tlsCertificateSelector | --tlsDisabledProtocols | --ssl*File | --ssl*Password | --sslCertificateSelector | --sslDisabledProtocols)
          expect="$arg"
          continue
          ;;
        -*) continue ;;
        *)
          option=''
          value="$arg"
          ;;
      esac
    fi
    case "$option" in
      --host) host="$value" ;;
      --port) port="$value" ;;
      --eval) scripts="$scripts$value$newline" ;;
      --file | -f) scripts="$scripts$(\cat "$value" 2>/dev/null)$newline" ;;
      '')
        case "$positionals:$value" in
          0:mongodb://* | 0:mongodb+srv://*) spec="$value" ;;
          0:*.js | 0:*.mongodb | [1-9]*:*) scripts="$scripts$(\cat "$value" 2>/dev/null)$newline" ;;
          *) spec="$value" ;;
        esac
        positionals=$((positionals + 1))
        ;;
    esac
  done
  local namespace=''
  local srv=0
  case "$spec" in
    mongodb://* | mongodb+srv://*)
      local rest="${spec#*://}"
      local authority="${rest%%[/?]*}"
      host="${authority##*@}"
      port=''
      rest="${rest#"$authority"}"
      rest="${rest#/}"
      namespace="${rest%%\?*}"
      case "$spec" in mongodb+srv://*) srv=1 ;; esac
      ;;
    '') ;;
    *)
      local endpoint="${spec%%/*}"
      case "$spec" in
        */*)
          namespace="${spec#*/}"
          namespace="${namespace%%\?*}"
          host="$endpoint"
          port=''
          ;;
        *:* | *.*)
          host="$endpoint"
          port=''
          ;;
        *) namespace="$spec" ;;
      esac
      ;;
  esac
  local address=''
  case "$host" in
    */* | *,*) ;;
    '') address=127.0.0.1 ;;
    \[*\]:*)
      address="${host%\]:*}"
      address="${address#\[}"
      port="${host##*\]:}"
      ;;
    \[*\])
      address="${host#\[}"
      address="${address%\]}"
      ;;
    *:*)
      address="${host%:*}"
      port="${host##*:}"
      ;;
    *) address="$host" ;;
  esac
  local transport=tcp
  case "$address" in
    %2[Ff]*)
      transport=unix
      address="$(\printf '%s' "$address" | \sed 's/%2[Ff]/\//g')"
      port=''
      ;;
    '') ;;
    *) if \[ "$srv" = 0 ] && \[ -z "$port" ]; then port=27017; fi ;;
  esac
  local operations="$(\printf '%s\n' "$scripts" | _otel_mongosh_operations)"
  if ! \printf '%s\n' "$operations" | \grep -qE '\|[A-Za-z0-9_]+$'; then
    _otel_mongosh_start_span "$address" "$port" "$transport" "${namespace:-test}" '' ''
    return 0
  fi
  namespace="${namespace:-test}"
  \printf '%s\n' "$operations" | while \read -r line; do
    local line_namespace="${line%%|*}"
    local line_rest="${line#*|}"
    case "$line_namespace" in
      =*) namespace="${line_namespace#=}" ;;
      '' | runCommand) _otel_mongosh_start_span "$address" "$port" "$transport" "$namespace" "${line_rest%|*}" "${line_rest##*|}" ;;
      *) _otel_mongosh_start_span "$address" "$port" "$transport" "$line_namespace" "${line_rest%|*}" "${line_rest##*|}" ;;
    esac
  done
}

# db.users.find({age: {$gt: 18}}) => |users|find
# db.getCollection("users").insertOne({}) => |users|insertOne
# db.getSiblingDB("other").users.find() => other|users|find
# db.runCommand({find: "users"}) => runCommand|users|find
# db.adminCommand({ping: 1}) => admin||ping
# use other => =other||

_otel_mongosh_operations() {
  \grep -oE "^[[:space:]]*use[[:space:]]+[A-Za-z0-9_-]+|db\.getSiblingDB\([^)]*\)\.[A-Za-z0-9_]+\.[A-Za-z0-9_]+\(|db\.getCollection\([^)]*\)\.[A-Za-z0-9_]+\(|db\.[A-Za-z0-9_]+\.[A-Za-z0-9_]+\(|db\.(runCommand|adminCommand)\([[:space:]]*\{[[:space:]]*[\"']?[A-Za-z0-9_]+[\"']?[[:space:]]*:([[:space:]]*[\"'][^\"']*[\"'])?" \
    | \sed -n -E \
      -e "s/^[[:space:]]*use[[:space:]]+(.*)/=\\1||/p" \
      -e "s/^db\\.getSiblingDB\\([\"']?([^\"')]*)[\"']?\\)\\.([A-Za-z0-9_]+)\\.([A-Za-z0-9_]+)\\(/\\1|\\2|\\3/p" \
      -e "s/^db\\.getCollection\\([\"']?([^\"')]*)[\"']?\\)\\.([A-Za-z0-9_]+)\\(/|\\1|\\2/p" \
      -e "s/^db\\.(runCommand)\\([[:space:]]*\\{[[:space:]]*[\"']?([A-Za-z0-9_]+)[\"']?[[:space:]]*:[[:space:]]*[\"']([^\"']*)[\"']/\\1|\\3|\\2/p" \
      -e "s/^db\\.(runCommand)\\([[:space:]]*\\{[[:space:]]*[\"']?([A-Za-z0-9_]+)[\"']?[[:space:]]*:/\\1||\\2/p" \
      -e "s/^db\\.adminCommand\\([[:space:]]*\\{[[:space:]]*[\"']?([A-Za-z0-9_]+)[\"']?[[:space:]]*:.*/admin||\\1/p" \
      -e "s/^db\\.([A-Za-z0-9_]+)\\.([A-Za-z0-9_]+)\\(/|\\1|\\2/p"
}

_otel_mongosh_start_span() {
  local address="$1"
  local port="$2"
  local transport="$3"
  local namespace="$4"
  local collection="$5"
  local operation="$6"
  local name=mongodb
  if \[ -n "$operation" ]; then name="$operation ${collection:-$namespace}"; fi
  local span_handle="$(otel_span_start CLIENT "$name")"
  otel_span_attribute_typed "$span_handle" string db.system.name=mongodb
  otel_span_attribute_typed "$span_handle" string db.namespace="$namespace"
  if \[ -n "$operation" ]; then otel_span_attribute_typed "$span_handle" string db.operation.name="$operation"; fi
  if \[ -n "$collection" ]; then otel_span_attribute_typed "$span_handle" string db.collection.name="$collection"; fi
  otel_span_attribute_typed "$span_handle" string network.transport="$transport"
  if \[ -n "$address" ]; then otel_span_attribute_typed "$span_handle" string server.address="$address"; fi
  if \[ -n "$port" ]; then otel_span_attribute_typed "$span_handle" int server.port="$port"; fi
  \echo "$span_handle"
}

_otel_alias_prepend mongosh _otel_trace_mongosh
