. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

echo hello world

span="$(resolve_span '.name == "echo hello world"')"
assert_equals "echo hello world" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals "null" $(\echo "$span" | jq -r '.parent_id')
assert_equals "UNSET" $(\echo "$span" | jq -r '.status.status_code')
assert_equals "echo hello world" "$(\echo "$span" | jq -r '.attributes."shell.command_line"')"
assert_equals "echo" "$(\echo "$span" | jq -r '.attributes."shell.command"')"
assert_equals "0" $(\echo "$span" | jq -r '.attributes."shell.command.exit_code"')

(echo hello world in a subshell)

span="$(resolve_span '.name == "echo hello world in a subshell"')"
assert_equals "echo hello world in a subshell" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals "null" $(\echo "$span" | jq -r '.parent_id')
assert_equals "UNSET" $(\echo "$span" | jq -r '.status.status_code')
assert_equals "echo hello world in a subshell" "$(\echo "$span" | jq -r '.attributes."shell.command_line"')"
assert_equals "echo" "$(\echo "$span" | jq -r '.attributes."shell.command"')"
assert_equals "0" $(\echo "$span" | jq -r '.attributes."shell.command.exit_code"')

echo hello world in a pipe | grep world | cat

span="$(resolve_span '.name == "grep world"')"
assert_equals "grep world" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals "null" $(\echo "$span" | jq -r '.parent_id')
assert_equals "UNSET" $(\echo "$span" | jq -r '.status.status_code')
assert_equals "grep world" "$(\echo "$span" | jq -r '.attributes."shell.command_line"')"
assert_equals "grep" "$(\echo "$span" | jq -r '.attributes."shell.command"')"
assert_equals "0" $(\echo "$span" | jq -r '.attributes."shell.command.exit_code"')

echo first; echo hello world in a command list; echo second

span="$(resolve_span '.name == "echo hello world in a command list"')"
assert_equals "echo hello world in a command list" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals "null" $(\echo "$span" | jq -r '.parent_id')
assert_equals "UNSET" $(\echo "$span" | jq -r '.status.status_code')
assert_equals "echo hello world in a command list" "$(\echo "$span" | jq -r '.attributes."shell.command_line"')"
assert_equals "echo" "$(\echo "$span" | jq -r '.attributes."shell.command"')"
assert_equals "0" $(\echo "$span" | jq -r '.attributes."shell.command.exit_code"')

echo first && echo hello world in a chain && echo second

span="$(resolve_span '.name == "echo hello world in a chain"')"
assert_equals "echo hello world in a chain" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals "null" $(\echo "$span" | jq -r '.parent_id')
assert_equals "UNSET" $(\echo "$span" | jq -r '.status.status_code')
assert_equals "echo hello world in a chain" "$(\echo "$span" | jq -r '.attributes."shell.command_line"')"
assert_equals "echo" "$(\echo "$span" | jq -r '.attributes."shell.command"')"
assert_equals "0" $(\echo "$span" | jq -r '.attributes."shell.command.exit_code"')

if [ ! -f 'FILE_THAT_DOES_NOT_EXIST' ]; then echo hello world in an if; fi

span="$(resolve_span '.name == "echo hello world in an if"')"
assert_equals "echo hello world in an if" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals "null" $(\echo "$span" | jq -r '.parent_id')
assert_equals "UNSET" $(\echo "$span" | jq -r '.status.status_code')
assert_equals "echo hello world in an if" "$(\echo "$span" | jq -r '.attributes."shell.command_line"')"
assert_equals "echo" "$(\echo "$span" | jq -r '.attributes."shell.command"')"
assert_equals "0" $(\echo "$span" | jq -r '.attributes."shell.command.exit_code"')
