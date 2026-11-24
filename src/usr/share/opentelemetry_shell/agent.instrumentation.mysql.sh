#!/bin/false
# shellcheck shell=bash

# mysql -h db.example.com -P 3307 -e 'SELECT * FROM users WHERE id = 1' => span "SELECT users" with db.query.text "SELECT * FROM users WHERE id = ?", db.namespace, server.address, server.port, ...

_otel_instrument_mysql() {
  local command="$1"
  shift
  local key value
  local host="" port="" socket="" protocol="" database="" delimiter=";" execute="" has_execute=0 force=0 positional="" pending="" end_of_options=0 passthrough=0
  for value in "$@"; do
    key=""
    if \[ -n "$pending" ]; then
      key="$pending"
      pending=""
    elif \[ "$end_of_options" = 1 ]; then
      key=positional
    else
      case "$value" in
        --) end_of_options=1 ;;
        --help | --version | --print-defaults) passthrough=1 ;;
        --host=* | --port=* | --socket=* | --protocol=* | --database=* | --execute=* | --delimiter=*)
          key="${value#--}"
          key="${key%%=*}"
          value="${value#*=}"
          ;;
        --host | --port | --socket | --protocol | --database | --execute | --delimiter) pending="${value#--}" ;;
        --user | --character-sets-dir | --connect-timeout | --default-auth | --default-character-set | --defaults-file | --defaults-extra-file | --defaults-group-suffix | --init-command | --max-allowed-packet | --max-join-size | --net-buffer-length | --plugin-dir | --prompt | --quick-max-column-width | --select-limit | --server-arg | --ssl-ca | --ssl-capath | --ssl-cert | --ssl-cipher | --ssl-key | --ssl-crl | --ssl-crlpath | --tls-version | --tee | --bind-address | --histignore | --login-path | --ssl-mode | --tls-ciphersuites | --server-public-key-path | --compression-algorithms | --zstd-compression-level | --network-namespace) pending=ignore ;;
        --force) force=1 ;;
        --*) ;;
        -?*)
          local flags="${value#-}"
          while \[ -n "$flags" ]; do
            local flag="${flags%"${flags#?}"}"
            local flags="${flags#?}"
            case "$flag" in
              f) force=1 ;;
              V | I | \?) passthrough=1 ;;
              p | '#') local flags="" ;;
              h | P | u | S | D | e)
                case "$flag" in
                  h) key=host ;;
                  P) key=port ;;
                  S) key=socket ;;
                  D) key=database ;;
                  e) key=execute ;;
                  *) key=ignore ;;
                esac
                if \[ -n "$flags" ]; then
                  value="$flags"
                else
                  pending="$key"
                  key=""
                fi
                local flags=""
                ;;
            esac
          done
          ;;
        *) key=positional ;;
      esac
    fi
    case "$key" in
      host) host="$value" ;;
      port) port="$value" ;;
      socket) socket="$value" ;;
      protocol) protocol="$value" ;;
      database) database="$value" ;;
      delimiter) delimiter="$value" ;;
      execute)
        execute="${execute:+$execute }$value"
        has_execute=1
        ;;
      positional) positional="$value" ;;
    esac
  done
  if \[ "$passthrough" = 1 ]; then
    _otel_call "$command" "$@"
    return "$?"
  fi
  case "$-" in
    *m*)
      local job_control=1
      \set +m
      ;;
    *) local job_control=0 ;;
  esac
  local name="${command#\\}"
  case "${name##*/}" in
    mariadb*) local system=mariadb ;;
    *)
      case "$(_otel_call "$command" --version 2>/dev/null)" in
        *MariaDB*) local system=mariadb ;;
        *) local system=mysql ;;
      esac
      ;;
  esac
  if \[ -n "$positional" ]; then database="$positional"; fi
  case "${1:-}" in
    --no-defaults) local defaults="" ;;
    --defaults-file=* | --defaults-extra-file=* | --defaults-group-suffix=* | --login-path=*)
      case "${2:-}" in
        --defaults-file=* | --defaults-extra-file=* | --defaults-group-suffix=* | --login-path=*) local defaults="$(_otel_call "$command" "$1" "$2" --print-defaults 2>/dev/null | \tail -n 1)" ;;
        *) local defaults="$(_otel_call "$command" "$1" --print-defaults 2>/dev/null | \tail -n 1)" ;;
      esac
      ;;
    *) local defaults="$(_otel_call "$command" --print-defaults 2>/dev/null | \tail -n 1)" ;;
  esac
  host="${host:-$(_otel_mysql_option "$defaults" host)}"
  port="${port:-$(_otel_mysql_option "$defaults" port)}"
  socket="${socket:-$(_otel_mysql_option "$defaults" socket)}"
  protocol="${protocol:-$(_otel_mysql_option "$defaults" protocol)}"
  database="${database:-$(_otel_mysql_option "$defaults" database)}"
  host="${host:-${MYSQL_HOST:-}}"
  port="${port:-${MYSQL_TCP_PORT:-}}"
  socket="${socket:-${MYSQL_UNIX_PORT:-${MARIADB_UNIX_PORT:-}}}"
  case "$protocol" in
    [Tt][Cc][Pp]) local transport=tcp ;;
    [Ss][Oo][Cc][Kk][Ee][Tt]) local transport=unix ;;
    *)
      case "$host" in
        '' | localhost) local transport=unix ;;
        *) local transport=tcp ;;
      esac
      ;;
  esac
  if \[ "$transport" = unix ] && \[ -n "$socket" ]; then
    local address="$socket"
  else
    local address="${host:-localhost}"
  fi
  if \[ "$transport" = tcp ] && \[ -n "$port" ] && \[ "$port" != 3306 ]; then local address_port="$port"; else local address_port=""; fi

  # shellcheck disable=SC2154 # the variable is assigned by the sourced instrumentation library or provided by the environment
  local stderr_file="$(\mktemp -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.stderr.mysql.XXXXXXXXXX)"
  local stdin_file="$(\mktemp -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.stdin.mysql.XXXXXXXXXX)"
  local stdin_limit=1048576
  if \[ ! -t 2 ] && ! \[ /dev/fd/1 -ef /dev/fd/2 ]; then
    local stderr_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.stderr.mysql.pipe.XXXXXXXXXX)"
    \mkfifo "$stderr_pipe"
    \tee "$stderr_file" <"$stderr_pipe" >&2 &
    local stderr_pid="$!"
  else
    local stderr_pipe=""
  fi
  if \[ "$has_execute" = 0 ] && \[ ! -t 0 ]; then
    local stdin_pipe="$(\mktemp -u -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.stdin.mysql.pipe.XXXXXXXXXX)"
    \mkfifo "$stdin_pipe"
    {
      \head -c "$stdin_limit" >"$stdin_file"
      \cat >/dev/null
    } <"$stdin_pipe" &
    local stdin_pid="$!"
  else
    local stdin_pipe=""
  fi

  local time_start="$(\date +%s.%N)"
  local exit_code=0
  if \[ -n "$stdin_pipe" ]; then
    { \tee "$stdin_pipe" 2>/dev/null || \true; } | _otel_mysql_call "$stderr_pipe" "$command" "$@" || exit_code="$?"
  else
    _otel_mysql_call "$stderr_pipe" "$command" "$@" || exit_code="$?"
  fi
  local time_end="$(\date +%s.%N)"
  if \[ -n "$stdin_pipe" ]; then
    \wait "$stdin_pid" || \true
    \rm -f "$stdin_pipe"
  fi
  if \[ -n "$stderr_pipe" ]; then
    \wait "$stderr_pid" || \true
    \rm -f "$stderr_pipe"
  fi

  local statements_file=/dev/null
  if \[ "$has_execute" = 1 ]; then
    \printf '%s\n' "$execute" >"$stdin_file"
    statements_file="$stdin_file"
  elif \[ -n "$stdin_pipe" ] && \[ "$(\wc -c <"$stdin_file")" -lt "$stdin_limit" ]; then
    statements_file="$stdin_file"
  fi
  local separator="$(\printf '\037')"
  _otel_mysql_analyze "$statements_file" "$stderr_file" "$delimiter" "$database" "$force" "$exit_code" "$separator" | while IFS="$separator" \read -r status code batch namespace operation summary text; do
    if \[ -n "$summary" ]; then
      local span_name="$summary"
    elif \[ -n "$namespace" ]; then
      local span_name="$namespace"
    else
      local span_name="$address${address_port:+:$address_port}"
    fi
    local span_handle="$(otel_span_start @"$time_start" CLIENT "$span_name")"
    otel_span_attribute_typed "$span_handle" string db.system.name="$system"
    if \[ -n "$namespace" ]; then otel_span_attribute_typed "$span_handle" string db.namespace="$namespace"; fi
    if \[ -n "$operation" ]; then otel_span_attribute_typed "$span_handle" string db.operation.name="$operation"; fi
    if \[ -n "$batch" ]; then otel_span_attribute_typed "$span_handle" int db.operation.batch.size="$batch"; fi
    if \[ -n "$summary" ]; then otel_span_attribute_typed "$span_handle" string db.query.summary="$summary"; fi
    if \[ -n "$text" ]; then otel_span_attribute_typed "$span_handle" string db.query.text="$text"; fi
    otel_span_attribute_typed "$span_handle" string server.address="$address"
    if \[ -n "$address_port" ]; then otel_span_attribute_typed "$span_handle" int server.port="$address_port"; fi
    otel_span_attribute_typed "$span_handle" string network.transport="$transport"
    if \[ "$status" = error ]; then
      otel_span_error "$span_handle"
      otel_span_attribute_typed "$span_handle" string error.type="${code:-_OTHER}"
      if \[ -n "$code" ]; then otel_span_attribute_typed "$span_handle" string db.response.status_code="$code"; fi
    fi
    otel_span_end "$span_handle" @"$time_end"
  done
  \rm -f "$stderr_file" "$stdin_file"
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}

