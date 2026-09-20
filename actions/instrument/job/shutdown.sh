#!/bin/sh
set -e
if [ -n "${STATE_disabled:-}" ] || [ -z "${STATE_pid:-}" ]; then
  exit 0
fi
if [ "$INPUT___JOB_STATUS" = failure ]; then
  touch /tmp/opentelemetry_shell.github.error
fi
root_pid="$STATE_pid"
debug_log_file=/tmp/opentelemetry_shell.github.debug.log
shutdown_timeout="${OTEL_GITHUB_JOB_SHUTDOWN_TIMEOUT:-600}"

root_process_state() {
  awk '/^State:/ { print $2; exit }' /proc/"$root_pid"/status 2>/dev/null || true
}

# Reading the debug log below is a rendezvous on a fifo: it blocks in open()
# until root4job_end, the SIGUSR1 handler, opens the same fifo for writing.
# A successful kill does not promise that handler will ever run. Signaling a
# zombie returns 0 and discards the signal, and a root process re-parented away
# from the already exited pre-step stays a zombie whenever the runner image has
# no reaping init, which is why container images such as ubuntu-slim hit this.
# A recycled pid behaves the same way. Without the guards below the read then
# blocks until the runner tears the whole job down, which showed up as post
# steps hanging 15+ minutes while emitting nothing at all (see issue #4256).
# So reject a zombie explicitly, and bound every blocking read regardless, so
# that a lost flush costs telemetry rather than the job.
if ! kill -0 "$root_pid" 2>/dev/null; then
  shutdown_warning="its root process $root_pid no longer exists"
elif [ "$(root_process_state)" = Z ]; then
  shutdown_warning="its root process $root_pid is a zombie and cannot handle signals"
elif ! kill -USR1 "$root_pid" 2>/dev/null; then
  shutdown_warning="its root process $root_pid could not be signaled"
elif ! timeout "$shutdown_timeout" cat "$debug_log_file"; then
  root_state="$(root_process_state)"
  shutdown_warning="its root process $root_pid did not finish shutting down within ${shutdown_timeout}s and is now in state ${root_state:-gone}"
fi
if [ -n "${shutdown_warning:-}" ]; then
  echo "::warning::Job-level instrumentation could not be shut down cleanly because ${shutdown_warning}. Telemetry for this job is incomplete or missing. The job itself is unaffected. Please report this at https://github.com/plengauer/Thoth/issues."
fi
timeout "$shutdown_timeout" cat <"$STATE_log_file" >"$STATE_otel_shell_sdk_output_redirect" || true
