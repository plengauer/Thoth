#!/bin/bash
set -e -o pipefail
if [ -n "$INPUT_DEBUG" ]; then set -mx; fi

echo "::group::Validate Configuration"
export OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-"$(echo "$GITHUB_REPOSITORY" | cut -d / -f 2-) CI"}"
export OTEL_SHELL_CONFIG_MUTE_BUILTINS="${OTEL_SHELL_CONFIG_MUTE_BUILTINS:-TRUE}"
export OTEL_SHELL_CONFIG_INJECT_DEEP="${OTEL_SHELL_CONFIG_INJECT_DEEP:-TRUE}"
export OTEL_SHELL_CONFIG_OBSERVE_STDERR="${OTEL_SHELL_CONFIG_OBSERVE_STDERR:-TRUE}"
export OTEL_SHELL_CONFIG_OBSERVE_PIPES="${OTEL_SHELL_CONFIG_OBSERVE_PIPES:-TRUE}"
export OTEL_SHELL_CONFIG_OBSERVE_SUBPROCESSES="${OTEL_SHELL_CONFIG_OBSERVE_SUBPROCESSES:-TRUE}"
export OTEL_SHELL_CONFIG_OBSERVE_SIGNALS="${OTEL_SHELL_CONFIG_OBSERVE_SIGNALS:-TRUE}"
. ../shared/config_validation.sh
echo "::endgroup::"

if [ "${OTEL_LOGS_EXPORTER:-otlp}" = deferred ]; then
  export OTEL_LOGS_EXPORTER=otlp
  export OTEL_EXPORTER_OTLP_LOGS_ENDPOINT=http://localhost:4320/v1/logs
  deferred=true
fi
if [ "${OTEL_METRICS_EXPORTER:-otlp}" = deferred ]; then
  export OTEL_METRICS_EXPORTER=otlp
  export OTEL_EXPORTER_OTLP_METRICS_ENDPOINT=http://localhost:4320/v1/metrics
  deferred=true
fi
if [ "${OTEL_TRACES_EXPORTER:-otlp}" = deferred ]; then
  export OTEL_TRACES_EXPORTER=otlp
  export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=http://localhost:4320/v1/traces
  deferred=true
