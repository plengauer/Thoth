if ! type sudo; then exit 0; fi
. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

sudo echo hello world
assert_equals 0 $?
span="$(resolve_span '.name == "sudo echo hello world"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo hello world"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
assert_equals "sudo echo hello world" "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

# security policy doesnt allow this
# sudo -D / echo hello world 1
# assert_equals 0 $?

# security policy doesnt allow this
# mkdir 'dir with blanks'
# sudo -D 'dir with blanks' echo hello world 2
# assert_equals 0 $?
