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
  "trace_id": "a154b35cf22b9fe7ada9f69e4887c6c9",
  "span_id": "94c82007d392b87f",
  "parent_span_id": "b8edb0d19f34aeb0",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786148049406731071,
  "time_end": 1786148049447175062,
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
    "host.name": "runnervmvrwv9",
    "os.description": "Linux 6.17.0-1020-azure",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.command_args": [
      "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/gradlehttppropagationagent.jar",
      "Main"
    ],
    "process.executable.path": "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
    "process.pid": 4694,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.19+10",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.19+10",
    "service.instance.id": "316a3167-5926-4e56-ad19-b35320aeb611",
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
  "trace_id": "a154b35cf22b9fe7ada9f69e4887c6c9",
  "span_id": "250ec26cf090ec67",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786148045444185856,
  "time_end": 1786148049647926784,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "0369a227-b482-4c8c-95c2-278dfc15795b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b7893289-0a79-4588-907c-085a16341b7b/resourceGroups/azure-westus-general-b7893289-0a79-4588-907c-085a16341b7b/providers/Microsoft.Compute/virtualMachines/zF11rqFvdaGPLh",
    "host.id": "b65f4df7-cfa7-4162-8e5c-3b5c9938dc2b",
    "host.name": "zF11rqFvdaGPLh",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3940,
    "process.parent_pid": 2865,
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
  "trace_id": "a154b35cf22b9fe7ada9f69e4887c6c9",
  "span_id": "b8edb0d19f34aeb0",
  "parent_span_id": "250ec26cf090ec67",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786148046034839552,
  "time_end": 1786148049626607872,
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
    "service.instance.id": "0369a227-b482-4c8c-95c2-278dfc15795b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b7893289-0a79-4588-907c-085a16341b7b/resourceGroups/azure-westus-general-b7893289-0a79-4588-907c-085a16341b7b/providers/Microsoft.Compute/virtualMachines/zF11rqFvdaGPLh",
    "host.id": "b65f4df7-cfa7-4162-8e5c-3b5c9938dc2b",
    "host.name": "zF11rqFvdaGPLh",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3940,
    "process.parent_pid": 2865,
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
  "trace_id": "a154b35cf22b9fe7ada9f69e4887c6c9",
  "span_id": "8534b47dd8008217",
  "parent_span_id": "250ec26cf090ec67",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786148045455936512,
  "time_end": 1786148046029853952,
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
    "service.instance.id": "0369a227-b482-4c8c-95c2-278dfc15795b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b7893289-0a79-4588-907c-085a16341b7b/resourceGroups/azure-westus-general-b7893289-0a79-4588-907c-085a16341b7b/providers/Microsoft.Compute/virtualMachines/zF11rqFvdaGPLh",
    "host.id": "b65f4df7-cfa7-4162-8e5c-3b5c9938dc2b",
    "host.name": "zF11rqFvdaGPLh",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3940,
    "process.parent_pid": 2865,
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
  "trace_id": "a154b35cf22b9fe7ada9f69e4887c6c9",
  "span_id": "8dabcc436820d5a1",
  "parent_span_id": "250ec26cf090ec67",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786148049631851264,
  "time_end": 1786148049647779072,
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
    "service.instance.id": "0369a227-b482-4c8c-95c2-278dfc15795b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b7893289-0a79-4588-907c-085a16341b7b/resourceGroups/azure-westus-general-b7893289-0a79-4588-907c-085a16341b7b/providers/Microsoft.Compute/virtualMachines/zF11rqFvdaGPLh",
    "host.id": "b65f4df7-cfa7-4162-8e5c-3b5c9938dc2b",
    "host.name": "zF11rqFvdaGPLh",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3940,
    "process.parent_pid": 2865,
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
