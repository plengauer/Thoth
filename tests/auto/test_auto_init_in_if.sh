. ./assert.sh
if [ ! -f "FILE_THAT_DOES_NOT_EXIST" ]; then
  . /usr/bin/opentelemetry_shell.sh
fi

echo hello world

resolve_span '.name == "echo hello world"'
