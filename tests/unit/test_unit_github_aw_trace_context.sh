. ./assert.sh

TRACEPARENT=00-11111111111111111111111111111111-2222222222222222-01
GITHUB_ACTIONS=true
GITHUB_ACTION=github/gh-aw-actions/setup
INPUT_TRACE_ID=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
INPUT_PARENT_SPAN_ID=bbbbbbbbbbbbbbbb
. ../src/usr/share/opentelemetry_shell/agent.instrumentation.github.aw.sh

assert_equals 11111111111111111111111111111111 "$INPUT_TRACE_ID"
assert_equals 2222222222222222 "$INPUT_PARENT_SPAN_ID"

TRACEPARENT=00-33333333333333333333333333333333-4444444444444444-01
GITHUB_ACTION=github/gh-aw-actions/execute
GITHUB_AW_OTEL_TRACE_ID=cccccccccccccccccccccccccccccccc
GITHUB_AW_OTEL_PARENT_SPAN_ID=dddddddddddddddd
. ../src/usr/share/opentelemetry_shell/agent.instrumentation.github.aw.sh

assert_equals 33333333333333333333333333333333 "$GITHUB_AW_OTEL_TRACE_ID"
assert_equals 4444444444444444 "$GITHUB_AW_OTEL_PARENT_SPAN_ID"
