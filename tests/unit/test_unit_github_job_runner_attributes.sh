. ./assert.sh

# runner_name and runner_group_name re-looked up from JSON by job id
assert_equals "my-runner-3" \
  "$(echo '{"id":42,"runner_name":"my-runner-3","runner_group_name":"my-runners"}' \
     | jq -r '. | select(.id == 42) | .runner_name // empty')"

assert_equals "my-runners" \
  "$(echo '{"id":42,"runner_name":"my-runner-3","runner_group_name":"my-runners"}' \
     | jq -r '. | select(.id == 42) | .runner_group_name // empty')"

# null runner fields produce empty string (not "null")
assert_equals "" \
  "$(echo '{"id":42,"runner_name":null,"runner_group_name":null}' \
     | jq -r '. | select(.id == 42) | .runner_name // empty')"

# labels emitted one per line for +string[1] array accumulation
assert_equals "self-hosted
linux
my-pool" \
  "$(echo '{"id":42,"labels":["self-hosted","linux","my-pool"]}' \
     | jq -r '. | select(.id == 42) | .labels[]? // empty')"

# empty labels produce no output
assert_equals "" \
  "$(echo '{"id":42,"labels":[]}' \
     | jq -r '. | select(.id == 42) | .labels[]? // empty')"

# created_at extracted alongside started_at for queue duration calculation
assert_equals "2024-01-01T10:00:00Z	2024-01-01T10:00:30Z" \
  "$(echo '{"created_at":"2024-01-01T10:00:00Z","started_at":"2024-01-01T10:00:30Z"}' \
     | jq -r '[.created_at, .started_at] | @tsv')"
