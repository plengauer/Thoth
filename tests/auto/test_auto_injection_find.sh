. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

n=5

directory="$(mktemp -d)"
mv "$directory" "$directory"". .dir"
directory="$directory"". .dir"
chmod +x "$directory"
for i in $(seq 1 $n); do \touch "$directory/$i"; done
expected="$(\find "$directory" -exec echo {} ';')"
actual="$(find "$directory" -exec echo {} ';')"
assert_equals "$expected" "$actual"
for i in $(seq 1 $n); do
  span="$(resolve_span ".name == \"echo $directory/$i\"")"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | \jq -r '.kind')"
  assert_equals "find $directory -exec echo {} ;" "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"
done

directory="$(mktemp -d)"
mv "$directory" "$directory"". .dir"
directory="$directory"". .dir"
chmod +x "$directory"
for i in $(seq 1 $n); do \touch "$directory/$i"; done
expected="$(\find "$directory" -exec echo {} '+' | \tr '\n' ' ')"
actual="$(find "$directory" -exec echo {} '+' | \tr '\n' ' ')"
assert_equals "$expected" "$actual"

if find --help | grep -- execdir; then
  directory="$(mktemp -d)"
  mv "$directory" "$directory"". .dir"
  directory="$directory"". .dir"
  chmod +x "$directory"
  for i in $(seq 1 $n); do \touch "$directory/$i"; done
  expected="$(\find "$directory" -execdir echo {} ';')"
  actual="$(find "$directory" -execdir echo {} ';')"
  assert_equals "$expected" "$actual"
  for i in $(seq 1 $n); do
    span="$(resolve_span ".name == \"echo ./$i\"")"
    assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | \jq -r '.kind')"
    assert_equals "find $directory -execdir echo {} ;" "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"
  done
  
  directory="$(mktemp -d)"
  mv "$directory" "$directory"". .dir"
  directory="$directory"". .dir"
  chmod +x "$directory"
  for i in $(seq 1 $n); do \touch "$directory/$i"; done
  expected="$(\find "$directory" -execdir echo {} '+' | \tr '\n' ' ')"
  actual="$(find "$directory" -execdir echo {} '+' | \tr '\n' ' ')"
  assert_equals "$expected" "$actual"
fi

if which busybox; then
  touch /tmp/busybox_find_test.txt
  busybox find /tmp -iname '*.txt' -exec echo {} ';'
  resolve_span '.name == "busybox find /tmp -iname *.txt -exec echo {} ;"'
  resolve_span '.name == "find /tmp -iname *.txt -exec echo {} ;"'
  resolve_span '.name == "echo /tmp/busybox_find_test.txt"'
fi
