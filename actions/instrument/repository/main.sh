#!/bin/bash
set -e -o pipefail
if [ -n "${INPUT_DEBUG:-}" ]; then cat "$GITHUB_EVENT_PATH" >&2; fi

echo "::group::Validate Configuration"
. ../shared/config_validation.sh
echo "::endgroup::"

. ../shared/github.sh
. ../shared/id_printer.sh

echo "::group::Ensuring rate limit"
gh_ensure_min_rate_limit_remaining 0.2
echo "::endgroup::"

echo "::group::Install dependencies"
if type dpkg; then
  bash -e -o pipefail ../shared/install.sh curl wget jq sed
else
  echo 'No debian, assuming dependencies are preinstalled.'
fi
echo "::endgroup::"

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
    counter_handle="$(otel_counter_create counter selfmonitoring.opentelemetry.github.repository.invocations 1 'Invocations of repository-level instrumentation')"
    observation_handle="$(otel_observation_create 1)"
    otel_counter_observe "$counter_handle" "$observation_handle"
    otel_shutdown
  ) &
fi

export OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-"$(echo "$GITHUB_REPOSITORY" | cut -d / -f 2-) CI"}"

echo "::group::Resolving repository information"
repo_json="$(mktemp)"
gh_curl | jq > "$repo_json"
echo "::endgroup::"

echo "::group::Export"
. otelapi.sh
export OTEL_DISABLE_RESOURCE_DETECTION=TRUE
_otel_resource_attributes_process() {
  _otel_resource_attribute string github.repository.id="$GITHUB_REPOSITORY_ID"
  _otel_resource_attribute string github.repository.name="$(echo "$GITHUB_REPOSITORY" | cut -d / -f 2)"
  _otel_resource_attribute string github.repository.owner.id="$GITHUB_REPOSITORY_OWNER_ID"
  _otel_resource_attribute string github.repository.owner.name="$GITHUB_REPOSITORY_OWNER"
  _otel_resource_attribute string vcs.repository.url.full="${GITHUB_SERVER_URL:-https://github.com}/$GITHUB_REPOSITORY"
  _otel_resource_attribute string vcs.repository.name="$(echo "$GITHUB_REPOSITORY" | cut -d / -f 2)"
  _otel_resource_attribute string vcs.owner.name="$GITHUB_REPOSITORY_OWNER"
  _otel_resource_attribute string vcs.provider.name=github
}
_otel_resource_attributes_custom() {
  _otel_resource_attribute string telemetry.sdk.language=github
}

otel_init

if [ "$GITHUB_REPOSITORY" = "$GITHUB_REPOSITORY_OWNER"/"$GITHUB_REPOSITORY_OWNER".github.io ]; then
  vcs_repository_count_handle="$(otel_counter_create gauge vcs.repository.count '{repository}' 'The number of repositories')"
  observation_handle="$(otel_observation_create "$(curl --no-progress-meter --fail --retry 16 --header "Authorization: Bearer $INPUT_GITHUB_TOKEN" "${GITHUB_API_URL:-https://api.github.com}"/users/"$GITHUB_REPOSITORY_OWNER" | jq .public_repos)")"
  otel_observation_attribute_typed "$observation_handle" string vcs.provider.name=github
  otel_observation_attribute_typed "$observation_handle" string vcs.owner.name="$GITHUB_REPOSITORY_OWNER"
  otel_counter_observe "$vcs_repository_count_handle" "$observation_handle"
fi

otel_github_repository_observation_create() {
  local observation_handle="$(otel_observation_create "$1")"
  otel_observation_attribute_typed "$observation_handle" string vcs.provider.name=github
  otel_observation_attribute_typed "$observation_handle" string vcs.owner.name="$GITHUB_REPOSITORY_OWNER"
  otel_observation_attribute_typed "$observation_handle" string vcs.repository.name="${GITHUB_REPOSITORY#*/}"
  otel_observation_attribute_typed "$observation_handle" string vcs.repository.url.full="${GITHUB_SERVER_URL:-https://github.com}/$GITHUB_REPOSITORY"
  echo "$observation_handle"
}

vcs_contributor_count_handle="$(otel_counter_create gauge vcs.contributor.count '{contributor}' 'The number of unique contributors to a repository')"
observation_handle="$(otel_github_repository_observation_create "$(gh_curl_paginated /contributors'&per_page=100' | jq '.[]' | jq -s length)")"
otel_counter_observe "$vcs_contributor_count_handle" "$observation_handle"

