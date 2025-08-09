#/bin/bash
set -e
. ../shared/config_validation.sh
. ../shared/github.sh
bash -e ../shared/install.sh

# selfmonitoring
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
    counter_handle="$(otel_counter_create counter selfmonitoring.opentelemetry.github.workflow.invocations 1 'Invocations of workflow-level instrumentation')"
    observation_handle="$(otel_observation_create 1)"
    otel_counter_observe "$counter_handle" "$observation_handle"
    otel_shutdown
  ) &
fi

export OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-"$(echo "$GITHUB_REPOSITORY" | cut -d / -f 2-) CI"}"

workflow_json="$(mktemp)"
jq < "$GITHUB_EVENT_PATH" > "$workflow_json" .workflow_run
if [ "$INPUT_WORKFLOW_RUN_ID" != "$(jq < "$workflow_json" .id)" ] || [ "$INPUT_WORKFLOW_RUN_ATTEMPT" != "$(jq < "$workflow_json" .run_attempt)" ]; then gh_workflow_run "$INPUT_WORKFLOW_RUN_ID" "$INPUT_WORKFLOW_RUN_ATTEMPT" > "$workflow_json"; fi
if [ "$(jq < "$workflow_json" -r .status)" != completed ]; then echo "::error ::Workflow not completed yet."; exit 1; fi

jobs_json="$(mktemp)"
gh_jobs "$INPUT_WORKFLOW_RUN_ID" "$INPUT_WORKFLOW_RUN_ATTEMPT" | jq .jobs[] > "$jobs_json"

artifacts_json="$(mktemp)"
gh_artifacts "$INPUT_WORKFLOW_RUN_ID" | jq -r .artifacts[] > "$artifacts_json"

logs_zip="$(mktemp)"
count=1
while [ "$count" -lt 60 ] && !(gh_workflow_run_logs "$INPUT_WORKFLOW_RUN_ID" "$INPUT_WORKFLOW_RUN_ATTEMPT" "$logs_zip" && unzip -t "$logs_zip" 1> /dev/null 2> /dev/null); do # sometimes downloads fail
  sleep "$count"
  count=$((count * 2))
done
if [ -r "$logs_zip" ] && unzip -t "$logs_zip"; then
  read_log_file() {
    unzip -Z1 "$logs_zip" | grep '.txt$' | grep -E "$(printf '%s' "$1" | sed 's/[.[\(*^$+?{|]/\\\\&/g')" | xargs -d '\n' -r unzip -p "$logs_zip" | sed '1s/^\xEF\xBB\xBF//' | sed '1s/^\xFE\xFF//' | sed '1s/^\x00\x00\xFE\xFF//'
  }
else
  read_log_file() { false; }
  rm -rf "$logs_zip"
fi 

times_dir="$(mktemp -d)"

echo "::notice ::Observing $(jq < "$workflow_json" -r .html_url)"

. otelapi.sh
export OTEL_DISABLE_RESOURCE_DETECTION=TRUE
_otel_resource_attributes_process() {
  _otel_resource_attribute string github.repository.id="$(jq < "$workflow_json" -r .repository.id)"
  _otel_resource_attribute string github.repository.name="$(jq < "$workflow_json" -r .repository.name)"
  _otel_resource_attribute string github.repository.owner.id="$(jq < "$workflow_json" -r .repository.owner.id)"
  _otel_resource_attribute string github.repository.owner.name="$(jq < "$workflow_json" -r .repository.owner.login)"
  _otel_resource_attribute string github.actions.workflow.id="$(jq < "$workflow_json" -r .workflow_id)"
  _otel_resource_attribute string github.actions.workflow.name="$(jq < "$workflow_json" -r .name)"
  _otel_resource_attribute string github.actions.workflow.ref="$(jq < "$workflow_json" -r .repository.owner.login)"/"$(jq < "$workflow_json" -r .repository.name)"/"$(jq < "$workflow_json" -r .path)"@/refs/heads/"$(jq < "$workflow_json" -r .head_branch)"
  _otel_resource_attribute string github.actions.workflow.sha="$(jq < "$workflow_json" -r .head_sha)"
}
_otel_resource_attributes_custom() {
  _otel_resource_attribute string telemetry.sdk.language=github
}
workflow_run_dir="$(mktemp -d)"
gh_artifact_download "$INPUT_WORKFLOW_RUN_ID" "$INPUT_WORKFLOW_RUN_ATTEMPT" opentelemetry_workflow_run_"$INPUT_WORKFLOW_RUN_ATTEMPT" "$workflow_run_dir" || true
if [ -r "$workflow_run_dir"/traceparent ]; then export OTEL_ID_GENERATOR_OVERRIDE_TRACEPARENT="$(cat "$workflow_run_dir"/traceparent)"; fi

