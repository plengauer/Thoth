#!/bin/bash
set -e

# some default configurations
export OTEL_SHELL_CONFIG_MUTE_BUILTINS="${OTEL_SHELL_CONFIG_MUTE_BUILTINS:-TRUE}"
export OTEL_SHELL_CONFIG_INJECT_DEEP="${OTEL_SHELL_CONFIG_INJECT_DEEP:-TRUE}"
export OTEL_SHELL_CONFIG_OBSERVE_SUBPROCESSES="${OTEL_SHELL_CONFIG_OBSERVE_SUBPROCESSES:-TRUE}"
export OTEL_SHELL_CONFIG_OBSERVE_SIGNALS="${OTEL_SHELL_CONFIG_OBSERVE_SIGNALS:-TRUE}"
export OTEL_SHELL_CONFIG_OBSERVE_PIPES="${OTEL_SHELL_CONFIG_OBSERVE_PIPES:-TRUE}"
export OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-"$(echo "$GITHUB_REPOSITORY" | cut -d / -f 2-) CI"}"
. ../shared/config_validation.sh

# redirect output to avoid race conditions and output being swallowed in case its a stream
tmp_dir="$(mktemp -d)"
chmod 777 "$tmp_dir"
echo otel_shell_sdk_output_redirect="${OTEL_SHELL_SDK_OUTPUT_REDIRECT:-/dev/null}" >> "$GITHUB_STATE"
export OTEL_SHELL_SDK_OUTPUT_REDIRECT="$(mktemp -u -p "$tmp_dir")"
mkfifo "$OTEL_SHELL_SDK_OUTPUT_REDIRECT"
chmod 777 "$OTEL_SHELL_SDK_OUTPUT_REDIRECT"
log_file="$(mktemp -u -p "$tmp_dir")"
echo "log_file=$log_file" >> "$GITHUB_STATE"
( while true; do cat "$OTEL_SHELL_SDK_OUTPUT_REDIRECT"; done >> "$log_file" ) 1> /dev/null 2> /dev/null &

# install dependencies
. ../shared/github.sh
. ../shared/install.sh

# configure collector if required
if [ "$INPUT_COLLECTOR" = true ] || ([ "$INPUT_COLLECTOR" = auto ] && ([ -n "${OTEL_EXPORTER_OTLP_HEADERS:-}" ] || [ -n "${OTEL_EXPORTER_OTLP_LOGS_HEADERS:-}" ] || [ -n "${OTEL_EXPORTER_OTLP_METRICS_HEADERS:-}" ] || [ -n "${OTEL_EXPORTER_OTLP_TRACES_HEADERS:-}" ] || [ "$INPUT_SECRETS_TO_REDACT" != '{}' ])); then
  if ! type docker; then echo "::error ::Cannot use collector because docker is unavailable." && false; fi
  section_exporter_logs="$(mktemp)"; section_exporter_metrics="$(mktemp)"; section_exporter_traces="$(mktemp)"
  section_pipeline_logs="$(mktemp)"; section_pipeline_metrics="$(mktemp)"; section_pipeline_traces="$(mktemp)"
  if [ "${OTEL_LOGS_EXPORTER:-otlp}" = otlp ]; then
    if [ "${OTEL_EXPORTER_OTLP_PROTOCOL:-http/protobuf}" ]; then collector_exporter=otlphttp; else collector_exporter=otlp; fi
    cat > "$section_exporter_logs" <<EOF
  $collector_exporter/logs:
    endpoint: "$(echo "${OTEL_EXPORTER_OTLP_LOGS_ENDPOINT:-$OTEL_EXPORTER_OTLP_ENDPOINT/v1/logs}" | rev | cut -d / -f 3- | rev)"
    headers:
$(echo "$OTEL_EXPORTER_OTLP_HEADERS","$OTEL_EXPORTER_OTLP_LOGS_HEADERS" | tr ',' '\n' | grep -v '^$' | sed 's/=/: /g' | sed 's/^/      /g')
EOF
    cat > "$section_pipeline_logs" <<EOF
    logs:
      receivers: [otlp]
      exporters: [$collector_exporter/logs]
      processors: [transform, batch]
