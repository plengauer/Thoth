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
bash -e demo.sh
  javac Main.java
  java Main
    GET
  rm Main.class
```
## Full Trace
```
{
  "trace_id": "b0a0ea7c07bb3156df7d2d1ea32cf26d",
  "span_id": "53c3b2fdbe12f95b",
  "parent_span_id": "9c8e371899c219f9",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783554837681763477,
  "time_end": 1783554837822794851,
  "attributes": {
    "server.address": "example.com",
    "network.protocol.version": "1.1",
    "http.request.method": "GET",
    "server.port": 80,
    "http.response.status_code": 200,
    "thread.name": "main",
    "url.full": "http://example.com",
    "thread.id": 1
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "runnervm5mmn9",
    "os.description": "Linux 6.17.0-1018-azure",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.command_args": [
      "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/gradlehttppropagationagent.jar",
      "Main"
    ],
    "process.executable.path": "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
    "process.pid": 4879,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.19+10",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.19+10",
    "service.instance.id": "c5351505-8b62-448f-ad6b-299c61e17298",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.29.0",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.63.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "b0a0ea7c07bb3156df7d2d1ea32cf26d",
  "span_id": "53aaeeb018358ff2",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1783554832670029568,
  "time_end": 1783554838036168704,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "c67cad7c-8de4-49d3-a254-07ef74ac6714",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/4b42d415-d0d3-47ca-a2d9-f2257d725d9d/resourceGroups/azure-eastus2-general-4b42d415-d0d3-47ca-a2d9-f2257d725d9d/providers/Microsoft.Compute/virtualMachines/WytkOTZi5ZETgj",
    "host.id": "cb5b4b30-406b-49b7-aca3-be7745bb2b10",
    "host.name": "WytkOTZi5ZETgj",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 4125,
    "process.parent_pid": 3038,
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
{
  "trace_id": "b0a0ea7c07bb3156df7d2d1ea32cf26d",
  "span_id": "9c8e371899c219f9",
  "parent_span_id": "53aaeeb018358ff2",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783554833939480064,
  "time_end": 1783554838013414912,
  "attributes": {
    "shell.command_line": "java Main",
    "shell.command": "java",
    "shell.command.type": "file",
    "shell.command.name": "java",
    "subprocess.executable.path": "/usr/bin/java",
    "subprocess.executable.name": "java",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 4
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "c67cad7c-8de4-49d3-a254-07ef74ac6714",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/4b42d415-d0d3-47ca-a2d9-f2257d725d9d/resourceGroups/azure-eastus2-general-4b42d415-d0d3-47ca-a2d9-f2257d725d9d/providers/Microsoft.Compute/virtualMachines/WytkOTZi5ZETgj",
    "host.id": "cb5b4b30-406b-49b7-aca3-be7745bb2b10",
    "host.name": "WytkOTZi5ZETgj",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 4125,
    "process.parent_pid": 3038,
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
{
  "trace_id": "b0a0ea7c07bb3156df7d2d1ea32cf26d",
  "span_id": "a1a71b7f253685f7",
  "parent_span_id": "53aaeeb018358ff2",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783554832682357248,
  "time_end": 1783554833934680064,
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
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "c67cad7c-8de4-49d3-a254-07ef74ac6714",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/4b42d415-d0d3-47ca-a2d9-f2257d725d9d/resourceGroups/azure-eastus2-general-4b42d415-d0d3-47ca-a2d9-f2257d725d9d/providers/Microsoft.Compute/virtualMachines/WytkOTZi5ZETgj",
    "host.id": "cb5b4b30-406b-49b7-aca3-be7745bb2b10",
    "host.name": "WytkOTZi5ZETgj",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 4125,
    "process.parent_pid": 3038,
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
{
  "trace_id": "b0a0ea7c07bb3156df7d2d1ea32cf26d",
  "span_id": "63b690a4c98c2e9c",
  "parent_span_id": "53aaeeb018358ff2",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783554838019126272,
  "time_end": 1783554838035953408,
  "attributes": {
    "shell.command_line": "rm Main.class",
    "shell.command": "rm",
    "shell.command.type": "file",
    "shell.command.name": "rm",
    "subprocess.executable.path": "/usr/bin/rm",
    "subprocess.executable.name": "rm",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 5
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "c67cad7c-8de4-49d3-a254-07ef74ac6714",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/4b42d415-d0d3-47ca-a2d9-f2257d725d9d/resourceGroups/azure-eastus2-general-4b42d415-d0d3-47ca-a2d9-f2257d725d9d/providers/Microsoft.Compute/virtualMachines/WytkOTZi5ZETgj",
    "host.id": "cb5b4b30-406b-49b7-aca3-be7745bb2b10",
    "host.name": "WytkOTZi5ZETgj",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 4125,
    "process.parent_pid": 3038,
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
