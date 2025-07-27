. ./assert.sh
. /usr/bin/opentelemetry_shell.sh
alias

if [ -n "$(alias | grep ech | grep cho)" ]; then printf '%s\n' "e-cho has been instrumented"; exit 1; fi
. auto/count_fail_no_auto.sh
alias
if [ -z "$(alias | grep ech | grep cho)" ]; then printf '%s\n' "e-cho has not been instrumented"; exit 1; fi

if [ "$(alias | wc -l)" -gt "100" ]; then
  printf '%s\n' "too many instrumentations"
  exit 1
fi

if [ -n "$(alias alias | grep otel_observe)" ] || [ -n "$(alias unalias | grep otel_observe)" ] || [ -n "$(alias . | grep otel_observe)" ]; then
  printf '%s\n' "aliased or unalias or . has been instrumented"
  exit 1
fi

file=$(mktemp)
$SHELL -c '. /usr/bin/opentelemetry_shell.sh
alias' | sed 's/^alias //g' | cut -d= -f1 > $file
assert_equals "" "$(cat $file | grep '^OTEL_')"
assert_equals "" "$(cat $file | grep '^_otel_')"
assert_equals "" "$(cat $file | grep '^otel_')"

exit 0
