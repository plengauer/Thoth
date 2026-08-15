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
  "trace_id": "dc99fa3ac1081c0974f76b67e5596a25",
  "span_id": "507fd3905f77b718",
  "parent_span_id": "0f7e4b2f3f0c1963",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793487544080976,
  "time_end": 1786793487642178398,
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
    "process.pid": 4745,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.20+8",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.20+8",
    "service.instance.id": "b1ee942b-ee9f-47bd-8fda-9c05ba3ff294",
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
  "trace_id": "dc99fa3ac1081c0974f76b67e5596a25",
  "span_id": "162d409e0e4cbd56",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786793483702981888,
  "time_end": 1786793487844201984,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "51f8d3de-be81-494d-81e3-69b2534921fd",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/c478196f-a52d-465a-9d3d-4a99c5c26a17/resourceGroups/azure-westcentralus-general-c478196f-a52d-465a-9d3d-4a99c5c26a17/providers/Microsoft.Compute/virtualMachines/8VWogzl7pWHIus",
    "host.id": "f5570150-6c8d-460d-915b-ae9b23157acd",
    "host.name": "8VWogzl7pWHIus",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4007,
    "process.parent_pid": 2932,
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
  "trace_id": "dc99fa3ac1081c0974f76b67e5596a25",
  "span_id": "0f7e4b2f3f0c1963",
  "parent_span_id": "162d409e0e4cbd56",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793484274755584,
  "time_end": 1786793487831303424,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "51f8d3de-be81-494d-81e3-69b2534921fd",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/c478196f-a52d-465a-9d3d-4a99c5c26a17/resourceGroups/azure-westcentralus-general-c478196f-a52d-465a-9d3d-4a99c5c26a17/providers/Microsoft.Compute/virtualMachines/8VWogzl7pWHIus",
    "host.id": "f5570150-6c8d-460d-915b-ae9b23157acd",
    "host.name": "8VWogzl7pWHIus",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4007,
    "process.parent_pid": 2932,
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
  "trace_id": "dc99fa3ac1081c0974f76b67e5596a25",
  "span_id": "e805897de0105d1b",
  "parent_span_id": "162d409e0e4cbd56",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793483710820352,
  "time_end": 1786793484270714880,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "51f8d3de-be81-494d-81e3-69b2534921fd",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/c478196f-a52d-465a-9d3d-4a99c5c26a17/resourceGroups/azure-westcentralus-general-c478196f-a52d-465a-9d3d-4a99c5c26a17/providers/Microsoft.Compute/virtualMachines/8VWogzl7pWHIus",
    "host.id": "f5570150-6c8d-460d-915b-ae9b23157acd",
    "host.name": "8VWogzl7pWHIus",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4007,
    "process.parent_pid": 2932,
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
  "trace_id": "dc99fa3ac1081c0974f76b67e5596a25",
  "span_id": "24a220b26bf316bf",
  "parent_span_id": "162d409e0e4cbd56",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793487835969536,
  "time_end": 1786793487843997184,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "51f8d3de-be81-494d-81e3-69b2534921fd",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/c478196f-a52d-465a-9d3d-4a99c5c26a17/resourceGroups/azure-westcentralus-general-c478196f-a52d-465a-9d3d-4a99c5c26a17/providers/Microsoft.Compute/virtualMachines/8VWogzl7pWHIus",
    "host.id": "f5570150-6c8d-460d-915b-ae9b23157acd",
    "host.name": "8VWogzl7pWHIus",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4007,
    "process.parent_pid": 2932,
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
