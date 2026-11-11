#!/bin/bash
set -e

root="$(cd "$(dirname "$0")" && pwd)"
dir="$(mktemp -d)"
trap 'rm -rf "$dir"' EXIT
mkdir "$dir/bin"
export test_dir="$dir"
export PATH="$dir/bin:$PATH"
export GITHUB_REPOSITORY=example/repo GITHUB_EVENT_NAME=workflow_run
export INPUT_WORKFLOW_RUN_ID=1 INPUT_WORKFLOW_RUN_ATTEMPT=1 INPUT_DEBUG=
export INPUT_GITHUB_TOKEN=
export GITHUB_EVENT_PATH="$dir/event.json"
export OTEL_TRACES_EXPORTER=none OTEL_METRICS_EXPORTER=none OTEL_LOGS_EXPORTER=none
cat >"$GITHUB_EVENT_PATH" <<'EOF'
{"workflow_run":{"id":1,"run_attempt":1,"status":"completed","workflow_id":1,"name":"test","run_started_at":"2026-01-01T00:00:00Z","updated_at":"2026-01-01T00:05:00Z","conclusion":"success","repository":{"owner":{"login":"example"},"name":"repo"}}}
EOF
cat >"$dir/bin/curl" <<'EOF'
#!/bin/bash
case "$*" in
  */rate_limit*) echo '{"resources":{"core":{"remaining":100,"limit":100}}}' ;;
  *--head*) echo 'link: <https://example.invalid/?page=1>; rel="last"' ;;
  */jobs?*) cat "$test_dir/jobs.json" ;;
  */artifacts?*) echo '{"artifacts":[]}' ;;
  */actions/workflows/*) echo '{"name":"test"}' ;;
  *) echo '[]' ;;
esac
EOF
cat >"$dir/bin/wget" <<'EOF'
#!/bin/bash
touch "$test_dir/log_downloaded"
cp "$test_dir/logs.zip" "${@: -1}"
EOF
cat >"$dir/bin/pgrep" <<'EOF'
#!/bin/bash
exit 1
EOF
touch "$dir/bin/otel.sh" "$dir/bin/parallel"
cat >"$dir/bin/otelapi.sh" <<'EOF'
otel_init() { echo init >>"$test_dir/telemetry"; }
otel_shutdown() { :; }
otel_counter_create() { echo 1; }
otel_observation_create() { [ -n "$1" ]; echo 1; }
otel_counter_observe() { :; }
otel_observation_attribute_typed() { :; }
otel_span_start() { echo 1; }
otel_span_attribute_typed() { :; }
otel_span_error() { :; }
otel_span_activate() { export TRACEPARENT=00-12345678901234567890123456789012-1234567890123456-01; }
otel_span_deactivate() { :; }
otel_span_end() { echo "$2" >>"$test_dir/telemetry"; }
EOF
chmod +x "$dir/bin/curl" "$dir/bin/wget" "$dir/bin/pgrep" "$dir/bin/otel.sh" "$dir/bin/parallel"
echo placeholder >"$dir/placeholder"
(cd "$dir" && zip -q logs.zip placeholder)

run() {
  rm -f "$dir/telemetry" "$dir/log_downloaded"
  (cd "$root" && timeout 15 bash ./main.sh) >"$dir/output" 2>&1 || { cat "$dir/output"; return 1; }
}

for field in started_at completed_at; do
  for value in null '""'; do
    jq -n --arg field "$field" --argjson value "$value" \
      '{jobs:[{id:1, conclusion:"success", started_at:"2026-01-01T00:01:00Z", completed_at:"2026-01-01T00:02:00Z"}, ({id:2, conclusion:"cancelled", started_at:"2026-01-01T00:01:00Z", completed_at:"2026-01-01T00:02:00Z"} | .[$field]=$value)]}' >"$dir/jobs.json"
    run
    grep -q '^::notice::Workflow telemetry not exported' "$dir/output"
    if grep -q '^::group::Export' "$dir/output"; then exit 1; fi
    [ ! -e "$dir/telemetry" ]
    [ ! -e "$dir/log_downloaded" ]
  done
done

echo '{"jobs":[{"id":1,"conclusion":"cancelled"}]}' >"$dir/jobs.json"
run
grep -q '^::notice::Workflow telemetry not exported' "$dir/output"
[ ! -e "$dir/telemetry" ]
[ ! -e "$dir/log_downloaded" ]

cat >"$dir/jobs.json" <<'EOF'
{"jobs":[{"id":1,"conclusion":"success","created_at":"2026-01-01T00:00:00Z","started_at":"2026-01-01T00:01:00Z","completed_at":"2026-01-01T00:02:00Z","name":"job","steps":[]},{"id":2,"conclusion":"skipped","created_at":"2026-01-01T00:00:00Z","started_at":null,"completed_at":null,"name":"skipped","steps":[]}]}
EOF
run
grep -q '^::group::Export' "$dir/output"
grep -q '^@2026-01-01T00:02:00Z$' "$dir/telemetry"
[ "$(grep -c '^@2026-01-01T00:02:00Z$' "$dir/telemetry")" -eq 2 ]
if grep -q 'not exported' "$dir/output"; then exit 1; fi

echo '{"jobs":[{"id":2,"conclusion":"skipped","created_at":"2026-01-01T00:00:00Z","started_at":null,"completed_at":null,"name":"skipped","steps":[]}]}' >"$dir/jobs.json"
run
grep -q '^@2026-01-01T00:05:00Z$' "$dir/telemetry"
