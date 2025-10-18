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
  { find $dir -iname 'test_*.sh'; find $dir -iname 'test_*.'"$SHELL"; } | sort -u | while read -r file; do
    rm /tmp/opentelemetry_shell_*_instrumentation_cache_*.aliases 2> /dev/null || true
    export OTEL_EXPORT_LOCATION="$(mktemp -u)".sdk.out
    export OTEL_SHELL_SDK_STDOUT_REDIRECT="$(mktemp -u -p "$(mktemp -d)")".pipe
    export OTEL_TRACES_EXPORTER=console
    export OTEL_METRICS_EXPORTER=console
    export OTEL_LOGS_EXPORTER=console
    mkfifo -m 666 "$OTEL_SHELL_SDK_STDOUT_REDIRECT"
    ( while true; do cat "$OTEL_SHELL_SDK_STDOUT_REDIRECT" >> "$OTEL_EXPORT_LOCATION"; done & )
    echo "running $file"
    options='-f -u'
    if [ "$TEST_SHELL" = bash ]; then
      options="$options -p -o pipefail"
    fi
    stdout="$(mktemp -u -p "$(mktemp -d)").out"
    stderr="$(mktemp -u -p "$(mktemp -d)").err"
    touch "$stdout" "$stderr"
    chmod 0666 "$stdout" "$stderr"
    export OTEL_SHELL_SDK_STDERR_REDIRECT="$stderr"
    timeout $((60 * 60 * 3)) $TEST_SHELL $options "$file" 1> "$stdout" && echo "$file SUCCEEDED" || (echo "$file FAILED" && echo "stdout:" && cat "$stdout" && echo "stderr:" && cat "$stderr" && echo "otlp:" && cat "$OTEL_EXPORT_LOCATION" && exit 1)
  done
done
echo "ALL TESTS SUCCESSFUL"
