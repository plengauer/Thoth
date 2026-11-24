#!/bin/false
# shellcheck shell=bash

# sqlcmd -S tcp:db.example.com\inst1,1433 -d prod -Q "SELECT * FROM users WHERE id = 5" => span "SELECT users" (db.namespace=inst1|prod, db.query.text="SELECT * FROM users WHERE id = ?")

_otel_sqlcmd_parse_arguments() {
  while \[ "$#" -gt 0 ]; do
    case "$1" in
      --authentication-method | --driver-logging-level) \shift ;;
      -[acdfFhHiJKlmoPqQsStUvVwyYzZ]*)
        local option="${1#-}"
        local option="${option%"${option#?}"}"
        local value="${1#-?}"
        if \[ -z "$value" ] && \[ "$#" -gt 1 ]; then
          \shift
          local value="$1"
        fi
        case "$option" in
          S) server="$value" ;;
          d) database="$value" ;;
          c) terminator="$value" ;;
          Q | q)
            query="$value"
            if \[ "$option" = Q ]; then reads_stdin=0; fi
            ;;
          i)
            files="${files:+$files,}$value"
            reads_stdin=0
            ;;
        esac
        ;;
      -D) dsn=1 ;;
    esac
    \shift
  done
}

_otel_sqlcmd_parse_server() {
  local backslash=\\
  local rest="$1"
  protocol=''
  host=''
  instance=''
  port=''
  case "$rest" in
    [Tt][Cc][Pp]:*) protocol=tcp ;;
    [Nn][Pp]:*) protocol=np ;;
    [Ll][Pp][Cc]:*) protocol=lpc ;;
  esac
  if \[ -n "$protocol" ]; then rest="${rest#*:}"; fi
  case "$rest" in
    *,*)
      port="${rest##*,}"
      rest="${rest%,*}"
      case "$port" in '' | *[!0-9]*) port='' ;; esac
      ;;
  esac
  case "$rest" in
    "$backslash$backslash"*)
      rest="${rest#"$backslash$backslash"}"
      host="${rest%%"$backslash"*}"
      ;;
    *"$backslash"*)
      host="${rest%%"$backslash"*}"
      instance="${rest#*"$backslash"}"
      ;;
    *) host="$rest" ;;
  esac
  host="${host#\[}"
  host="${host%\]}"
}