case "$INPUT_EVENT_NAME" in
  pull_request)
    vcs_change_count_handle="$(otel_counter_create up_down_counter vcs.change.count '{change}' 'The number of changes (pull requests/merge requests) by their state')"
    case "$INPUT_EVENT_ACTION" in
      opened)
        observation_handle="$(otel_github_repository_observation_create 1)"
        otel_observation_attribute_typed "$observation_handle" string vcs.change.state=open
        otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
        ;;
      closed)
        vcs_change_duration_handle="$(otel_counter_create gauge vcs.change.duration 's' 'The time duration a change (pull request/merge_request/changelist) has been in a given state.')"
        vcs_change_time_to_merge_handle="$(otel_counter_create gauge vcs.change.time_to_merge 's' 'The amount of time from creation until merge for a change (pull request/merge request/changelist).')"
        created_at="$(jq <<< "$INPUT_EVENT_BODY" .pull_request.created_at -r)"
        closed_at="$(jq <<< "$INPUT_EVENT_BODY" '.pull_request.merged_at // .pull_request.closed_at // empty' -r)"
        duration_opened="$(python3 -c "print(str(max(0, $(date -d "$closed_at" '+%s.%N') - $(date -d "$created_at" '+%s.%N'))))")"
        base_label="$(jq <<< "$INPUT_EVENT_BODY" .pull_request.base.label -r)"
        base_sha="$(jq <<< "$INPUT_EVENT_BODY" .pull_request.base.sha -r)"
        head_label="$(jq <<< "$INPUT_EVENT_BODY" .pull_request.head.label -r)"
        head_sha="$(jq <<< "$INPUT_EVENT_BODY" .pull_request.head.sha -r)"
        observation_handle="$(otel_github_repository_observation_create "$duration_opened")"
        otel_observation_attribute_typed "$observation_handle" string vcs.change.state=open
        otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.name="$head_label"
        otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.revision="$head_sha"
        otel_counter_observe "$vcs_change_duration_handle" "$observation_handle"
        observation_handle="$(otel_github_repository_observation_create -1)"
        otel_observation_attribute_typed "$observation_handle" string vcs.change.state=open
        otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
        if [ -n "$(jq <<< "$INPUT_EVENT_BODY" '.pull_request.merge_commit_sha // empty' -r)" ]; then
          observation_handle="$(otel_github_repository_observation_create "$duration_opened")"
          otel_observation_attribute_typed "$observation_handle" string vcs.ref.base.name="$base_label"
          otel_observation_attribute_typed "$observation_handle" string vcs.ref.base.revision="$base_sha"
          otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.name="$head_label"
          otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.revision="$head_sha"
          otel_counter_observe "$vcs_change_time_to_merge_handle" "$observation_handle"
          observation_handle="$(otel_github_repository_observation_create 1)"
          otel_observation_attribute_typed "$observation_handle" string vcs.change.state=merged
          otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
        else
          observation_handle="$(otel_github_repository_observation_create 1)"
          otel_observation_attribute_typed "$observation_handle" string vcs.change.state=closed
          otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
        fi
        ;;
      reopened)
        if [ -n "$(jq <<< "$INPUT_EVENT_BODY" '.pull_request.merge_commit_sha // empty' -r)" ]; then
          observation_handle="$(otel_github_repository_observation_create -1)"
          otel_observation_attribute_typed "$observation_handle" string vcs.change.state=merged
          otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
        else
          observation_handle="$(otel_github_repository_observation_create -1)"
          otel_observation_attribute_typed "$observation_handle" string vcs.change.state=closed
          otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
        fi
        observation_handle="$(otel_github_repository_observation_create 1)"
        otel_observation_attribute_typed "$observation_handle" string vcs.change.state=open
        otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
        ;;
      submitted)
        if [ "$(jq <<< "$INPUT_EVENT_BODY" .review.state -r)" = approved ]; then
          vcs_change_time_to_approval_handle="$(otel_counter_create gauge vcs.change.time_to_approval 's' 'The amount of time since its creation it took a change (pull request/merge request/changelist) to get the first approval.')"
          created_at="$(jq <<< "$INPUT_EVENT_BODY" .pull_request.created_at -r)"
          observation_handle="$(otel_github_repository_observation_create "$(python3 -c "print(str(max(0, $(date -d "$(jq <<< "$INPUT_EVENT_BODY" .review.submitted_at -r)" '+%s.%N') - $(date -d "$created_at" '+%s.%N'))))")")"
          otel_counter_observe "$vcs_change_time_to_approval_handle" "$observation_handle"
        fi
        ;;
    esac
    ;;

  create)
    vcs_ref_count_handle="$(otel_counter_create up_down_counter vcs.ref.count '{ref}' 'The number of refs of type branch or tag in a repository')"
    observation_handle="$(otel_github_repository_observation_create 1)"
    otel_observation_attribute_typed "$observation_handle" string vcs.ref.type="$(jq <<< "$INPUT_EVENT_BODY" .ref_type -r)"
    otel_counter_observe "$vcs_ref_count_handle" "$observation_handle"
    ;;
  delete)
    vcs_ref_count_handle="$(otel_counter_create up_down_counter vcs.ref.count '{ref}' 'The number of refs of type branch or tag in a repository')"
    observation_handle="$(otel_github_repository_observation_create -1)"
    otel_observation_attribute_typed "$observation_handle" string vcs.ref.type="$(jq <<< "$INPUT_EVENT_BODY" .ref_type -r)"
    otel_counter_observe "$vcs_ref_count_handle" "$observation_handle"
    ;;

  push)
    base="$(jq <<< "$INPUT_EVENT_BODY" '.base_ref // empty' -r)"
    ref="$(jq <<< "$INPUT_EVENT_BODY" .ref -r)"
    if [ -n "$base" ]; then
      [ "${base#refs/tags/}" = "$base" ] && base_ref_type=branch || base_ref_type=tag
      [ "${ref#refs/tags/}" = "$ref" ] && ref_type=branch || ref_type=tag
      curl --no-progress-meter --fail --retry 16 --header "Authorization: Bearer $INPUT_GITHUB_TOKEN" "${GITHUB_API_URL:-https://api.github.com}"/repos/"$GITHUB_REPOSITORY"/compare/"$base"..."$ref" > compare.json
      vcs_ref_lines_delta_handle="$(otel_counter_create gauge vcs.ref.lines_delta '{line}' 'The number of lines added/removed in a ref (branch) relative to the base ref')"
      vcs_ref_revisions_delta_handle="$(otel_counter_create gauge vcs.ref.revisions_delta '{revision}' 'The number of revisions ahead/behind in a ref (branch) relative to the base ref')"
      vcs_ref_time_handle="$(otel_counter_create gauge vcs.ref.time 's' 'Time a ref (branch) created from the default branch (trunk) has existed')"
      observation_handle="$(otel_github_repository_observation_create "$(jq < compare.json .files[].additions | jq -s add)")"
      otel_observation_attribute_typed "$observation_handle" string vcs.line_change.type=added
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.base.name="$base"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.base.type="$base_ref_type"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.name="$ref"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.type="$ref_type"
      otel_counter_observe "$vcs_ref_lines_delta_handle" "$observation_handle"
      observation_handle="$(otel_github_repository_observation_create "$(jq < compare.json .files[].deletions | jq -s add)")"
      otel_observation_attribute_typed "$observation_handle" string vcs.line_change.type=removed
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.base.name="$base"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.base.type="$base_ref_type"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.name="$ref"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.type="$ref_type"      
      otel_counter_observe "$vcs_ref_lines_delta_handle" "$observation_handle"
      observation_handle="$(otel_github_repository_observation_create "$(jq < compare.json .ahead_by)")"
      otel_observation_attribute_typed "$observation_handle" string vcs.revision_delta.direction=ahead
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.base.name="$base"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.base.type="$base_ref_type"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.name="$ref"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.type="$ref_type"
      otel_counter_observe "$vcs_ref_revisions_delta_handle" "$observation_handle"
      observation_handle="$(otel_github_repository_observation_create "$(jq < compare.json .behind_by)")"
      otel_observation_attribute_typed "$observation_handle" string vcs.revision_delta.direction=behind
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.base.name="$base"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.base.type="$base_ref_type"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.name="$ref"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.type="$ref_type"      
      otel_counter_observe "$vcs_ref_revisions_delta_handle" "$observation_handle"
      observation_handle="$(otel_github_repository_observation_create "$(python3 -c "print(str(max(0, $(date -d "$(jq < compare.json .commits[].commit.committer.date -r | sort | tail -n 1)" '+%s.%N') - $(date -d "$(jq < compare.json .commits[].commit.committer.date -r | sort | head -n 1)" '+%s.%N'))))")")"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.base.name="$base"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.base.type="$base_ref_type"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.name="$ref"
      otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.type="$ref_type"    
      otel_counter_observe "$vcs_ref_time_handle" "$observation_handle"
    fi
    ;;
esac
echo "::endgroup::"

otel_shutdown
while pgrep -f /opt/opentelemetry_shell/; do sleep 1; done
