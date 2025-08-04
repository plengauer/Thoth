. ./assert.sh
# from a real world example
# setup the environment
sudo touch /usr/bin/bash-ai
sudo sh -c 'echo "#!/bin/'"$TEST_SHELL"' -e" >> /usr/bin/bash-ai'
sudo sh -c 'echo "echo hello world" >> /usr/bin/bash-ai' # lets abstract away the actual content of the script
sudo chmod +x /usr/bin/bash-ai
alias ai=bash-ai
# lets simulate the caller
. /usr/bin/opentelemetry_shell.sh
if [ "$TEST_SHELL" = 'busybox sh' ] && ! [ -x /bin/busybox ]; then sudo ln --symbolic $(which busybox) /bin/busybox; fi
alias
ai some arguments
# lets assert
assert_equals 0 $?
span="$(resolve_span '.name | endswith("/bash-ai some arguments")')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
span="$(resolve_span '.name == "echo hello world"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