otel_init
workflow_run_counter_handle="$(otel_counter_create counter github.actions.workflows 1 'Number of workflow runs')"
job_run_counter_handle="$(otel_counter_create counter github.actions.jobs 1 'Number of job runs')"
step_run_counter_handle="$(otel_counter_create counter github.actions.steps 1 'Number of step runs')"
action_run_counter_handle="$(otel_counter_create counter github.actions.actions 1 'Number of action runs')"
workflow_duration_counter_handle="$(otel_counter_create counter github.actions.workflows.duration s 'Duration of workflow runs')"
job_duration_counter_handle="$(otel_counter_create counter github.actions.jobs.duration s 'Duration of job runs')"
step_duration_counter_handle="$(otel_counter_create counter github.actions.steps.duration s 'Duration of step runs')"
action_duration_counter_handle="$(otel_counter_create counter github.actions.actions.duration s 'Duration of action runs')"

link="${GITHUB_SERVER_URL:-https://github.com}"/"$(jq < "$workflow_json" -r .repository.owner.login)"/"$(jq < "$workflow_json" -r .repository.name)"/actions/runs/"$(jq < "$workflow_json" -r .id)"
workflow_started_at="$(jq < "$workflow_json" -r .run_started_at)"
workflow_ended_at="$(jq < "$jobs_json" -r .completed_at | sort -r | head -n 1)"
last_log_timestamp="$(read_log_file '.txt' | cut -d ' ' -f 1 | sort | tail -n 1)"
if [ "$last_log_timestamp" > "$workflow_ended_at" ]; then workflow_ended_at="$last_log_timestamp"; fi

observation_handle="$(otel_observation_create 1)"
otel_observation_attribute_typed "$observation_handle" string github.actions.workflow.id="$(jq < "$workflow_json" -r .workflow_id)"
otel_observation_attribute_typed "$observation_handle" string github.actions.workflow.name="$(jq < "$workflow_json" -r .name)"
otel_observation_attribute_typed "$observation_handle" int github.actions.workflow_run.attempt="$(jq < "$workflow_json" .run_attempt)"
otel_observation_attribute_typed "$observation_handle" string github.actions.workflow_run.conclusion="$(jq < "$workflow_json" -r .conclusion)"
otel_observation_attribute_typed "$observation_handle" int github.actions.actor.id="$(jq < "$workflow_json" .actor.id)"
otel_observation_attribute_typed "$observation_handle" string github.actions.actor.name="$(jq < "$workflow_json" -r .actor.login)"
otel_observation_attribute_typed "$observation_handle" string github.actions.event.name="$(jq < "$workflow_json" -r .event)"
otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref="/refs/heads/$(jq < "$workflow_json" -r .head_branch)"
otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref.name="$(jq < "$workflow_json" -r .head_branch)"
otel_counter_observe "$workflow_run_counter_handle" "$observation_handle"

observation_handle="$(otel_observation_create "$(python3 -c "print(str(max(0, $(date -d "$workflow_ended_at" '+%s.%N') - $(date -d "$workflow_started_at" '+%s.%N'))))")")"
otel_observation_attribute_typed "$observation_handle" string github.actions.workflow.id="$(jq < "$workflow_json" -r .workflow_id)"
otel_observation_attribute_typed "$observation_handle" string github.actions.workflow.name="$(jq < "$workflow_json" -r .name)"
otel_observation_attribute_typed "$observation_handle" int github.actions.workflow_run.attempt="$(jq < "$workflow_json" .run_attempt)"
otel_observation_attribute_typed "$observation_handle" string github.actions.workflow_run.conclusion="$(jq < "$workflow_json" -r .conclusion)"
otel_observation_attribute_typed "$observation_handle" int github.actions.actor.id="$(jq < "$workflow_json" .actor.id)"
otel_observation_attribute_typed "$observation_handle" string github.actions.actor.name="$(jq < "$workflow_json" -r .actor.login)"
otel_observation_attribute_typed "$observation_handle" string github.actions.event.name="$(jq < "$workflow_json" -r .event)"
otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref="/refs/heads/$(jq < "$workflow_json" -r .head_branch)"
otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref.name="$(jq < "$workflow_json" -r .head_branch)"
otel_counter_observe "$workflow_duration_counter_handle" "$observation_handle"

