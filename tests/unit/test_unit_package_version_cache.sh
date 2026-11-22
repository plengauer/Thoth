# shellcheck shell=bash
. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

cache_calls="$(\mktemp)"
export cache_calls
trap '\rm -f "$cache_calls"' EXIT

_otel_resolve_package_version() {
  \echo "$1" >>"$cache_calls"
  \printf '%s\n' 'version $(false)'
}

unset OTEL_SHELL_PACKAGE_VERSION_CACHE_package_name
unset OTEL_SHELL_PACKAGE_VERSION_CACHE_package_name_1
_otel_package_version package-name >/dev/null
_otel_package_version package.name.1 >/dev/null
assert_equals 'version $(false)' "$(_otel_package_version package-name)"
assert_equals 'version $(false)' "$(_otel_package_version package.name.1)"
assert_equals 2 "$(\wc -l <"$cache_calls" | \tr -d ' ')"

# shellcheck disable=SC2086
${TEST_SHELL:-sh} -f -u -c '
  . /usr/bin/opentelemetry_shell_api.sh
  _otel_resolve_package_version() { exit 1; }
  [ "$(_otel_package_version package-name)" = "version \$(false)" ] &&
    [ "$(_otel_package_version package.name.1)" = "version \$(false)" ]
'
assert_equals 0 "$?"