EOF
    unset OTEL_EXPORTER_OTLP_LOGS_HEADERS
    export OTEL_LOGS_EXPORTER=otlp
    export OTEL_EXPORTER_OTLP_LOGS_ENDPOINT=http://localhost:4318/v1/logs
    export OTEL_EXPORTER_OTLP_LOGS_PROTOCOL=http/protobuf
  fi
  if [ "${OTEL_METRICS_EXPORTER:-otlp}" = otlp ]; then
    if [ "${OTEL_EXPORTER_OTLP_PROTOCOL:-http/protobuf}" ]; then collector_exporter=otlphttp; else collector_exporter=otlp; fi
    cat > "$section_exporter_metrics" <<EOF
  $collector_exporter/metrics:
    endpoint: "$(echo "${OTEL_EXPORTER_OTLP_METRICS_ENDPOINT:-$OTEL_EXPORTER_OTLP_ENDPOINT/v1/metrics}" | rev | cut -d / -f 3- | rev)"
    headers:
$(echo "$OTEL_EXPORTER_OTLP_HEADERS","$OTEL_EXPORTER_OTLP_METRICS_HEADERS" | tr ',' '\n' | grep -v '^$' | sed 's/=/: /g' | sed 's/^/      /g')
EOF
    cat > "$section_pipeline_metrics" <<EOF
    metrics:
      receivers: [otlp]
      exporters: [$collector_exporter/metrics]
      processors: [transform, batch]
EOF
    unset OTEL_EXPORTER_OTLP_METRICS_HEADERS
    export OTEL_METRICS_EXPORTER=otlp
    export OTEL_EXPORTER_OTLP_METRICS_ENDPOINT=http://localhost:4318/v1/metrics
    export OTEL_EXPORTER_OTLP_METRICS_PROTOCOL=http/protobuf
  fi
  if [ "${OTEL_TRACES_EXPORTER:-otlp}" = otlp ]; then
    if [ "${OTEL_EXPORTER_OTLP_PROTOCOL:-http/protobuf}" ]; then collector_exporter=otlphttp; else collector_exporter=otlp; fi
    cat > "$section_exporter_traces" <<EOF
  $collector_exporter/traces:
    endpoint: "$(echo "${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-$OTEL_EXPORTER_OTLP_ENDPOINT/v1/traces}" | rev | cut -d / -f 3- | rev)"
    headers:
$(echo "$OTEL_EXPORTER_OTLP_HEADERS","$OTEL_EXPORTER_OTLP_TRACES_HEADERS" | tr ',' '\n' | grep -v '^$' | sed 's/=/: /g' | sed 's/^/      /g')
EOF
    cat > "$section_pipeline_traces" <<EOF
    traces:
      receivers: [otlp]
      exporters: [$collector_exporter/traces]
      processors: [transform, batch]
EOF
    unset OTEL_EXPORTER_OTLP_TRACES_HEADERS
    export OTEL_TRACES_EXPORTER=otlp
    export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=http://localhost:4318/v1/traces
    export OTEL_EXPORTER_OTLP_TRACES_PROTOCOL=http/protobuf
  fi
  unset OTEL_EXPORTER_OTLP_HEADERS OTEL_EXPORTER_OTLP_ENDPOINT
  cat > collector.yaml <<EOF
receivers:
  otlp:
    protocols:
      http:
        endpoint: localhost:4318
exporters:
$(cat $section_exporter_logs)
$(cat $section_exporter_metrics)
$(cat $section_exporter_traces)
processors:
  batch:
  transform:
    error_mode: ignore
    log_statements:
$(echo "$INPUT_SECRETS_TO_REDACT" | jq -r '. | to_entries[].value' | sed 's/[.[\(*^$+?{|]/\\\\&/g' | xargs -d '\n' -I '{}' printf '%s\n' 'replace_all_patterns(log.attributes, "value", "{}", "***")' | sed 's/^/      - /g')
$(echo "$INPUT_SECRETS_TO_REDACT" | jq -r '. | to_entries[].value' | sed 's/[.[\(*^$+?{|]/\\\\&/g' | xargs -d '\n' -I '{}' printf '%s\n' 'replace_pattern(log.body, "{}", "***")' | sed 's/^/      - /g')
    metric_statements:
