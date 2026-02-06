#!/bin/bash
set -e -o pipefail

echo "::group::Validate Configuration"
. ../shared/config_validation.sh
echo "::endgroup::"

. ../shared/github.sh
. ../shared/id_printer.sh

echo "::group::Install Dependencies"
if type dpkg; then
  bash -e -o pipefail ../shared/install.sh curl wget jq sed
else
  echo 'No debian, assuming dependencies are preinstalled.'
fi
echo "::endgroup::"

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
    otel_init
    counter_handle="$(otel_counter_create counter selfmonitoring.opentelemetry.github.checksuite.invocations 1 'Invocations of check suite-level instrumentation')"
    observation_handle="$(otel_observation_create 1)"
    otel_counter_observe "$counter_handle" "$observation_handle"
    otel_shutdown
  ) &
fi

export OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-"$(echo "$GITHUB_REPOSITORY" | cut -d / -f 2-) CI"}"

echo "::group::Resolve Check Suite"
check_suite_json="$(mktemp)"
jq < "$GITHUB_EVENT_PATH" > "$check_suite_json" .check_suite
if [ "$INPUT_CHECK_SUITE_ID" != "$(jq < "$check_suite_json" .id)" ]; then gh_check_suite "$INPUT_CHECK_SUITE_ID" > "$check_suite_json"; fi
if [ "$(jq < "$check_suite_json" -r .status)" != completed ]; then echo "::error ::Check suite not completed yet."; exit 1; fi
echo "::endgroup::"

echo "::group::Check for GitHub Actions"
if [ "$(jq < "$check_suite_json" -r '.app.slug')" = "github-actions" ]; then
  echo "::warning ::Check suite is from GitHub Actions, skipping."
  echo "::endgroup::"
  exit 0
fi
echo "::endgroup::"

echo "::group::Resolve Check Runs"
check_runs_json="$(mktemp)"
gh_check_runs "$INPUT_CHECK_SUITE_ID" | jq '.check_runs[]' > "$check_runs_json"
if [ ! -s "$check_runs_json" ]; then
  echo "::warning ::No check runs found in this check suite."
  exit 0
fi
echo "::endgroup::"

echo "::group::Export"
. otelapi.sh
export OTEL_DISABLE_RESOURCE_DETECTION=TRUE
_otel_resource_attributes_process() {
  _otel_resource_attribute string github.repository.id="$GITHUB_REPOSITORY_ID"
  _otel_resource_attribute string github.repository.name="$(echo "$GITHUB_REPOSITORY" | cut -d / -f 2)"
  _otel_resource_attribute string github.repository.owner.id="$GITHUB_REPOSITORY_OWNER_ID"
  _otel_resource_attribute string github.repository.owner.name="$GITHUB_REPOSITORY_OWNER"
}
_otel_resource_attributes_custom() {
  _otel_resource_attribute string telemetry.sdk.language=github
}

otel_init
cicd_pipeline_run_duration_handle="$(otel_counter_create counter cicd.pipeline.run.duration s 'Duration of a pipeline run grouped by pipeline, state and result')"
cicd_pipeline_run_errors_handle="$(otel_counter_create counter cicd.pipeline.run.errors '{error}' 'The number of errors encountered in pipeline runs')"
check_suite_counter_handle="$(otel_counter_create counter github.checks.suites 1 'Number of check suites')"
check_suite_duration_counter_handle="$(otel_counter_create counter github.checks.suites.duration s 'Duration of check suites')"
check_run_counter_handle="$(otel_counter_create counter github.checks.runs 1 'Number of check runs')"
check_run_duration_counter_handle="$(otel_counter_create counter github.checks.runs.duration s 'Duration of check runs')"

link="${GITHUB_SERVER_URL:-https://github.com}"/"$GITHUB_REPOSITORY"/runs
check_suite_started_at="$(jq < "$check_runs_json" -r .started_at | sort | head -n 1)"
check_suite_ended_at="$(jq < "$check_runs_json" -r .completed_at | sort -r | head -n 1)"

observation_handle="$(otel_observation_create 1)"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.suite.id="$(jq < "$check_suite_json" .id)"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.suite.conclusion="$(jq < "$check_suite_json" -r .conclusion)"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.suite.ref="/refs/heads/$(jq < "$check_suite_json" -r .head_branch)"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.suite.ref.sha="$(jq < "$check_suite_json" -r .head_sha)"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.suite.ref.name="$(jq < "$check_suite_json" -r .head_branch)"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.app.name="$(jq < "$check_suite_json" -r .app.name)"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.app.slug="$(jq < "$check_suite_json" -r .app.slug)"
otel_counter_observe "$check_suite_counter_handle" "$observation_handle"

