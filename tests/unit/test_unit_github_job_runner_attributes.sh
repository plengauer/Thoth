. ./assert.sh

# Verify that the jq extraction used in actions/instrument/workflow/main.sh
# correctly pulls created_at, runner_name, runner_group_name, and labels
# from the GitHub Jobs API response.

jobs_json="$(mktemp)"
cat >"$jobs_json" <<'EOF'
[
  {
    "id": 123,
    "name": "build",
    "conclusion": "success",
    "created_at": "2024-01-01T10:00:00Z",
    "started_at": "2024-01-01T10:00:30Z",
    "completed_at": "2024-01-01T10:05:00Z",
    "runner_name": "sg-migrate-vmss_3",
    "runner_group_name": "sg-migrate",
    "labels": ["self-hosted", "windows", "sg-migrate-vmss"]
  },
  {
    "id": 456,
    "name": "test",
    "conclusion": "failure",
    "created_at": "2024-01-01T10:00:00Z",
    "started_at": "2024-01-01T10:01:00Z",
    "completed_at": "2024-01-01T10:03:00Z",
    "runner_name": null,
    "runner_group_name": null,
    "labels": []
  }
]
EOF

# Test: full fields extracted correctly for a runner with all fields populated
result="$(jq <"$jobs_json" -r '.[] | select(.id == 123) | [.id, .conclusion, .created_at, .started_at, .completed_at, .name, (.runner_name // ""), (.runner_group_name // ""), ((.labels // []) | join(","))] | @tsv')"
job_id="$(echo "$result" | cut -f1)"
job_created_at="$(echo "$result" | cut -f3)"
job_runner_name="$(echo "$result" | cut -f7)"
job_runner_group_name="$(echo "$result" | cut -f8)"
job_runner_labels="$(echo "$result" | cut -f9)"

assert_equals "123" "$job_id"
assert_equals "2024-01-01T10:00:00Z" "$job_created_at"
assert_equals "sg-migrate-vmss_3" "$job_runner_name"
assert_equals "sg-migrate" "$job_runner_group_name"
assert_equals "self-hosted,windows,sg-migrate-vmss" "$job_runner_labels"

# Test: null runner fields produce empty strings (not the literal "null")
result="$(jq <"$jobs_json" -r '.[] | select(.id == 456) | [.id, .conclusion, .created_at, .started_at, .completed_at, .name, (.runner_name // ""), (.runner_group_name // ""), ((.labels // []) | join(","))] | @tsv')"
job_runner_name="$(echo "$result" | cut -f7)"
job_runner_group_name="$(echo "$result" | cut -f8)"
job_runner_labels="$(echo "$result" | cut -f9)"

assert_equals "" "$job_runner_name"
assert_equals "" "$job_runner_group_name"
assert_equals "" "$job_runner_labels"

rm "$jobs_json"