fi
if [ "$deferred" = true ]; then
  echo "::group::Setup Deferred Export"
  export INTERNAL_OTEL_DEFERRED_EXPORT_DIR="$(TMPDIR="$(pwd)" mktemp -d)"
  ( nohup node -e "
    let counter = 0;
    require('http').createServer(function (req, res) {
      let filename = '$INTERNAL_OTEL_DEFERRED_EXPORT_DIR' + '/' + counter++ + '.' + req.url.split('/').pop();
      require('fs').appendFileSync(filename, req.headers['content-type'] + '\n');
      req.on('data', (chunk) => { require('fs').appendFileSync(filename, chunk); });
      req.on('end', () => { res.writeHead(200); res.end(); });
    }).listen(4320);
  " 1> /dev/null 2> /dev/null & )
  echo "::endgroup::"
fi

echo "::group::Setup SDK Output Redirect"
tmp_dir="$(mktemp -d)"
chmod 777 "$tmp_dir"
echo otel_shell_sdk_output_redirect="${OTEL_SHELL_SDK_OUTPUT_REDIRECT:-/dev/null}" >> "$GITHUB_STATE"
export OTEL_SHELL_SDK_OUTPUT_REDIRECT="$(mktemp -u -p "$tmp_dir")"
mkfifo "$OTEL_SHELL_SDK_OUTPUT_REDIRECT"
chmod 777 "$OTEL_SHELL_SDK_OUTPUT_REDIRECT"
log_file="$(mktemp -u -p "$tmp_dir")"
echo "log_file=$log_file" >> "$GITHUB_STATE"
( while true; do cat "$OTEL_SHELL_SDK_OUTPUT_REDIRECT"; done >> "$log_file" 2> /dev/null & )
echo "::endgroup::"

echo "::group::Install Dependencies"
. ../shared/github.sh
. ../shared/id_printer.sh
export GITHUB_ACTION_REPOSITORY="${GITHUB_ACTION_REPOSITORY:-"$GITHUB_REPOSITORY"}"
npm --no-audit ci
action_tag_name="$(echo "$GITHUB_ACTION_REF" | cut -sd @ -f 2-)"
if [ -z "$action_tag_name" ]; then action_tag_name="v$(cat ../../../VERSION)"; fi
if [ "$INPUT_CACHE" = "true" ]; then
  export INSTRUMENTATION_CACHE_KEY="${GITHUB_ACTION_REPOSITORY} ${action_tag_name} instrumentation $GITHUB_WORKFLOW $GITHUB_JOB"
  sudo -E -H node -e "require('@actions/cache').restoreCache(['/tmp/*.aliases'], '$INSTRUMENTATION_CACHE_KEY');" 2>&1 | { type perl && perl -0777 -pe '' || cat > /dev/null; } &
  cache_key="${GITHUB_ACTION_REPOSITORY} ${action_tag_name} dependencies $({ cat /etc/os-release; python3 --version || true; node --version || true; printenv | grep -E '^OTEL_SHELL_CONFIG_INSTALL_' || true; } | md5sum | cut -d ' ' -f 1)"
  sudo -E -H node -e "require('@actions/cache').restoreCache(['/var/cache/apt/archives/*.deb', '/root/.cache/pip', '/opt/opentelemetry_shell/collector.image'], '$cache_key');"
  [ "$(find /var/cache/apt/archives/ -name '*.deb' | wc -l)" -gt 0 ] && [ -r /opt/opentelemetry_shell/collector.image ] || write_back_cache=TRUE
  if ! type otel.sh &&  [ -r /var/cache/apt/archives/opentelemetry-shell*.deb ]; then # fast track install, what could possibly go wrong
    control_dir="$(mktemp -d)"
    dpkg-deb --control /var/cache/apt/archives/opentelemetry-shell*.deb "$control_dir"
    if cat "$control_dir"/control | grep -E '^Pre-Depends:|^Depends:' | cut -d ':' -f 2 - | tr ',' '\n' | grep -v '|' | tr -d ' ' | cut -d '(' -f 1 | sed 's/awk/gawk/g' | xargs -I '{}' [ -r /var/lib/dpkg/info/'{}'.list ]; then
      sudo dpkg-deb --extract /var/cache/apt/archives/opentelemetry-shell*.deb /
      ( sudo "$control_dir"/postinst configure && rm -rf "$control_dir" ) 2>&1 | { type perl && perl -0777 -pe '' || cat > /dev/null; } &
      export OTEL_SHELL_PACKAGE_VERSION_CACHE_opentelemetry_shell="$(cat ../../../VERSION)"
    else
      rm -rf "$control_dir"
    fi
  fi
fi
bash -e -o pipefail ../shared/install.sh perl curl wget jq sed unzip parallel 'node;nodejs' npm 'docker;docker.io' 'gcc;build-essential' lsof
export OTEL_SHELL_COLLECTOR_IMAGE="$(cat Dockerfile | grep '^FROM ' | cut -d ' ' -f 2-)"
if [ -r /opt/opentelemetry_shell/collector.image ]; then
  sudo docker load < /opt/opentelemetry_shell/collector.image
else
  sudo docker pull "$OTEL_SHELL_COLLECTOR_IMAGE"
fi 2>&1 | perl -0777 -pe '' &
if [ "${write_back_cache:-FALSE}" = TRUE ] && [ -n "${cache_key:-}" ]; then
  wait # only join in case we wanna write back, this will be rare and is necessary to have a good cache
  ( ( sudo docker save "$OTEL_SHELL_COLLECTOR_IMAGE" | sudo tee /opt/opentelemetry_shell/collector.image > /dev/null && sudo -E -H node -e "require('@actions/cache').saveCache(['/var/cache/apt/archives/*.deb', '/root/.cache/pip', '/opt/opentelemetry_shell/collector.image'], '$cache_key');" ) &> /dev/null & )
fi
echo "::endgroup::"

echo "::group::Build Collector Configuration"
backup_otel_exporter_otlp_traces_endpoint="${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-}}"
section_exporter_logs="$(mktemp)"; section_exporter_metrics="$(mktemp)"; section_exporter_traces="$(mktemp)"
section_pipeline_logs="$(mktemp)"; section_pipeline_metrics="$(mktemp)"; section_pipeline_traces="$(mktemp)"
if [ "${OTEL_LOGS_EXPORTER:-otlp}" = otlp ]; then
  if [ "${OTEL_EXPORTER_OTLP_LOGS_PROTOCOL:-${OTEL_EXPORTER_OTLP_PROTOCOL:-http/protobuf}}" = http/protobuf ] || [ "${OTEL_EXPORTER_OTLP_LOGS_PROTOCOL:-${OTEL_EXPORTER_OTLP_PROTOCOL:-http/protobuf}}" = http/json ]; then collector_exporter=otlphttp; else collector_exporter=otlp; fi
  cat > "$section_exporter_logs" <<EOF
  $collector_exporter/logs:
    endpoint: ${OTEL_EXPORTER_OTLP_ENDPOINT:-${OTEL_EXPORTER_OTLP_LOGS_ENDPOINT%/v1/logs}}
    $([ -z "${OTEL_EXPORTER_OTLP_LOGS_ENDPOINT:-}" ] || echo "logs_endpoint: $OTEL_EXPORTER_OTLP_LOGS_ENDPOINT")
    headers:
$(echo "$OTEL_EXPORTER_OTLP_HEADERS","$OTEL_EXPORTER_OTLP_LOGS_HEADERS" | tr ',' '\n' | grep -v '^$' | sed 's/=/: /g' | sed 's/^/      /g')
$([ "${OTEL_EXPORTER_OTLP_LOGS_PROTOCOL:-${OTEL_EXPORTER_OTLP_PROTOCOL:-http/protobuf}}" = http/json ] && echo '    encoding: json' || true)
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
  if [ "${OTEL_EXPORTER_OTLP_METRICS_PROTOCOL:-${OTEL_EXPORTER_OTLP_PROTOCOL:-http/protobuf}}" = http/protobuf ] || [ "${OTEL_EXPORTER_OTLP_METRICS_PROTOCOL:-${OTEL_EXPORTER_OTLP_PROTOCOL:-http/protobuf}}" = http/json ]; then collector_exporter=otlphttp; else collector_exporter=otlp; fi
  cat > "$section_exporter_metrics" <<EOF
  $collector_exporter/metrics:
    endpoint: ${OTEL_EXPORTER_OTLP_ENDPOINT:-${OTEL_EXPORTER_OTLP_METRICS_ENDPOINT%/v1/metrics}}
    $([ -z "${OTEL_EXPORTER_OTLP_METRICS_ENDPOINT:-}" ] || echo "metrics_endpoint: $OTEL_EXPORTER_OTLP_METRICS_ENDPOINT")
    headers:
$(echo "$OTEL_EXPORTER_OTLP_HEADERS","$OTEL_EXPORTER_OTLP_METRICS_HEADERS" | tr ',' '\n' | grep -v '^$' | sed 's/=/: /g' | sed 's/^/      /g')
$([ "${OTEL_EXPORTER_OTLP_METRICS_PROTOCOL:-${OTEL_EXPORTER_OTLP_PROTOCOL:-http/protobuf}}" = http/json ] && echo '    encoding: json' || true)
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
  if [ "${OTEL_EXPORTER_OTLP_TRACES_PROTOCOL:-${OTEL_EXPORTER_OTLP_PROTOCOL:-http/protobuf}}" = http/protobuf ] || [ "${OTEL_EXPORTER_OTLP_TRACES_PROTOCOL:-${OTEL_EXPORTER_OTLP_PROTOCOL:-http/protobuf}}" = http/json ]; then collector_exporter=otlphttp; else collector_exporter=otlp; fi
  cat > "$section_exporter_traces" <<EOF
  $collector_exporter/traces:
    endpoint: ${OTEL_EXPORTER_OTLP_ENDPOINT:-${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT%/v1/traces}}
    $([ -z "${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-}" ] || echo "traces_endpoint: $OTEL_EXPORTER_OTLP_TRACES_ENDPOINT")
    headers:
$(echo "$OTEL_EXPORTER_OTLP_HEADERS","$OTEL_EXPORTER_OTLP_TRACES_HEADERS" | tr ',' '\n' | grep -v '^$' | sed 's/=/: /g' | sed 's/^/      /g')
$([ "${OTEL_EXPORTER_OTLP_TRACES_PROTOCOL:-${OTEL_EXPORTER_OTLP_PROTOCOL:-http/protobuf}}" = http/json ] && echo '    encoding: json' || true)
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
if [ -n "$INPUT_DEBUG" ]; then set +x; fi
echo "$INPUT_SECRETS_TO_REDACT" | jq -r '. | to_entries[].value' | sed 's/[.[\(*^$+?{|]/\\\\&/g' | xargs -I '{}' echo '::add-mask::{}'
if [ -n "$INPUT_DEBUG" ]; then set -x; fi
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
    timeout: $([ "${deferred:-false}" = true ] && echo $((60 * 60 * 1)) || echo 10)s
  transform:
    error_mode: ignore
    log_statements:
$(echo "$INPUT_SECRETS_TO_REDACT" | jq -r '. | to_entries[].value' | grep -v '^$' | sed 's/[.[\(*^$+?{|]/\\\\&/g' | xargs -d '\n' -I '{}' printf '%s\n' 'replace_all_patterns(log.attributes, "value", "{}", "***")' | sed 's/^/      - /g')
$(echo "$INPUT_SECRETS_TO_REDACT" | jq -r '. | to_entries[].value' | grep -v '^$' | sed 's/[.[\(*^$+?{|]/\\\\&/g' | xargs -d '\n' -I '{}' printf '%s\n' 'replace_pattern(log.body, "{}", "***")' | sed 's/^/      - /g')
    metric_statements:
$(echo "$INPUT_SECRETS_TO_REDACT" | jq -r '. | to_entries[].value' | grep -v '^$' | sed 's/[.[\(*^$+?{|]/\\\\&/g' | xargs -d '\n' -I '{}' printf '%s\n' 'replace_all_patterns(datapoint.attributes, "value", "{}", "***")' | sed 's/^/      - /g')
    trace_statements:
$(echo "$INPUT_SECRETS_TO_REDACT" | jq -r '. | to_entries[].value' | grep -v '^$' | sed 's/[.[\(*^$+?{|]/\\\\&/g' | xargs -d '\n' -I '{}' printf '%s\n' 'replace_all_patterns(span.attributes, "value", "{}", "***")' | sed 's/^/      - /g')
$(echo "$INPUT_SECRETS_TO_REDACT" | jq -r '. | to_entries[].value' | grep -v '^$' | sed 's/[.[\(*^$+?{|]/\\\\&/g' | xargs -d '\n' -I '{}' printf '%s\n' 'replace_pattern(span.name, "{}", "***")' | sed 's/^/      - /g')
service:
  pipelines:
$(cat $section_pipeline_logs)
$(cat $section_pipeline_metrics)
$(cat $section_pipeline_traces)
EOF
if [ -n "$INPUT_DEBUG" ]; then cat collector.yaml; fi
echo "::endgroup::"

echo "::group::Instrument shell/javascript/docker actions"
echo "$GITHUB_ACTION" > /tmp/opentelemetry_shell_action_name # to avoid recursions
export GITHUB_ACTION_PATH="$(pwd)"
new_binary_dir="$GITHUB_ACTION_PATH/bin"
relocated_binary_dir="$GITHUB_ACTION_PATH/relocated_bin"
mkdir -p "$new_binary_dir" "$relocated_binary_dir"
echo "$new_binary_dir" >> "$GITHUB_PATH"
( if type sh;   then gcc -o "$new_binary_dir"/sh forward.c -DEXECUTABLE="$(which sh)" -DARG1="$GITHUB_ACTION_PATH"/decorate_action_run.sh -DARG2="$(which sh)"; fi 2>&1 | perl -0777 -pe '' ) &
( if type ash;  then gcc -o "$new_binary_dir"/dash forward.c -DEXECUTABLE="$(which ash)" -DARG1="$GITHUB_ACTION_PATH"/decorate_action_run.sh -DARG2="$(which ash)"; fi 2>&1 | perl -0777 -pe '' ) &
( if type dash; then gcc -o "$new_binary_dir"/dash forward.c -DEXECUTABLE="$(which dash)" -DARG1="$GITHUB_ACTION_PATH"/decorate_action_run.sh -DARG2="$(which dash)"; fi 2>&1 | perl -0777 -pe '' ) &
( if type bash; then gcc -o "$new_binary_dir"/bash forward.c -DEXECUTABLE="$(which bash)" -DARG1="$GITHUB_ACTION_PATH"/decorate_action_run.sh -DARG2="$(which bash)"; fi 2>&1 | perl -0777 -pe '' ) &
for node_path in "$(readlink -f /proc/*/exe | grep '/Runner.Worker$' | rev | cut -d / -f 4- | rev)"/*/externals/node*/bin/node; do
  dir_path_new="$relocated_binary_dir"/"$(echo "$node_path" | rev | cut -d / -f 3 | rev)"
  mkdir "$dir_path_new"
  node_path_new="$dir_path_new"/node
  mv "$node_path" "$node_path_new"
  gcc -o "$node_path" forward.c -DEXECUTABLE=/bin/bash -DARG1="$GITHUB_ACTION_PATH"/decorate_action_node.sh -DARG2="$node_path_new" 2>&1 | perl -0777 -pe '' & # path is hardcoded in the runners
done
( if type docker; then docker_path="$(which docker)" && sudo mv "$docker_path" "$relocated_binary_dir" && sudo gcc -o "$docker_path" forward.c -DEXECUTABLE=/bin/bash -DARG1="$GITHUB_ACTION_PATH"/decorate_action_docker.sh -DARG2="$relocated_binary_dir"/docker; fi 2>&1 | perl -0777 -pe '' ) &
echo "::endgroup::"

echo "::group::Resolve W3C Tracecontext"
opentelemetry_root_dir="$(mktemp -d)"
count=0
while [ "$count" -lt 60 ] && ! gh_artifact_download "$GITHUB_RUN_ID" "$GITHUB_RUN_ATTEMPT" opentelemetry_workflow_run_"$GITHUB_RUN_ATTEMPT" "$opentelemetry_root_dir" || ! [ -r "$opentelemetry_root_dir"/traceparent ]; do
  if [ "$count" -gt 0 ]; then sleep $count; fi
  wait # only join within this loop, because we need to make sure everything is installed properly at this point, in most cases, it is unnecessary though and we can join later
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
echo "::endgroup::"

echo "::group::Resolve Job ID and Job name"
OTEL_SHELL_GITHUB_JOB="$GITHUB_JOB"
job_arguments="$(printf '%s' "$INPUT___JOB_MATRIX" | jq -r '. | [.. | scalars] | @tsv' | sed 's/\t/, /g')"
if [ -n "$job_arguments" ]; then OTEL_SHELL_GITHUB_JOB="$OTEL_SHELL_GITHUB_JOB ($job_arguments)"; fi
export OTEL_SHELL_GITHUB_JOB
if [ -n "$INPUT___JOB_ID" ]; then
  export GITHUB_JOB_ID="$INPUT___JOB_ID"
  echo "Resolved GitHub job id to $GITHUB_JOB_ID"
else
  GITHUB_JOB_ID="$(gh_jobs "$GITHUB_RUN_ID" "$GITHUB_RUN_ATTEMPT" | jq --unbuffered -r '. | .jobs[] | [.id, .name] | @tsv' | sed 's/\t/ /g' | grep " $OTEL_SHELL_GITHUB_JOB"'$' | cut -d ' ' -f 1)"
  if [ "$(printf '%s' "$GITHUB_JOB_ID" | wc -l)" -le 1 ]; then echo "Guessing GitHub job id to be $GITHUB_JOB_ID" >&2; export GITHUB_JOB_ID; else echo ::warning ::Could not guess GitHub job id.; fi
fi
echo "::endgroup::"

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
    for i in 1 2 3 4 5; do
      if ! [ -r /tmp/opentelemetry_shell.github.observe_rate_limits ]; then break; fi
      sleep 1
    done
  done
}
export -f observe_rate_limit

