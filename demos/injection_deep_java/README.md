# Demo "Deep injection into a Java app"
This script uses a java app and configures opentelemetry to inject into the app and continue tracing.
## Script
```bash
export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE
. otel.sh
javac Main.java
java Main
rm Main.class
```
## Trace Structure Overview
```bash
bash -e demo.sh
  javac Main.java
  java Main
    GET
  rm Main.class
```
## Full Trace
```json
{
  "trace_id": "d3b3c379705532eed59e36c8b306f46b",
  "span_id": "6897e942d986fcc9",
  "parent_span_id": "df5fef8e3e6f8dbf",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787581531416370330,
  "time_end": 1787581531495039654,
  "attributes": {
    "network.protocol.version": "1.1",
    "http.request.method": "GET",
    "server.address": "example.com",
    "server.port": 80,
    "thread.name": "main",
    "url.full": "http://example.com",
    "http.response.status_code": 200,
    "thread.id": 1
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "runnervm76f27",
    "os.description": "Linux 6.17.0-1022-azure",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.command_args": [
      "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/gradlehttppropagationagent.jar",
      "Main"
    ],
    "process.executable.path": "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
    "process.pid": 4739,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.20+8",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.20+8",
    "service.instance.id": "d1701392-85e7-4667-a267-83584fa5dba4",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.30.0",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.64.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "d3b3c379705532eed59e36c8b306f46b",
  "span_id": "b2caaa1fccf2f403",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1787581527177783808,
  "time_end": 1787581531676949504,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "ed3811b3-76c7-4533-9623-aa1994862950",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/d2946416-6773-4534-8152-a2270c531101/resourceGroups/azure-eastus-general-d2946416-6773-4534-8152-a2270c531101/providers/Microsoft.Compute/virtualMachines/uhWCfE4ZxU90hk",
    "host.id": "d3016bb2-222e-465f-af82-12a514ab0878",
    "host.name": "uhWCfE4ZxU90hk",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4000,
    "process.parent_pid": 2927,
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
  "trace_id": "d3b3c379705532eed59e36c8b306f46b",
  "span_id": "df5fef8e3e6f8dbf",
  "parent_span_id": "b2caaa1fccf2f403",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787581528004439808,
  "time_end": 1787581531664789504,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "ed3811b3-76c7-4533-9623-aa1994862950",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/d2946416-6773-4534-8152-a2270c531101/resourceGroups/azure-eastus-general-d2946416-6773-4534-8152-a2270c531101/providers/Microsoft.Compute/virtualMachines/uhWCfE4ZxU90hk",
    "host.id": "d3016bb2-222e-465f-af82-12a514ab0878",
    "host.name": "uhWCfE4ZxU90hk",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4000,
    "process.parent_pid": 2927,
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
  "trace_id": "d3b3c379705532eed59e36c8b306f46b",
  "span_id": "e17cc0bb07c536e0",
  "parent_span_id": "b2caaa1fccf2f403",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787581527185372672,
  "time_end": 1787581528000642560,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "ed3811b3-76c7-4533-9623-aa1994862950",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/d2946416-6773-4534-8152-a2270c531101/resourceGroups/azure-eastus-general-d2946416-6773-4534-8152-a2270c531101/providers/Microsoft.Compute/virtualMachines/uhWCfE4ZxU90hk",
    "host.id": "d3016bb2-222e-465f-af82-12a514ab0878",
    "host.name": "uhWCfE4ZxU90hk",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4000,
    "process.parent_pid": 2927,
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
  "trace_id": "d3b3c379705532eed59e36c8b306f46b",
  "span_id": "40381f6b9336815c",
  "parent_span_id": "b2caaa1fccf2f403",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787581531669292544,
  "time_end": 1787581531676769792,
  "attributes": {
    "shell.command_line": "rm Main.class",
    "shell.command": "rm",
    "shell.command.type": "builtin",
    "shell.command.name": "rm",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 5
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "ed3811b3-76c7-4533-9623-aa1994862950",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/d2946416-6773-4534-8152-a2270c531101/resourceGroups/azure-eastus-general-d2946416-6773-4534-8152-a2270c531101/providers/Microsoft.Compute/virtualMachines/uhWCfE4ZxU90hk",
    "host.id": "d3016bb2-222e-465f-af82-12a514ab0878",
    "host.name": "uhWCfE4ZxU90hk",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4000,
    "process.parent_pid": 2927,
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
