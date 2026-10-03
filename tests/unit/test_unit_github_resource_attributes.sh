. ./assert.sh

GITHUB_REPOSITORY_ID=1
GITHUB_REPOSITORY=owner/repo
GITHUB_REPOSITORY_OWNER_ID=2
GITHUB_REPOSITORY_OWNER=owner
GITHUB_WORKFLOW_REF=owner/repo/.github/workflows/workflow.yml@refs/heads/main
GITHUB_WORKFLOW_SHA=abc
GITHUB_WORKFLOW=workflow

INPUT___JOB_WORKFLOW_REF=
INPUT___JOB_WORKFLOW_SHA=
INPUT___JOB_WORKFLOW_REPOSITORY=
INPUT___JOB_WORKFLOW_FILE_PATH=
OTEL_RESOURCE_ATTRIBUTES=
workflow_ref="${INPUT___JOB_WORKFLOW_REF:-$GITHUB_WORKFLOW_REF}"
workflow_sha="${INPUT___JOB_WORKFLOW_SHA:-$GITHUB_WORKFLOW_SHA}"
OTEL_RESOURCE_ATTRIBUTES=github.repository.id="$GITHUB_REPOSITORY_ID",github.repository.name="${GITHUB_REPOSITORY#*/}",github.repository.owner.id="$GITHUB_REPOSITORY_OWNER_ID",github.repository.owner.name="$GITHUB_REPOSITORY_OWNER",github.actions.workflow.ref="$workflow_ref",github.actions.workflow.sha="$workflow_sha",github.actions.workflow.name="$GITHUB_WORKFLOW",github.actions.workflow.caller.ref="$GITHUB_WORKFLOW_REF",github.actions.workflow.caller.sha="$GITHUB_WORKFLOW_SHA",github.actions.workflow.caller.name="$GITHUB_WORKFLOW"${OTEL_RESOURCE_ATTRIBUTES:+,$OTEL_RESOURCE_ATTRIBUTES}
assert_equals "github.repository.id=1,github.repository.name=repo,github.repository.owner.id=2,github.repository.owner.name=owner,github.actions.workflow.ref=owner/repo/.github/workflows/workflow.yml@refs/heads/main,github.actions.workflow.sha=abc,github.actions.workflow.name=workflow,github.actions.workflow.caller.ref=owner/repo/.github/workflows/workflow.yml@refs/heads/main,github.actions.workflow.caller.sha=abc,github.actions.workflow.caller.name=workflow" "$OTEL_RESOURCE_ATTRIBUTES"

INPUT___JOB_WORKFLOW_REF=owner/repo/.github/workflows/reusable.yml@refs/heads/main
INPUT___JOB_WORKFLOW_SHA=def
INPUT___JOB_WORKFLOW_REPOSITORY=owner/repo
INPUT___JOB_WORKFLOW_FILE_PATH=.github/workflows/reusable.yml
OTEL_RESOURCE_ATTRIBUTES=deployment.environment=production
workflow_ref="${INPUT___JOB_WORKFLOW_REF:-$GITHUB_WORKFLOW_REF}"
workflow_sha="${INPUT___JOB_WORKFLOW_SHA:-$GITHUB_WORKFLOW_SHA}"
OTEL_RESOURCE_ATTRIBUTES=github.repository.id="$GITHUB_REPOSITORY_ID",github.repository.name="${GITHUB_REPOSITORY#*/}",github.repository.owner.id="$GITHUB_REPOSITORY_OWNER_ID",github.repository.owner.name="$GITHUB_REPOSITORY_OWNER",github.actions.workflow.ref="$workflow_ref",github.actions.workflow.sha="$workflow_sha",github.actions.workflow.name="$GITHUB_WORKFLOW",github.actions.workflow.caller.ref="$GITHUB_WORKFLOW_REF",github.actions.workflow.caller.sha="$GITHUB_WORKFLOW_SHA",github.actions.workflow.caller.name="$GITHUB_WORKFLOW"${OTEL_RESOURCE_ATTRIBUTES:+,$OTEL_RESOURCE_ATTRIBUTES}
[ -z "${INPUT___JOB_WORKFLOW_REPOSITORY:-}" ] || OTEL_RESOURCE_ATTRIBUTES="$OTEL_RESOURCE_ATTRIBUTES,github.actions.workflow.repository=$INPUT___JOB_WORKFLOW_REPOSITORY"
[ -z "${INPUT___JOB_WORKFLOW_FILE_PATH:-}" ] || OTEL_RESOURCE_ATTRIBUTES="$OTEL_RESOURCE_ATTRIBUTES,github.actions.workflow.file_path=$INPUT___JOB_WORKFLOW_FILE_PATH"
assert_equals "github.repository.id=1,github.repository.name=repo,github.repository.owner.id=2,github.repository.owner.name=owner,github.actions.workflow.ref=owner/repo/.github/workflows/reusable.yml@refs/heads/main,github.actions.workflow.sha=def,github.actions.workflow.name=workflow,github.actions.workflow.caller.ref=owner/repo/.github/workflows/workflow.yml@refs/heads/main,github.actions.workflow.caller.sha=abc,github.actions.workflow.caller.name=workflow,deployment.environment=production,github.actions.workflow.repository=owner/repo,github.actions.workflow.file_path=.github/workflows/reusable.yml" "$OTEL_RESOURCE_ATTRIBUTES"
