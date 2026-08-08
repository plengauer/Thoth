. ./assert.sh
if [ ! -f "FILE_THAT_DOES_NOT_EXIST" ]; then
  . ${OTEL_TEST_ENTRYPOINT:-/usr/bin/opentelemetry_shell.sh}
fi

echo hello world

resolve_span '.name == "echo hello world"'