workflow_span_handle="$(otel_span_start @"$workflow_started_at" CONSUMER "$(jq < "$workflow_json" -r .name)")"
otel_span_attribute_typed "$workflow_span_handle" string github.actions.type=workflow
otel_span_attribute_typed "$workflow_span_handle" string github.actions.url="$link"/attempts/"$(jq < "$workflow_json" -r .run_attempt)"
otel_span_attribute_typed "$workflow_span_handle" string github.actions.workflow.id="$(jq < "$workflow_json" -r .workflow_id)"
otel_span_attribute_typed "$workflow_span_handle" string github.actions.workflow.name="$(jq < "$workflow_json" -r .name)"
otel_span_attribute_typed "$workflow_span_handle" int github.actions.workflow_run.id="$(jq < "$workflow_json" .id)"
otel_span_attribute_typed "$workflow_span_handle" int github.actions.workflow_run.attempt="$(jq < "$workflow_json" .run_attempt)"
otel_span_attribute_typed "$workflow_span_handle" int github.actions.workflow_run.number="$(jq < "$workflow_json" .run_number)"
otel_span_attribute_typed "$workflow_span_handle" string github.actions.workflow_run.conclusion="$(jq < "$workflow_json" -r .conclusion)"
otel_span_attribute_typed "$workflow_span_handle" int github.actions.actor.id="$(jq < "$workflow_json" .actor.id)"
otel_span_attribute_typed "$workflow_span_handle" string github.actions.actor.name="$(jq < "$workflow_json" -r .actor.login)"
otel_span_attribute_typed "$workflow_span_handle" string github.actions.event.name="$(jq < "$workflow_json" -r .event)"
otel_span_attribute_typed "$workflow_span_handle" string github.actions.event.ref="/refs/heads/$(jq < "$workflow_json" -r .head_branch)"
otel_span_attribute_typed "$workflow_span_handle" string github.actions.event.ref.sha="$(jq < "$workflow_json" -r .head_sha)"
otel_span_attribute_typed "$workflow_span_handle" string github.actions.event.ref.name="$(jq < "$workflow_json" -r .head_branch)"
if [ "$INPUT_WORKFLOW_RUN_ATTEMPT" -gt 1 ] && gh_artifact_download "$INPUT_WORKFLOW_RUN_ID" "$((INPUT_WORKFLOW_RUN_ATTEMPT - 1))" opentelemetry_workflow_run_"$((INPUT_WORKFLOW_RUN_ATTEMPT - 1))" opentelemetry_workflow_run_prev; then
  otel_link_add "$(otel_link_create "$(cat opentelemetry_workflow_run_prev/traceparent)" "")" "$workflow_span_handle"
fi
otel_span_activate "$workflow_span_handle"
[ -z "${INPUT_DEBUG}" ] || echo "span workflow $TRACEPARENT $(jq < "$workflow_json" -r .name)" >&2
if [ "$(jq < "$workflow_json" .conclusion -r)" = failure ]; then otel_span_error "$workflow_span_handle"; fi
echo ::notice::"Trace ID: $(echo "$TRACEPARENT" | cut -d - -f 2), Span ID: $(echo "$TRACEPARENT" | cut -d - -f 3)"
otel_span_end "$workflow_span_handle" @"$workflow_ended_at"

