# shellcheck shell=bash
. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh
_otel_alias_prepend() { :; }
. /usr/share/opentelemetry_shell/agent.instrumentation.sqlcmd.sh

analyze() { \printf '%s\n' "$1" | _otel_sqlcmd_analyze "${2:-GO}" | \tr '\037' '|'; }
server() {
  _otel_sqlcmd_parse_server "$1"
  # shellcheck disable=SC2154 # the variables are assigned by _otel_sqlcmd_parse_server, which deliberately returns its result through globals
  \printf '%s|%s|%s|%s' "$protocol" "$host" "$instance" "$port"
}
arguments() {
  server='' database='' query='' files='' terminator=GO dsn=0 reads_stdin=1
  _otel_sqlcmd_parse_arguments "$@"
  \printf '%s|%s|%s|%s|%s|%s|%s' "$server" "$database" "$query" "$files" "$terminator" "$dsn" "$reads_stdin"
}
results() { \printf '%s\n' "$1" | _otel_sqlcmd_parse_results | \tr '\037' '|'; }

assert_equals "|localhost||" "$(server localhost)"
assert_equals "|localhost||1444" "$(server localhost,1444)"
assert_equals "tcp|db.example.com||1433" "$(server tcp:db.example.com,1433)"
assert_equals "tcp|DB.EXAMPLE.COM||" "$(server TCP:DB.EXAMPLE.COM)"
assert_equals "|host|inst1|" "$(server 'host\inst1')"
assert_equals "tcp|host|inst1|1500" "$(server 'tcp:host\inst1,1500')"
assert_equals "tcp|::1||1433" "$(server 'tcp:[::1],1433')"
assert_equals "np|host||" "$(server 'np:\\host\pipe\sql\query')"
assert_equals "lpc|localhost||" "$(server lpc:localhost)"
assert_equals "|host||" "$(server 'host,notaport')"

assert_equals "tcp:h,1|db|select 1||GO|0|0" "$(arguments -S tcp:h,1 -d db -Q 'select 1')"
assert_equals "h|db|||GO|1|1" "$(arguments -Sh -ddb -D)"
assert_equals "h||select 1||GO|0|1" "$(arguments -S h -E -C -N -q 'select 1')"
assert_equals "||||GO|0|0" "$(arguments -i)"
assert_equals "|||a.sql,b.sql,c.sql|GO|0|0" "$(arguments -i a.sql,b.sql -i c.sql)"
assert_equals "h|||a.sql|;|0|0" "$(arguments -S h -c ';' -i a.sql)"
assert_equals "h||||GO|0|1" "$(arguments -S h -U sa -P secret -H ws -l 5 -t 10 -w 200 -h -1 -m-1 -V 16 --driver-logging-level 64 --authentication-method SqlPassword -r1 -b -W)"
assert_equals "x||||GO|0|1" "$(arguments -P -d -S x)"
case "$(arguments -S h -U sa -P topsecret -Z newsecret -Q 'select 1')" in *secret*) \echo "ASSERT FAILED secret recorded" >&2; exit 1 ;; esac