root4job_end() {
  exec 1> /tmp/opentelemetry_shell.github.debug.log
  exec 2> /tmp/opentelemetry_shell.github.debug.log
  rm /tmp/opentelemetry_shell.github.observe_rate_limits
  [ -z "${INSTRUMENTATION_CACHE_KEY:-}" ] || sudo -E -H node -e "require('@actions/cache').saveCache(['/tmp/*.aliases'], '$INSTRUMENTATION_CACHE_KEY');" &> /dev/null &

  if [ -f /tmp/opentelemetry_shell.github.error ]; then local conclusion=failure; else local conclusion=success; fi
  otel_span_attribute_typed $span_handle string github.actions.conclusion="$conclusion"
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

  if [ -p /tmp/otel_shell/sdk_factory."$USER".pipe ]; then echo "EOF" > /tmp/otel_shell/sdk_factory."$USER".pipe; rm -rf /tmp/otel_shell; fi
  timeout 5s sh -c 'while fuser /opt/opentelemetry_shell/venv/bin/python; do sleep 1; done; true' &> /dev/null || echo "Found leaked SDK processes (this may be due to leaked processes that are still being observed)."
  
  if [ -n "${OTEL_SHELL_COLLECTOR_CONTAINER:-}" ]; then
    sudo docker stop "$OTEL_SHELL_COLLECTOR_CONTAINER"
    local collector_pipe_warning="$(mktemp -u)"
    local collector_pipe_error="$(mktemp -u)"
    mkfifo "$collector_pipe_warning" "$collector_pipe_error"
    cat "$collector_pipe_warning" | grep '^warn ' | cut -d ' ' -f 2- | sort -u | while read -r line; do echo ::warning::"$line"; done &
    cat "$collector_pipe_error" | grep '^err ' | cut -d ' ' -f 2- | sort -u | while read -r line; do echo ::error::"$line"; done &
    sudo docker logs "$OTEL_SHELL_COLLECTOR_CONTAINER" 2>&1 | tr '\t' ' ' | cut -d ' ' -f 2- | tee "$collector_pipe_warning" | tee "$collector_pipe_error" | { if [ -n "$INPUT_DEBUG" ]; then cat; else cat > /dev/null; fi; }
  fi
  
  if [ -n "${INTERNAL_OTEL_DEFERRED_EXPORT_DIR:-}" ]; then
    export -f gh_artifact_upload
    ( cd "$INTERNAL_OTEL_DEFERRED_EXPORT_DIR" && ls | grep -E '.logs$|.metrics$|.traces$' | xargs -r -I '{}' bash -c 'gh_artifact_upload "$@" "{}"' bash "$GITHUB_RUN_ID" "$GITHUB_RUN_ATTEMPT" opentelemetry_job_"$GITHUB_JOB_ID"_signals_0 ) &
  fi
  
  wait
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
  time_start="$(date +%s.%N)"
  span_handle="$(otel_span_start CONSUMER "${OTEL_SHELL_GITHUB_JOB:-$GITHUB_JOB}")"
  otel_span_attribute_typed $span_handle string github.actions.type=job
  if [ -n "$GITHUB_JOB_ID" ]; then
    otel_span_attribute_typed $span_handle string github.actions.url="${GITHUB_SERVER_URL:-https://github.com}"/"$GITHUB_REPOSITORY"/actions/runs/"$GITHUB_RUN_ID"/job/"$GITHUB_JOB_ID"
  fi
  otel_span_attribute_typed $span_handle int github.actions.job.id="${GITHUB_JOB_ID:-}"
  otel_span_attribute_typed $span_handle string github.actions.job.name="${OTEL_SHELL_GITHUB_JOB:-$GITHUB_JOB}"
  printf '%s' "$INPUT___JOB_MATRIX" | jq 'to_entries | .[] | [ .key, .value ] | @tsv' -r | sed 's/\t/ /g' | while read -r key value; do otel_span_attribute_typed $span_handle string github.actions.job.matrix."$key"="$value"; done
  otel_span_attribute_typed $span_handle string github.actions.runner.name="$RUNNER_NAME"
  otel_span_attribute_typed $span_handle string github.actions.runner.os="$RUNNER_OS"
  otel_span_attribute_typed $span_handle string github.actions.runner.arch="$RUNNER_ARCH"
  otel_span_attribute_typed $span_handle string github.actions.runner.environment="$RUNNER_ENVIRONMENT"
  otel_span_activate "$span_handle"
  echo "$TRACEPARENT" > "$traceparent_file"
  if [ -n "${GITHUB_JOB_ID:-}" ]; then
    opentelemetry_job_dir="$(mktemp -d)"
    echo "$TRACEPARENT" > "$opentelemetry_job_dir"/traceparent
    ( gh_artifact_upload "$GITHUB_RUN_ID" "$GITHUB_RUN_ATTEMPT" opentelemetry_job_"$GITHUB_JOB_ID" "$opentelemetry_job_dir"/traceparent && rm -rf "$opentelemetry_job_dir" ) &> /dev/null &
  fi
  otel_span_deactivate "$span_handle"
  trap root4job_end SIGUSR1
  exec 2>&-
  exec 1>&-
  while true; do sleep 1; done
}
export -f root4job

