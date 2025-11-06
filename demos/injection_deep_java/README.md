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
  "trace_id": "5dc69f150d1af4efcce2591b8f8d2da1",
  "span_id": "3a61ad82067b8327",
  "parent_span_id": "957a5432f8309217",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1762433312130144114,
  "time_end": 1762433312198218668,
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
    "process.pid": 4856,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.17+10",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.17+10",
    "service.instance.id": "9df53d12-23c3-4850-aa51-b893be88271d",
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
  "trace_id": "5dc69f150d1af4efcce2591b8f8d2da1",
  "span_id": "8da60d4900f7c4b2",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1762433308221468928,
  "time_end": 1762433312382929152,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/3651f01f-01fb-424c-af06-a89e70b71134/resourceGroups/azure-eastus2-general-3651f01f-01fb-424c-af06-a89e70b71134/providers/Microsoft.Compute/virtualMachines/6bwTQXTBJF8VWD",
    "host.id": "041f1a1c-b937-4873-bd3d-4898f0798050",
    "host.name": "6bwTQXTBJF8VWD",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "041f1a1c-b937-4873-bd3d-4898f0798050",
    "process.pid": 4013,
    "process.parent_pid": 2365,
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
  "trace_id": "5dc69f150d1af4efcce2591b8f8d2da1",
  "span_id": "957a5432f8309217",
  "parent_span_id": "8da60d4900f7c4b2",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762433309086594560,
  "time_end": 1762433312361056000,
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
    "telemetry.sdk.version": "5.33.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/3651f01f-01fb-424c-af06-a89e70b71134/resourceGroups/azure-eastus2-general-3651f01f-01fb-424c-af06-a89e70b71134/providers/Microsoft.Compute/virtualMachines/6bwTQXTBJF8VWD",
    "host.id": "041f1a1c-b937-4873-bd3d-4898f0798050",
    "host.name": "6bwTQXTBJF8VWD",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "041f1a1c-b937-4873-bd3d-4898f0798050",
    "process.pid": 4013,
    "process.parent_pid": 2365,
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
  "trace_id": "5dc69f150d1af4efcce2591b8f8d2da1",
  "span_id": "9a5a8c98f713790f",
  "parent_span_id": "8da60d4900f7c4b2",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762433308233880320,
  "time_end": 1762433309082261760,
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
    "telemetry.sdk.version": "5.33.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/3651f01f-01fb-424c-af06-a89e70b71134/resourceGroups/azure-eastus2-general-3651f01f-01fb-424c-af06-a89e70b71134/providers/Microsoft.Compute/virtualMachines/6bwTQXTBJF8VWD",
    "host.id": "041f1a1c-b937-4873-bd3d-4898f0798050",
    "host.name": "6bwTQXTBJF8VWD",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "041f1a1c-b937-4873-bd3d-4898f0798050",
    "process.pid": 4013,
    "process.parent_pid": 2365,
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
  "trace_id": "5dc69f150d1af4efcce2591b8f8d2da1",
  "span_id": "1d939e9dec10d6d4",
  "parent_span_id": "8da60d4900f7c4b2",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762433312365455360,
  "time_end": 1762433312382793728,
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
    "telemetry.sdk.version": "5.33.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/3651f01f-01fb-424c-af06-a89e70b71134/resourceGroups/azure-eastus2-general-3651f01f-01fb-424c-af06-a89e70b71134/providers/Microsoft.Compute/virtualMachines/6bwTQXTBJF8VWD",
    "host.id": "041f1a1c-b937-4873-bd3d-4898f0798050",
    "host.name": "6bwTQXTBJF8VWD",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "041f1a1c-b937-4873-bd3d-4898f0798050",
    "process.pid": 4013,
    "process.parent_pid": 2365,
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