jq < "$jobs_json" -r --unbuffered '. | ["'"$TRACEPARENT"'", .id, .conclusion, .started_at, .completed_at, .name] | @tsv' | sed 's/\t/ /g' | while read -r TRACEPARENT job_id job_conclusion job_started_at job_completed_at job_name; do
  if [ "$job_conclusion" = skipped ]; then continue; fi
  if [[ "$job_started_at" < "$workflow_started_at" ]] || jq < "$artifacts_json" -r .name | grep -q '^opentelemetry_job_'"$job_id"'$'; then continue; fi
  job_log_file="$(printf '%s' "${job_name//\//}" | tr -d ':')"
  last_log_timestamp="$(read_log_file "$job_log_file" | tail -n 1 | cut -d ' ' -f 1)"
  if [ -n "$last_log_timestamp" ] && [ "$last_log_timestamp" > "$job_completed_at" ]; then job_completed_at="$last_log_timestamp"; fi
  
  observation_handle="$(otel_observation_create 1)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.workflow.name="$(jq < "$workflow_json" -r .name)"
  otel_observation_attribute_typed "$observation_handle" int github.actions.workflow_run.attempt="$(jq < "$workflow_json" .run_attempt)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.workflow_run.conclusion="$(jq < "$workflow_json" -r .conclusion)"
  otel_observation_attribute_typed "$observation_handle" int github.actions.actor.id="$(jq < "$workflow_json" .actor.id)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.actor.name="$(jq < "$workflow_json" -r .actor.login)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.name="$(jq < "$workflow_json" -r .event)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref="/refs/heads/$(jq < "$workflow_json" -r .head_branch)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref.name="$(jq < "$workflow_json" -r .head_branch)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.job.name="$job_name"
  otel_observation_attribute_typed "$observation_handle" string github.actions.job.conclusion="$job_conclusion"
  otel_counter_observe "$job_run_counter_handle" "$observation_handle"
  
  observation_handle="$(otel_observation_create "$(python3 -c "print(str(max(0, $(date -d "$job_completed_at" '+%s.%N') - $(date -d "$job_started_at" '+%s.%N'))))")")"
  otel_observation_attribute_typed "$observation_handle" string github.actions.workflow.name="$(jq < "$workflow_json" -r .name)"
  otel_observation_attribute_typed "$observation_handle" int github.actions.workflow_run.attempt="$(jq < "$workflow_json" .run_attempt)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.workflow_run.conclusion="$(jq < "$workflow_json" -r .conclusion)"
  otel_observation_attribute_typed "$observation_handle" int github.actions.actor.id="$(jq < "$workflow_json" .actor.id)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.actor.name="$(jq < "$workflow_json" -r .actor.login)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.name="$(jq < "$workflow_json" -r .event)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref="/refs/heads/$(jq < "$workflow_json" -r .head_branch)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref.name="$(jq < "$workflow_json" -r .head_branch)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.job.name="$job_name"
  otel_observation_attribute_typed "$observation_handle" string github.actions.job.conclusion="$job_conclusion"
  otel_counter_observe "$job_duration_counter_handle" "$observation_handle"
  
  job_span_handle="$(otel_span_start @"$job_started_at" CONSUMER "$job_name")"
  otel_span_attribute_typed "$job_span_handle" string github.actions.type=job
  otel_span_attribute_typed "$job_span_handle" string github.actions.url="$link"/job/"$job_id"
  otel_span_attribute_typed "$job_span_handle" int github.actions.job.id="$job_id"
  otel_span_attribute_typed "$job_span_handle" string github.actions.job.name="$job_name"
  otel_span_attribute_typed "$job_span_handle" string github.actions.job.conclusion="$job_conclusion"
  otel_span_activate "$job_span_handle"
  [ -z "${INPUT_DEBUG}" ] || echo "span job $TRACEPARENT $job_name" >&2
  jq < "$jobs_json" -r --unbuffered '. | select(.id == '"$job_id"') | .steps[] | ["'"$TRACEPARENT"'", "'"$job_id"'", .number, .conclusion, .started_at, .completed_at, .name] | @tsv'
  otel_span_deactivate "$job_span_handle"
  if [ "$job_conclusion" = failure ]; then otel_span_error "$job_span_handle"; fi
  otel_span_end "$job_span_handle" @"$job_completed_at"

done | sed 's/\t/ /g' | while read -r TRACEPARENT job_id step_number step_conclusion step_started_at step_completed_at step_name; do
  if [ "$step_conclusion" = skipped ]; then continue; fi
  job_name="$(jq < "$jobs_json" -r '. | select(.id == '"$job_id"') | .name')"
  if [ -r "$times_dir"/"$TRACEPARENT" ]; then
    previous_step_completed_at="$(cat "$times_dir"/"$TRACEPARENT")"
    if [ "$previous_step_completed_at" > "$step_started_at" ]; then step_started_at="$previous_step_completed_at"; fi
    if [ "$step_started_at" > "$step_completed_at" ]; then step_completed_at="$step_started_at"; fi
  fi
  step_log_file="$(printf '%s' "${job_name//\//}"/"$step_number"_ | tr -d ':')"
  last_log_timestamp="$(read_log_file "$step_log_file" | tail -n 1 | cut -d ' ' -f 1)"
  if [ -n "$last_log_timestamp" ] && [ "$last_log_timestamp" > "$step_completed_at" ]; then step_completed_at="$last_log_timestamp"; fi

  action_name="$step_name"
  case "$action_name" in
    'Pre '*) action_phase=pre;;
    'Build '*) action_phase=pre;;
    'Run '*) action_phase=main;;
    'Post '*) action_phase=post;;
    'Set up job') action_phase=pre;;
    'Complete job') action_phase=post;;
    *) ;;
  esac
  if [ -n "${action_phase:-}" ]; then action_name="${action_name#* }"; fi
  if echo "$action_name" | grep -qE '^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+(@[a-zA-Z0-9_.-]+)?$'; then
    if _otel_string_contains "$action_name" @; then
      action_name="${action_name%%@*}"
      action_tag="${action_name##*@}"
    else
      action_tag=main
    fi
  else
    unset action_name action_tag
  fi
  
  observation_handle="$(otel_observation_create 1)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.workflow.name="$(jq < "$workflow_json" -r .name)"
  otel_observation_attribute_typed "$observation_handle" int github.actions.workflow_run.attempt="$(jq < "$workflow_json" .run_attempt)"
  otel_observation_attribute_typed "$observation_handle" int github.actions.actor.id="$(jq < "$workflow_json" .actor.id)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.actor.name="$(jq < "$workflow_json" -r .actor.login)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.name="$(jq < "$workflow_json" -r .event)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref="/refs/heads/$(jq < "$workflow_json" -r .head_branch)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref.name="$(jq < "$workflow_json" -r .head_branch)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.job.name="$job_name"
  otel_observation_attribute_typed "$observation_handle" string github.actions.step.name="$step_name"
  otel_observation_attribute_typed "$observation_handle" string github.actions.step.conclusion="$step_conclusion"
  otel_counter_observe "$step_run_counter_handle" "$observation_handle"
  
  observation_handle="$(otel_observation_create "$(python3 -c "print(str(max(0, $(date -d "$step_completed_at" '+%s.%N') - $(date -d "$step_started_at" '+%s.%N'))))")")"
  otel_observation_attribute_typed "$observation_handle" string github.actions.workflow.name="$(jq < "$workflow_json" -r .name)"
  otel_observation_attribute_typed "$observation_handle" int github.actions.workflow_run.attempt="$(jq < "$workflow_json" .run_attempt)"
  otel_observation_attribute_typed "$observation_handle" int github.actions.actor.id="$(jq < "$workflow_json" .actor.id)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.actor.name="$(jq < "$workflow_json" -r .actor.login)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.name="$(jq < "$workflow_json" -r .event)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref="/refs/heads/$(jq < "$workflow_json" -r .head_branch)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref.name="$(jq < "$workflow_json" -r .head_branch)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.job.name="$job_name"
  otel_observation_attribute_typed "$observation_handle" string github.actions.step.name="$step_name"
  otel_observation_attribute_typed "$observation_handle" string github.actions.step.conclusion="$step_conclusion"
  otel_counter_observe "$step_duration_counter_handle" "$observation_handle"

  if [ -n "${action_name:-}" ]; then
    observation_handle="$(otel_observation_create 1)"
    otel_observation_attribute_typed "$observation_handle" string github.actions.workflow.name="$(jq < "$workflow_json" -r .name)"
    otel_observation_attribute_typed "$observation_handle" int github.actions.workflow_run.attempt="$(jq < "$workflow_json" .run_attempt)"
    otel_observation_attribute_typed "$observation_handle" int github.actions.actor.id="$(jq < "$workflow_json" .actor.id)"
    otel_observation_attribute_typed "$observation_handle" string github.actions.actor.name="$(jq < "$workflow_json" -r .actor.login)"
    otel_observation_attribute_typed "$observation_handle" string github.actions.event.name="$(jq < "$workflow_json" -r .event)"
    otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref="/refs/heads/$(jq < "$workflow_json" -r .head_branch)"
    otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref.name="$(jq < "$workflow_json" -r .head_branch)"
    otel_observation_attribute_typed "$observation_handle" string github.actions.job.name="$job_name"
    otel_observation_attribute_typed "$observation_handle" string github.actions.step.name="$step_name"
    otel_observation_attribute_typed "$observation_handle" string github.actions.action.name="$action_name"
    otel_observation_attribute_typed "$observation_handle" string github.actions.action.ref="$action_tag"
    otel_observation_attribute_typed "$observation_handle" string github.actions.action.conclusion="$step_conclusion"
    otel_counter_observe "$action_run_counter_handle" "$observation_handle"
    
    observation_handle="$(otel_observation_create "$(python3 -c "print(str(max(0, $(date -d "$step_completed_at" '+%s.%N') - $(date -d "$step_started_at" '+%s.%N'))))")")"
    otel_observation_attribute_typed "$observation_handle" string github.actions.workflow.name="$(jq < "$workflow_json" -r .name)"
    otel_observation_attribute_typed "$observation_handle" int github.actions.workflow_run.attempt="$(jq < "$workflow_json" .run_attempt)"
    otel_observation_attribute_typed "$observation_handle" int github.actions.actor.id="$(jq < "$workflow_json" .actor.id)"
    otel_observation_attribute_typed "$observation_handle" string github.actions.actor.name="$(jq < "$workflow_json" -r .actor.login)"
    otel_observation_attribute_typed "$observation_handle" string github.actions.event.name="$(jq < "$workflow_json" -r .event)"
    otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref="/refs/heads/$(jq < "$workflow_json" -r .head_branch)"
    otel_observation_attribute_typed "$observation_handle" string github.actions.event.ref.name="$(jq < "$workflow_json" -r .head_branch)"
    otel_observation_attribute_typed "$observation_handle" string github.actions.job.name="$job_name"
    otel_observation_attribute_typed "$observation_handle" string github.actions.step.name="$step_name"
    otel_observation_attribute_typed "$observation_handle" string github.actions.action.name="$action_name"
    otel_observation_attribute_typed "$observation_handle" string github.actions.action.ref="$action_tag"
    otel_observation_attribute_typed "$observation_handle" string github.actions.action.conclusion="$step_conclusion"
    otel_counter_observe "$action_duration_counter_handle" "$observation_handle"
  fi

  step_span_handle="$(otel_span_start @"$step_started_at" INTERNAL "$step_name")"
  otel_span_attribute_typed "$step_span_handle" string github.actions.type=step
  otel_span_attribute_typed "$step_span_handle" string github.actions.url="$link"/job/"$job_id"'#'step:"$step_number":1
  otel_span_attribute_typed "$step_span_handle" string github.actions.step.name="$step_name"
  otel_span_attribute_typed "$step_span_handle" string github.actions.action.name="${action_name:-}"
  otel_span_attribute_typed "$step_span_handle" string github.actions.action.ref="${action_tag:-}"
  otel_span_attribute_typed "$step_span_handle" string github.actions.action.phase="${action_phase:-}"
  otel_span_attribute_typed "$step_span_handle" string github.actions.step.conclusion="$step_conclusion"
  otel_span_activate "$step_span_handle"
  read_log_file "$step_log_file" | while read -r line; do
    timestamp="${line%% *}"
    if ! [[ "$timestamp" =~ ^[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\.[0-9]{7}Z$ ]]; then continue; fi
    line="${line#* }"
    case "$line" in
      '[command]'*)
        severity=trace
        line="${line#[command]}"
        ;;
      '##[group]'*)
        severity=unspecified
        line="${line#*]}"
        ;;
      '##[endgroup]')
        severity=unspecified
        line=""
        ;;
      '##['*']'*)
        severity="${line#*[}"
        severity="${severity%%]*}"
        line="${line#*]}"
        ;;
      *) severity=unspecified;;
    esac
    case "$severity" in
      trace) severity=1;;
      debug) severity=5;;
      notice) severity=9;;
      warning) severity=13;;
      error) severity=17;;
      *) severity=0;;
    esac
    [ -z "${INPUT_DEBUG}" ] || echo "log $TRACEPARENT $job_name $timestamp $severity $line" >&2
    _otel_log_record "$TRACEPARENT" "$timestamp" "$severity" "$line"
  done || [ "$step_conclusion" = skipped ] || echo "::warning ::Cannot resolve log for job $job_name step $step_number."
  [ -z "${INPUT_DEBUG}" ] || echo "span step $TRACEPARENT $step_name" >&2
  otel_span_deactivate "$step_span_handle"
  if [ "$step_conclusion" = failure ]; then otel_span_error "$step_span_handle"; fi
  otel_span_end "$step_span_handle" @"$step_completed_at"
  echo "$step_completed_at" > "$times_dir"/"$TRACEPARENT"
  
done

otel_shutdown
while pgrep -f /opt/opentelemetry_shell/; do sleep 1; done