observation_handle="$(otel_observation_create "$(python3 -c "print(str(max(0, $(date -d "$check_suite_ended_at" '+%s.%N') - $(date -d "$check_suite_started_at" '+%s.%N'))))")")"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.suite.id="$(jq < "$check_suite_json" .id)"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.suite.conclusion="$(jq < "$check_suite_json" -r .conclusion)"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.suite.ref="/refs/heads/$(jq < "$check_suite_json" -r .head_branch)"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.suite.ref.sha="$(jq < "$check_suite_json" -r .head_sha)"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.suite.ref.name="$(jq < "$check_suite_json" -r .head_branch)"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.app.name="$(jq < "$check_suite_json" -r .app.name)"
otel_observation_attribute_typed "$observation_handle" string github.actions.checks.app.slug="$(jq < "$check_suite_json" -r .app.slug)"
otel_counter_observe "$check_suite_duration_counter_handle" "$observation_handle"

check_suite_span_handle="$(otel_span_start @"$check_suite_started_at" CONSUMER "$(jq < "$check_suite_json" -r '.app.name')")"
otel_span_attribute_typed "$check_suite_span_handle" string github.actions.type=checksuite
otel_span_attribute_typed "$check_suite_span_handle" int github.actions.checks.suite.id="$(jq < "$check_suite_json" .id)"
otel_span_attribute_typed "$check_suite_span_handle" string github.actions.conclusion="$(jq < "$check_suite_json" -r .conclusion)"
otel_span_attribute_typed "$check_suite_span_handle" string github.actions.checks.suite.ref="/refs/heads/$(jq < "$check_suite_json" -r .head_branch)"
otel_span_attribute_typed "$check_suite_span_handle" string github.actions.checks.suite.ref.sha="$(jq < "$check_suite_json" -r .head_sha)"
otel_span_attribute_typed "$check_suite_span_handle" string github.actions.checks.suite.ref.name="$(jq < "$check_suite_json" -r .head_branch)"
otel_span_attribute_typed "$check_suite_span_handle" string github.actions.checks.app.name="$(jq < "$check_suite_json" -r .app.name)"
otel_span_attribute_typed "$check_suite_span_handle" string github.actions.checks.app.slug="$(jq < "$check_suite_json" -r .app.slug)"
otel_span_activate "$check_suite_span_handle"
[ -z "${INPUT_DEBUG}" ] || echo "span checksuite $TRACEPARENT $check_suite_name" >&2
if [ "$(jq < "$check_suite_json" -r .conclusion)" = failure ]; then otel_span_error "$check_suite_span_handle"; fi
echo ::notice title=Observability Information::"Trace ID: $(echo "$TRACEPARENT" | cut -d - -f 2), Span ID: $(echo "$TRACEPARENT" | cut -d - -f 3), Trace Deep Link: $(print_trace_link "$check_suite_started_at" || echo unavailable)"

