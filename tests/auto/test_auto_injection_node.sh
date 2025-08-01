if ! type node; then exit 0; fi
if ! [ -d /usr/share/opentelemetry_shell/agent.instrumentation.node/"$(node -v | tr -d v | cut -d . -f 1)"/node_modules ]; then exit 0; fi
. ./assert.sh

. otel.sh

node -e "const child_process = require('child_process'); child_process.exec('echo hello world 0', {}, (error, stdout, stderr) => { console.log(stdout); console.error(stderr); });"
assert_equals 0 $?
span="$(resolve_span '.name == "echo hello world 0"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals null $(\echo "$span" | jq -r '.parent_id')

node -e "const child_process = require('child_process'); child_process.exec('echo hello world 1', {});"
assert_equals 0 $?
span="$(resolve_span '.name == "echo hello world 1"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals null $(\echo "$span" | jq -r '.parent_id')

node -e "const child_process = require('child_process'); child_process.exec('echo hello world 2', (error, stdout, stderr) => { console.log(stdout); console.error(stderr); });"
assert_equals 0 $?
span="$(resolve_span '.name == "echo hello world 2"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals null $(\echo "$span" | jq -r '.parent_id')

node -e "const child_process = require('child_process'); child_process.exec('echo hello world 3');"
assert_equals 0 $?
span="$(resolve_span '.name == "echo hello world 3"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals null $(\echo "$span" | jq -r '.parent_id')

node -e "const child_process = require('child_process'); child_process.spawn('echo', [ 'hello', 'world', '4' ], { stdio: 'inherit' });"
assert_equals 0 $?
span="$(resolve_span '.name == "echo hello world 4"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals null $(\echo "$span" | jq -r '.parent_id')

node -e "const child_process = require('child_process'); child_process.spawn('echo', [ 'hello', 'world', '5' ]);"
assert_equals 0 $?
span="$(resolve_span '.name == "echo hello world 5"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals null $(\echo "$span" | jq -r '.parent_id')

node -e "const child_process = require('child_process'); child_process.spawn('echo', { stdio: 'inherit' });"
assert_equals 0 $?
span="$(resolve_span '.name == "echo"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals null $(\echo "$span" | jq -r '.parent_id')

type npm || exit 1

export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE

node -e "const child_process = require('child_process'); child_process.spawn('echo', [ 'hello', 'world', '6' ]);"
assert_equals 0 $?
span="$(resolve_span '.name == "echo hello world 6"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals null $(\echo "$span" | jq -r '.parent_id')
# assert_equals $(resolve_span '.name == "echo hello world 6"' | jq -r .parent_id) $(resolve_span '.name == "TODO"' | jq -r .id)

# lets check with the above test if it works on any node version, but lets not rely on instrumentations actually working

\node -e "require('http').createServer(function (req, res) { console.log(req.method, req.url); res.writeHead(200); res.end(); }).listen(8080);" 1> /tmp/http.log 2> /dev/null &
server_pid="$!"

directory="$(mktemp -d)"
echo "
const http = require('http');
const options = {
  hostname: '127.0.0.1',
  port: 8080,
  path: '/',
  method: 'GET',
  headers: {
    'Connection': 'close'
  }
};
const req = http.request(options, (res) => {});
req.end();
" > "$directory"/index.js
span="$(node "$directory"/index.js 2>&1)"
assert_equals 0 $?
\echo "$span"
assert_equals "GET" "$(\echo "$span" | grep -E '^  name:' | cut -d ':' -f 2- | tr -d \''" ,')"
assert_not_equals undefined "$(\echo "$span" | grep parentId | cut -d ':' -f 2- | tr -d \''" ,')"

directory="$(mktemp -d)"
echo "
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { ConsoleSpanExporter } = require('@opentelemetry/sdk-trace-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const sdk = new NodeSDK({
  traceExporter: new ConsoleSpanExporter(),
  instrumentations: [getNodeAutoInstrumentations()],
  resourceDetectors: []
});
sdk.start();
process.on('exit', () => sdk.shutdown());
const http = require('http');
const options = {
  hostname: '127.0.0.1',
  port: 8080,
  path: '/',
  method: 'GET',
  headers: {
    'Connection': 'close'
  }
};
const req = http.request(options, (res) => {});
req.end();
" > "$directory"/index.js
(cd "$directory" && npm install @opentelemetry/api @opentelemetry/sdk-node @opentelemetry/sdk-trace-node @opentelemetry/auto-instrumentations-node)
span="$(node "$directory"/index.js 2>&1)"
assert_equals 0 $?
\echo "$span"
assert_equals "GET" "$(\echo "$span" | grep -E '^  name:' | cut -d ':' -f 2- | tr -d \''" ,')"
assert_not_equals undefined "$(\echo "$span" | grep parentId | cut -d ':' -f 2- | tr -d \''" ,')"

directory="$(mktemp -d)"
echo "
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { ConsoleSpanExporter } = require('@opentelemetry/sdk-trace-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const sdk = new NodeSDK({
  traceExporter: new ConsoleSpanExporter(),
  instrumentations: [getNodeAutoInstrumentations()],
  resourceDetectors: []
});
sdk.start();
process.on('exit', () => sdk.shutdown());
const child_process = require('child_process');
const opentelemetry_api = require('@opentelemetry/api');
opentelemetry_api.trace.getTracerProvider().getTracer('my-tracer').startActiveSpan('my-span', {}, opentelemetry_api.context.active(), span => {
  let proc = child_process.spawn('echo', [ 'hello', 'world', '7' ], { stdio: 'inherit' });
  proc.on('exit', () => span.end());
});
" > "$directory"/index.js
(cd "$directory" && npm install @opentelemetry/api @opentelemetry/sdk-node @opentelemetry/sdk-trace-node @opentelemetry/auto-instrumentations-node)
span="$(node "$directory"/index.js 2>&1)"
assert_equals 0 $?
\echo "$span"
assert_equals "$(resolve_span '.name == "echo hello world 7"' | jq -r .parent_id)" 0x"$(\echo "$span" | grep -E '^  id:' | cut -d ':' -f 2- | tr -d \''" ,')"

kill -9 "$server_pid"
