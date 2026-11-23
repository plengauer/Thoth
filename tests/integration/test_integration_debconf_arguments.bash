. ./assert.sh

if ! [ -f /usr/share/debconf/confmodule ]; then exit 0; fi

# shellcheck disable=SC2016 # single quotes are intentional, the text is meant to be expanded later by another shell or tool
simple_command='. /usr/share/debconf/confmodule; echo $2 >&2'
command=". /usr/bin/opentelemetry_shell.sh; $simple_command"

script="$(mktemp)"
chmod +x "$script"
echo "$command" > "$script"
assert_equals bar "$(bash "$script" foo bar baz 2>&1 | grep -v 'debconf')"
# assert_equals bar "$(bash -c "$command" bash foo bar baz)" # this does not work with debconf, with and without instrumentation

script="$(mktemp)"
chmod +x "$script"
echo "$simple_command" > "$script"
. /usr/bin/opentelemetry_shell.sh
assert_equals bar "$(bash "$script" foo bar baz 2>&1 | grep -v 'debconf')"
# assert_equals bar "$(bash -c "$simple_command" bash foo bar baz)" # this does not work with debconf, with and without instrumentation