$(echo "$INPUT_SECRETS_TO_REDACT" | jq -r '. | to_entries[].value' | sed 's/[.[\(*^$+?{|]/\\\\&/g' | xargs -d '\n' -I '{}' printf '%s\n' 'replace_all_patterns(datapoint.attributes, "value", "{}", "***")' | sed 's/^/      - /g')
    trace_statements:
$(echo "$INPUT_SECRETS_TO_REDACT" | jq -r '. | to_entries[].value' | sed 's/[.[\(*^$+?{|]/\\\\&/g' | xargs -d '\n' -I '{}' printf '%s\n' 'replace_all_patterns(span.attributes, "value", "{}", "***")' | sed 's/^/      - /g')
$(echo "$INPUT_SECRETS_TO_REDACT" | jq -r '. | to_entries[].value' | sed 's/[.[\(*^$+?{|]/\\\\&/g' | xargs -d '\n' -I '{}' printf '%s\n' 'replace_pattern(span.name, "{}", "***")' | sed 's/^/      - /g')
service:
  pipelines:
$(cat $section_pipeline_logs)
$(cat $section_pipeline_metrics)
$(cat $section_pipeline_traces)
EOF
  if [ -n "$INPUT_DEBUG" ]; then
    echo "$INPUT_SECRETS_TO_REDACT" | jq -r '. | to_entries[].value' | sed 's/[.[\(*^$+?{|]/\\\\&/g' | xargs -I '{}' echo '::add-mask::{}'
    cat collector.yaml
  fi
fi

# setup injections
echo "$GITHUB_ACTION" > /tmp/opentelemetry_shell_action_name # to avoid recursions
export GITHUB_ACTION_PATH="$(pwd)"
new_binary_dir="$GITHUB_ACTION_PATH/bin"
relocated_binary_dir="$GITHUB_ACTION_PATH/relocated_bin"
mkdir -p "$new_binary_dir" "$relocated_binary_dir"
echo "$new_binary_dir" >> "$GITHUB_PATH"
## setup injection for shell actions
gcc -o "$new_binary_dir"/sh forward.c -DEXECUTABLE="$(which sh)" -DARG1="$GITHUB_ACTION_PATH"/decorate_action_run.sh -DARG2="$(which sh)"
gcc -o "$new_binary_dir"/dash forward.c -DEXECUTABLE="$(which dash)" -DARG1="$GITHUB_ACTION_PATH"/decorate_action_run.sh -DARG2="$(which dash)"
gcc -o "$new_binary_dir"/bash forward.c -DEXECUTABLE="$(which bash)" -DARG1="$GITHUB_ACTION_PATH"/decorate_action_run.sh -DARG2="$(which bash)"
## setup injections into node actions
for node_path in "$(readlink -f /proc/*/exe | grep '/Runner.Worker$' | rev | cut -d / -f 4- | rev)"/*/externals/node*/bin/node; do
  dir_path_new="$relocated_binary_dir"/"$(echo "$node_path" | rev | cut -d / -f 3 | rev)"
  mkdir "$dir_path_new"
  node_path_new="$dir_path_new"/node
  mv "$node_path" "$node_path_new"
  gcc -o "$node_path" forward.c -DEXECUTABLE=/bin/bash -DARG1="$GITHUB_ACTION_PATH"/decorate_action_node.sh -DARG2="$node_path_new" # path is hardcoded in the runners
done
## setup injections into docker actions
docker_path="$(which docker)"
sudo mv "$docker_path" "$relocated_binary_dir"
sudo gcc -o "$docker_path" forward.c -DEXECUTABLE=/bin/bash -DARG1="$GITHUB_ACTION_PATH"/decorate_action_docker.sh -DARG2="$relocated_binary_dir"/docker

# resolve parent (does not exist yet - see workflow action) and make sure all jobs are of the same trace and have the same deferred parent 
opentelemetry_root_dir="$(mktemp -d)"
count=0
while [ "$count" -lt 60 ] && ! gh_artifact_download "$GITHUB_RUN_ID" "$GITHUB_RUN_ATTEMPT" opentelemetry_workflow_run_"$GITHUB_RUN_ATTEMPT" "$opentelemetry_root_dir" || ! [ -r "$opentelemetry_root_dir"/traceparent ]; do
  if [ "$count" -gt 0 ]; then sleep $count; fi
  . otelapi.sh
  otel_init
  otel_span_traceparent "$(otel_span_start INTERNAL dummy)" > "$opentelemetry_root_dir"/traceparent
  gh_artifact_upload "$GITHUB_RUN_ID" "$GITHUB_RUN_ATTEMPT" opentelemetry_workflow_run_"$GITHUB_RUN_ATTEMPT" "$opentelemetry_root_dir"/traceparent || true
  rm "$opentelemetry_root_dir"/traceparent
  otel_shutdown
  count=$((count + 1))
