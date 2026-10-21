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
  "trace_id": "4a515acda62c1de03c1f1825e138c4b7",
  "span_id": "98f7bf6b73467ba3",
  "parent_span_id": "be6b2f730059db9b",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1792566663421797897,
  "time_end": 1792566663510779950,
  "attributes": {
    "http.request.method": "GET",
    "server.address": "example.com",
    "server.port": 80,
    "url.full": "http://example.com",
    "thread.id": 1,
    "thread.name": "main",
    "http.response.status_code": 200,
    "network.protocol.version": "1.1"
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "runnervm8k3b6",
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
    "process.pid": 4672,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.20.1+1",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.20.1+1",
    "service.instance.id": "03608b09-0956-4cb1-8ae3-c62ee1a0ea49",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.32.0",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.66.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "4a515acda62c1de03c1f1825e138c4b7",
  "span_id": "e1f97a04e8a639ef",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1792566657898321664,
  "time_end": 1792566663663810816,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "86a92f76-5ac5-42ea-a0c4-8d60bb8f9f1c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/0c983385-d2c2-42da-8954-df639182a455/resourceGroups/azure-westus3-general-0c983385-d2c2-42da-8954-df639182a455/providers/Microsoft.Compute/virtualMachines/YvI3Vz2i6PSNMA",
    "host.id": "437c38fa-cca0-4d67-8aeb-63d1c13f19a7",
    "host.name": "YvI3Vz2i6PSNMA",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3934,
    "process.parent_pid": 2926,
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
  "trace_id": "4a515acda62c1de03c1f1825e138c4b7",
  "span_id": "be6b2f730059db9b",
  "parent_span_id": "e1f97a04e8a639ef",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566658896798720,
  "time_end": 1792566663652682752,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "86a92f76-5ac5-42ea-a0c4-8d60bb8f9f1c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/0c983385-d2c2-42da-8954-df639182a455/resourceGroups/azure-westus3-general-0c983385-d2c2-42da-8954-df639182a455/providers/Microsoft.Compute/virtualMachines/YvI3Vz2i6PSNMA",
    "host.id": "437c38fa-cca0-4d67-8aeb-63d1c13f19a7",
    "host.name": "YvI3Vz2i6PSNMA",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3934,
    "process.parent_pid": 2926,
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
  "trace_id": "4a515acda62c1de03c1f1825e138c4b7",
  "span_id": "a1518cbf735b25c1",
  "parent_span_id": "e1f97a04e8a639ef",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566657905147392,
  "time_end": 1792566658893315584,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "86a92f76-5ac5-42ea-a0c4-8d60bb8f9f1c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/0c983385-d2c2-42da-8954-df639182a455/resourceGroups/azure-westus3-general-0c983385-d2c2-42da-8954-df639182a455/providers/Microsoft.Compute/virtualMachines/YvI3Vz2i6PSNMA",
    "host.id": "437c38fa-cca0-4d67-8aeb-63d1c13f19a7",
    "host.name": "YvI3Vz2i6PSNMA",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3934,
    "process.parent_pid": 2926,
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
  "trace_id": "4a515acda62c1de03c1f1825e138c4b7",
  "span_id": "e44edce7a9e2c328",
  "parent_span_id": "e1f97a04e8a639ef",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566663656751360,
  "time_end": 1792566663663666688,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "86a92f76-5ac5-42ea-a0c4-8d60bb8f9f1c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/0c983385-d2c2-42da-8954-df639182a455/resourceGroups/azure-westus3-general-0c983385-d2c2-42da-8954-df639182a455/providers/Microsoft.Compute/virtualMachines/YvI3Vz2i6PSNMA",
    "host.id": "437c38fa-cca0-4d67-8aeb-63d1c13f19a7",
    "host.name": "YvI3Vz2i6PSNMA",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3934,
    "process.parent_pid": 2926,
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
