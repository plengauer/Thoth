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
  "trace_id": "285ef69fbae894f9e869b3bcd6ed7822",
  "span_id": "e28bbc52e48c9379",
  "parent_span_id": "654c66148156a147",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1759818594948206737,
  "time_end": 1759818595159583237,
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
    "host.name": "runnervmwhb2z",
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
    "process.pid": 4840,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.16+8",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.16+8",
    "service.instance.id": "97c5e98c-a99f-4fc0-913d-86b1cadd2ff9",
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
  "trace_id": "285ef69fbae894f9e869b3bcd6ed7822",
  "span_id": "570312b235ba2eb3",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1759818591675425792,
  "time_end": 1759818595320259072,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.29.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/31449e13-9b5a-4a04-97db-0489ef89d191/resourceGroups/azure-northcentralus-general-31449e13-9b5a-4a04-97db-0489ef89d191/providers/Microsoft.Compute/virtualMachines/pUDd3age93V37c",
    "host.id": "622e66b7-04ab-47a1-bf9e-3ba6078dcdb3",
    "host.name": "pUDd3age93V37c",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3990,
    "process.parent_pid": 2362,
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
  "trace_id": "285ef69fbae894f9e869b3bcd6ed7822",
  "span_id": "654c66148156a147",
  "parent_span_id": "570312b235ba2eb3",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759818592202168320,
  "time_end": 1759818595301818112,
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
    "telemetry.sdk.version": "5.29.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/31449e13-9b5a-4a04-97db-0489ef89d191/resourceGroups/azure-northcentralus-general-31449e13-9b5a-4a04-97db-0489ef89d191/providers/Microsoft.Compute/virtualMachines/pUDd3age93V37c",
    "host.id": "622e66b7-04ab-47a1-bf9e-3ba6078dcdb3",
    "host.name": "pUDd3age93V37c",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3990,
    "process.parent_pid": 2362,
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
  "trace_id": "285ef69fbae894f9e869b3bcd6ed7822",
  "span_id": "561a8b1d230838e8",
  "parent_span_id": "570312b235ba2eb3",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759818591685788928,
  "time_end": 1759818592198308608,
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
    "telemetry.sdk.version": "5.29.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/31449e13-9b5a-4a04-97db-0489ef89d191/resourceGroups/azure-northcentralus-general-31449e13-9b5a-4a04-97db-0489ef89d191/providers/Microsoft.Compute/virtualMachines/pUDd3age93V37c",
    "host.id": "622e66b7-04ab-47a1-bf9e-3ba6078dcdb3",
    "host.name": "pUDd3age93V37c",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3990,
    "process.parent_pid": 2362,
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
  "trace_id": "285ef69fbae894f9e869b3bcd6ed7822",
  "span_id": "9c378c1147749e88",
  "parent_span_id": "570312b235ba2eb3",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759818595305740544,
  "time_end": 1759818595320140288,
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
    "telemetry.sdk.version": "5.29.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/31449e13-9b5a-4a04-97db-0489ef89d191/resourceGroups/azure-northcentralus-general-31449e13-9b5a-4a04-97db-0489ef89d191/providers/Microsoft.Compute/virtualMachines/pUDd3age93V37c",
    "host.id": "622e66b7-04ab-47a1-bf9e-3ba6078dcdb3",
    "host.name": "pUDd3age93V37c",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3990,
    "process.parent_pid": 2362,
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
