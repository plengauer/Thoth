#!/bin/false

gh_curl() {
  curl -L --no-progress-meter --fail --retry 16 -H "Authorization: Bearer $INPUT_GITHUB_TOKEN" "${GITHUB_API_URL:-https://api.github.com}"/repos/"$GITHUB_REPOSITORY""$@"
}
export -f gh_curl

gh_curl_paginated() {
  {
    gh_curl "$@" --head | grep '^link: ' | cut -d ' '  -f 2- | tr -d ' <>' | tr ',' '\n' \
      | grep 'rel="last"' | cut -d ';' -f1 | cut -d '?' -f 2- | tr '&' '\n' \
      | grep '^page=' | cut -d = -f 2 \
      | xargs seq 1 || true
  } | while read -r page; do echo "$@"'&page='"$page"; done | xargs -r -n 1 bash -ec 'gh_curl "$@"' bash
}
export -f gh_curl_paginated

gh_rate_limit() {
  curl --no-progress-meter --fail --retry 16 -H "Authorization: Bearer $INPUT_GITHUB_TOKEN" "${GITHUB_API_URL:-https://api.github.com}"/rate_limit
}
export -f gh_rate_limit

gh_ensure_min_rate_limit_remaining() {
  local threshold="$1"
  local delay=1
  while [ "$(gh_rate_limit | jq '.resources.core | .remaining / .limit * 100 | floor')" -lt "$(echo "$threshold" | jq '. * 100 | floor')" ]; do
    sleep "$delay"
    local delay=$((delay * 2))
  done
}
export -f gh_ensure_min_rate_limit_remaining

gh_releases() {
  gh_curl_paginated /releases'?per_page=100'
}
export -f gh_releases

gh_release() {
  local tag="$1"
  if [ "$tag" = main ]; then
    local path=latest
  else
    local path=tags/"$tag"
  fi
  gh_curl /releases/"$path"
}
export -f gh_release

gh_workflow_runs() {
  gh_curl_paginated /actions/runs'?per_page=100'
}
export -f gh_workflow_runs

gh_workflow_run() {
  gh_curl /actions/runs/"$1"/attempts/"$2"
}
export -f gh_workflow_run

gh_workflow_run_logs() {
  wget -q --header="Authorization: Bearer $INPUT_GITHUB_TOKEN" "${GITHUB_API_URL:-https://api.github.com}"/repos/"$GITHUB_REPOSITORY"/actions/runs/"$1"/attempts/"$2"/logs -O "$3"
}
export -f gh_workflow_run_logs

gh_jobs() {
  gh_curl_paginated /actions/runs/"$1"/attempts/"$2"/jobs'?per_page=50'
}
export -f gh_jobs

gh_job() {
  gh_curl /actions/jobs/"$3"
}
export -f gh_job

gh_artifacts() {
  gh_curl_paginated /actions/runs/"$1"/artifacts'?per_page=100'
}
export -f gh_artifacts

gh_workflow_run_traceparent() {
  local seed="${GITHUB_SERVER_URL:-https://github.com}"/"$GITHUB_REPOSITORY"/actions/runs/"$1"/attempts/"$2"
  local hash
  if type sha256sum 1> /dev/null 2> /dev/null; then
    hash="$(printf '%s' "$seed" | sha256sum | cut -d ' ' -f 1)"
  else
    hash="$(printf '%s' "$seed" | shasum -a 256 | cut -d ' ' -f 1)"
  fi
  local trace_id="$(printf '%s' "$hash" | cut -c 1-32)"
  local span_id="$(printf '%s' "$hash" | cut -c 33-48)"
  [ "$trace_id" != 00000000000000000000000000000000 ] || trace_id=00000000000000000000000000000001
  [ "$span_id" != 0000000000000000 ] || span_id=0000000000000001
  printf '00-%s-%s-01\n' "$trace_id" "$span_id"
}
export -f gh_workflow_run_traceparent

gh_artifact_download() {
  local artifact_filename="$(mktemp)"
  gh_curl /actions/runs/"$1"/artifacts'?per_page=1&'name="$3" | jq '.artifacts[0].id' | grep -v '^null$' | xargs -r -I '{}' bash -c 'gh_curl "$@"' bash /actions/artifacts/'{}'/zip --head | tr -d '\r' | grep '^location:' | cut -d ' ' -f 2- | xargs -r wget -q -O "$artifact_filename" || return 1
  [ -r "$artifact_filename" ] || return 1
  mkdir -p "$4"
  if unzip -t "$artifact_filename" 1> /dev/null 2> /dev/null; then
    unzip "$artifact_filename" -d "$4" >&2
    rm "$artifact_filename"
  else
    mv "$artifact_filename" "$4"/"$3"
  fi
}
export -f gh_artifact_download

gh_artifact_upload() {
  local compression_level="${OTEL_GH_ARTIFACT_COMPRESSION_LEVEL:-6}"
  local skip_archive="${OTEL_GH_ARTIFACT_SKIP_ARCHIVE:-false}"
  case "$compression_level" in
    [0-9]) ;;
    *) compression_level=6;;
  esac
  case "$skip_archive" in
    1|true|TRUE|yes|YES) skip_archive=true;;
    *) skip_archive=false;;
  esac
  GITHUB_TOKEN="$INPUT_GITHUB_TOKEN" node --input-type=module -e '
    import path from "node:path";
    import { DefaultArtifactClient } from "@actions/artifact";
    new DefaultArtifactClient().uploadArtifact("'"$3"'", [ '"$(echo "${@:4}" | tr ' ' '\n' | sed -E 's/^(.*)$/"\1"/g' | tr '\n' ',')"' ], path.dirname("'"$4"'"), { compressionLevel: '"$compression_level"', skipArchive: '"$skip_archive"' });
  '
}
export -f gh_artifact_upload

gh_artifact_delete() {
  GITHUB_TOKEN="$INPUT_GITHUB_TOKEN" node --input-type=module -e '
    import { DefaultArtifactClient } from "@actions/artifact";
    new DefaultArtifactClient().deleteArtifact("'"$3"'");
  '
}
export -f gh_artifact_delete

gh_repo_properties() {
  gh_curl /properties/values
}
export -f gh_repo_properties

gh_check_suite() {
  gh_curl /check-suites/"$1"
}
export -f gh_check_suite

gh_check_runs() {
  gh_curl_paginated /check-suites/"$1"/check-runs'?per_page=100'
}
export -f gh_check_runs
