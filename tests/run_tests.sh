#!/bin/bash
set -e
export SHELL=$1
if [ "$SHELL" = "" ]; then
  echo "need to specify shell to test"
  exit 1
fi

# (while sleep 15; do pstree -a -c -p; done) &
for dir in unit sdk auto integration; do
  for file in $(find $dir -iname 'test_*.shell') $(find $dir -iname 'test_*.'$SHELL); do
    export OTEL_EXPORT_LOCATION=$(mktemp -u).sdk.out
    export OTEL_SHELL_SDK_OUTPUT_REDIRECT=$(mktemp -u).pipe
    export OTEL_TRACES_EXPORTER=console
    export OTEL_METRICS_EXPORTER=console
    export OTEL_LOGS_EXPORTER=console
    mkfifo $OTEL_SHELL_SDK_OUTPUT_REDIRECT
    ( while true; do cat $OTEL_SHELL_SDK_OUTPUT_REDIRECT >> $OTEL_EXPORT_LOCATION; done ) &
    echo "running $file"
    timeout $((60 * 5)) $SHELL $file && echo "SUCCEEDED" || (echo "FAILED" && cat $OTEL_EXPORT_LOCATION && exit 1)
  done
done
echo "ALL TESTS SUCCESSFUL"
