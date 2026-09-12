. ./assert.sh

# PR numbers emitted one per line for +string[1] array accumulation
assert_equals "42
99" \
  "$(echo '{"pull_requests":[{"number":42},{"number":99}]}' \
     | jq -r '.pull_requests[]?.number | tostring')"

# no PRs produces no output
assert_equals "" \
  "$(echo '{"pull_requests":[]}' \
     | jq -r '.pull_requests[]?.number | tostring')"

# missing pull_requests field handled gracefully
assert_equals "" \
  "$(echo '{}' \
     | jq -r '.pull_requests[]?.number | tostring')"

# triggering_actor extracted
assert_equals "alice" \
  "$(echo '{"triggering_actor":{"login":"alice"}}' \
     | jq -r '.triggering_actor.login // empty')"

# missing triggering_actor produces empty (not "null")
assert_equals "" \
  "$(echo '{}' \
     | jq -r '.triggering_actor.login // empty')"
