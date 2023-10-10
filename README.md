This project delivers OpenTelemetry traces and logs from shell scripts (POSIX sh, dash, bash, zsh, ...). Compared to other similar projects, it delivers not just an SDK to create spans manually, but also provides context propagation via HTTP (wget and curl), auto-instrumentation for selected commands, custom instrumentations, auto-injection into child scripts and automatic log collection from stderr. Its installable via a debian package from the releases in this repository, or from the apt-repository below.

Use it to manually create spans:
```bash
#!/bin/bash
export OTEL_SERVICE_NAME=Test
export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=...
export OTEL_EXPORTER_OTLP_TRACES_HEADERS=...
export OTEL_EXPORTER_OTLP_LOGS_ENDPOINT=...
export OTEL_EXPORTER_OTLP_LOGS_HEADERS=...
. /usr/bin/opentelemetry_shell_api.sh
# initialize the sdk
otel_init

# create a default span for the command and collect all output to stderr as logs
# the span will contain all the information about the command, including the code location in the script, and error information
# every line written to stderr will be collected as a log
otel_observe echo "hello world"

# create a manual span for the job with a custom attribute
span_id=$(otel_span_start INTERNAL myspan)
otel_span_attribute $span_id key=value
echo "hello world again"
otel_span_end $span_id

# flush and shutdown the sdk
otel_shutdown
```

Use it to automatically instrument and inject into child scripts:
```bash
#!/bin/bash
export OTEL_SERVICE_NAME=Test
export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=...
export OTEL_EXPORTER_OTLP_TRACES_HEADERS=...
export OTEL_EXPORTER_OTLP_LOGS_ENDPOINT=...
export OTEL_EXPORTER_OTLP_LOGS_HEADERS=...
. /usr/bin/opentelemetry_shell.sh

# create spans for all echo's, both in this script and all child scripts
otel_instrument echo

echo "hello world" # this will create a span
echo "hello world again" # this as well

curl http://www.google.com # this will create a http client span and inject w3c tracecontext

bash ./print_hello_world.sh # this will create a span for the script
# it will also auto-instrument all jobs just like in this script,
# auto-inject into its childen, even without the init code at the start
```

Install either from https://github.com/plengauer/opentelemetry-bash/releases/latest or via
```bash
echo "deb [arch=all] https://3.73.14.87:8000/ stable main" | sudo tee /etc/apt/sources.list.d/example.list
sudo apt-get update
sudo apt-get install opentelemetry-shell
```

