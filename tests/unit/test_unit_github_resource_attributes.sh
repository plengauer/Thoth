. ./assert.sh

GITHUB_REPOSITORY_ID=1
GITHUB_REPOSITORY=owner/repo
GITHUB_REPOSITORY_OWNER_ID=2
GITHUB_REPOSITORY_OWNER=owner
GITHUB_WORKFLOW_REF=owner/repo/.github/workflows/workflow.yml@refs/heads/main
GITHUB_WORKFLOW_SHA=abc
GITHUB_WORKFLOW=workflow

OTEL_RESOURCE_ATTRIBUTES=
OTEL_RESOURCE_ATTRIBUTES=github.repository.id="$GITHUB_REPOSITORY_ID",github.repository.name="${GITHUB_REPOSITORY#*/}",github.repository.owner.id="$GITHUB_REPOSITORY_OWNER_ID",github.repository.owner.name="$GITHUB_REPOSITORY_OWNER",github.actions.workflow.ref="$GITHUB_WORKFLOW_REF",github.actions.workflow.sha="$GITHUB_WORKFLOW_SHA",github.actions.workflow.name="$GITHUB_WORKFLOW"${OTEL_RESOURCE_ATTRIBUTES:+,$OTEL_RESOURCE_ATTRIBUTES}
assert_equals "github.repository.id=1,github.repository.name=repo,github.repository.owner.id=2,github.repository.owner.name=owner,github.actions.workflow.ref=owner/repo/.github/workflows/workflow.yml@refs/heads/main,github.actions.workflow.sha=abc,github.actions.workflow.name=workflow" "$OTEL_RESOURCE_ATTRIBUTES"

OTEL_RESOURCE_ATTRIBUTES=deployment.environment=production
OTEL_RESOURCE_ATTRIBUTES=github.repository.id="$GITHUB_REPOSITORY_ID",github.repository.name="${GITHUB_REPOSITORY#*/}",github.repository.owner.id="$GITHUB_REPOSITORY_OWNER_ID",github.repository.owner.name="$GITHUB_REPOSITORY_OWNER",github.actions.workflow.ref="$GITHUB_WORKFLOW_REF",github.actions.workflow.sha="$GITHUB_WORKFLOW_SHA",github.actions.workflow.name="$GITHUB_WORKFLOW"${OTEL_RESOURCE_ATTRIBUTES:+,$OTEL_RESOURCE_ATTRIBUTES}
assert_equals "github.repository.id=1,github.repository.name=repo,github.repository.owner.id=2,github.repository.owner.name=owner,github.actions.workflow.ref=owner/repo/.github/workflows/workflow.yml@refs/heads/main,github.actions.workflow.sha=abc,github.actions.workflow.name=workflow,deployment.environment=production" "$OTEL_RESOURCE_ATTRIBUTES"