_otel_mysql_option() {
  local options=" $1"
  local rest="${options#* --"$2"=}"
  if \[ "$rest" != "$options" ]; then \echo "${rest%% *}"; fi
}

_otel_mysql_call() {
  local stderr_pipe="$1"
  shift
  if \[ -n "$stderr_pipe" ]; then _otel_call "$@" 2>"$stderr_pipe"; else _otel_call "$@"; fi
}

# ERROR 1064 (42000) at line 1: You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'selec 1' at line 1
# ERROR 2002 (HY000): Can't connect to local server through socket '/run/mysqld/mysqld.sock' (2)

_otel_mysql_analyze() {
  \awk -v errfile="$2" -v delim="$3" -v ns="$4" -v force="$5" -v exit_code="$6" -v us="$7" -v maxlen=1024 -v cap=100 '
function isid(c) { return c ~ /[A-Za-z0-9_$@.`]/ }
function add(tok) {
  if (sp && stmt != "") { stmt = stmt " " }
  sp = 0 # SKIP_DEPENDENCY_CHECK
  if (!have) { have = 1; start = FNR }
  stmt = stmt tok # SKIP_DEPENDENCY_CHECK
}
function summarize(t,   m, j, k, k0, len, c, ch, w, out, expect, tk) {
  m = 0; j = 1; len = length(t)
  while (j <= len) {
    c = substr(t, j, 1)
    if (c ~ /[A-Za-z_$@`]/) {
      k = j
      while (k <= len) {
        ch = substr(t, k, 1) # SKIP_DEPENDENCY_CHECK
        if (ch == "`") { k++; while (k <= len && substr(t, k, 1) != "`") { k++ }; k++ }
        else if (ch ~ /[A-Za-z0-9_$@.]/) { k++ }
        else { break }
      }
      m++; tk[m] = substr(t, j, k - j); j = k
    } else if (c == "(" || c == ")" || c == ",") { m++; tk[m] = c; j++ }
    else { j++ }
  }
  for (k0 = 1; k0 <= m && tk[k0] == "("; k0++) { }
  if (k0 > m) { return "" }
  out = tk[k0] # SKIP_DEPENDENCY_CHECK
  w = tolower(tk[k0])
  expect = (w ~ /^(update|call|describe|desc|use)$/) ? 1 : 0 # SKIP_DEPENDENCY_CHECK
  for (k = k0 + 1; k <= m; k++) {
    w = tolower(tk[k])
    if (w == "select") { out = out " " tk[k]; expect = 0 }
    else if (expect) {
      if (tk[k] == ",") { }
      else if (w ~ /^(if|not|exists|only|temporary|ignore|low_priority|delayed|quick|high_priority|table|database|schema)$/) { }
      else if (tk[k] ~ /^[A-Za-z_$`]/) { out = out " " tk[k]; expect = (tk[k + 1] == ",") ? 1 : 0 }
      else { expect = 0 }
    }
    else if (w ~ /^(from|join|into|table|database|schema|view)$/) { expect = 1 }
    if (length(out) > 255) { return substr(out, 1, 255) }
  }
  return out
}
function finish(   t) {
  if (!have) { stmt = ""; return }
  t = stmt
  gsub(/[?]( *, *[?])+/, "?", t)
  gsub(/[(][?][)]( *, *[(][?][)])+/, "(?)", t)
  n++
  st[n] = start
  nsv[n] = ns
  tx[n] = substr(t, 1, maxlen)
  sm[n] = summarize(t)
  op[n] = sm[n]; sub(/ .*$/, "", op[n])
  stmt = ""; have = 0; sp = 0 # SKIP_DEPENDENCY_CHECK
}
function client(rest,   w, lw, arg, p) {
  w = rest; sub(/[ \t\r].*$/, "", w)
  lw = tolower(w) # SKIP_DEPENDENCY_CHECK
  arg = substr(rest, length(w) + 1); sub(/^[ \t]+/, "", arg); sub(/[ \t\r]+$/, "", arg) # SKIP_DEPENDENCY_CHECK
  if (lw == "delimiter") { delim = arg; return length(rest) }
  if (lw == "exit" || lw == "quit" || w == "\\q") { stopped = 1; return length(rest) }
  if (lw == "use" || w == "\\u") {
    p = index(arg, ";")
    if (p > 0) { arg = substr(arg, 1, p - 1) }
    gsub(/`/, "", arg); sub(/[ \t].*$/, "", arg)
    ns = arg # SKIP_DEPENDENCY_CHECK
    return (p > 0) ? length(w) + index(substr(rest, length(w) + 1), ";") : length(rest)
  }
  if (lw ~ /^(source|exit|quit|status|help|charset|prompt|rehash|tee|notee|warnings|nowarning|pager|nopager|print|system|edit|clear|resetconnection|connect|go|ego|query_attributes)$/ || w ~ /^\\./) { return length(rest) }
  return 0
}
function rec(a1, a2, a3, a4, a5, a6, a7) {
  printf "%s%s%s%s%s%s%s%s%s%s%s%s%s\n", a1, us, a2, us, a3, us, a4, us, a5, us, a6, us, a7
}
BEGIN { n = 0; stmt = ""; have = 0; sp = 0; q = ""; cm = 0; exe = 0; sq = "\047"; if (delim == "") { delim = ";" } } # SKIP_DEPENDENCY_CHECK
FILENAME == errfile { # SKIP_DEPENDENCY_CHECK
  if ($0 ~ /^ERROR [0-9]+ \(/) {
    if (firstcode == "") { firstcode = $2 }
    if ($0 ~ / at line [0-9]+ in file: /) { }
    else if (match($0, / at line [0-9]+:/)) {
      ln = substr($0, RSTART + 9, RLENGTH - 10) + 0 # SKIP_DEPENDENCY_CHECK
      if (!(ln in errcode)) { errcode[ln] = $2; nerr++; if (nerr == 1 || ln < first_err) { first_err = ln } }
    } else if (lineless == "") { lineless = $2; nerr++ }
  }
  next;
}
stopped { next; } # SKIP_DEPENDENCY_CHECK
{
  len = length($0); i = 1 # SKIP_DEPENDENCY_CHECK
  while (i <= len) {
    c = substr($0, i, 1)
    if (q != "") {
      if (c == "\\" && q != "`") { i += 2; continue }
      if (c == q) {
        if (substr($0, i + 1, 1) == q) { if (q == "`") { stmt = stmt c c }; i += 2; continue }
        if (q == "`") { stmt = stmt "`" } else { stmt = stmt "?" }
        q = ""
      } else if (q == "`") { stmt = stmt c }
      i++; continue
    }
    if (cm) {
      if (c == "*" && substr($0, i + 1, 1) == "/") { cm = 0; i += 2 } else { i++ }
      continue
    }
    if (c == " " || c == "\t" || c == "\r") { sp = 1; i++; continue }
    if (exe && c == "*" && substr($0, i + 1, 1) == "/") { exe = 0; i += 2; continue }
    if (c == "#") { break }
    if (c == "-" && substr($0, i + 1, 1) == "-" && (substr($0, i + 2, 1) == "" || substr($0, i + 2, 1) ~ /[ \t\r]/)) { break }
    if (c == "/" && substr($0, i + 1, 1) == "*") {
      if (substr($0, i + 2, 1) == "!") { exe = 1; i += 3; while (substr($0, i, 1) ~ /[0-9]/) { i++ } }
      else { cm = 1; i += 2 }
      continue
    }
    if (!have && (k = client(substr($0, i))) > 0) { i += k; continue }
    if (substr($0, i, length(delim)) == delim) { finish(); i += length(delim); continue }
    if (c == "\\") {
      c = substr($0, i + 1, 1)
      if (c == "g" || c == "G") { finish() }
      else if (c == "c") { stmt = ""; have = 0; sp = 0 }
      i += 2; continue
    }
    if (c == sq || c == "\"" || c == "`") {
      q = c
      if (c == "`") { add("`") } else { add("") }
      i++; continue
    }
    if ((c ~ /[0-9]/ || (c == "." && substr($0, i + 1, 1) ~ /[0-9]/)) && (sp || !isid(substr(stmt, length(stmt), 1)))) {
      j = i + 1
      while (substr($0, j, 1) ~ /[0-9A-Za-z_.]/) { j++ }
      add("?"); i = j; continue
    }
    if (c ~ /[A-Za-z_$@]/) {
      j = i + 1
      while (substr($0, j, 1) ~ /[A-Za-z0-9_$@.]/) { j++ }
      w = substr($0, i, j - i); lw = tolower(w)
      if (lw == "true" || lw == "false") { add("?") }
      else if ((lw == "x" || lw == "b" || lw == "n") && substr($0, j, 1) == sq) { add("") }
      else { add(w) }
      i = j; continue
    }
    add(c); i++
  }
  sp = 1 # SKIP_DEPENDENCY_CHECK
}
END { # SKIP_DEPENDENCY_CHECK
  finish()
  failed = (exit_code != 0) # SKIP_DEPENDENCY_CHECK
  limit = 1000000000 # SKIP_DEPENDENCY_CHECK
  if (!force && nerr > 0) {
    limit = (lineless != "") ? 0 : first_err # SKIP_DEPENDENCY_CHECK
    if (n > 0 && limit < st[1]) { limit = st[1] }
  }
  kept = 0 # SKIP_DEPENDENCY_CHECK
  for (k = 1; k <= n; k++) { if (st[k] <= limit) { kept++ } }
  if (kept == 0) {
    if (failed || nerr > 0) { rec("error", firstcode, "", ns, "", "", "") } else { rec("ok", "", "", ns, "", "", "") }
    exit
  }
  for (k = 1; k <= kept; k++) {
    code[k] = (st[k] in errcode) ? errcode[st[k]] : lineless
    bad[k] = (code[k] != "" || (nerr == 0 && failed && kept == 1)) ? "error" : "ok"
  }
  if (kept <= cap) {
    for (k = 1; k <= kept; k++) { rec(bad[k], code[k], "", nsv[k], op[k], sm[k], tx[k]) }
    exit
  }
  status = "ok"; bcode = ""; same_op = 1; same_sm = 1; text = "" # SKIP_DEPENDENCY_CHECK
  for (k = 1; k <= kept; k++) {
    if (bad[k] == "error" && status == "ok") { status = "error"; bcode = code[k] }
    if (op[k] != op[1]) { same_op = 0 }
    if (sm[k] != sm[1]) { same_sm = 0 }
    if (length(text) < maxlen) { text = text (k > 1 ? "; " : "") tx[k] }
  }
  rec(status, bcode, kept, nsv[1], same_op ? "BATCH " op[1] : "BATCH", same_sm ? "BATCH " sm[1] : "BATCH", substr(text, 1, maxlen))
}
' "$1" "$2"
}

_otel_alias_prepend mysql _otel_instrument_mysql
_otel_alias_prepend mariadb _otel_instrument_mysql