_otel_sqlcmd_analyze() {
  \awk -v terminator="${1:-GO}" '
    function sanitize(s,    out, n, i, c, d, j, depth, e) {
      out=""
      n=length(s)
      i=1
      while (i <= n) {
        c=substr(s, i, 1)
        d=substr(s, i, 2)
        if (d == "--") {
          j=index(substr(s, i), "\n")
          i=j ? i + j : n + 1
          out=out " "
        } else if (d == "/*") {
          depth=1
          j=i + 2
          while (j <= n && depth > 0) {
            e=substr(s, j, 2)
            if (e == "/*") { depth++; j+=2 } else if (e == "*/") { depth--; j+=2 } else j++
          }
          i=j
          out=out " "
        } else if (c == "\047" || c == "\"") {
          j=i + 1
          while (j <= n) {
            if (substr(s, j, 1) == c) { if (substr(s, j + 1, 1) == c) j+=2; else break } else j++
          }
          i=j + 1
          if (out ~ /(^|[^A-Za-z0-9_@#$])[Nn]$/) out=substr(out, 1, length(out) - 1)
          out=out "?"
        } else if (c == "[") {
          j=i + 1
          while (j <= n) {
            if (substr(s, j, 1) == "]") { if (substr(s, j + 1, 1) == "]") j+=2; else break } else j++
          }
          out=out substr(s, i, j - i + 1)
          i=j + 1
        } else if (c ~ /[A-Za-z_@#]/) {
          j=i + 1
          while (j <= n && substr(s, j, 1) ~ /[A-Za-z0-9_@#$]/) j++
          out=out substr(s, i, j - i)
          i=j
        } else if (c ~ /[0-9]/ || (c == "." && substr(s, i + 1, 1) ~ /[0-9]/)) {
          j=i + 1
          if (d == "0x" || d == "0X") {
            j=i + 2
            while (j <= n && substr(s, j, 1) ~ /[0-9A-Fa-f]/) j++
          } else {
            while (j <= n && substr(s, j, 1) ~ /[0-9.]/) j++
            if (substr(s, j, 1) ~ /[eE]/ && substr(s, j + 1, 2) ~ /^([0-9]|[+-][0-9])/) {
              j+=2
              while (j <= n && substr(s, j, 1) ~ /[0-9]/) j++
            }
          }
          out=out "?"
          i=j
        } else {
          out=out c
          i++
        }
      }
      gsub(/[ \t\r\n]+/, " ", out)
      sub(/^ /, "", out)
      sub(/ $/, "", out)
      while (match(out, /(^|[^A-Za-z0-9_@#$])[Ii][Nn] *\( *\? *(, *\? *)+\)/)) {
        e=substr(out, RSTART, RLENGTH)
        c=(e ~ /^[Ii][Nn]/) ? "" : substr(e, 1, 1)
        out=substr(out, 1, RSTART - 1) c substr(e, length(c) + 1, 2) " (?)" substr(out, RSTART + RLENGTH)
      }
      return out
    }
    function add_target(x) {
      if (x !~ /^[A-Za-z_#\[]/ || toupper(x) ~ /^(SELECT|WITH|VALUES)$/) return
      targets=targets " " x
      target_count++
      first_target=x
    }
    function summarize(statement,    t, w, n, k, u) {
      op=""
      targets=""
      target_count=0
      first_target=""
      procedure=""
      t=statement
      gsub(/[(),=<>+*\/%&|^~!:-]/, " ", t)
      n=split(t, w, " ")
      if (n == 0 || w[1] !~ /^[A-Za-z]+$/ || toupper(w[1]) == "WITH") return
      op=w[1]
      u=toupper(op)
      if (u == "SELECT") {
        for (k=2; k < n; k++) if (toupper(w[k]) == "FROM" || toupper(w[k]) == "JOIN") add_target(w[k + 1])
      } else if (u == "DELETE") {
        for (k=2; k < n; k++) if (toupper(w[k]) == "FROM") { add_target(w[k + 1]); break }
        if (!target_count) add_target(w[2])
      } else if (u == "INSERT") {
        for (k=2; k < n; k++) if (toupper(w[k]) == "INTO") { add_target(w[k + 1]); break }
        if (!target_count) add_target(w[2])
      } else if (u == "UPDATE") {
        add_target(toupper(w[2]) == "TOP" ? w[4] : w[2])
      } else if (u == "MERGE") {
        add_target(toupper(w[2]) == "INTO" ? w[3] : w[2])
      } else if (u == "TRUNCATE" && toupper(w[2]) == "TABLE") {
        add_target(w[3])
      } else if (u == "EXEC" || u == "EXECUTE") {
        procedure=(w[2] ~ /^@/) ? w[3] : w[2]
        if (procedure !~ /^[A-Za-z_#\[]/) procedure=""
        else add_target(procedure)
      }
    }
    function flush(count,    text, m, parts, k, statements, summary, statement_op, statement_collection, statement_procedure) {
      text=sanitize(buffer)
      buffer=""
      if (text == "" || count == 0) return
      m=split(text, parts, ";")
      statements=0
      summary=""
      for (k=1; k <= m; k++) {
        if (parts[k] ~ /^ *$/) continue
        statements++
        summarize(parts[k])
        if (op != "") summary=summary (summary == "" ? "" : " ") op targets
        if (statements == 1) {
          statement_op=op
          statement_collection=(target_count == 1 && procedure == "") ? first_target : ""
          statement_procedure=procedure
        }
      }
      if (statements > 1) { statement_op=""; statement_collection=""; statement_procedure="" }
      sub(/;[ ;]*$/, "", text)
      batches++
      total+=count
      batch_text[batches]=text
      batch_summary[batches]=summary
      batch_op[batches]=statement_op
      batch_collection[batches]=statement_collection
      batch_procedure[batches]=statement_procedure
      batch_rows[batches]=(statements == 1 && toupper(statement_op) == "SELECT" && text !~ /@/ && toupper(text) !~ / INTO /) ? 1 : 0
    }
    function common(array,    k, v) {
      v=array[1]
      for (k=2; k <= batches; k++) if (array[k] != v) return ""
      return v
    }
    BEGIN{
      limit=1048576
      terminator=tolower(terminator)
    }
    {
      line=$0
      sub(/\r$/, "", line)
      consumed+=length(line) + 1
      trimmed=line
      gsub(/^[ \t]+|[ \t]+$/, "", trimmed)
      n=split(trimmed, fields, /[ \t]+/)
      if (tolower(fields[1]) == terminator && (n == 1 || (n == 2 && fields[2] ~ /^[0-9]+$/))) flush(n == 2 ? fields[2] + 0 : 1)
      else if (trimmed ~ /^(:|!!)/ || tolower(trimmed) ~ /^(exit|quit)$/) { }
      else if (length(buffer) < 65536) buffer=buffer "\n" line
      if (consumed > limit) exit
    }
    END{
      flush(1)
      if (batches == 0) exit
      text=batch_text[1]
      for (k=2; k <= batches; k++) text=text "; " batch_text[k]
      summary=common(batch_summary)
      operation=common(batch_op)
      collection=common(batch_collection)
      procedure=common(batch_procedure)
      rows=common(batch_rows)
      size=total
      if (batches > 1 || total > 1) {
        summary=(summary != "") ? "BATCH " summary : "BATCH"
        operation=(operation != "") ? "BATCH " operation : "BATCH"
        rows=0
      }
      printf "%s\037%s\037%s\037%s\037%s\037%s\037%s\n", size, operation, collection, procedure, substr(summary, 1, 255), rows, substr(text, 1, 1024)
    }
  '
}

# Msg 102, Level 15, State 1, Server DB01, Line 1
# Incorrect syntax near 'x'.
# (3 rows affected)
# Sqlcmd: Error: Microsoft ODBC Driver 18 for SQL Server : Login timeout expired.

_otel_sqlcmd_parse_results() {
  \awk '
    /^Msg [0-9]+, Level [0-9]+, State [0-9]+/ {
      number=$2
      sub(/,$/, "", number)
      level=$4
      sub(/,$/, "", level)
      if (level + 0 >= 11) { if (error == "") error=number } else if (warning == "") warning=number
    }
    /^\([0-9]+ rows? affected\)/ {
      count=substr($1, 2) + 0
      rows=(rows == "" ? 0 : rows) + count
    }
    END{ printf "%s\037%s\037%s\n", error, warning, rows }
  '
}

_otel_sqlcmd_input() {
  if \[ -n "$1" ]; then \printf '%s\n' "$1"; fi
  local rest="$2"
  while \[ -n "$rest" ]; do
    \cat "${rest%%,*}" 2>/dev/null || \true
    case "$rest" in
      *,*) rest="${rest#*,}" ;;
      *) rest='' ;;
    esac
  done
  if \[ -n "$3" ]; then \cat "$3" 2>/dev/null || \true; fi
}

_otel_sqlcmd_statement_attributes() {
  local span_handle="$1"
  local size operation collection procedure summary rows text
  IFS="$(\printf '\037')" \read -r size operation collection procedure summary rows text <<_otel_sqlcmd_end_of_input
$2
_otel_sqlcmd_end_of_input
  if \[ -z "$size" ]; then return 0; fi
  if \[ -n "$summary" ]; then
    otel_span_name "$span_handle" "$summary"
    otel_span_attribute_typed "$span_handle" string db.query.summary="$summary"
  fi
  if \[ -n "$operation" ]; then otel_span_attribute_typed "$span_handle" string db.operation.name="$operation"; fi
  if \[ -n "$collection" ]; then otel_span_attribute_typed "$span_handle" string db.collection.name="$collection"; fi
  if \[ -n "$procedure" ]; then otel_span_attribute_typed "$span_handle" string db.stored_procedure.name="$procedure"; fi
  if \[ "$size" -gt 1 ]; then otel_span_attribute_typed "$span_handle" int db.operation.batch.size="$size"; fi
  otel_span_attribute_typed "$span_handle" string db.query.text="$text"
  returns_rows="$rows"
}

_otel_inject_sqlcmd() {
  case "${2:-}" in
    '-?' | --help | --version | create | config | query | open | start | stop | delete | completion | help)
      local passthrough_exit_code=0
      _otel_call "$@" || passthrough_exit_code="$?"
      return "$passthrough_exit_code"
      ;;
  esac
  case "$-" in
    *m*)
      local job_control=1
      \set +m
      ;;
    *) local job_control=0 ;;
  esac
  local server="${SQLCMDSERVER:-}" database="${SQLCMDDBNAME:-}" query='' files='' terminator=GO dsn=0 reads_stdin=1
  _otel_sqlcmd_parse_arguments "$@"
  local protocol='' host='' instance='' port='' transport='' namespace='' returns_rows=0
  if \[ "$dsn" = 0 ] && \[ -n "$server" ]; then
    _otel_sqlcmd_parse_server "$server"
    case "$protocol" in
      np) transport=pipe ;;
      lpc) transport='' ;;
      *) transport=tcp ;;
    esac
    if \[ "$transport" = tcp ] && \[ -z "$port" ] && \[ -z "$instance" ]; then port=1433; fi
  fi
  if \[ -n "$database" ]; then
    if \[ -z "$instance" ]; then namespace="$database"; else namespace="$instance|$database"; fi
  fi
  local capture=0 interpose_stdin=0
  if \[ "$reads_stdin" = 0 ] || ! \[ -t 0 ]; then capture=1; fi
  if \[ "$reads_stdin" = 1 ] && ! \[ -t 0 ]; then interpose_stdin=1; fi
  local name="$namespace"
  if \[ -z "$name" ] && \[ -n "$host" ]; then
    local name="$host"
    if \[ -n "$port" ]; then local name="$name:$port"; fi
  fi
  local span_handle="$(otel_span_start CLIENT "${name:-microsoft.sql_server}")"
  otel_span_attribute_typed "$span_handle" string db.system.name=microsoft.sql_server
  if \[ -n "$host" ]; then otel_span_attribute_typed "$span_handle" string server.address="$host"; fi
  if \[ -n "$port" ]; then otel_span_attribute_typed "$span_handle" int server.port="$port"; fi
  if \[ -n "$transport" ]; then otel_span_attribute_typed "$span_handle" string network.transport="$transport"; fi
  if \[ -n "$namespace" ]; then otel_span_attribute_typed "$span_handle" string db.namespace="$namespace"; fi
  if \[ "$interpose_stdin" = 0 ]; then _otel_sqlcmd_statement_attributes "$span_handle" "$(_otel_sqlcmd_input "$query" "$files" '' | _otel_sqlcmd_analyze "$terminator")"; fi
  local dir="$(\mktemp -d -p "$_otel_shell_pipe_dir" opentelemetry_shell_$$.sqlcmd.XXXXXXXXXX)"
  local capture_stdout=0 capture_stderr=0
  if \[ "$capture" = 1 ] && ! \[ -t 1 ]; then capture_stdout=1; fi
  if \[ "$capture" = 1 ] && ! \[ -t 2 ]; then capture_stderr=1; fi
  local pattern='^(Msg [0-9]+, Level [0-9]+, State [0-9]+|\([0-9]+ rows? affected\))'
  if \[ "$capture_stdout" = 1 ]; then
    \mkfifo "$dir/stdout.pipe" "$dir/stdout.filter"
    \tee "$dir/stdout.filter" <"$dir/stdout.pipe" &
    local stdout_tee_pid="$!"
    \grep -E "$pattern" <"$dir/stdout.filter" >"$dir/stdout.results" &
    local stdout_grep_pid="$!"
  fi
  if \[ "$capture_stderr" = 1 ]; then
    \mkfifo "$dir/stderr.pipe" "$dir/stderr.filter"
    \tee "$dir/stderr.filter" <"$dir/stderr.pipe" >&2 &
    local stderr_tee_pid="$!"
    \grep -E "$pattern" <"$dir/stderr.filter" >"$dir/stderr.results" &
    local stderr_grep_pid="$!"
  fi
  if \[ "$interpose_stdin" = 1 ]; then
    \mkfifo "$dir/stdin.pipe" "$dir/stdin.filter"
    { \tee "$dir/stdin.filter" <&3 3<&- >"$dir/stdin.pipe" & } 3<&0
    local stdin_tee_pid="$!"
    \awk 'n < 1048576 { print; n += length($0) + 1 }' <"$dir/stdin.filter" >"$dir/stdin.copy" &
    local stdin_awk_pid="$!"
  fi
  local exit_code=0
  (
    if \[ "$capture_stdout" = 1 ]; then \exec >"$dir/stdout.pipe"; fi
    if \[ "$capture_stderr" = 1 ]; then \exec 2>"$dir/stderr.pipe"; fi
    if \[ "$interpose_stdin" = 1 ]; then \exec <"$dir/stdin.pipe"; fi
    _otel_call "$@"
  ) || exit_code="$?"
  if \[ "$capture_stdout" = 1 ]; then \wait "$stdout_tee_pid" "$stdout_grep_pid" || \true; fi
  if \[ "$capture_stderr" = 1 ]; then \wait "$stderr_tee_pid" "$stderr_grep_pid" || \true; fi
  if \[ "$interpose_stdin" = 1 ]; then
    \kill "$stdin_tee_pid" 2>/dev/null || \true
    \wait "$stdin_tee_pid" "$stdin_awk_pid" || \true
    _otel_sqlcmd_statement_attributes "$span_handle" "$(_otel_sqlcmd_input "$query" "$files" "$dir/stdin.copy" | _otel_sqlcmd_analyze "$terminator")"
  fi
  local error_number='' warning_number='' rows=''
  if \[ "$capture_stdout" = 1 ] || \[ "$capture_stderr" = 1 ]; then
    IFS="$(\printf '\037')" \read -r error_number warning_number rows <<_otel_sqlcmd_end_of_input
$(\cat "$dir/stdout.results" "$dir/stderr.results" 2>/dev/null | _otel_sqlcmd_parse_results)
_otel_sqlcmd_end_of_input
  fi
  \rm -rf "$dir"
  if \[ -n "$error_number" ]; then
    otel_span_attribute_typed "$span_handle" string db.response.status_code="$error_number"
    otel_span_attribute_typed "$span_handle" string error.type="$error_number"
    otel_span_error "$span_handle"
  elif \[ "$exit_code" != 0 ]; then
    otel_span_attribute_typed "$span_handle" string error.type=_OTHER
    otel_span_error "$span_handle"
  elif \[ -n "$warning_number" ]; then
    otel_span_attribute_typed "$span_handle" string db.response.status_code="$warning_number"
  fi
  if \[ -n "$rows" ] && \[ "$returns_rows" = 1 ] && \[ -z "$error_number" ]; then otel_span_attribute_typed "$span_handle" int db.response.returned_rows="$rows"; fi
  otel_span_end "$span_handle"
  if \[ "$job_control" = 1 ]; then \set -m; fi
  return "$exit_code"
}

_otel_alias_prepend sqlcmd _otel_inject_sqlcmd
