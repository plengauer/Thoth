set -e
. ./assert.sh

if ! type python3 1> /dev/null 2> /dev/null; then exit 0; fi

tmp_dir="$(mktemp -d)"
\printf '%s\n' hello > "$tmp_dir"/file
port=38080
python3 -m http.server "$port" --bind 127.0.0.1 --directory "$tmp_dir" 1> /dev/null 2> /dev/null &
server_pid="$!"
trap 'kill "$server_pid" 1> /dev/null 2> /dev/null || true' EXIT
\sleep 1

. /usr/bin/opentelemetry_shell.sh
old_ld_preload="${LD_PRELOAD:-}"
url=http://127.0.0.1:"$port"/file

curl -fsSL "$url" 1> /dev/null
assert_equals "$old_ld_preload" "${LD_PRELOAD:-}"

if ! wget --version 2> /dev/null | grep -q Wget2; then
  wget -q -O - "$url" 1> /dev/null
  assert_equals "$old_ld_preload" "${LD_PRELOAD:-}"
fi
