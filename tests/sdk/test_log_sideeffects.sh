. ./assert.sh
. /usr/bin/opentelemetry_shell_api.sh

otel_init

expected="$(echo hello world 2>&1)"
actual="$(otel_observe echo hello world 2>&1)"
assert_equals "$expected" "$actual"

# expected="$(echo -e 'hello\\rworld' 2>&1)"
# actual="$(otel_observe echo -e 'hello\\rworld' 2>&1)"
# assert_equals "$expected" "$actual"

# expected="$((/usr/bin/time echo hello world) 2>&1)"
# actual="$((otel_observe /usr/bin/time echo hello world) 2>&1)"
# assert_equals "$(echo $expected | sed 's/[0-9]//g')" "$(echo $actual | sed 's/[0-9]//g')"

# if [ "$(which)" = "sudo" ]; then
#   echo "deb [arch=all] http://127.0.0.1:8000/ stable main" | sudo tee /etc/apt/sources.list.d/example.list
#   expected="$(sudo apt-get update)"
#   actual="$(otel_observe sudo apt-get update)"
#   assert_equals "$(echo $expected | sed 's/[0-9]//g')" "$(echo $actual | sed 's/[0-9]//g')"
# fi

otel_shutdown
