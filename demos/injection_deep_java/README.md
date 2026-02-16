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
  "trace_id": "1d1eeebd5485dc8007230f3315da2472",
  "span_id": "6f27f5e0a3c22f75",
  "parent_span_id": "f0a20ac475a3c705",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1770978751045473280,
  "time_end": 1770978751118605953,
  "attributes": {
    "server.address": "example.com",
    "http.request.method": "GET",
    "network.protocol.version": "1.1",
    "http.response.status_code": 200,
    "thread.id": 1,
    "thread.name": "main",
    "url.full": "http://example.com"
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "runnervmjduv7",
    "os.description": "Linux 6.14.0-1017-azure",
    "os.type": "linux",
    "process.command_args": [
      "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar",
      "Main"
    ],
    "process.executable.path": "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
    "process.pid": 4383,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.18+8",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.18+8",
    "service.instance.id": "e413e429-62fa-4965-85a6-f5867925c9e2",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.24.0",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.58.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "1d1eeebd5485dc8007230f3315da2472",
  "span_id": "9e27162f79768449",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1770978747266760448,
  "time_end": 1770978751325963776,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/f1ddb7e7-7b8c-4e4f-abdd-90ae9319a6d7/resourceGroups/azure-centralus-general-f1ddb7e7-7b8c-4e4f-abdd-90ae9319a6d7/providers/Microsoft.Compute/virtualMachines/kWsHlbV5EtQIq0",
    "host.id": "9e4c3a5e-8ebf-4329-91a4-b7adbced71c8",
    "host.name": "kWsHlbV5EtQIq0",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "9e4c3a5e-8ebf-4329-91a4-b7adbced71c8",
    "process.pid": 3562,
    "process.parent_pid": 2482,
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
  "trace_id": "1d1eeebd5485dc8007230f3315da2472",
  "span_id": "f0a20ac475a3c705",
  "parent_span_id": "9e27162f79768449",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978748061255680,
  "time_end": 1770978751303627776,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/f1ddb7e7-7b8c-4e4f-abdd-90ae9319a6d7/resourceGroups/azure-centralus-general-f1ddb7e7-7b8c-4e4f-abdd-90ae9319a6d7/providers/Microsoft.Compute/virtualMachines/kWsHlbV5EtQIq0",
    "host.id": "9e4c3a5e-8ebf-4329-91a4-b7adbced71c8",
    "host.name": "kWsHlbV5EtQIq0",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "9e4c3a5e-8ebf-4329-91a4-b7adbced71c8",
    "process.pid": 3562,
    "process.parent_pid": 2482,
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
  "trace_id": "1d1eeebd5485dc8007230f3315da2472",
  "span_id": "b9e8c5ea92f4b342",
  "parent_span_id": "9e27162f79768449",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978747279766528,
  "time_end": 1770978748056480768,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/f1ddb7e7-7b8c-4e4f-abdd-90ae9319a6d7/resourceGroups/azure-centralus-general-f1ddb7e7-7b8c-4e4f-abdd-90ae9319a6d7/providers/Microsoft.Compute/virtualMachines/kWsHlbV5EtQIq0",
    "host.id": "9e4c3a5e-8ebf-4329-91a4-b7adbced71c8",
    "host.name": "kWsHlbV5EtQIq0",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "9e4c3a5e-8ebf-4329-91a4-b7adbced71c8",
    "process.pid": 3562,
    "process.parent_pid": 2482,
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
  "trace_id": "1d1eeebd5485dc8007230f3315da2472",
  "span_id": "af73cafee8a08923",
  "parent_span_id": "9e27162f79768449",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978751309051136,
  "time_end": 1770978751325774336,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/f1ddb7e7-7b8c-4e4f-abdd-90ae9319a6d7/resourceGroups/azure-centralus-general-f1ddb7e7-7b8c-4e4f-abdd-90ae9319a6d7/providers/Microsoft.Compute/virtualMachines/kWsHlbV5EtQIq0",
    "host.id": "9e4c3a5e-8ebf-4329-91a4-b7adbced71c8",
    "host.name": "kWsHlbV5EtQIq0",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "9e4c3a5e-8ebf-4329-91a4-b7adbced71c8",
    "process.pid": 3562,
    "process.parent_pid": 2482,
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
