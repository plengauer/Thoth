#!/bin/bash -e
set -e
export SHELL="$1"
if [ "$SHELL" = "" ]; then
  echo "need to specify shell to test"
  exit 1
fi
if [ "$SHELL" = busybox ]; then
  export TEST_SHELL="busybox sh";
else
  export TEST_SHELL="$SHELL"
fi

for dir in unit sdk auto integration; do
  ls "$dir" | grep '\.sh$' | grep '\.'"$SHELL"'$' | while read -r name; do
    file="$dir"/"$name"
    rm /tmp/opentelemetry_shell_*_instrumentation_cache_*.aliases 2> /dev/null || true
    export OTEL_EXPORT_LOCATION="$(mktemp -u)".sdk.out
    export OTEL_SHELL_SDK_OUTPUT_REDIRECT="$(mktemp -u -p "$(mktemp -d)")".pipe
    export OTEL_TRACES_EXPORTER=console
    export OTEL_METRICS_EXPORTER=console
    export OTEL_LOGS_EXPORTER=console
    mkfifo --mode=666 "$OTEL_SHELL_SDK_OUTPUT_REDIRECT"
    ( while true; do cat "$OTEL_SHELL_SDK_OUTPUT_REDIRECT" >> "$OTEL_EXPORT_LOCATION"; done & )
    echo "running $file"
    options='-f -u'
    if [ "$TEST_SHELL" = bash ]; then
      options="$options -p -o pipefail"
    fi
    stdout="$(mktemp -u).out"
    stderr="$(mktemp -u).err"
    timeout $((60 * 60 * 3)) $TEST_SHELL $options "$file" 1> "$stdout" && echo "$file SUCCEEDED" || (echo "$file FAILED" && echo "stdout:" && cat "$stdout" && echo "otlp:" && cat "$OTEL_EXPORT_LOCATION" && exit 1)
  done
done
echo "ALL TESTS SUCCESSFUL"
