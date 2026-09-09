. ./assert.sh

# PR numbers comma-joined
assert_equals "42,99" \
  "$(echo '{"pull_requests":[{"number":42},{"number":99}]}' \
     | jq -r '[.pull_requests[]?.number] | map(tostring) | join(",")')"

# no PRs produces empty string
assert_equals "" \
  "$(echo '{"pull_requests":[]}' \
     | jq -r '[.pull_requests[]?.number] | map(tostring) | join(",")')"

# missing pull_requests field handled gracefully
assert_equals "" \
  "$(echo '{}' \
     | jq -r '[.pull_requests[]?.number] | map(tostring) | join(",")')"

# triggering_actor extracted
assert_equals "alice" \
  "$(echo '{"triggering_actor":{"login":"alice"}}' \
     | jq -r '.triggering_actor.login // empty')"

# missing triggering_actor produces empty (not "null")
assert_equals "" \
  "$(echo '{}' \
     | jq -r '.triggering_actor.login // empty')"
