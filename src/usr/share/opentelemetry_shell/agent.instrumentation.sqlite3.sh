#!/bin/false
# shellcheck shell=bash

# sqlite3 test.db 'SELECT * FROM users WHERE id = 42' => span "SELECT users" with db.system.name=sqlite, db.namespace=test.db, db.query.text="SELECT * FROM users WHERE id = ?"

_otel_instrument_sqlite3() {
  local command="$1"
  shift
  local newline='
'
  local database=''
  local sql=''
  local has_sql_args=0
  local skip=0
  local previous=''
  local passthrough=0
  local arg
  for arg in "$@"; do
    if \[ "$skip" -gt 0 ]; then
      case "$previous" in
        -cmd) local sql="$sql$arg$newline;$newline" ;;
        -init) local sql="$sql.read $arg$newline" ;;
      esac
      local skip=$((skip - 1))
      continue
    fi
    local previous="$arg"
    case "$arg" in
      --*) local previous="${arg#-}" ;;
    esac
    case "$previous" in
      -help | -version | -A) local passthrough=1 ;;
      -cmd | -init | -separator | -newline | -nullvalue | -vfs | -nonce | -mmap | -maxsize | -heap) local skip=1 ;;
      -pagecache | -lookaside) local skip=2 ;;
      - | -?*) ;;
      *)
        if \[ -z "$database" ]; then
          local database="$arg"
        else
          local sql="$sql$arg$newline;$newline"
          local has_sql_args=1
        fi
        ;;
    esac
  done
  if \[ "$passthrough" = 1 ]; then
    _otel_call "$command" "$@"
    return "$?"
  fi
  local kind=CLIENT
  case "$database" in
    '' | :memory: | file::memory:* | *mode=memory*) local kind=INTERNAL ;;
  esac
  case "$database" in
    file:*)
      local database="${database#file:}"
      local database="${database%%\?*}"
      local database="${database#//}"
      ;;
  esac
  local database="${database:-:memory:}"
  local count=0 summary='' operation='' collection='' text=''
  if \[ "$has_sql_args" = 1 ] || \[ -f /dev/stdin ]; then
    local result="$({ \printf '%s' "$sql"; if \[ "$has_sql_args" = 0 ]; then \head -c 1048576 /dev/stdin; fi; } | _otel_sqlite3_analyze)"
    local field
    for field in count summary operation collection text; do
      \eval "local $field=\"\${result%%\"\$newline\"*}\""
      local result="${result#*"$newline"}"
    done
    if \[ "$count" = 0 ]; then
      _otel_call "$command" "$@"
      return "$?"
    fi
  fi
  local span_handle="$(otel_span_start "$kind" "${summary:-$database}")"
  otel_span_attribute_typed "$span_handle" string db.system.name=sqlite
  otel_span_attribute_typed "$span_handle" string db.namespace="$database"
  if \[ -n "$summary" ]; then otel_span_attribute_typed "$span_handle" string db.query.summary="$summary"; fi
  if \[ -n "$operation" ]; then otel_span_attribute_typed "$span_handle" string db.operation.name="$operation"; fi
  if \[ -n "$collection" ]; then otel_span_attribute_typed "$span_handle" string db.collection.name="$collection"; fi
  if \[ -n "$text" ]; then otel_span_attribute_typed "$span_handle" string db.query.text="$text"; fi
  if \[ "${count:-0}" -gt 1 ]; then otel_span_attribute_typed "$span_handle" int db.operation.batch.size="$count"; fi
  local exit_code=0
  _otel_call "$command" "$@" || local exit_code="$?"
  if \[ "$exit_code" != 0 ]; then
    otel_span_error "$span_handle"
    local status="$(\echo 'ERROR INTERNAL PERM ABORT BUSY LOCKED NOMEM READONLY INTERRUPT IOERR CORRUPT NOTFOUND FULL CANTOPEN PROTOCOL EMPTY SCHEMA TOOBIG CONSTRAINT MISMATCH MISUSE NOLFS AUTH FORMAT RANGE NOTADB' | \cut -d ' ' -f "$exit_code")"
    if \[ "$exit_code" -gt 1 ] && \[ -n "$status" ]; then
      otel_span_attribute_typed "$span_handle" string db.response.status_code="SQLITE_$status"
      otel_span_attribute_typed "$span_handle" string error.type="SQLITE_$status"
    else
      otel_span_attribute_typed "$span_handle" string error.type=_OTHER
    fi
  fi
  otel_span_end "$span_handle"
  return "$exit_code"
}

