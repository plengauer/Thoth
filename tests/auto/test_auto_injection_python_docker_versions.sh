if ! type docker 1> /dev/null 2> /dev/null; then exit 0; fi
if ! [ -f /usr/share/opentelemetry_shell/agent.instrumentation.python/python_site_packages.tar.xz ]; then exit 0; fi

. ./assert.sh

archived_versions="$(
  tar -tJf /usr/share/opentelemetry_shell/agent.instrumentation.python/python_site_packages.tar.xz \
    | cut -d / -f 2 \
    | grep '^3\.' \
    | sort -t. -k2 -n -u
)"
[ -n "$archived_versions" ] || exit 0

missing_versions="$(
  printf '%s\n' "$archived_versions" | while read -r version; do
    [ -d /usr/share/opentelemetry_shell/agent.instrumentation.python/"$version" ] || printf '%s\n' "$version"
  done
)"

assert_equals "" "$missing_versions"
