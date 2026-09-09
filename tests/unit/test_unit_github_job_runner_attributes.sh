. ./assert.sh

# runner fields present
assert_equals "my-runner-3	my-runners	self-hosted,linux,my-pool" \
  "$(echo '{"runner_name":"my-runner-3","runner_group_name":"my-runners","labels":["self-hosted","linux","my-pool"]}' \
     | jq -r '[(.runner_name // ""), (.runner_group_name // ""), ((.labels // []) | join(","))] | @tsv')"

# null runner fields produce empty strings, not "null"
assert_equals "		" \
  "$(echo '{"runner_name":null,"runner_group_name":null,"labels":[]}' \
     | jq -r '[(.runner_name // ""), (.runner_group_name // ""), ((.labels // []) | join(","))] | @tsv')"

# created_at extracted alongside started_at for queue duration calculation
assert_equals "2024-01-01T10:00:00Z	2024-01-01T10:00:30Z" \
  "$(echo '{"created_at":"2024-01-01T10:00:00Z","started_at":"2024-01-01T10:00:30Z"}' \
     | jq -r '[.created_at, .started_at] | @tsv')"
