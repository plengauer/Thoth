. ./assert.sh
if [ "$(whoami)" = "root" ]; then
  echo "#!/bin/sh -x" > /usr/bin/fail_no_auto.sh
  cat auto/fail_no_auto.sh >> /usr/bin/fail_no_auto.sh
  chmod +x /usr/bin/fail_no_auto.sh
else
  echo "#!/bin/sh -x" | sudo tee /usr/bin/fail_no_auto.sh
  cat auto/fail_no_auto.sh | sudo tee -a /usr/bin/fail_no_auto.sh
  sudo chmod +x /usr/bin/fail_no_auto.sh
fi
. /usr/bin/opentelemetry_shell.sh
fail_no_auto.sh
assert_equals 0 $?
span="$(resolve_span '.resource.attributes."process.command_line" | contains("/fail_no_auto.sh")')"
assert_equals "myspan" "$(\echo "$span" | jq -r '.name')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
