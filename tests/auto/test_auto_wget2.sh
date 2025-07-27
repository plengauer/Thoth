if ! type wget2; then exit 0; fi

set -e
. ./assert.sh

$SHELL auto/wget2.sh http://www.google.com/

span="$(resolve_span '.name == "wget2 -O - http://www.google.com/"')"
assert_equals "wget2 -O - http://www.google.com/" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_equals "0" $(\echo "$span" | jq -r '.attributes."shell.command.exit_code"')
