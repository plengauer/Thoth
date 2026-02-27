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
  "trace_id": "cbaeb73ef13b004f7144ddae7dbe1b7b",
  "span_id": "3362068e2f95d418",
  "parent_span_id": "e9c1bdebab2b5ff9",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1771893785942163849,
  "time_end": 1771893786078509606,
  "attributes": {
    "server.address": "example.com",
    "http.response.status_code": 200,
    "network.protocol.version": "1.1",
    "thread.id": 1,
    "http.request.method": "GET",
    "url.full": "http://example.com",
    "thread.name": "main"
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "runnervmwffz4",
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
    "process.pid": 4463,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.18+8",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.18+8",
    "service.instance.id": "72922cf1-9f83-4498-a575-1dba5ccbed38",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.25.0",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.59.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "cbaeb73ef13b004f7144ddae7dbe1b7b",
  "span_id": "bdabaddce1375634",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1771893780350738432,
  "time_end": 1771893786343946752,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.45.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/413b73db-ce3e-47fb-ab8c-8294b01275e5/resourceGroups/azure-westus-general-413b73db-ce3e-47fb-ab8c-8294b01275e5/providers/Microsoft.Compute/virtualMachines/pBcyhY2eOyPqY3",
    "host.id": "ed56e37c-71cb-4556-8e50-84d3f721fed7",
    "host.name": "pBcyhY2eOyPqY3",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ed56e37c-71cb-4556-8e50-84d3f721fed7",
    "process.pid": 3642,
    "process.parent_pid": 2560,
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
  "trace_id": "cbaeb73ef13b004f7144ddae7dbe1b7b",
  "span_id": "e9c1bdebab2b5ff9",
  "parent_span_id": "bdabaddce1375634",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771893782051853824,
  "time_end": 1771893786322569728,
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
    "telemetry.sdk.version": "5.45.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/413b73db-ce3e-47fb-ab8c-8294b01275e5/resourceGroups/azure-westus-general-413b73db-ce3e-47fb-ab8c-8294b01275e5/providers/Microsoft.Compute/virtualMachines/pBcyhY2eOyPqY3",
    "host.id": "ed56e37c-71cb-4556-8e50-84d3f721fed7",
    "host.name": "pBcyhY2eOyPqY3",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ed56e37c-71cb-4556-8e50-84d3f721fed7",
    "process.pid": 3642,
    "process.parent_pid": 2560,
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
  "trace_id": "cbaeb73ef13b004f7144ddae7dbe1b7b",
  "span_id": "94ea6b60d7654e5d",
  "parent_span_id": "bdabaddce1375634",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771893780362187776,
  "time_end": 1771893782047237120,
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
    "telemetry.sdk.version": "5.45.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/413b73db-ce3e-47fb-ab8c-8294b01275e5/resourceGroups/azure-westus-general-413b73db-ce3e-47fb-ab8c-8294b01275e5/providers/Microsoft.Compute/virtualMachines/pBcyhY2eOyPqY3",
    "host.id": "ed56e37c-71cb-4556-8e50-84d3f721fed7",
    "host.name": "pBcyhY2eOyPqY3",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ed56e37c-71cb-4556-8e50-84d3f721fed7",
    "process.pid": 3642,
    "process.parent_pid": 2560,
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
  "trace_id": "cbaeb73ef13b004f7144ddae7dbe1b7b",
  "span_id": "4a5b1c36835f85c5",
  "parent_span_id": "bdabaddce1375634",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771893786327712000,
  "time_end": 1771893786343775488,
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
    "telemetry.sdk.version": "5.45.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/413b73db-ce3e-47fb-ab8c-8294b01275e5/resourceGroups/azure-westus-general-413b73db-ce3e-47fb-ab8c-8294b01275e5/providers/Microsoft.Compute/virtualMachines/pBcyhY2eOyPqY3",
    "host.id": "ed56e37c-71cb-4556-8e50-84d3f721fed7",
    "host.name": "pBcyhY2eOyPqY3",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ed56e37c-71cb-4556-8e50-84d3f721fed7",
    "process.pid": 3642,
    "process.parent_pid": 2560,
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