_otel_sqlite3_analyze() {
  \awk -v q="'" '
function isword(c) { return index(" \t\r\n" q "\"`[](),;.+-*/%<>=!|&~^?:@#{}\\", c) == 0 }
function isdigit(c) { return index("0123456789", c) > 0 }
function add(t, k) { nt++; tk[nt] = t; kd[nt] = k }
function lit() { add("?", "l"); txt = txt "?" }
function space() { if (substr(txt, length(txt)) != " ") txt = txt " " }
function istrigger(   i) { if (toupper(tk[1]) != "CREATE") return 0; for (i = 2; i <= 3 && i <= nt; i++) if (toupper(tk[i]) == "TRIGGER") return 1; return 0 }
function readable(f) { return f ~ "^[A-Za-z0-9_./-]+$" && system("test -f " f) == 0 }
function dotcmd(l,   a) {
  split(l, a, "[ \t]+")
  if (a[1] == ".read" && depth < 8 && readable(a[2])) {
    depth++
    while ((getline line < a[2]) > 0) feed(line)
    close(a[2])
    finish()
    depth-- # SKIP_DEPENDENCY_CHECK
  }
}
function feed(s,   i, n, c, d, j, p, w, u) {
  n = length(s)
  i = 1
  if (inq == "" && !inbc && nt == 0) {
    while (substr(s, i, 1) == " " || substr(s, i, 1) == "\t") i++
    if (substr(s, i, 1) == ".") { dotcmd(substr(s, i)); return }
  }
  while (i <= n) {
    c = substr(s, i, 1)
    d = substr(txt, length(txt))
    if (inbc) {
      if (c == "*" && substr(s, i + 1, 1) == "/") { inbc = 0; i++ }
      i++
    } else if (inq != "") {
      j = index(substr(s, i), inq)
      if (j == 0) { if (inq != q) qb = qb substr(s, i); i = n + 1 }
      else {
        p = i + j - 1
        if (inq != "]" && substr(s, p + 1, 1) == inq) { if (inq != q) qb = qb substr(s, i, j + 1); i = p + 2 }
        else {
          if (inq == q) {
            if (nt > 0 && kd[nt] == "w" && toupper(tk[nt]) == "X" && d == tk[nt]) { nt--; txt = substr(txt, 1, length(txt) - 1) }
            lit()
          } else { qb = qb substr(s, i, j); add(substr(qb, 2, length(qb) - 2), "i"); txt = txt qb }
          inq = "" # SKIP_DEPENDENCY_CHECK
          i = p + 1
        }
      }
    } else if (c == " " || c == "\t" || c == "\r") { space(); i++ }
    else if (c == "-" && substr(s, i + 1, 1) == "-") { space(); i = n + 1 }
    else if (c == "/" && substr(s, i + 1, 1) == "*") { space(); inbc = 1; i += 2 }
    else if (c == q || c == "\"" || c == "`" || c == "[") { inq = (c == "[" ? "]" : c); qb = c; i++ }
    else if (c == "?" || c == ":" || c == "@") {
      j = i + 1
      while (j <= n && (c == "?" ? isdigit(substr(s, j, 1)) : isword(substr(s, j, 1)))) j++
      w = substr(s, i, j - i)
      add(w, "v")
      txt = txt w # SKIP_DEPENDENCY_CHECK
      i = j
    } else if (isdigit(c) || (c == "." && isdigit(substr(s, i + 1, 1)) && !(d != "" && isword(d)))) {
      j = i
      if (c == "0" && (substr(s, i + 1, 1) == "x" || substr(s, i + 1, 1) == "X")) {
        j = i + 2
        while (j <= n && index("0123456789abcdefABCDEF", substr(s, j, 1)) > 0) j++
      } else {
        while (j <= n) {
          u = substr(s, j, 1)
          if (isdigit(u) || u == ".") j++
          else if (u == "e" || u == "E") { j++; if (substr(s, j, 1) == "+" || substr(s, j, 1) == "-") j++ }
          else break
        }
      }
      lit()
      i = j
    } else if (isword(c)) {
      j = i + 1
      while (j <= n && isword(substr(s, j, 1))) j++
      w = substr(s, i, j - i)
      u = toupper(w)
      if (u == "TRUE" || u == "FALSE") lit()
      else { add(w, "w"); txt = txt w }
      i = j
    } else if (c == ";") {
      if (istrigger() && toupper(tk[nt]) != "END") { add(c, "p"); txt = txt c }
      else finish()
      i++
    } else { add(c, "p"); txt = txt c; i++ }
  }
  space()
}
function finish(   i, u, op, sm, st, al, from, name, nm, coll, seen, t) {
  if (nt == 0) { txt = ""; return }
  op = toupper(tk[1]) # SKIP_DEPENDENCY_CHECK
  if (op == "CREATE" || op == "DROP" || op == "ALTER") {
    for (i = 2; i <= 5 && i <= nt; i++) {
      u = toupper(tk[i])
      if (index(" TABLE INDEX VIEW TRIGGER ", " " u " ")) { op = op " " u; break }
    }
  }
  sm = op # SKIP_DEPENDENCY_CHECK
  st = (op == "UPDATE" ? 1 : 0) # SKIP_DEPENDENCY_CHECK
  for (i = 2; i <= nt; i++) {
    u = toupper(tk[i])
    if (st == 2) {
      if (tk[i] == ",") { st = 1; al = 0; continue }
      if (u == "AS" && !al) continue
      if ((kd[i] == "w" || kd[i] == "i") && !al && index(" ON USING WHERE GROUP ORDER LIMIT HAVING UNION EXCEPT INTERSECT JOIN LEFT RIGHT INNER OUTER CROSS NATURAL FULL WINDOW INDEXED NOT SET SELECT VALUES ", " " u " ") == 0) { al = 1; continue }
      st = 0 # SKIP_DEPENDENCY_CHECK
    }
    if (st == 1) {
      if (kd[i] == "w" && index(" IF NOT EXISTS OR ROLLBACK ABORT FAIL IGNORE REPLACE TEMP TEMPORARY ONLY ", " " u " ")) continue
      if (kd[i] == "w" || kd[i] == "i") {
        name = tk[i] # SKIP_DEPENDENCY_CHECK
        if (tk[i + 1] == "." && i + 2 <= nt) { name = tk[i + 2]; i += 2 }
        sm = sm " " name # SKIP_DEPENDENCY_CHECK
        if (index(seen, " " name " ") == 0) { seen = seen " " name " "; nm++; coll = name }
        st = (from ? 2 : 0) # SKIP_DEPENDENCY_CHECK
        al = 0 # SKIP_DEPENDENCY_CHECK
        continue
      }
      st = 0 # SKIP_DEPENDENCY_CHECK
    }
    if (kd[i] != "w") continue
    if (u == "FROM") { st = 1; from = 1 }
    else if (u == "JOIN" || u == "INTO" || u == "TABLE" || u == "VIEW" || u == "INDEX" || u == "TRIGGER") { st = 1; from = 0 }
    else if (u == "SELECT") sm = sm " SELECT"
  }
  if (nm != 1 || op ~ /INDEX|TRIGGER/) coll = ""
  t = txt
  sub(/^ +/, "", t)
  sub(/ +$/, "", t)
  gsub(/[Ii][Nn] ?\( ?\? ?(, ?\? ?)+\)/, "IN (?)", t)
  total++
  if (total == 1) { s1 = sm; o1 = op; c1 = coll; t1 = t; ss = os = cs = ts = 1 }
  else { if (sm != s1) ss = 0; if (op != o1) os = 0; if (coll != c1) cs = 0; if (t != t1) ts = 0 }
  if (length(all) < 1024) all = all (total > 1 ? "; " : "") t
  nt = 0 # SKIP_DEPENDENCY_CHECK
  txt = "" # SKIP_DEPENDENCY_CHECK
}
{ feed($0) }
END { # SKIP_DEPENDENCY_CHECK
  finish()
  if (total <= 1) { print total + 0; print substr(s1, 1, 255); print o1; print c1; print substr(t1, 1, 1024); exit }
  print total
  print substr(ss ? "BATCH " s1 : "BATCH", 1, 255)
  print (os ? "BATCH " o1 : "BATCH")
  print (cs ? c1 : "")
  print substr(ts ? t1 : all, 1, 1024)
}
'
}

_otel_alias_prepend sqlite3 _otel_instrument_sqlite3

