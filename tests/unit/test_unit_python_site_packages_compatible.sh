# shellcheck shell=bash
set -e
. ./assert.sh

_otel_alias_prepend() { :; }
. /usr/share/opentelemetry_shell/agent.instrumentation.python.sh

dir="$(mktemp -d)"
trap 'rm -rf "$dir"' EXIT

assert_equals 0 "$(_otel_python_site_packages_compatible "$dir" && echo 0 || echo 1)"
assert_equals 1 "$(_otel_python_site_packages_compatible "$dir"/missing 2>/dev/null && echo 0 || echo 1)"
if \ldd /bin/sh >/dev/null 2>&1; then
  cp /bin/sh "$dir"/'compatible library.so'
  ln -s 'compatible library.so' "$dir"/link.so
  assert_equals 0 "$(_otel_python_site_packages_compatible "$dir" && echo 0 || echo 1)"
  rm "$dir"/link.so
fi

printf '%s\n' 'not a shared library' >"$dir"/incompatible.so
assert_equals 1 "$(_otel_python_site_packages_compatible "$dir" && echo 0 || echo 1)"
rm "$dir"/incompatible.so
ln -s missing "$dir"/broken.so
assert_equals 1 "$(_otel_python_site_packages_compatible "$dir" && echo 0 || echo 1)"
rm "$dir"/broken.so

# only run if there is a compiler that can actually link shared libraries (e.g. alpine ships gcc without the libc development files)
if command -v cc >/dev/null 2>&1 && printf '%s\n' 'void probe(void) {}' | cc -shared -fPIC -x c - -o "$dir"/probe.so 2>/dev/null; then
  rm -f "$dir"/probe.so
  printf '%s\n' 'void dependency(void) {}' | cc -shared -fPIC -x c - -o "$dir"/libdependency.so
  printf '%s\n' 'void dependency(void); void call_dependency(void) { dependency(); }' | cc -shared -fPIC -x c - -L"$dir" -ldependency -Wl,-rpath,"$dir" -o "$dir"/dependent.so
  assert_equals 0 "$(_otel_python_site_packages_compatible "$dir" && echo 0 || echo 1)"
  rm "$dir"/libdependency.so
  assert_equals 1 "$(_otel_python_site_packages_compatible "$dir" && echo 0 || echo 1)"
fi
