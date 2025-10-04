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
  "trace_id": "b5e335b41d97ad62eb67e483280449dd",
  "span_id": "5961db7f3ec571a1",
  "parent_span_id": "40d87e0aa120cb67",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1759515289478796601,
  "time_end": 1759515289642972022,
  "attributes": {
    "thread.name": "main",
    "url.full": "http://example.com",
    "http.response.status_code": 200,
    "thread.id": 1,
    "network.protocol.version": "1.1",
    "http.request.method": "GET",
    "server.address": "example.com"
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "runnervm3ublj",
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
    "process.pid": 4845,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.16+8",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.16+8",
    "service.instance.id": "815248ef-5df9-4ad5-90a4-670a8fc7c4a7",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.20.1",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.54.1"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "b5e335b41d97ad62eb67e483280449dd",
  "span_id": "72e2ae659b34e19f",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1759515283287568128,
  "time_end": 1759515289859538944,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.28.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/99271023-a1ec-455b-a1ed-1bf7658a12d7/resourceGroups/azure-northcentralus-general-99271023-a1ec-455b-a1ed-1bf7658a12d7/providers/Microsoft.Compute/virtualMachines/I8iQT14QehpCdK",
    "host.id": "6f7b8c53-de75-4b86-9072-a2f14cc07bef",
    "host.name": "I8iQT14QehpCdK",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3995,
    "process.parent_pid": 2367,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "b5e335b41d97ad62eb67e483280449dd",
  "span_id": "40d87e0aa120cb67",
  "parent_span_id": "72e2ae659b34e19f",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759515284820345344,
  "time_end": 1759515289837732864,
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
    "telemetry.sdk.version": "5.28.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/99271023-a1ec-455b-a1ed-1bf7658a12d7/resourceGroups/azure-northcentralus-general-99271023-a1ec-455b-a1ed-1bf7658a12d7/providers/Microsoft.Compute/virtualMachines/I8iQT14QehpCdK",
    "host.id": "6f7b8c53-de75-4b86-9072-a2f14cc07bef",
    "host.name": "I8iQT14QehpCdK",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3995,
    "process.parent_pid": 2367,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "b5e335b41d97ad62eb67e483280449dd",
  "span_id": "7b7112d51b0c39d3",
  "parent_span_id": "72e2ae659b34e19f",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759515283299733760,
  "time_end": 1759515284816084480,
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
    "telemetry.sdk.version": "5.28.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/99271023-a1ec-455b-a1ed-1bf7658a12d7/resourceGroups/azure-northcentralus-general-99271023-a1ec-455b-a1ed-1bf7658a12d7/providers/Microsoft.Compute/virtualMachines/I8iQT14QehpCdK",
    "host.id": "6f7b8c53-de75-4b86-9072-a2f14cc07bef",
    "host.name": "I8iQT14QehpCdK",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3995,
    "process.parent_pid": 2367,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "b5e335b41d97ad62eb67e483280449dd",
  "span_id": "332cc2cdef7b67ac",
  "parent_span_id": "72e2ae659b34e19f",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759515289842127360,
  "time_end": 1759515289859329792,
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
    "telemetry.sdk.version": "5.28.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/99271023-a1ec-455b-a1ed-1bf7658a12d7/resourceGroups/azure-northcentralus-general-99271023-a1ec-455b-a1ed-1bf7658a12d7/providers/Microsoft.Compute/virtualMachines/I8iQT14QehpCdK",
    "host.id": "6f7b8c53-de75-4b86-9072-a2f14cc07bef",
    "host.name": "I8iQT14QehpCdK",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3995,
    "process.parent_pid": 2367,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": ""
  },
  "links": [],
  "events": []
}
```
