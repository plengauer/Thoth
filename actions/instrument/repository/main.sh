#!/bin/bash
set -e -o pipefail

echo "::group::Validate Configuration"
. ../shared/config_validation.sh
echo "::endgroup::"

. ../shared/github.sh
. ../shared/id_printer.sh

echo "::group::Ensuring rate limit"
gh_ensure_min_rate_limit_remaining 0.2
echo "::endgroup::"

echo "::group::Install Dependencies"
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

echo "::group::Collecting metrics"
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
vcs_contributor_count_handle="$(otel_counter_create updowncounter vcs.contributor.count '{contributor}' 'The number of contributors in a repository')"
vcs_change_count_handle="$(otel_counter_create updowncounter vcs.change.count '{change}' 'The number of changes (pull requests/merge requests) by their state')"
vcs_ref_count_handle="$(otel_counter_create updowncounter vcs.ref.count '{ref}' 'The number of refs of type branch or tag in a repository')"

repository_url="${GITHUB_SERVER_URL:-https://github.com}/$GITHUB_REPOSITORY"
owner_name="$GITHUB_REPOSITORY_OWNER"
repo_name="$(echo "$GITHUB_REPOSITORY" | cut -d / -f 2)"

case "$GITHUB_EVENT_NAME" in
  issues|pull_request|pull_request_target)
    echo "Processing $GITHUB_EVENT_NAME event"
    
    if [ "$GITHUB_EVENT_NAME" = issues ]; then
      if [ "$(jq < "$GITHUB_EVENT_PATH" -r .action)" = opened ]; then
        observation_handle="$(otel_observation_create 1)"
        otel_observation_attribute_typed "$observation_handle" string vcs.repository.url.full="$repository_url"
        otel_observation_attribute_typed "$observation_handle" string vcs.owner.name="$owner_name"
        otel_observation_attribute_typed "$observation_handle" string vcs.repository.name="$repo_name"
        otel_observation_attribute_typed "$observation_handle" string vcs.provider.name=github
        otel_observation_attribute_typed "$observation_handle" string vcs.change.state=open
        otel_observation_attribute_typed "$observation_handle" string vcs.change.type=issue
        otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
      elif [ "$(jq < "$GITHUB_EVENT_PATH" -r .action)" = closed ]; then
        observation_handle="$(otel_observation_create -1)"
        otel_observation_attribute_typed "$observation_handle" string vcs.repository.url.full="$repository_url"
        otel_observation_attribute_typed "$observation_handle" string vcs.owner.name="$owner_name"
        otel_observation_attribute_typed "$observation_handle" string vcs.repository.name="$repo_name"
        otel_observation_attribute_typed "$observation_handle" string vcs.provider.name=github
        otel_observation_attribute_typed "$observation_handle" string vcs.change.state=open
        otel_observation_attribute_typed "$observation_handle" string vcs.change.type=issue
        otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
        
        observation_handle="$(otel_observation_create 1)"
        otel_observation_attribute_typed "$observation_handle" string vcs.repository.url.full="$repository_url"
        otel_observation_attribute_typed "$observation_handle" string vcs.owner.name="$owner_name"
        otel_observation_attribute_typed "$observation_handle" string vcs.repository.name="$repo_name"
        otel_observation_attribute_typed "$observation_handle" string vcs.provider.name=github
        otel_observation_attribute_typed "$observation_handle" string vcs.change.state=closed
        otel_observation_attribute_typed "$observation_handle" string vcs.change.type=issue
        otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
      fi
    fi
    
    if [ "$GITHUB_EVENT_NAME" = pull_request ] || [ "$GITHUB_EVENT_NAME" = pull_request_target ]; then
      if [ "$(jq < "$GITHUB_EVENT_PATH" -r .action)" = opened ]; then
        observation_handle="$(otel_observation_create 1)"
        otel_observation_attribute_typed "$observation_handle" string vcs.repository.url.full="$repository_url"
        otel_observation_attribute_typed "$observation_handle" string vcs.owner.name="$owner_name"
        otel_observation_attribute_typed "$observation_handle" string vcs.repository.name="$repo_name"
        otel_observation_attribute_typed "$observation_handle" string vcs.provider.name=github
        otel_observation_attribute_typed "$observation_handle" string vcs.change.state=open
        otel_observation_attribute_typed "$observation_handle" string vcs.change.type=pull_request
        otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
      elif [ "$(jq < "$GITHUB_EVENT_PATH" -r .action)" = closed ]; then
        observation_handle="$(otel_observation_create -1)"
        otel_observation_attribute_typed "$observation_handle" string vcs.repository.url.full="$repository_url"
        otel_observation_attribute_typed "$observation_handle" string vcs.owner.name="$owner_name"
        otel_observation_attribute_typed "$observation_handle" string vcs.repository.name="$repo_name"
        otel_observation_attribute_typed "$observation_handle" string vcs.provider.name=github
        otel_observation_attribute_typed "$observation_handle" string vcs.change.state=open
        otel_observation_attribute_typed "$observation_handle" string vcs.change.type=pull_request
        otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
        
        observation_handle="$(otel_observation_create 1)"
        otel_observation_attribute_typed "$observation_handle" string vcs.repository.url.full="$repository_url"
        otel_observation_attribute_typed "$observation_handle" string vcs.owner.name="$owner_name"
        otel_observation_attribute_typed "$observation_handle" string vcs.repository.name="$repo_name"
        otel_observation_attribute_typed "$observation_handle" string vcs.provider.name=github
        otel_observation_attribute_typed "$observation_handle" string vcs.change.state=closed
        otel_observation_attribute_typed "$observation_handle" string vcs.change.type=pull_request
        otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
        
        if [ "$(jq < "$GITHUB_EVENT_PATH" -r .pull_request.merged)" = true ]; then
          pr_created_at="$(jq < "$GITHUB_EVENT_PATH" -r .pull_request.created_at)"
          pr_merged_at="$(jq < "$GITHUB_EVENT_PATH" -r .pull_request.merged_at)"
          time_to_merge="$(python3 -c "print(str(max(0, $(date -d "$pr_merged_at" '+%s.%N') - $(date -d "$pr_created_at" '+%s.%N'))))")"
          
          vcs_change_time_to_merge_handle="$(otel_gauge_create gauge vcs.change.time_to_merge s 'The amount of time since its creation it took a change (pull request/merge request/changelist) to get merged into the target(base) ref')"
          observation_handle="$(otel_observation_create "$time_to_merge")"
          otel_observation_attribute_typed "$observation_handle" string vcs.repository.url.full="$repository_url"
          otel_observation_attribute_typed "$observation_handle" string vcs.owner.name="$owner_name"
          otel_observation_attribute_typed "$observation_handle" string vcs.repository.name="$repo_name"
          otel_observation_attribute_typed "$observation_handle" string vcs.provider.name=github
          otel_observation_attribute_typed "$observation_handle" string vcs.ref.head.name="$(jq < "$GITHUB_EVENT_PATH" -r .pull_request.head.ref)"
          otel_observation_attribute_typed "$observation_handle" string vcs.ref.base.name="$(jq < "$GITHUB_EVENT_PATH" -r .pull_request.base.ref)"
          otel_gauge_observe "$vcs_change_time_to_merge_handle" "$observation_handle"
        fi
      fi
    fi
    ;;
    
  schedule|workflow_dispatch)
    echo "Running scheduled/manual repository metrics collection"
    
    contributors_json="$(mktemp)"
    gh_curl /contributors | jq > "$contributors_json"
    contributor_count="$(jq < "$contributors_json" 'length')"
    
    observation_handle="$(otel_observation_create "$contributor_count")"
    otel_observation_attribute_typed "$observation_handle" string vcs.repository.url.full="$repository_url"
    otel_observation_attribute_typed "$observation_handle" string vcs.owner.name="$owner_name"
    otel_observation_attribute_typed "$observation_handle" string vcs.repository.name="$repo_name"
    otel_observation_attribute_typed "$observation_handle" string vcs.provider.name=github
    otel_counter_observe "$vcs_contributor_count_handle" "$observation_handle"
    
    branches_json="$(mktemp)"
    gh_curl /branches | jq > "$branches_json"
    branch_count="$(jq < "$branches_json" 'length')"
    
    observation_handle="$(otel_observation_create "$branch_count")"
    otel_observation_attribute_typed "$observation_handle" string vcs.repository.url.full="$repository_url"
    otel_observation_attribute_typed "$observation_handle" string vcs.owner.name="$owner_name"
    otel_observation_attribute_typed "$observation_handle" string vcs.repository.name="$repo_name"
    otel_observation_attribute_typed "$observation_handle" string vcs.provider.name=github
    otel_observation_attribute_typed "$observation_handle" string vcs.ref.type=branch
    otel_counter_observe "$vcs_ref_count_handle" "$observation_handle"
    
    tags_json="$(mktemp)"
    gh_curl /tags | jq > "$tags_json"
    tag_count="$(jq < "$tags_json" 'length')"
    
    observation_handle="$(otel_observation_create "$tag_count")"
    otel_observation_attribute_typed "$observation_handle" string vcs.repository.url.full="$repository_url"
    otel_observation_attribute_typed "$observation_handle" string vcs.owner.name="$owner_name"
    otel_observation_attribute_typed "$observation_handle" string vcs.repository.name="$repo_name"
    otel_observation_attribute_typed "$observation_handle" string vcs.provider.name=github
    otel_observation_attribute_typed "$observation_handle" string vcs.ref.type=tag
    otel_counter_observe "$vcs_ref_count_handle" "$observation_handle"
    
    open_issues="$(jq < "$repo_json" -r .open_issues_count)"
    observation_handle="$(otel_observation_create "$open_issues")"
    otel_observation_attribute_typed "$observation_handle" string vcs.repository.url.full="$repository_url"
    otel_observation_attribute_typed "$observation_handle" string vcs.owner.name="$owner_name"
    otel_observation_attribute_typed "$observation_handle" string vcs.repository.name="$repo_name"
    otel_observation_attribute_typed "$observation_handle" string vcs.provider.name=github
    otel_observation_attribute_typed "$observation_handle" string vcs.change.state=open
    otel_observation_attribute_typed "$observation_handle" string vcs.change.type=issue
    otel_counter_observe "$vcs_change_count_handle" "$observation_handle"
    ;;
    
  *)
    echo "::warning::Event type $GITHUB_EVENT_NAME not supported for repository-level instrumentation"
    ;;
esac

echo "::endgroup::"

otel_shutdown
while pgrep -f /opt/opentelemetry_shell/; do sleep 1; done
