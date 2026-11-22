# shellcheck shell=bash
set -e
. ./assert.sh
if ! command -v python3 >/dev/null 2>&1; then exit 0; fi
version="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f -2)"
site_packages="/usr/share/opentelemetry_shell/agent.instrumentation.python/$version/site-packages"
if ! [ -d "$site_packages" ] || ! find "$site_packages" -type f -name '*.so' | grep -q .; then exit 0; fi

dir="$(mktemp -d)"
trap 'rm -rf "$dir"' EXIT
printf '%s\n' '#!/bin/sh' 'echo "library not found"' >"$dir"/ldd
chmod +x "$dir"/ldd
export PATH="$dir:$PATH"
export PYTHONPATH="$site_packages:$dir"
export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE
. otel.sh

result="$(python3 -c 'import os, sys; print("BUNDLED_PATH=" + str(any(p.startswith("/usr/share/opentelemetry_shell/agent.instrumentation.python/") for p in sys.path))); print("USER_PATH=" + str(os.environ["PYTHONPATH"].split(":")[0] in sys.path))')"
assert_equals 'BUNDLED_PATH=False
USER_PATH=True' "$result"
