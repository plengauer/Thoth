. ./assert.sh

node() {
  printf '%s\n' "$*"
}

INPUT_GITHUB_TOKEN=token
. ../actions/instrument/shared/github.sh

default_upload="$(gh_artifact_upload 1 1 artifact /tmp/traceparent)"
custom_upload="$(OTEL_GH_ARTIFACT_COMPRESSION_LEVEL=0 gh_artifact_upload 1 1 artifact /tmp/traceparent)"
invalid_upload="$(OTEL_GH_ARTIFACT_COMPRESSION_LEVEL=invalid gh_artifact_upload 1 1 artifact /tmp/traceparent)"

printf '%s' "$default_upload" | grep -q 'compressionLevel: 6'
printf '%s' "$custom_upload" | grep -q 'compressionLevel: 0'
printf '%s' "$invalid_upload" | grep -q 'compressionLevel: 6'
