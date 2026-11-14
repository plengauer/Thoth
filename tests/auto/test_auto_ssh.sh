# shellcheck shell=bash
if ! type ssh || ! type ssh-keygen || ! [ -x /usr/sbin/sshd ]; then exit 0; fi

set -e
. ./assert.sh

dir="$(\mktemp -d)"
trap 'kill "$(\cat "$dir/sshd.pid")" 2>/dev/null || true' EXIT
\ssh-keygen -q -t ed25519 -N '' -f "$dir/host_key"
\ssh-keygen -q -t ed25519 -N '' -f "$dir/id"
\cp "$dir/id.pub" "$dir/authorized_keys"
\mkdir -p /run/sshd
port=$((20000 + $$ % 20000))
/usr/sbin/sshd -f /dev/null -p "$port" -o ListenAddress=127.0.0.1 -o HostKey="$dir/host_key" -o AuthorizedKeysFile="$dir/authorized_keys" -o PidFile="$dir/sshd.pid" -o AcceptEnv='TRACEPARENT TRACESTATE' -o StrictModes=no -o UsePAM=no

$TEST_SHELL auto/ssh.sh -i "$dir/id" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p "$port" 127.0.0.1 'echo "$TRACEPARENT"' >"$dir/stdout"

command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | startswith("ssh ")) and (.name | contains("TRACEPARENT"))')"
assert_equals "0" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"
assert_equals "00-$(\echo "$command_span" | jq -r '.context.trace_id | ltrimstr("0x")')-$(\echo "$command_span" | jq -r '.context.span_id | ltrimstr("0x")')" "$(\cat "$dir/stdout" | \cut -d - -f 1-3)"

span="$(resolve_span '.name == "echo" and .kind == "SpanKind.CLIENT"')"
assert_equals "$(\echo "$command_span" | jq -r '.context.span_id')" "$(\echo "$span" | jq -r '.parent_id')"
assert_equals "UNSET" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "tcp" "$(\echo "$span" | jq -r '.attributes."network.transport"')"
assert_equals "ssh" "$(\echo "$span" | jq -r '.attributes."network.protocol.name"')"
assert_equals "2.0" "$(\echo "$span" | jq -r '.attributes."network.protocol.version"')"
assert_equals "127.0.0.1" "$(\echo "$span" | jq -r '.attributes."network.peer.address"')"
assert_equals "$port" "$(\echo "$span" | jq -r '.attributes."network.peer.port"')"
assert_equals "127.0.0.1" "$(\echo "$span" | jq -r '.attributes."server.address"')"
assert_equals "$port" "$(\echo "$span" | jq -r '.attributes."server.port"')"
assert_equals "ssh://127.0.0.1:$port" "$(\echo "$span" | jq -r '.attributes."url.full"')"
assert_equals "ssh" "$(\echo "$span" | jq -r '.attributes."url.scheme"')"
assert_not_equals "null" "$(\echo "$span" | jq -r '.attributes."user_agent.original"')"
assert_not_equals "null" "$(\echo "$span" | jq -r '.attributes."ssh.server.version"')"
assert_equals "$(\id -un)" "$(\echo "$span" | jq -r '.attributes."ssh.user"')"
assert_equals "publickey" "$(\echo "$span" | jq -r '.attributes."ssh.auth.method"')"
assert_equals "echo" "$(\echo "$span" | jq -r '.attributes."ssh.command"')"
assert_equals "0" "$(\echo "$span" | jq -r '.attributes."ssh.exit_status"')"
assert_not_equals "null" "$(\echo "$span" | jq -r '.attributes."ssh.bytes.sent"')"
assert_not_equals "null" "$(\echo "$span" | jq -r '.attributes."ssh.bytes.received"')"

$TEST_SHELL auto/ssh.sh -i "$dir/id" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p "$port" 127.0.0.1 'exit 3' || true

command_span="$(resolve_span '.kind == "SpanKind.INTERNAL" and (.name | startswith("ssh ")) and (.name | contains("exit 3"))')"
assert_equals "3" "$(\echo "$command_span" | jq -r '.attributes."shell.command.exit_code"')"

span="$(resolve_span '.name == "exit" and .kind == "SpanKind.CLIENT"')"
assert_equals "ERROR" "$(\echo "$span" | jq -r '.status.status_code')"
assert_equals "3" "$(\echo "$span" | jq -r '.attributes."ssh.exit_status"')"
