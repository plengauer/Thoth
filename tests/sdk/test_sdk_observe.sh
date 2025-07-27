. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

if [ "$SHELL" = "bash" ]; then
  shopt -s expand_aliases
fi
alias my_echo=echo
my_func() { echo "$*"; }

otel_init
otel_observe my_echo hello world alias
assert_equals 0 $?
otel_observe my_func hello world function
assert_equals 0 $?
otel_observe echo hello world builtin
assert_equals 0 $?
otel_observe /bin/echo hello world path
assert_equals 0 $?
otel_observe cat file > /dev/null
assert_not_equals 0 $?
otel_shutdown

span="$(resolve_span '.name == "my_echo hello world alias"')"
assert_equals "SpanKind.INTERNAL" $(echo "$span" | jq -r '.kind')
assert_equals "null" $(echo "$span" | jq -r '.parent_id')
assert_equals "UNSET" $(echo "$span" | jq -r '.status.status_code')
assert_equals "alias" "$(echo "$span" | jq -r '.attributes."shell.command.type"')"
assert_equals "my_echo hello world alias" "$(echo "$span" | jq -r '.attributes."shell.command_line"')"
assert_equals "my_echo" "$(echo "$span" | jq -r '.attributes."shell.command"')"
assert_equals "null" "$(echo "$span" | jq -r '.attributes."subprocess.executable.name"')"
assert_equals "null" "$(echo "$span" | jq -r '.attributes."subprocess.executable.path"')"
assert_equals "0" $(echo "$span" | jq -r '.attributes."shell.command.exit_code"')

span="$(resolve_span '.name == "my_func hello world function"')"
assert_equals "SpanKind.INTERNAL" $(echo "$span" | jq -r '.kind')
assert_equals "null" $(echo "$span" | jq -r '.parent_id')
assert_equals "UNSET" $(echo "$span" | jq -r '.status.status_code')
assert_equals "function" "$(echo "$span" | jq -r '.attributes."shell.command.type"')"
assert_equals "my_func hello world function" "$(echo "$span" | jq -r '.attributes."shell.command_line"')"
assert_equals "my_func" "$(echo "$span" | jq -r '.attributes."shell.command"')"
assert_equals "null" "$(echo "$span" | jq -r '.attributes."subprocess.executable.name"')"
assert_equals "null" "$(echo "$span" | jq -r '.attributes."subprocess.executable.path"')"
assert_equals "0" $(echo "$span" | jq -r '.attributes."shell.command.exit_code"')

span="$(resolve_span '.name == "echo hello world builtin"')"
assert_equals "SpanKind.INTERNAL" $(echo "$span" | jq -r '.kind')
assert_equals "null" $(echo "$span" | jq -r '.parent_id')
assert_equals "UNSET" $(echo "$span" | jq -r '.status.status_code')
assert_equals "builtin" "$(echo "$span" | jq -r '.attributes."shell.command.type"')"
assert_equals "echo hello world builtin" "$(echo "$span" | jq -r '.attributes."shell.command_line"')"
assert_equals "echo" "$(echo "$span" | jq -r '.attributes."shell.command"')"
assert_equals "null" "$(echo "$span" | jq -r '.attributes."subprocess.executable.name"')"
assert_equals "null" "$(echo "$span" | jq -r '.attributes."subprocess.executable.path"')"
assert_equals "0" $(echo "$span" | jq -r '.attributes."shell.command.exit_code"')

span="$(resolve_span '.name == "/bin/echo hello world path"')"
assert_equals "SpanKind.INTERNAL" $(echo "$span" | jq -r '.kind')
assert_equals "null" $(echo "$span" | jq -r '.parent_id')
assert_equals "UNSET" $(echo "$span" | jq -r '.status.status_code')
assert_equals "file" "$(echo "$span" | jq -r '.attributes."shell.command.type"')"
assert_equals "/bin/echo hello world path" "$(echo "$span" | jq -r '.attributes."shell.command_line"')"
assert_equals "/bin/echo" "$(echo "$span" | jq -r '.attributes."shell.command"')"
assert_equals "echo" "$(echo "$span" | jq -r '.attributes."subprocess.executable.name"')"
assert_equals "/bin/echo" "$(echo "$span" | jq -r '.attributes."subprocess.executable.path"')"
assert_equals "0" $(echo "$span" | jq -r '.attributes."shell.command.exit_code"')

span="$(resolve_span '.name == "cat file"')"
assert_equals "SpanKind.INTERNAL" $(echo "$span" | jq -r '.kind')
assert_equals "null" $(echo "$span" | jq -r '.parent_id')
assert_equals "ERROR" $(echo "$span" | jq -r '.status.status_code')
assert_equals "file" "$(echo "$span" | jq -r '.attributes."shell.command.type"')"
assert_equals "cat file" "$(echo "$span" | jq -r '.attributes."shell.command_line"')"
assert_equals "cat" "$(echo "$span" | jq -r '.attributes."shell.command"')"
assert_equals "cat" "$(echo "$span" | jq -r '.attributes."subprocess.executable.name"')"
assert_equals "$(which cat | rev | cut -d ' ' -f 1 | rev)" "$(echo "$span" | jq -r '.attributes."subprocess.executable.path"')"
assert_not_equals "0" $(echo "$span" | jq -r '.attributes."shell.command.exit_code"')
