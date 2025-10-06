. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

file=$(mktemp)
echo "hello world 0" >> $file
echo "hello world 0" >> $file
actual="$(cat $file | xargs)"
assert_equals 'hello world 0 hello world 0' "$actual"

printf '%s' 'hello world 1' | xargs echo
span="$(resolve_span '.name == "xargs echo"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo hello world 1"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
assert_equals "xargs echo" "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

printf '%s' 'hello world 2' | xargs -I '{}' echo '{}'
span="$(resolve_span '.name == "xargs -I '{}' echo '{}'"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo hello world 2"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
assert_equals "xargs -I {} echo {}" "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

printf '%s' 'hello world 3' | xargs -i'{}' echo '{}'
span="$(resolve_span '.name == "xargs -i'{}' echo '{}'"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo hello world 3"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
assert_equals "xargs -i{} echo {}" "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

if xargs --help | grep -F -- --replace; then
  printf '%s' 'hello world 4' | xargs --replace='{}' echo '{}'
  span="$(resolve_span '.name == "xargs --replace='{}' echo '{}'"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "echo hello world 4"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  assert_equals "xargs --replace={} echo {}" "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"
fi

assert_equals 'hello
world
5' "$(echo hello world 5 | xargs printf '%s\n%s\n%s')"

text='foo;bar'
assert_equals "$text" "$(echo "$text" | xargs echo)"
