if ! type docker; then exit 0; fi

. ./assert.sh

container_name="otel_test_detached_$$"
cleanup() { sudo docker rm -f "$container_name" 1>/dev/null 2>/dev/null || true; }
trap cleanup EXIT

runner_script="$(mktemp)"
{
  \echo '. /usr/bin/opentelemetry_shell.sh'
  \echo "sudo docker run -d --name $container_name debian:latest sleep 300"
} >"$runner_script"

# run "docker run -d" from an instrumented shell that exits immediately afterwards,
# closing its sdk pipe; a deeply injected container would hang/die shortly after this point
"$TEST_SHELL" "$runner_script"
assert_equals 0 "$?"
rm -f "$runner_script"

sleep 2
assert_equals "true" "$(sudo docker inspect --format='{{.State.Running}}' "$container_name")"

# a shallow injection only adds TRACEPARENT/TRACESTATE and must not mount otel.sh into the container
sudo docker exec "$container_name" which otel.sh 1>/dev/null 2>/dev/null
assert_not_equals 0 "$?"

sleep 2
assert_equals "true" "$(sudo docker inspect --format='{{.State.Running}}' "$container_name")"
