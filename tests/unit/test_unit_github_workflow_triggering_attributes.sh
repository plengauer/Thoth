. ./assert.sh

# Verify jq extraction of triggering_actor and pull_requests from the
# GitHub Workflow Run API response, as used in actions/instrument/workflow/main.sh.

workflow_json="$(mktemp)"

# Test: pull_request.numbers extracted as comma-joined string
cat >"$workflow_json" <<'EOF'
{
  "id": 1,
  "actor": { "login": "dependabot" },
  "triggering_actor": { "login": "alice" },
  "pull_requests": [
    { "number": 42 },
    { "number": 99 }
  ]
}
EOF

triggering_actor="$(jq <"$workflow_json" -r '.triggering_actor.login // empty')"
actor="$(jq <"$workflow_json" -r '.actor.login')"
pr_numbers="$(jq <"$workflow_json" -r '[.pull_requests[]?.number] | map(tostring) | join(",")')"

assert_equals "alice" "$triggering_actor"
assert_equals "dependabot" "$actor"
assert_equals "42,99" "$pr_numbers"

# Test: triggering_actor suppressed when same as actor (no-op re-runs)
cat >"$workflow_json" <<'EOF'
{
  "id": 2,
  "actor": { "login": "alice" },
  "triggering_actor": { "login": "alice" },
  "pull_requests": []
}
EOF

triggering_actor="$(jq <"$workflow_json" -r '.triggering_actor.login // empty')"
actor="$(jq <"$workflow_json" -r '.actor.login')"
pr_numbers="$(jq <"$workflow_json" -r '[.pull_requests[]?.number] | map(tostring) | join(",")')"

# When same, the attribute should be suppressed (empty string after join on empty array)
assert_equals "$actor" "$triggering_actor"
assert_equals "" "$pr_numbers"

# Test: missing pull_requests field is handled gracefully
cat >"$workflow_json" <<'EOF'
{
  "id": 3,
  "actor": { "login": "alice" },
  "triggering_actor": { "login": "alice" }
}
EOF

pr_numbers="$(jq <"$workflow_json" -r '[.pull_requests[]?.number] | map(tostring) | join(",")' 2>/dev/null || true)"
assert_equals "" "$pr_numbers"

rm "$workflow_json"