done
[ -r "$opentelemetry_root_dir"/traceparent ] || (echo "::error ::Cannot sync trace id via artifacts. This is most likely a token permission issue, please consult the README." && false)
export TRACEPARENT="$(cat "$opentelemetry_root_dir"/traceparent)"
rm -rf "$opentelemetry_root_dir"

# guess job id for proper linking
OTEL_SHELL_GITHUB_JOB="$GITHUB_JOB"
job_arguments="$(printf '%s' "$INPUT___JOB_MATRIX" | jq -r '. | [.. | scalars] | @tsv' | sed 's/\t/, /g')"
if [ -n "$job_arguments" ]; then OTEL_SHELL_GITHUB_JOB="$OTEL_SHELL_GITHUB_JOB ($job_arguments)"; fi
export OTEL_SHELL_GITHUB_JOB
GITHUB_JOB_ID="$(gh_jobs "$GITHUB_RUN_ID" "$GITHUB_RUN_ATTEMPT" | jq --unbuffered -r '. | .jobs[] | [.id, .name] | @tsv' | sed 's/\t/ /g' | grep " $OTEL_SHELL_GITHUB_JOB"'$' | cut -d ' ' -f 1)"
if [ "$(printf '%s' "$GITHUB_JOB_ID" | wc -l)" -le 1 ]; then echo "Guessing GitHub job id to be $GITHUB_JOB_ID" >&2; export GITHUB_JOB_ID; else echo ::warning ::Could not guess GitHub job id.; fi

# observe ...

observe_rate_limit() {
  used_gauge_handle="$(otel_counter_create observable_gauge github.api.rate_limit.used 1 "The amount of rate limited requests used")"
  remaining_gauge_handle="$(otel_counter_create observable_gauge github.api.rate_limit.remaining 1 "The amount of rate limited requests remaining")"
  while [ -r /tmp/opentelemetry_shell.github.observe_rate_limits ]; do
    gh_rate_limit | jq --unbuffered -r '.resources | to_entries[] | [.key, .value.used, .value.remaining] | @tsv' | sed 's/\t/ /g' | while read -r resource used remaining; do
      observation_handle="$(otel_observation_create "$used")"
      otel_observation_attribute_typed "$observation_handle" string github.api.resource="$resource"
      otel_counter_observe "$used_gauge_handle" "$observation_handle"
      observation_handle="$(otel_observation_create "$remaining")"
      otel_observation_attribute_typed "$observation_handle" string github.api.resource="$resource"
      otel_counter_observe "$remaining_gauge_handle" "$observation_handle"
    done
    sleep 5
  done
}
export -f observe_rate_limit

