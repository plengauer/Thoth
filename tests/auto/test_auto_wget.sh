set -e
. ./assert.sh

if wget --version | grep -q Wget2; then exit 0; fi

$SHELL auto/wget.sh http://www.google.com/

span="$(resolve_span '.name == "wget -O - http://www.google.com/"')"
assert_equals "wget -O - http://www.google.com/" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_equals "0" $(\echo "$span" | jq -r '.attributes."shell.command.exit_code"')
span="$(resolve_span '.name == "GET"')"
assert_equals "SpanKind.CLIENT" $(\echo "$span" | jq -r '.kind')
assert_not_equals "null" $(\echo "$span" | jq -r '.parent_id')
assert_equals "UNSET" $(\echo "$span" | jq -r '.status.status_code')
assert_equals "http" "$(\echo "$span" | jq -r '.attributes."network.protocol.name"')"
assert_equals "tcp" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "http://www.google.com/" "$(\echo "$span" | jq -r '.attributes."url.full"')"
assert_equals "http" "$(\echo "$span" | jq -r '.attributes."url.scheme"')"
assert_equals "/" "$(\echo "$span" | jq -r '.attributes."url.path"')"
assert_equals null "$(\echo "$span" | jq -r '.attributes."url.query"')"
assert_equals "wget" "$(\echo "$span" | jq -r '.attributes."user_agent.original"')"
assert_equals "200" "$(\echo "$span" | jq -r '.attributes."http.response.status_code"')"
assert_not_equals null "$(\echo "$span" | jq -r '.attributes."http.response.header.content-type"')"
assert_not_equals null "$(\echo "$span" | jq -r '.attributes."network.peer.address"')"
assert_not_equals null "$(\echo "$span" | jq -r '.attributes."network.peer.port"')"

$SHELL auto/wget.sh https://www.google.de/index.html https://www.google.de/index || true

span="$(resolve_span '.attributes."url.path" == "/index.html"')"
assert_equals "GET" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.CLIENT" $(\echo "$span" | jq -r '.kind')
assert_not_equals "null" $(\echo "$span" | jq -r '.parent_id')
assert_equals "UNSET" $(\echo "$span" | jq -r '.status.status_code')
assert_equals "https" "$(\echo "$span" | jq -r '.attributes."network.protocol.name"')"
assert_equals "tcp" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "https://www.google.de/index.html" "$(\echo "$span" | jq -r '.attributes."url.full"')"
assert_equals "https" "$(\echo "$span" | jq -r '.attributes."url.scheme"')"
assert_equals "/index.html" "$(\echo "$span" | jq -r '.attributes."url.path"')"
assert_equals null "$(\echo "$span" | jq -r '.attributes."url.query"')"
assert_equals "wget" "$(\echo "$span" | jq -r '.attributes."user_agent.original"')"
assert_equals "200" "$(\echo "$span" | jq -r '.attributes."http.response.status_code"')"
assert_not_equals null "$(\echo "$span" | jq -r '.attributes."http.response.header.content-type"')"
assert_not_equals null "$(\echo "$span" | jq -r '.attributes."network.peer.address"')"
assert_not_equals null "$(\echo "$span" | jq -r '.attributes."network.peer.port"')"

span="$(resolve_span '.attributes."url.path" == "/index"')"
assert_equals "GET" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.CLIENT" $(\echo "$span" | jq -r '.kind')
assert_not_equals "null" $(\echo "$span" | jq -r '.parent_id')
assert_equals "ERROR" $(\echo "$span" | jq -r '.status.status_code')
assert_equals "https" "$(\echo "$span" | jq -r '.attributes."network.protocol.name"')"
assert_equals "tcp" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "https://www.google.de/index" "$(\echo "$span" | jq -r '.attributes."url.full"')"
assert_equals "https" "$(\echo "$span" | jq -r '.attributes."url.scheme"')"
assert_equals "/index" "$(\echo "$span" | jq -r '.attributes."url.path"')"
assert_equals null "$(\echo "$span" | jq -r '.attributes."url.query"')"
assert_equals "wget" "$(\echo "$span" | jq -r '.attributes."user_agent.original"')"
assert_equals "404" "$(\echo "$span" | jq -r '.attributes."http.response.status_code"')"
assert_not_equals null "$(\echo "$span" | jq -r '.attributes."network.peer.address"')"
assert_not_equals null "$(\echo "$span" | jq -r '.attributes."network.peer.port"')"
