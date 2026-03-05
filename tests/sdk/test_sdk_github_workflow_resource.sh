. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

export GITHUB_ACTIONS=true
export GITHUB_REPOSITORY_ID=123
export GITHUB_REPOSITORY_OWNER_ID=456
export GITHUB_REPOSITORY_OWNER=owner
export GITHUB_REPOSITORY=owner/repo
export GITHUB_WORKFLOW=ci
export GITHUB_WORKFLOW_REF=owner/repo/.github/workflows/ci.yml@refs/heads/main
export GITHUB_WORKFLOW_SHA=abcdef1234567890

otel_init
span_id=$(otel_span_start INTERNAL workflow-span)
otel_span_end $span_id
otel_shutdown

span="$(resolve_span)"
assert_equals "$GITHUB_WORKFLOW_REF" $(echo "$span" | jq -r '.resource.attributes."github.workflow.ref"')
assert_equals "$GITHUB_WORKFLOW_SHA" $(echo "$span" | jq -r '.resource.attributes."github.workflow.sha"')
assert_equals "$GITHUB_WORKFLOW_REF" $(echo "$span" | jq -r '.resource.attributes."github.actions.workflow.ref"')
assert_equals "$GITHUB_WORKFLOW_SHA" $(echo "$span" | jq -r '.resource.attributes."github.actions.workflow.sha"')
