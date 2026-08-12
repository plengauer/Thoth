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
  "trace_id": "cd1407e041f866cb173946bd81da96ed",
  "span_id": "8aaad115c4772827",
  "parent_span_id": "cb296780b4eb74c6",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264507574650268,
  "time_end": 1786264507670101657,
  "attributes": {
    "server.port": 80,
    "server.address": "example.com",
    "http.response.status_code": 200,
    "network.protocol.version": "1.1",
    "http.request.method": "GET",
    "thread.id": 1,
    "thread.name": "main",
    "url.full": "http://example.com"
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
    "process.pid": 4677,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.19+10",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.19+10",
    "service.instance.id": "05ff9807-b666-4c32-b697-7390ee222fa2",
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
  "trace_id": "cd1407e041f866cb173946bd81da96ed",
  "span_id": "6b75a0237a7810be",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786264502583704320,
  "time_end": 1786264507898023168,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "3f31059b-f665-425b-8318-e6da1b72aa00",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/b566b91c-c6e5-4387-bd92-f864e8592a94/resourceGroups/azure-eastus2-general-b566b91c-c6e5-4387-bd92-f864e8592a94/providers/Microsoft.Compute/virtualMachines/LswVXM9Kyev2Vh",
    "host.id": "f349c43b-ee9c-430f-8a50-a0efdf3d6c65",
    "host.name": "LswVXM9Kyev2Vh",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3920,
    "process.parent_pid": 2851,
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
  "trace_id": "cd1407e041f866cb173946bd81da96ed",
  "span_id": "cb296780b4eb74c6",
  "parent_span_id": "6b75a0237a7810be",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264503752728064,
  "time_end": 1786264507875500032,
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
    "service.instance.id": "3f31059b-f665-425b-8318-e6da1b72aa00",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/b566b91c-c6e5-4387-bd92-f864e8592a94/resourceGroups/azure-eastus2-general-b566b91c-c6e5-4387-bd92-f864e8592a94/providers/Microsoft.Compute/virtualMachines/LswVXM9Kyev2Vh",
    "host.id": "f349c43b-ee9c-430f-8a50-a0efdf3d6c65",
    "host.name": "LswVXM9Kyev2Vh",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3920,
    "process.parent_pid": 2851,
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
  "trace_id": "cd1407e041f866cb173946bd81da96ed",
  "span_id": "ce9fdea15f33daa6",
  "parent_span_id": "6b75a0237a7810be",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264502596122368,
  "time_end": 1786264503747694848,
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
    "service.instance.id": "3f31059b-f665-425b-8318-e6da1b72aa00",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/b566b91c-c6e5-4387-bd92-f864e8592a94/resourceGroups/azure-eastus2-general-b566b91c-c6e5-4387-bd92-f864e8592a94/providers/Microsoft.Compute/virtualMachines/LswVXM9Kyev2Vh",
    "host.id": "f349c43b-ee9c-430f-8a50-a0efdf3d6c65",
    "host.name": "LswVXM9Kyev2Vh",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3920,
    "process.parent_pid": 2851,
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
  "trace_id": "cd1407e041f866cb173946bd81da96ed",
  "span_id": "20f5a39a424b7097",
  "parent_span_id": "6b75a0237a7810be",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264507881110272,
  "time_end": 1786264507897868544,
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
    "service.instance.id": "3f31059b-f665-425b-8318-e6da1b72aa00",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/b566b91c-c6e5-4387-bd92-f864e8592a94/resourceGroups/azure-eastus2-general-b566b91c-c6e5-4387-bd92-f864e8592a94/providers/Microsoft.Compute/virtualMachines/LswVXM9Kyev2Vh",
    "host.id": "f349c43b-ee9c-430f-8a50-a0efdf3d6c65",
    "host.name": "LswVXM9Kyev2Vh",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3920,
    "process.parent_pid": 2851,
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