assert_equals "1|SELECT|users||SELECT users|1|SELECT * FROM users WHERE id = ?" "$(analyze 'SELECT * FROM users WHERE id = 5')"
assert_equals "1|select|users||select users|1|select name FROM users WHERE name = ?" "$(analyze "select name FROM users WHERE name = 'bob''s'")"
assert_equals "1|SELECT|t||SELECT t|1|SELECT * FROM t WHERE a = ? AND b = ? AND c = ? AND d = ? AND e = ?" "$(analyze "SELECT * FROM t WHERE a = N'x' AND b = 0xDEADbeef AND c = 1.5e-3 AND d = .5 AND e = \"double\"")"
assert_equals "1|SELECT|t||SELECT t|1|SELECT col2, t1.c3 FROM t WHERE x = ?" "$(analyze 'SELECT col2, t1.c3 FROM t WHERE x = 12')"
assert_equals "1|SELECT|t||SELECT t|1|SELECT * FROM t WHERE a IN (?) AND b NOT IN (?)" "$(analyze 'SELECT * FROM t WHERE a IN (1,2,3) AND b NOT IN ( 4 , 5 )')"
assert_equals "1|SELECT|t||SELECT t|1|SELECT * FROM t WHERE a IN (?)" "$(analyze 'SELECT * FROM t WHERE a IN (1)')"
assert_equals "1|SELECT|t||SELECT t|1|SELECT ? FROM t WHERE x = ?" "$(analyze "SELECT 'a -- b /* c' FROM t /* hidden 'x' */ WHERE x = 1 -- trailing 'y'")"
assert_equals "1|SELECT|t||SELECT t|1|SELECT * FROM t WHERE x = ?" "$(analyze "SELECT * FROM t WHERE x = 'unterminated")"
assert_equals "1|CREATE|||CREATE|0|CREATE LOGIN bob WITH PASSWORD = ?" "$(analyze "CREATE LOGIN bob WITH PASSWORD = 'hunter2'")"
assert_equals "1|INSERT|[dbo].[t]||INSERT [dbo].[t]|0|INSERT INTO [dbo].[t] (a, b) VALUES (?, ?)" "$(analyze "INSERT INTO [dbo].[t] (a, b) VALUES (1, 'x')")"
assert_equals "1|UPDATE|t||UPDATE t|0|UPDATE TOP (?) t SET a = ?" "$(analyze 'UPDATE TOP (5) t SET a = 1')"
assert_equals "1|DELETE|t||DELETE t|0|DELETE FROM t WHERE id = ?" "$(analyze 'DELETE FROM t WHERE id = 1')"
assert_equals "1|TRUNCATE|logs||TRUNCATE logs|0|TRUNCATE TABLE logs" "$(analyze 'TRUNCATE TABLE logs')"
assert_equals "1|SELECT|||SELECT x y|1|SELECT * FROM x JOIN y ON x.id = y.id" "$(analyze 'SELECT * FROM x JOIN y ON x.id = y.id')"
assert_equals "1|EXEC||dbo.sp_x|EXEC dbo.sp_x|0|EXEC dbo.sp_x @a = ?" "$(analyze 'EXEC dbo.sp_x @a = 5')"
assert_equals "1|execute||sp_y|execute sp_y|0|execute @rc = sp_y ?" "$(analyze 'execute @rc = sp_y 1')"
assert_equals "1||||DELETE a DELETE b|0|DELETE FROM a; DELETE FROM b" "$(analyze 'DELETE FROM a; DELETE FROM b;')"
assert_equals "1|SELECT|||SELECT|0|SELECT @x = ?" "$(analyze 'SELECT @x = 1')"
assert_equals "1|SELECT|t||SELECT t|0|SELECT * INTO #copy FROM t" "$(analyze 'SELECT * INTO #copy FROM t')"
assert_equals "1|||||0|WITH c AS (SELECT ?) SELECT * FROM c" "$(analyze 'WITH c AS (SELECT 1) SELECT * FROM c')"
assert_equals "" "$(analyze '')"
assert_equals "" "$(analyze 'GO')"
assert_equals "" "$(analyze '-- only a comment')"

assert_equals "2|BATCH SELECT|||BATCH SELECT|0|SELECT ?; SELECT ?" "$(analyze 'SELECT 1
GO
SELECT 2
GO')"
assert_equals "4|BATCH INSERT|t||BATCH INSERT t|0|INSERT INTO t VALUES (?); INSERT INTO t VALUES (?)" "$(analyze 'INSERT INTO t VALUES (1)
go 3
INSERT INTO t VALUES (2)
GO')"
assert_equals "3|BATCH SELECT|t||BATCH SELECT t|0|SELECT * FROM t" "$(analyze 'SELECT * FROM t
GO 3')"
assert_equals "2|BATCH|||BATCH|0|SELECT ?; DELETE FROM t" "$(analyze 'SELECT 1
GO
DELETE FROM t')"
assert_equals "1|select|t||select t|1|select ? from t" "$(analyze ':setvar x 1
:r other.sql
!!echo hi
select 1 from t
exit')"
assert_equals "2|BATCH SELECT|||BATCH SELECT|0|SELECT ?; SELECT ?" "$(analyze 'SELECT 1
RUN
SELECT 2
RUN' RUN)"

long="$(\awk 'BEGIN { for (i = 0; i < 2000; i++) printf "SELECT %d;", i }')"
assert_equals "1024" "$(analyze "$long" | \cut -d '|' -f 7- | \tr -d '\n' | \wc -c | \tr -d ' ')"

assert_equals "||" "$(results '')"
assert_equals "102||" "$(results "Msg 102, Level 15, State 1, Server DB, Line 1
Incorrect syntax near 'x'.")"
assert_equals "547||" "$(results "Msg 547, Level 16, State 0, Server DB, Procedure P, Line 3
conflict")"
assert_equals "|5701|" "$(results 'Msg 5701, Level 0, State 2, Server DB, Line 1')"
assert_equals "|50000|" "$(results 'Msg 50000, Level 10, State 1, Server DB, Line 1')"
assert_equals "208|50000|" "$(results 'Msg 50000, Level 10, State 1, Server DB, Line 1
Msg 208, Level 16, State 1, Server DB, Line 1
Msg 102, Level 15, State 1, Server DB, Line 2')"
assert_equals "||1" "$(results '(1 row affected)')"
assert_equals "||7" "$(results '(3 rows affected)
(4 rows affected)')"
assert_equals "||0" "$(results '(0 rows affected)')"
assert_equals "||" "$(results 'Msg is not an error line
(not rows)')"
