. ./assert.sh

# Regression guard for https://github.com/plengauer/Thoth/issues/4256:
# the job-level post step must never block indefinitely on the debug-log fifo
# rendezvous with root4job_end, no matter what state the root process is in.

shutdown_script="$(cd "$(dirname "$0")"/../.. && pwd)"/actions/instrument/job/shutdown.sh
debug_log_file=/tmp/opentelemetry_shell.github.debug.log

# Runs shutdown.sh against a given root pid and echoes "<elapsed_seconds> <exit_code>".
# Anything that takes as long as the outer guard means the post step hung.
run_shutdown() {
  local root_pid="$1" timeout_s="$2"
  local log_file sink start elapsed code
  log_file="$(mktemp)"
  sink="$(mktemp)"
  \echo payload >"$log_file"
  start="$(\date +%s)"
  STATE_pid="$root_pid" STATE_log_file="$log_file" STATE_otel_shell_sdk_output_redirect="$sink" \
    INPUT___JOB_STATUS=success OTEL_GITHUB_JOB_SHUTDOWN_TIMEOUT="$timeout_s" \
    timeout 60 sh -e "$shutdown_script" >/dev/null 2>&1
  code=$?
  elapsed=$(($(\date +%s) - start))
  # the sdk output redirect must still be forwarded on every path
  assert_equals payload "$(\cat "$sink")"
  \rm -f "$log_file" "$sink"
  \echo "$elapsed $code"
}

# A root process that installs the SIGUSR1 handler and parks, like root4job does.
start_responsive_root() {
  \rm -f "$debug_log_file"
  \mkfifo "$debug_log_file"
  setsid bash -c '
    exec 1>'"$debug_log_file"'; exec 2>'"$debug_log_file"'
    \echo init
    trap "exec 1>'"$debug_log_file"'; exec 2>'"$debug_log_file"'; exit 0" USR1
    exec 1>&-; exec 2>&-
    while true; do \sleep 1; done
  ' >/dev/null 2>&1 &
  local pid=$!
  \cat "$debug_log_file" >/dev/null   # drains until the handler is installed, like the pre step
  \echo "$pid"
}

# healthy: the handler answers, shutdown completes promptly and succeeds
pid="$(start_responsive_root)"
result="$(run_shutdown "$pid" 30)"
assert_equals 0 "$(\echo "$result" | \cut -d ' ' -f 2)"
assert_equals true "$([ "$(\echo "$result" | \cut -d ' ' -f 1)" -lt 15 ] && \echo true || \echo false)"
\kill -9 "$pid" 2>/dev/null

# alive but never answers: bounded by OTEL_GITHUB_JOB_SHUTDOWN_TIMEOUT, not by the runner
\rm -f "$debug_log_file"
\mkfifo "$debug_log_file"
setsid bash -c 'while true; do \sleep 1; done' >/dev/null 2>&1 &
pid=$!
disown 2>/dev/null || true
\sleep 1
result="$(run_shutdown "$pid" 3)"
assert_equals 0 "$(\echo "$result" | \cut -d ' ' -f 2)"
assert_equals true "$([ "$(\echo "$result" | \cut -d ' ' -f 1)" -lt 30 ] && \echo true || \echo false)"
\kill -9 "$pid" 2>/dev/null

# zombie root process: kill(2) succeeds and the signal is discarded, so the
# rendezvous would never be released - must be detected up front, not waited on
\rm -f "$debug_log_file"
\mkfifo "$debug_log_file"
zombie_pid_file="$(mktemp)"
python3 -u -c 'import os, time
pid = os.fork()
if pid == 0:
    os._exit(0)
open("'"$zombie_pid_file"'", "w").write(str(pid))
time.sleep(120)' >/dev/null 2>&1 &
parent_pid=$!
disown 2>/dev/null || true
\sleep 2
pid="$(\cat "$zombie_pid_file")"
assert_equals Z "$(\awk '/^State:/ { print $2; exit }' /proc/"$pid"/status)"
result="$(run_shutdown "$pid" 30)"
assert_equals 0 "$(\echo "$result" | \cut -d ' ' -f 2)"
assert_equals true "$([ "$(\echo "$result" | \cut -d ' ' -f 1)" -lt 15 ] && \echo true || \echo false)"
\kill -9 "$parent_pid" 2>/dev/null
\rm -f "$zombie_pid_file"

# root process gone entirely: degrade to a warning, never fail the job
\rm -f "$debug_log_file"
\mkfifo "$debug_log_file"
setsid bash -c 'exit 0' >/dev/null 2>&1 &
pid=$!
wait "$pid" 2>/dev/null
\sleep 1
result="$(run_shutdown "$pid" 30)"
assert_equals 0 "$(\echo "$result" | \cut -d ' ' -f 2)"

\rm -f "$debug_log_file"