echo "::group::Setting Up SDK Factory"
mv sdk_factory.py sdk_factory.py.backup
cat /usr/share/opentelemetry_shell/sdk.py | grep -E 'from|import' | while read -r line; do echo "$line"; done | sort -u > sdk_factory.py
cat sdk_factory.py.backup >> sdk_factory.py
rm sdk_factory.py.backup
echo "::endgroup::"

echo "::group::Start Observation"
traceparent_file="$(mktemp -u)"
mkdir -p /tmp/otel_shell
mkfifo /tmp/opentelemetry_shell.github.debug.log /tmp/otel_shell/sdk_factory."$USER".pipe # subdirectory to avoid sticky bit
wait # make sure we wait for all background jobs before we actually start
sudo find /tmp | grep -qE '.aliases$' && unset INSTRUMENTATION_CACHE_KEY || true
nohup /opt/opentelemetry_shell/venv/bin/python sdk_factory.py /tmp/otel_shell/sdk_factory."$USER".pipe &> /dev/null &
nohup bash -c 'root4job "$@"' bash "$traceparent_file" &> /dev/null &
echo "pid=$!" >> "$GITHUB_STATE"
cat /tmp/opentelemetry_shell.github.debug.log
echo "::endgroup::"

echo "::group::Propagate W3C Tracecontext to Steps"
export TRACEPARENT="$(cat "$traceparent_file")"
rm "$traceparent_file"
printenv | grep -E '^OTEL_|^TRACEPARENT=|^TRACESTATE=' >> "$GITHUB_ENV"
echo "::endgroup::"

echo ::notice title=Observability Information for ${OTEL_SHELL_GITHUB_JOB:-$GITHUB_JOB}::"Trace ID: $(echo "$TRACEPARENT" | cut -d - -f 2), Span ID: $(echo "$TRACEPARENT" | cut -d - -f 3), Trace Deep Link: $(OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="$backup_otel_exporter_otlp_traces_endpoint" print_trace_link "$(date +%Y-%M-%dT%H:%M:%S.%N%:z | jq -sRr @uri)" || echo unavailable)"
