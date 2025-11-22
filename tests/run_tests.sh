#!/bin/bash -e
set -e
export SHELL="$1"
if [ "$SHELL" = "" ]; then
  echo "need to specify shell to test"
  exit 1
fi
. /etc/os-release
if [ "$SHELL" = dash ] && ! ( [ "$ID" = debian ] || [ "$ID_LIKE" = debian ] ); then
  exit 0
fi

if [ "$SHELL" = busybox ]; then
  export TEST_SHELL="busybox sh";
else
  export TEST_SHELL="$SHELL"
fi

# Create temporary directory for test outputs
output_dir="$(mktemp -d)"
declare -a test_files=()
declare -a test_pids=()
declare -a test_outputs=()

# Collect all test files
for dir in unit sdk auto integration; do
  while IFS= read -r file; do
    test_files+=("$file")
  done < <({ find $dir -iname 'test_*.sh'; find $dir -iname 'test_*.'"$SHELL"; } | sort -u)
done

# Run all tests in parallel
for file in "${test_files[@]}"; do
  (
    rm /tmp/opentelemetry_shell_*_instrumentation_cache_*.aliases 2> /dev/null || true
    export OTEL_EXPORT_LOCATION="$(mktemp -u)".sdk.out
    export OTEL_SHELL_SDK_STDOUT_REDIRECT="$(mktemp -u -p "$(mktemp -d)")".pipe
    export OTEL_TRACES_EXPORTER=console
    export OTEL_METRICS_EXPORTER=console
    export OTEL_LOGS_EXPORTER=console
    mkfifo -m 666 "$OTEL_SHELL_SDK_STDOUT_REDIRECT"
    ( while true; do cat "$OTEL_SHELL_SDK_STDOUT_REDIRECT" >> "$OTEL_EXPORT_LOCATION"; done & )
    options='-f -u'
    if [ "$TEST_SHELL" = bash ]; then
      options="$options -p -o pipefail"
    fi
    stdout="$(mktemp -u -p "$(mktemp -d)").out"
    stderr="$(mktemp -u -p "$(mktemp -d)").err"
    touch "$stdout" "$stderr"
    chmod 0666 "$stdout" "$stderr"
    export OTEL_SHELL_SDK_STDERR_REDIRECT="$stderr"
    
    # Run test and capture result
    test_output="$output_dir/$(basename "$file").output"
    if timeout $((60 * 60 * 3)) $TEST_SHELL $options "$file" 1> "$stdout" 2>&1; then
      echo "$file SUCCEEDED" > "$test_output"
      exit 0
    else
      {
        echo "$file FAILED"
        echo "stdout:"
        cat "$stdout"
        echo "stderr:"
        cat "$stderr"
        echo "otlp:"
        cat "$OTEL_EXPORT_LOCATION"
      } > "$test_output"
      exit 1
    fi
  ) &
  test_pids+=($!)
  test_outputs+=("$output_dir/$(basename "$file").output")
done

# Wait for all tests to complete and track failures
failed=0
for i in "${!test_pids[@]}"; do
  if ! wait "${test_pids[$i]}"; then
    failed=1
  fi
done

# Print all outputs sequentially
for i in "${!test_files[@]}"; do
  echo "running ${test_files[$i]}"
  if [ -f "${test_outputs[$i]}" ]; then
    cat "${test_outputs[$i]}"
  fi
done

# Clean up
rm -rf "$output_dir"

# Exit with failure if any test failed
if [ "$failed" -eq 1 ]; then
  exit 1
fi

echo "ALL TESTS SUCCESSFUL"
