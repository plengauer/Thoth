set -e
. ./assert.sh

$TEST_SHELL auto/curl_subshell.sh

span="$(resolve_span '.name == "curl http://www.google.com/"')"
assert_equals "curl http://www.google.com/" "$(\echo "$span" | jq -r '.name')"
