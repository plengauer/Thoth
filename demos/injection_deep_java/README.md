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
  "trace_id": "f1433b7d342a240478b9afe05526370a",
  "span_id": "b72d0fc325fa7a41",
  "parent_span_id": "0f22f97babd39e4a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786604793524412196,
  "time_end": 1786604793588987770,
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
    "host.name": "runnervmzvulz",
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
    "process.pid": 4549,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.20+8",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.20+8",
    "service.instance.id": "fb77b430-43f1-4ace-a10b-e3b39300259d",
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
  "trace_id": "f1433b7d342a240478b9afe05526370a",
  "span_id": "b5abcb691c530501",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786604789872956416,
  "time_end": 1786604793779560192,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "6aaa966d-8d8f-470d-927e-67904441e007",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/49d893db-d0aa-494b-a0c2-2a3d1208ca6a/resourceGroups/azure-centralus-general-49d893db-d0aa-494b-a0c2-2a3d1208ca6a/providers/Microsoft.Compute/virtualMachines/sDW3ajzgZTIvvk",
    "host.id": "6a356291-e798-45ec-8bb8-ace73ca8a007",
    "host.name": "sDW3ajzgZTIvvk",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3795,
    "process.parent_pid": 2722,
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
  "trace_id": "f1433b7d342a240478b9afe05526370a",
  "span_id": "0f22f97babd39e4a",
  "parent_span_id": "b5abcb691c530501",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786604790450218240,
  "time_end": 1786604793761975552,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "6aaa966d-8d8f-470d-927e-67904441e007",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/49d893db-d0aa-494b-a0c2-2a3d1208ca6a/resourceGroups/azure-centralus-general-49d893db-d0aa-494b-a0c2-2a3d1208ca6a/providers/Microsoft.Compute/virtualMachines/sDW3ajzgZTIvvk",
    "host.id": "6a356291-e798-45ec-8bb8-ace73ca8a007",
    "host.name": "sDW3ajzgZTIvvk",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3795,
    "process.parent_pid": 2722,
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
  "trace_id": "f1433b7d342a240478b9afe05526370a",
  "span_id": "10ee3c7279e2f757",
  "parent_span_id": "b5abcb691c530501",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786604789883162880,
  "time_end": 1786604790446118400,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "6aaa966d-8d8f-470d-927e-67904441e007",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/49d893db-d0aa-494b-a0c2-2a3d1208ca6a/resourceGroups/azure-centralus-general-49d893db-d0aa-494b-a0c2-2a3d1208ca6a/providers/Microsoft.Compute/virtualMachines/sDW3ajzgZTIvvk",
    "host.id": "6a356291-e798-45ec-8bb8-ace73ca8a007",
    "host.name": "sDW3ajzgZTIvvk",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3795,
    "process.parent_pid": 2722,
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
  "trace_id": "f1433b7d342a240478b9afe05526370a",
  "span_id": "0a05e506754b9514",
  "parent_span_id": "b5abcb691c530501",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786604793766491136,
  "time_end": 1786604793779405056,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "6aaa966d-8d8f-470d-927e-67904441e007",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/49d893db-d0aa-494b-a0c2-2a3d1208ca6a/resourceGroups/azure-centralus-general-49d893db-d0aa-494b-a0c2-2a3d1208ca6a/providers/Microsoft.Compute/virtualMachines/sDW3ajzgZTIvvk",
    "host.id": "6a356291-e798-45ec-8bb8-ace73ca8a007",
    "host.name": "sDW3ajzgZTIvvk",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3795,
    "process.parent_pid": 2722,
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
