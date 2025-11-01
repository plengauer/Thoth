# Demo "Deep injection into a Java app"
This script uses a java app and configures opentelemetry to inject into the app and continue tracing.
## Script
```sh
export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE
. otel.sh
javac Main.java
java Main
rm Main.class
```
## Trace Structure Overview
```
```
## Full Trace
```
{
  "trace_id": "fa7e477ab6cea5507140592fa994f9b9",
  "span_id": "4938ac729b7efc90",
  "parent_span_id": "3c6803ad902d0f83",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1761994511884330026,
  "time_end": 1761994512131119355,
  "attributes": {
    "thread.id": 1,
    "url.full": "http://example.com",
    "thread.name": "main",
    "http.response.status_code": 200,
    "server.address": "example.com",
    "network.protocol.version": "1.1",
    "http.request.method": "GET"
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "runnervmf2e7y",
    "os.description": "Linux 6.11.0-1018-azure",
    "os.type": "linux",
    "process.command_args": [
      "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar",
      "Main"
    ],
    "process.executable.path": "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
    "process.pid": 4840,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.17+10",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.17+10",
    "service.instance.id": "90c5e68a-c86a-41bf-9947-2c5ab307af35",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.21.0",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.55.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "fa7e477ab6cea5507140592fa994f9b9",
  "span_id": "269d42d3c2ca5a82",
  "parent_span_id": "28434188167c01b1",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761994506134345984,
  "time_end": 1761994507526335744,
  "attributes": {
    "shell.command_line": "javac Main.java",
    "shell.command": "javac",
    "shell.command.type": "file",
    "shell.command.name": "javac",
    "subprocess.executable.path": "/usr/bin/javac",
    "subprocess.executable.name": "javac",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 3
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/a05a7447-17c8-4e90-8527-0ae95a5722ab/resourceGroups/azure-northcentralus-general-a05a7447-17c8-4e90-8527-0ae95a5722ab/providers/Microsoft.Compute/virtualMachines/3tnqnMMNvXQQ8g",
    "host.id": "941c4e45-4d70-4d1e-96e9-654e032e7507",
    "host.name": "3tnqnMMNvXQQ8g",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "941c4e45-4d70-4d1e-96e9-654e032e7507",
    "process.pid": 3997,
    "process.parent_pid": 2361,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB"
  },
  "links": [],
  "events": []
}
```
