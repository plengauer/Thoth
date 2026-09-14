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
  "trace_id": "e8971fc819a0d30d49e36eabe17f4e5b",
  "span_id": "5d88402fe48c450c",
  "parent_span_id": "b09988b2edb32725",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789140987154553832,
  "time_end": 1789140987257851638,
  "attributes": {
    "server.port": 80,
    "url.full": "http://example.com",
    "server.address": "example.com",
    "http.request.method": "GET",
    "thread.id": 1,
    "thread.name": "main",
    "http.response.status_code": 200,
    "network.protocol.version": "1.1"
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "runnervmlun5p",
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
    "process.pid": 4474,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.20.1+1",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.20.1+1",
    "service.instance.id": "ee6ce1cc-12df-4f18-a698-0c2c6fd26aca",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.31.1",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.65.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "e8971fc819a0d30d49e36eabe17f4e5b",
  "span_id": "8b23a1082e53e0d8",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1789140983121875456,
  "time_end": 1789140987726476288,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "0178a89e-3469-428c-a637-17d489269193",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/1b81a300-6f1d-4a2a-8639-a65857d71bc5/resourceGroups/azure-westus3-general-1b81a300-6f1d-4a2a-8639-a65857d71bc5/providers/Microsoft.Compute/virtualMachines/dWLYyLbEYkve8G",
    "host.id": "60532da7-6192-4306-90f3-b430bb7d180f",
    "host.name": "dWLYyLbEYkve8G",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3736,
    "process.parent_pid": 2679,
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
  "trace_id": "e8971fc819a0d30d49e36eabe17f4e5b",
  "span_id": "b09988b2edb32725",
  "parent_span_id": "8b23a1082e53e0d8",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789140983849550080,
  "time_end": 1789140987716735488,
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
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "0178a89e-3469-428c-a637-17d489269193",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/1b81a300-6f1d-4a2a-8639-a65857d71bc5/resourceGroups/azure-westus3-general-1b81a300-6f1d-4a2a-8639-a65857d71bc5/providers/Microsoft.Compute/virtualMachines/dWLYyLbEYkve8G",
    "host.id": "60532da7-6192-4306-90f3-b430bb7d180f",
    "host.name": "dWLYyLbEYkve8G",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3736,
    "process.parent_pid": 2679,
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
  "trace_id": "e8971fc819a0d30d49e36eabe17f4e5b",
  "span_id": "c97b8c294e095312",
  "parent_span_id": "8b23a1082e53e0d8",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789140983127932928,
  "time_end": 1789140983846344960,
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
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "0178a89e-3469-428c-a637-17d489269193",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/1b81a300-6f1d-4a2a-8639-a65857d71bc5/resourceGroups/azure-westus3-general-1b81a300-6f1d-4a2a-8639-a65857d71bc5/providers/Microsoft.Compute/virtualMachines/dWLYyLbEYkve8G",
    "host.id": "60532da7-6192-4306-90f3-b430bb7d180f",
    "host.name": "dWLYyLbEYkve8G",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3736,
    "process.parent_pid": 2679,
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
  "trace_id": "e8971fc819a0d30d49e36eabe17f4e5b",
  "span_id": "5bc4912ad1b3fef9",
  "parent_span_id": "8b23a1082e53e0d8",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789140987720350464,
  "time_end": 1789140987726339840,
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
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "0178a89e-3469-428c-a637-17d489269193",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/1b81a300-6f1d-4a2a-8639-a65857d71bc5/resourceGroups/azure-westus3-general-1b81a300-6f1d-4a2a-8639-a65857d71bc5/providers/Microsoft.Compute/virtualMachines/dWLYyLbEYkve8G",
    "host.id": "60532da7-6192-4306-90f3-b430bb7d180f",
    "host.name": "dWLYyLbEYkve8G",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3736,
    "process.parent_pid": 2679,
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
