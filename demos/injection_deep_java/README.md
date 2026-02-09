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
  "trace_id": "a4bdab4009982c018b5167bae93c76cc",
  "span_id": "f0e0f186c70c4358",
  "parent_span_id": "f5a7b4a298251755",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1769886963564546614,
  "time_end": 1769886963659318523,
  "attributes": {
    "url.full": "http://example.com",
    "thread.name": "main",
    "http.response.status_code": 200,
    "server.address": "example.com",
    "thread.id": 1,
    "network.protocol.version": "1.1",
    "http.request.method": "GET"
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "runnervmkj6or",
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
    "process.pid": 4367,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.18+8",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.18+8",
    "service.instance.id": "5fc9c862-43c2-4a50-bdd3-def2b7f89cb5",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.23.0",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.57.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "a4bdab4009982c018b5167bae93c76cc",
  "span_id": "79411cc33cbdd56a",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1769886959668965632,
  "time_end": 1769886963847542528,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.42.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/94ad5a36-77d3-4e48-b596-4facd35823e8/resourceGroups/azure-centralus-general-94ad5a36-77d3-4e48-b596-4facd35823e8/providers/Microsoft.Compute/virtualMachines/GwVdqUNmzOhMcH",
    "host.id": "5f28882c-09e4-4260-87e1-adb681f0fc71",
    "host.name": "GwVdqUNmzOhMcH",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "5f28882c-09e4-4260-87e1-adb681f0fc71",
    "process.pid": 3546,
    "process.parent_pid": 2464,
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
  "trace_id": "a4bdab4009982c018b5167bae93c76cc",
  "span_id": "f5a7b4a298251755",
  "parent_span_id": "79411cc33cbdd56a",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769886960562643968,
  "time_end": 1769886963827422720,
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
    "telemetry.sdk.version": "5.42.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/94ad5a36-77d3-4e48-b596-4facd35823e8/resourceGroups/azure-centralus-general-94ad5a36-77d3-4e48-b596-4facd35823e8/providers/Microsoft.Compute/virtualMachines/GwVdqUNmzOhMcH",
    "host.id": "5f28882c-09e4-4260-87e1-adb681f0fc71",
    "host.name": "GwVdqUNmzOhMcH",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "5f28882c-09e4-4260-87e1-adb681f0fc71",
    "process.pid": 3546,
    "process.parent_pid": 2464,
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
  "trace_id": "a4bdab4009982c018b5167bae93c76cc",
  "span_id": "9879115b39aad79a",
  "parent_span_id": "79411cc33cbdd56a",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769886959680128256,
  "time_end": 1769886960558427136,
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
    "telemetry.sdk.version": "5.42.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/94ad5a36-77d3-4e48-b596-4facd35823e8/resourceGroups/azure-centralus-general-94ad5a36-77d3-4e48-b596-4facd35823e8/providers/Microsoft.Compute/virtualMachines/GwVdqUNmzOhMcH",
    "host.id": "5f28882c-09e4-4260-87e1-adb681f0fc71",
    "host.name": "GwVdqUNmzOhMcH",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "5f28882c-09e4-4260-87e1-adb681f0fc71",
    "process.pid": 3546,
    "process.parent_pid": 2464,
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
  "trace_id": "a4bdab4009982c018b5167bae93c76cc",
  "span_id": "0dc35383fd04898f",
  "parent_span_id": "79411cc33cbdd56a",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769886963832333568,
  "time_end": 1769886963847358720,
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
    "telemetry.sdk.version": "5.42.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/94ad5a36-77d3-4e48-b596-4facd35823e8/resourceGroups/azure-centralus-general-94ad5a36-77d3-4e48-b596-4facd35823e8/providers/Microsoft.Compute/virtualMachines/GwVdqUNmzOhMcH",
    "host.id": "5f28882c-09e4-4260-87e1-adb681f0fc71",
    "host.name": "GwVdqUNmzOhMcH",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "5f28882c-09e4-4260-87e1-adb681f0fc71",
    "process.pid": 3546,
    "process.parent_pid": 2464,
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