jq < "$check_runs_json" -r --unbuffered '. | ["'"$TRACEPARENT"'", .id, .conclusion, .started_at, .completed_at, .app.slug, .name] | @tsv' | while IFS=$'\t' read -r TRACEPARENT check_run_id check_run_conclusion check_run_started_at check_run_completed_at app_slug check_run_name; do
  if [ "$check_run_conclusion" = null ] || [ -z "$check_run_conclusion" ]; then continue; fi
  if [ "$check_run_started_at" = null ] || [ -z "$check_run_started_at" ]; then continue; fi
  if [ "$check_run_completed_at" = null ] || [ -z "$check_run_completed_at" ]; then check_run_completed_at="$check_run_started_at"; fi

  observation_handle="$(otel_observation_create "$(python3 -c "print(str(max(0, $(date -d "$check_run_completed_at" '+%s.%N') - $(date -d "$check_run_started_at" '+%s.%N'))))")")"
  otel_observation_attribute_typed "$observation_handle" string cicd.pipeline.name="$check_run_name)"
  otel_observation_attribute_typed "$observation_handle" string cicd.pipeline.run.state=executing
  case "$check_run_conclusion" in
    neutral) otel_observation_attribute_typed "$observation_handle" string cicd.pipeline.result=success;;
    skipped) otel_observation_attribute_typed "$observation_handle" string cicd.pipeline.result=skip;;
    cancelled) otel_observation_attribute_typed "$observation_handle" string cicd.pipeline.result=cancellation;;
    timed_out) otel_observation_attribute_typed "$observation_handle" string cicd.pipeline.result=timeout;;
    *) otel_observation_attribute_typed "$observation_handle" string cicd.pipeline.result="$check_run_conclusion";;
  esac
  otel_counter_observe "$cicd_pipeline_run_duration_handle" "$observation_handle"

  if [ "$check_run_conclusion" = failure ]; then
    observation_handle="$(otel_observation_create 1)"
    otel_observation_attribute_typed "$observation_handle" string cicd.pipeline.name="$check_run_name)"
    otel_counter_observe "$cicd_pipeline_run_errors_handle" "$observation_handle"
  fi

  observation_handle="$(otel_observation_create 1)"
  otel_observation_attribute_typed "$observation_handle" string github.actions.checks.run.name="$check_run_name"
  otel_observation_attribute_typed "$observation_handle" string github.actions.checks.run.conclusion="$check_run_conclusion"
  otel_observation_attribute_typed "$observation_handle" string github.actions.checks.app.slug="$app_slug"
  otel_counter_observe "$check_run_counter_handle" "$observation_handle"

  observation_handle="$(otel_observation_create "$(python3 -c "print(str(max(0, $(date -d "$check_run_completed_at" '+%s.%N') - $(date -d "$check_run_started_at" '+%s.%N'))))")")"
  otel_observation_attribute_typed "$observation_handle" string github.actions.checks.run.name="$check_run_name"
  otel_observation_attribute_typed "$observation_handle" string github.actions.checks.run.conclusion="$check_run_conclusion"
  otel_observation_attribute_typed "$observation_handle" string github.actions.checks.app.slug="$app_slug"
  otel_counter_observe "$check_run_duration_counter_handle" "$observation_handle"

  check_run_span_handle="$(otel_span_start @"$check_run_started_at" SERVER "$check_run_name")"
  otel_span_attribute_typed "$job_span_handle" string cicd.pipeline.run_id="$check_run_id"
  otel_span_attribute_typed "$job_span_handle" string cicd.pipeline.name="$check_run_name"
  otel_span_attribute_typed "$job_span_handle" string cicd.pipeline.action.name=RUN
  otel_span_attribute_typed "$job_span_handle" string cicd.pipeline.run.url.full="$link"/"$check_run_id"
  otel_span_attribute_typed "$check_run_span_handle" string github.actions.type=check
  otel_span_attribute_typed "$check_run_span_handle" string github.actions.url.full="$link"/"$check_run_id"
  otel_span_attribute_typed "$check_run_span_handle" int github.actions.checks.run.id="$check_run_id"
  otel_span_attribute_typed "$check_run_span_handle" string github.actions.checks.run.name="$check_run_name"
  otel_span_attribute_typed "$check_run_span_handle" string github.actions.conclusion="$check_run_conclusion"
  otel_span_attribute_typed "$check_run_span_handle" string github.actions.checks.app.slug="$app_slug"
  [ -z "${INPUT_DEBUG}" ] || echo "span check $TRACEPARENT $check_run_name" >&2
  case "$check_run_conclusion" in
    failure) otel_span_attribute_typed "$check_run_span_handle" string cicd.pipeline.result=failure; otel_span_error "$check_run_span_handle";;
    neutral) otel_span_attribute_typed "$check_run_span_handle" string cicd.pipeline.result=success;;
    cancelled) otel_span_attribute_typed "$check_run_span_handle" string cicd.pipeline.result=cancellation;;
    timed_out) otel_span_attribute_typed "$check_run_span_handle" string cicd.pipeline.result=timeout;;
    skipped) otel_span_attribute_typed "$check_run_span_handle" string cicd.pipeline.result=skip;;
    *) otel_span_attribute_typed "$check_run_span_handle" string cicd.pipeline.result="$check_run_conclusion";;
  esac
  otel_span_end "$check_run_span_handle" @"$check_run_completed_at"
done

otel_span_deactivate "$check_suite_span_handle"
otel_span_end "$check_suite_span_handle" @"$check_suite_ended_at"

echo "::endgroup::"

otel_shutdown
while pgrep -f /opt/opentelemetry_shell/; do sleep 1; done
