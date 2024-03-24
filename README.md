This project delivers [OpenTelemetry](https://opentelemetry.io/) traces, metrics and logs from shell scripts (sh, ash, dash, bash, and all POSIX compliant shells). Compared to similar projects, it delivers not just a command-line SDK to create spans manually, but also provides context propagation via HTTP (wget and curl), auto-instrumentation, auto-injection into child scripts and into commands using shebangs, as well as automatic log collection from stderr. Its installable via a debian package from the releases in this repository, or from the apt-repository below. This project is not officially affiliated with the CNCF project [OpenTelemetry](https://opentelemetry.io/).

Use it to manually create spans and metrics (see automatic below):
```bash
#!/bin/bash

# configure SDK according to https://opentelemetry.io/docs/languages/sdk-configuration/
export OTEL_SERVICE_NAME=Test
# currently, only 'otlp' and 'console' are supported as exporters
# currently, only 'tracecontext' is supported as propagator

# import API
. otelapi.sh

# initialize the sdk
otel_init

# create a default span for the command
# all lines written to stderr will be collected as logs
otel_observe echo "hello world"

# create a manual span with a custom attribute
span_id=$(otel_span_start INTERNAL myspan)
otel_span_attribute $span_id key=value
echo "hello world again"
otel_span_end $span_id

# write a metric data point with custom attributes
metric_id=$(otel_metric_create my.metric)
otel_metric_attribute $metric_id foo=bar
otel_metric_add $metric_id 42

# flush and shutdown the sdk
otel_shutdown
```

Use it to automatically instrument and inject into child scripts:
```bash
#!/bin/bash

# configure SDK according to https://opentelemetry.io/docs/languages/sdk-configuration/
export OTEL_SERVICE_NAME=Test

# init automatic instrumentation, automatic context propagation, and automatic log collection
. otel.sh

echo "hello world" # this will create a span
echo "hello world again" # this as well

curl http://www.google.com # this will create a http client span and inject w3c tracecontext

# the following script (and all its direct and indirect children) will be auto-injected without the init code being necessary
bash ./print_hello_world.sh
```

Install either via
```bash
wget -O - https://raw.githubusercontent.com/plengauer/opentelemetry-bash/main/INSTALL.sh | sh -E
```
or via
```bash
echo "deb [arch=all] https://3.73.14.87:8000/ stable main" | sudo tee /etc/apt/sources.list.d/example.list
sudo apt-get update
sudo apt-get install opentelemetry-shell
```

