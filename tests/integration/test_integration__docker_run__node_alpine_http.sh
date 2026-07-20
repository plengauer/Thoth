if ! type docker 1> /dev/null 2> /dev/null || ! type sudo 1> /dev/null 2> /dev/null; then exit 0; fi
. ./assert.sh

server_directory="$(\mktemp -d)"
server_name=test_integration__docker_run__node_alpine_http_server
server_port=18080

cleanup() {
  \sudo docker rm --force "$server_name" 1> /dev/null 2> /dev/null || true
  \rm -rf "$server_directory"
}

trap cleanup EXIT INT TERM

\printf ok > "$server_directory"/index.html
\sudo docker run --detach --rm --network host --name "$server_name" --mount type=bind,src="$server_directory",dst=/srv,readonly busybox httpd -f -p "$server_port" -h /srv 1> /dev/null
\curl --silent --fail --retry 16 --retry-connrefused http://127.0.0.1:"$server_port"/ 1> /dev/null

. /usr/bin/opentelemetry_shell.sh

\cat <<'EOF' | sudo docker run --rm --network host -i node:alpine node -
const http = require('http')
const req = http.get('http://127.0.0.1:18080', (res) => {
  res.resume()
  res.on('end', () => process.exit(0))
})
req.setTimeout(30000, () => req.destroy(new Error('timeout')))
req.on('error', (error) => {
  console.error(error)
  process.exit(1)
})
EOF
assert_equals 0 $?