root4job_end() {
  exec 1> /tmp/opentelemetry_shell.github.debug.log
  exec 2> /tmp/opentelemetry_shell.github.debug.log
  rm /tmp/opentelemetry_shell.github.observe_rate_limits
  if [ -f /tmp/opentelemetry_shell.github.error ]; then local conclusion=failure; else local conclusion=success; fi
  otel_span_attribute_typed $span_handle string github.actions.job.conclusion="$conclusion"
  if [ "$conclusion" = failure ]; then otel_span_error "$span_handle"; fi
  otel_span_end "$span_handle"
  time_end="$(date +%s.%N)"
  local counter_handle="$(otel_counter_create counter github.actions.jobs 1 'Number of job runs')"
  local observation_handle="$(otel_observation_create 1)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.workflow.name="$GITHUB_WORKFLOW"
  otel_observation_attribute_typed "$observation_handle" int github.actions.workflow_run.attempt="$GITHUB_RUN_ATTEMPT"
  otel_observation_attribute_typed "$observation_handle" int github.actions.actor.id="$GITHUB_ACTOR_ID"
  otel_observation_attribute_typed "$observation_handle" string github.actions.actor.name="$GITHUB_ACTOR"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.name="$GITHUB_EVENT_NAME"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref="/refs/heads/$GITHUB_REF_NAME"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref.name="$GITHUB_REF_NAME"
  otel_observation_attribute_typed "$observation_handle" string github.actions.job.name="${OTEL_SHELL_GITHUB_JOB:-$GITHUB_JOB}"
  otel_observation_attribute_typed "$observation_handle" string github.actions.job.conclusion="$conclusion"
  otel_counter_observe "$counter_handle" "$observation_handle"
  local counter_handle="$(otel_counter_create counter github.actions.jobs.duration s 'Duration of job runs')"
  local observation_handle="$(otel_observation_create "$(python3 -c "print(str($time_end - $time_start))")")"
  otel_observation_attribute_typed "$observation_handle" string github.actions.workflow.name="$GITHUB_WORKFLOW"
  otel_observation_attribute_typed "$observation_handle" int github.actions.workflow_run.attempt="$GITHUB_RUN_ATTEMPT"
  otel_observation_attribute_typed "$observation_handle" int github.actions.actor.id="$GITHUB_ACTOR_ID"
  otel_observation_attribute_typed "$observation_handle" string github.actions.actor.name="$GITHUB_ACTOR"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.name="$GITHUB_EVENT_NAME"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref="/refs/heads/$GITHUB_REF_NAME"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref.name="$GITHUB_REF_NAME"
  otel_observation_attribute_typed "$observation_handle" string github.actions.job.name="${OTEL_SHELL_GITHUB_JOB:-$GITHUB_JOB}"
  otel_observation_attribute_typed "$observation_handle" string github.actions.job.conclusion="$conclusion"
  otel_counter_observe "$counter_handle" "$observation_handle"
  otel_shutdown

  if ([ "$INPUT_SELF_MONITORING" = true ] || ([ "$INPUT_SELF_MONITORING" = auto ] && [ "$GITHUB_API_URL" = 'https://api.github.com' ])); then
    (
      unset OTEL_EXPORTER_OTLP_METRICS_ENDPOINT OTEL_EXPORTER_OTLP_LOGS_ENDPOINT OTEL_EXPORTER_OTLP_TRACES_ENDPOINT
      export OTEL_SHELL_SDK_OUTPUT_REDIRECT=/dev/null
      export OTEL_SERVICE_NAME="OpenTelemetry GitHub Selfmonitoring"
      export OTEL_TRACES_EXPORTER=none
      export OTEL_LOGS_EXPORTER=none
      [ "${OTEL_SHELL_CONFIG_GITHUB_IS_TEST:-FALSE}" = FALSE ] && export OTEL_METRICS_EXPORTER=otlp || export OTEL_METRICS_EXPORTER=none
      export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
      export OTEL_EXPORTER_OTLP_ENDPOINT=http://3.73.14.87:4318
      export OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE=delta
      . otelapi.sh
      _otel_resource_attributes_process() {
        :
      }
      _otel_resource_attributes_custom() {
        _otel_resource_attribute string telemetry.sdk.language=github
      }
      if [ "$INPUT_SELF_MONITORING_ANONYMIZE" = true ] || ([ "$INPUT_SELF_MONITORING_ANONYMIZE" = auto ] && ([ "$GITHUB_API_URL" != 'https://api.github.com' ] || [ "$(gh_curl | jq -r .visibility)" != public ])); then
        unset GITHUB_REPOSITORY_ID GITHUB_REPOSITORY GITHUB_REPOSITORY_OWNER_ID GITHUB_REPOSITORY_OWNER
      fi
      unset GITHUB_WORKFLOW_REF GITHUB_WORKFLOW_SHA GITHUB_WORKFLOW
      otel_init
      invocation_observation_handle="$(otel_observation_create 1)"
      otel_observation_attribute_typed "$invocation_observation_handle" string github.actions.runner.os="$RUNNER_OS"
      otel_observation_attribute_typed "$invocation_observation_handle" string github.actions.runner.arch="$RUNNER_ARCH"
      otel_observation_attribute_typed "$invocation_observation_handle" string github.actions.runner.environment="$RUNNER_ENVIRONMENT"
      otel_counter_observe "$(otel_counter_create counter selfmonitoring.opentelemetry.github.job.invocations 1 'Invocations of job-level instrumentation')" "$invocation_observation_handle"
      self_monitoring_metrics_file="$(mktemp)"
      [ -z "${OTEL_SHELL_COLLECTOR_CONTAINER:-}" ] || curl -s http://localhost:8888/metrics > "$self_monitoring_metrics_file"
      metrics_observation_handle="$(otel_observation_create "$({ echo 0; cat "$self_monitoring_metrics_file" | grep '^otelcol_receiver_accepted_metric_points' | cut -d ' ' -f 2; } | paste -sd+ | bc)")"
      otel_observation_attribute_typed "$metrics_observation_handle" string github.actions.runner.os="$RUNNER_OS"
      otel_observation_attribute_typed "$metrics_observation_handle" string github.actions.runner.arch="$RUNNER_ARCH"
      otel_observation_attribute_typed "$metrics_observation_handle" string github.actions.runner.environment="$RUNNER_ENVIRONMENT"
      otel_counter_observe "$(otel_counter_create counter selfmonitoring.opentelemetry.github.job.metric_points 1 'Metric Datapoints created by job-level instrumentation')" "$metrics_observation_handle"
      logs_observation_handle="$(otel_observation_create "$({ echo 0; cat "$self_monitoring_metrics_file" | grep '^otelcol_receiver_accepted_log_records' | cut -d ' ' -f 2; } | paste -sd+ | bc)")"
      otel_observation_attribute_typed "$logs_observation_handle" string github.actions.runner.os="$RUNNER_OS"
      otel_observation_attribute_typed "$logs_observation_handle" string github.actions.runner.arch="$RUNNER_ARCH"
      otel_observation_attribute_typed "$logs_observation_handle" string github.actions.runner.environment="$RUNNER_ENVIRONMENT"
      otel_counter_observe "$(otel_counter_create counter selfmonitoring.opentelemetry.github.job.logs 1 'Logs created by job-level instrumentation')" "$logs_observation_handle"
      spans_observation_handle="$(otel_observation_create "$({ echo 0; cat "$self_monitoring_metrics_file" | grep '^otelcol_receiver_accepted_spans' | cut -d ' ' -f 2; } | paste -sd+ | bc)")"
      otel_observation_attribute_typed "$spans_observation_handle" string github.actions.runner.os="$RUNNER_OS"
      otel_observation_attribute_typed "$spans_observation_handle" string github.actions.runner.arch="$RUNNER_ARCH"
      otel_observation_attribute_typed "$spans_observation_handle" string github.actions.runner.environment="$RUNNER_ENVIRONMENT"
      otel_counter_observe "$(otel_counter_create counter selfmonitoring.opentelemetry.github.job.spans 1 'Spans created by job-level instrumentation')" "$spans_observation_handle"
      rm "$self_monitoring_metrics_file"
      step_counter_handle="$(otel_counter_create counter selfmonitoring.opentelemetry.github.job.steps 1 'Steps observed by job-level instrumentation')"
      ( cat /tmp/opentelemetry_shell.github.step.log || true ) | while read -r action_type action_name; do
        step_observation_handle="$(otel_observation_create 1)"
        otel_observation_attribute_typed "$step_observation_handle" string github.actions.runner.os="$RUNNER_OS"
        otel_observation_attribute_typed "$step_observation_handle" string github.actions.runner.arch="$RUNNER_ARCH"
        otel_observation_attribute_typed "$step_observation_handle" string github.actions.runner.environment="$RUNNER_ENVIRONMENT"
        otel_observation_attribute_typed "$step_observation_handle" string github.actions.action.type="$action_type"
        otel_observation_attribute_typed "$step_observation_handle" string github.actions.action.name="$action_name"
        otel_counter_observe "$step_counter_handle" "$step_observation_handle"
      done
      otel_shutdown
    )
  fi

  while kill -0 "$observe_rate_limit_pid" 2> /dev/null; do sleep 1; done
  timeout 60s sh -c 'while fuser /opt/opentelemetry_shell/venv/bin/python; do sleep 1; done' &> /dev/null || true
  
  if [ -n "${OTEL_SHELL_COLLECTOR_CONTAINER:-}" ]; then
    sudo docker stop "$OTEL_SHELL_COLLECTOR_CONTAINER"
    if [ -n "$INPUT_DEBUG" ]; then
      sudo docker logs "$OTEL_SHELL_COLLECTOR_CONTAINER"
    fi
  fi
  exit 0
}
export -f root4job_end

