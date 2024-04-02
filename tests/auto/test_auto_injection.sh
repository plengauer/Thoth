. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

sh auto/fail_no_auto.shell
assert_equals 0 $?
span="$(resolve_span '.resource.attributes."process.command_line" == "sh auto/fail_no_auto.shell"')"
assert_equals "myspan" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
sh auto/fail.shell 42
assert_equals 42 $?
