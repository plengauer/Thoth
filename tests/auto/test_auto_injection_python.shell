if ! which python3; then exit 0; fi
if ! [ -d /usr/share/opentelemetry_shell/agent.instrumentation.python/"$(python3 --version | cut -d ' ' -f 2 | cut -d . -f -2)" ]; then exit 0; fi
. ./assert.sh

. otel.sh

dir=$(mktemp -d)
python3 -m venv --system-site-packages "$dir"/venv || exit 1
. "$dir"/venv/bin/activate
\echo "$PATH"
\alias pip3
\which pip3
pip3 install requests 2>&1 | grep writable && exit 1
deactivate
python3 --version
python3 --help

echo '
import os
os.execl("/bin/echo", "echo", "hello", "world", "0")
' | python3
assert_equals 0 $?
span="$(resolve_span '.name == "/bin/echo hello world 0"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | \jq -r '.kind')
assert_not_equals null $(\echo "$span" | \jq -r '.parent_id')

\echo '
import os
os.execv("/bin/echo", [ "echo", "hello", "world", "1" ])
' | python3
assert_equals 0 $?
span="$(resolve_span '.name | endswith("/echo hello world 1")')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | \jq -r '.kind')
assert_not_equals null $(\echo "$span" | \jq -r '.parent_id')

echo '
import os
os.spawnl(os.P_WAIT, "/bin/echo", "echo", "hello", "world", "2")
' | python3
assert_equals 0 $?
span="$(resolve_span '.name | endswith("/echo hello world 2")')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | \jq -r '.kind')
assert_not_equals null $(\echo "$span" | \jq -r '.parent_id')

echo '
import os
os.spawnlp(os.P_WAIT, "echo", "echo", "hello", "world", "3")
' | python3
assert_equals 0 $?
span="$(resolve_span '.name | endswith("/echo hello world 3")')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | \jq -r '.kind')
assert_not_equals null $(\echo "$span" | \jq -r '.parent_id')

echo '
import os
os.spawnv(os.P_WAIT, "/bin/echo", ["echo", "hello", "world", "4"])
' | python3
assert_equals 0 $?
span="$(resolve_span '.name | endswith("/echo hello world 4")')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | \jq -r '.kind')
assert_not_equals null $(\echo "$span" | \jq -r '.parent_id')

echo '
import os
os.spawnvp(os.P_WAIT, "echo", ["echo", "hello", "world", "5"])
' | python3
assert_equals 0 $?
span="$(resolve_span '.name | endswith("/echo hello world 5")')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | \jq -r '.kind')
assert_not_equals null $(\echo "$span" | \jq -r '.parent_id')

printf '%s' '
import subprocess
with subprocess.Popen(["/bin/echo", "hello", "world", "6"], stdout=subprocess.DEVNULL) as proc:
  pass
' | python3
assert_equals 0 $?
span="$(resolve_span '.name | endswith("/echo hello world 6")')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | \jq -r '.kind')
assert_not_equals null $(\echo "$span" | \jq -r '.parent_id')

dir=$(mktemp -d)
python3 -m venv --system-site-packages "$dir"/venv || exit 1
. "$dir"/venv/bin/activate
pip3 install opentelemetry-distro opentelemetry-exporter-otlp
opentelemetry-bootstrap --action install || exit 1
printf '%s' '
import subprocess
with subprocess.Popen(["/bin/echo", "hello", "world", "7"], stdout=subprocess.DEVNULL) as proc:
  pass
' | python3
assert_equals 0 $?
deactivate
span="$(resolve_span '.name | endswith("/echo hello world 7")')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | \jq -r '.kind')
assert_not_equals null $(\echo "$span" | \jq -r '.parent_id')

echo '
import subprocess
subprocess.run(["/bin/echo", "hello", "world", "8"])
' | python3
assert_equals 0 $?
span="$(resolve_span '.name | endswith("/echo hello world 8")')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | \jq -r '.kind')
assert_not_equals null $(\echo "$span" | \jq -r '.parent_id')

echo '
import subprocess
subprocess.run("echo hello world 9", shell=True)
' | python3
assert_equals 0 $?
span="$(resolve_span '.name == "echo hello world 9"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | \jq -r '.kind')
assert_not_equals null $(\echo "$span" | \jq -r '.parent_id')

echo '
import subprocess
subprocess.run(["echo", "hello", "world", "10"], shell=True)
' | python3
assert_equals 0 $?
span="$(resolve_span '.name == "echo hello world 10"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | \jq -r '.kind')
assert_not_equals null $(\echo "$span" | \jq -r '.parent_id')

export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE
echo "$TRACEPARENT"

echo '
import requests
requests.get("http://example.com/foo")
' | python3 | grep -v -F '"parent_id": null,' | grep -- '/foo' || exit 1

python3 -c '
import requests
requests.get("http://example.com/bar")
' | grep -v -F '"parent_id": null,' | grep -- '/bar' || exit 1

echo '
import requests
requests.get("http://example.com/baz")
' > script.py
python3 script.py | grep -v -F '"parent_id": null,' | grep -- '/baz' || exit 1

dir=$(mktemp -d)
python3 -m venv --system-site-packages "$dir"/venv || exit 1
. "$dir"/venv/bin/activate
pip install requests
echo '
import requests
requests.get("http://example.com/venv")
' | python | grep -v -F '"parent_id": null,' | grep -- '/venv' || exit 1
deactivate

dir=$(mktemp -d)
python3 -m venv --system-site-packages "$dir"/venv || exit 1
. "$dir"/venv/bin/activate
pip3 install requests
pip3 install opentelemetry-distro opentelemetry-exporter-otlp
opentelemetry-bootstrap --action install || exit 1
script=$(mktemp -u).py
echo '
import requests
requests.get("http://example.com/instrumented")
' > "$script"
opentelemetry-instrument python3 "$script" | grep -v -F '"parent_id": null,' | grep -- '/instrumented' || exit 1
deactivate

dir=$(mktemp -d)
python3 -m venv "$dir"/venv || exit 1
. "$dir"/venv/bin/activate
pip install requests
echo '
import requests
requests.get("http://example.com/venv_deep_stdin")
' | python | grep -v -F '"parent_id": null,' | grep -- '/venv_deep_stdin' || exit 1
deactivate

dir=$(mktemp -d)
python3 -m venv "$dir"/venv || exit 1
. "$dir"/venv/bin/activate
pip install requests
python -c '
import requests
requests.get("http://example.com/venv_deep_c")
' | grep -v -F '"parent_id": null,' | grep -- '/venv_deep_c' || exit 1
deactivate

dir=$(mktemp -d)
python3 -m venv "$dir"/venv || exit 1
. "$dir"/venv/bin/activate
pip install requests
echo '
import requests
requests.get("http://example.com/venv_deep_file")
' > "$dir"/script.py
python "$dir"/script.py | grep -v -F '"parent_id": null,' | grep -- '/venv_deep_file' || exit 1
deactivate
