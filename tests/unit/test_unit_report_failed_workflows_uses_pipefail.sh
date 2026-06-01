. ./assert.sh

grep -q 'set -o pipefail' ../.github/workflows/report_failed_workflows.yml
assert_equals "0" "$?"