root4job() {
  exec 1> /tmp/opentelemetry_shell.github.debug.log
  exec 2> /tmp/opentelemetry_shell.github.debug.log
  [ -z "${OTEL_SHELL_COLLECTOR_IMAGE:-}" ] || export OTEL_SHELL_COLLECTOR_CONTAINER="$(OTEL_SHELL_COLLECTOR_CONFIG="$(cat "$(pwd)"/collector.yaml)" sudo -E docker run --detach --restart unless-stopped --network=host --env OTEL_SHELL_COLLECTOR_CONFIG "$OTEL_SHELL_COLLECTOR_IMAGE" --config=env:OTEL_SHELL_COLLECTOR_CONFIG)"
  rm -rf "$(pwd)"/collector.yaml 2> /dev/null
  rm /tmp/opentelemetry_shell.github.error 2> /dev/null
  traceparent_file="$1"
  . otelapi.sh
  _otel_resource_attributes_process() {
    :
  }
  _otel_resource_attributes_custom() {
    _otel_resource_attribute string telemetry.sdk.language=github
  }
  otel_init
  touch /tmp/opentelemetry_shell.github.observe_rate_limits
  observe_rate_limit &> /dev/null &
  observe_rate_limit_pid="$!"
  time_start="$(date +%s.%N)"
  span_handle="$(otel_span_start CONSUMER "${OTEL_SHELL_GITHUB_JOB:-$GITHUB_JOB}")"
  otel_span_attribute_typed $span_handle string github.actions.type=job
  if [ -n "$GITHUB_JOB_ID" ]; then
    otel_span_attribute_typed $span_handle string github.actions.url="${GITHUB_SERVER_URL:-https://github.com}"/"$GITHUB_REPOSITORY"/actions/runs/"$GITHUB_RUN_ID"/job/"$GITHUB_JOB_ID"
  fi
  otel_span_attribute_typed $span_handle int github.actions.job.id="${GITHUB_JOB_ID:-}"
  otel_span_attribute_typed $span_handle string github.actions.job.name="${OTEL_SHELL_GITHUB_JOB:-$GITHUB_JOB}"
  otel_span_attribute_typed $span_handle string github.actions.runner.name="$RUNNER_NAME"
  otel_span_attribute_typed $span_handle string github.actions.runner.os="$RUNNER_OS"
  otel_span_attribute_typed $span_handle string github.actions.runner.arch="$RUNNER_ARCH"
  otel_span_attribute_typed $span_handle string github.actions.runner.environment="$RUNNER_ENVIRONMENT"
  otel_span_activate "$span_handle"
  echo "$TRACEPARENT" > "$traceparent_file"
  if [ -n "${GITHUB_JOB_ID:-}" ]; then
    opentelemetry_job_dir="$(mktemp -d)"
    echo "$TRACEPARENT" > "$opentelemetry_job_dir"/traceparent
    gh_artifact_upload "$GITHUB_RUN_ID" "$GITHUB_RUN_ATTEMPT" opentelemetry_job_"$GITHUB_JOB_ID" "$opentelemetry_job_dir"/traceparent
    rm -rf "$opentelemetry_job_dir"
  fi
  otel_span_deactivate "$span_handle"
  exec 2>&-
  exec 1>&-
  trap root4job_end SIGUSR1
  while true; do sleep 1; done
}
export -f root4job

traceparent_file="$(mktemp -u)"
mkfifo /tmp/opentelemetry_shell.github.debug.log
nohup bash -c 'root4job "$@"' bash "$traceparent_file" &> /dev/null &
echo "pid=$!" >> "$GITHUB_STATE"
cat /tmp/opentelemetry_shell.github.debug.log

# propagate context to the steps
export TRACEPARENT="$(cat "$traceparent_file")"
rm "$traceparent_file"
printenv | grep -E '^OTEL_|^TRACEPARENT=|^TRACESTATE=' >> "$GITHUB_ENV"
