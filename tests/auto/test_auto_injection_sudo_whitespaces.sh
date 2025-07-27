if ! type sudo; then exit 0; fi
. ./assert.sh
export OTEL_SERVICE_NAME="Test Service with Whitespaces"
. /usr/bin/opentelemetry_shell.sh
sudo echo hello world
assert_equals 0 $?
