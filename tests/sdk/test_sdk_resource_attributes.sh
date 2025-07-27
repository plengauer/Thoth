. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

export OTEL_SERVICE_NAME=TEST

otel_init
span_id=$(otel_span_start INTERNAL myspan)
otel_span_end $span_id
otel_shutdown

span="$(resolve_span)"
assert_equals "shell" $(echo "$span" | jq -r '.resource.attributes."telemetry.sdk.language"')
assert_equals "opentelemetry" $(echo "$span" | jq -r '.resource.attributes."telemetry.sdk.name"')
assert_not_equals "null" $(echo "$span" | jq -r '.resource.attributes."telemetry.sdk.version"')
assert_not_equals "null" $(echo "$span" | jq -r '.resource.attributes."process.pid"')
if  [ "$SHELL" = "sh" ] || [ "$SHELL" = "ash" ]; then
  : # we dont know what sh defaults to, and ash sometimes is dash (on debian systems) but also sometimes just ash
elif  [ "$SHELL" = "busybox sh" ]; then
  assert_equals "busybox" $(echo "$span" | jq -r '.resource.attributes."process.executable.name"')
else
  assert_equals "$SHELL" $(echo "$span" | jq -r '.resource.attributes."process.executable.name"')
fi
assert_not_equals "null" $(echo "$span" | jq -r '.resource.attributes."process.executable.path"')
assert_not_equals "null" $(echo "$span" | jq -r '.resource.attributes."process.command_line"')
assert_not_equals "null" $(echo "$span" | jq -r '.resource.attributes."process.command"')
assert_not_equals "null" $(echo "$span" | jq -r '.resource.attributes."process.owner"')
if [ "$SHELL" = "sh" ] || [ "$SHELL" = "ash" ]; then
  : # we dont know what sh defaults to, and ash sometimes is dash (on debian systems) but also sometimes just ash
elif [ "$SHELL" = "dash" ]; then
  assert_not_equals null "$(echo "$span" | jq -r '.resource.attributes."process.runtime.name"')"
  assert_equals "Debian Almquist Shell" "$(echo "$span" | jq -r '.resource.attributes."process.runtime.description"')"
elif [ "$SHELL" = "bash" ]; then
  assert_equals "bash" "$(echo "$span" | jq -r '.resource.attributes."process.runtime.name"')"
  assert_equals "Bourne Again Shell" "$(echo "$span" | jq -r '.resource.attributes."process.runtime.description"')"
elif [ "$SHELL" = "busybox sh" ]; then
  assert_equals "busybox sh" "$(echo "$span" | jq -r '.resource.attributes."process.runtime.name"')"
  assert_equals "Busy Box" "$(echo "$span" | jq -r '.resource.attributes."process.runtime.description"')"
else
  exit 1
fi
# assert_not_equals "null" $(echo "$span" | jq -r '.resource.attributes."process.runtime.version"')
# assert_not_equals "null" $(echo "$span" | jq -r '.resource.attributes."host.name"')
assert_equals "$OTEL_SERVICE_NAME" $(echo "$span" | jq -r '.resource.attributes."service.name"')

