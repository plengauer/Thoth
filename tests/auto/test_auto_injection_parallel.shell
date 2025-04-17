if ! type parallel; then exit 0; fi
. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

if type dpkg && dpkg -s moreutils; then
  parallel.moreutils echo -- a1 a2 a3
  span="$(resolve_span '.name == "parallel.moreutils echo -- a1 a2 a3"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "echo a1"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "echo a2"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "echo a3"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  
  parallel.moreutils -i echo {} i4 -- i1 i2 i3
  span="$(resolve_span '.name == "parallel.moreutils -i echo {} i4 -- i1 i2 i3"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "echo i1 i4"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "echo i2 i4"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "echo i3 i4"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  
  parallel.moreutils -- 'echo b1' 'echo b2' 'echo b3'
  span="$(resolve_span '.name == "parallel.moreutils -- echo b1 echo b2 echo b3"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "echo b1"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "echo b2"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "echo b3"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
fi

shebang="$(alias parallel | grep -q env && echo /usr/bin/env perl || echo /usr/bin/perl)"

parallel echo ::: c1 c2 c3
span="$(resolve_span '.name | endswith("/parallel echo ::: c1 c2 c3")')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo c1"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo c2"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo c3"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"

{ printf '%s\n' d1; printf '%s\n' d2; printf '%s\n' d3; } | parallel echo
span="$(resolve_span '.name | endswith("/parallel echo")')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo d1"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo d2"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
span="$(resolve_span '.name == "echo d3"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"

if [ "$SHELL" = bash ]; then
  my_echo() { echo "$1"; }
  export -f my_echo
  parallel my_echo ::: e1 e2 e3
  span="$(resolve_span '.name | endswith("/parallel my_echo ::: e1 e2 e3")')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "echo e1"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "echo e2"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "echo e3"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"

  my_wget() { wget -O - "$1"; }
  export -f my_wget
  parallel my_wget ::: http://www.google.at
  span="$(resolve_span '.name | endswith("/parallel my_wget ::: http://www.google.at")')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
  span="$(resolve_span '.name == "wget -O - http://www.google.at"')"
  assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | jq -r '.kind')"
else
  true
fi
