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
  "trace_id": "c8d1b233045154ba993cc3bbab2cedd8",
  "span_id": "ad5c74e68653619e",
  "parent_span_id": "cb623b574d6d18a2",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274369102059371,
  "time_end": 1788274369171687316,
  "attributes": {
    "network.protocol.version": "1.1",
    "http.request.method": "GET",
    "server.address": "example.com",
    "server.port": 80,
    "thread.name": "main",
    "url.full": "http://example.com",
    "http.response.status_code": 200,
    "thread.id": 1
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "runnervmgx7h7",
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
    "process.pid": 4674,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.20.1+1",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.20.1+1",
    "service.instance.id": "c1308065-3d95-472a-a246-85a683190e9f",
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
  "trace_id": "c8d1b233045154ba993cc3bbab2cedd8",
  "span_id": "2222d45f6cb2b636",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1788274364469792256,
  "time_end": 1788274369375734272,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "0d4f75bb-56fb-4e22-bae9-773534ba6cba",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e5b640f6-e5d7-4068-b010-34284a62ea24/resourceGroups/azure-westus3-general-e5b640f6-e5d7-4068-b010-34284a62ea24/providers/Microsoft.Compute/virtualMachines/qYTYhtnZeYwk7h",
    "host.id": "7c277410-99f7-4a2b-b14f-77960d305712",
    "host.name": "qYTYhtnZeYwk7h",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3935,
    "process.parent_pid": 2864,
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
  "trace_id": "c8d1b233045154ba993cc3bbab2cedd8",
  "span_id": "cb623b574d6d18a2",
  "parent_span_id": "2222d45f6cb2b636",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274365460813568,
  "time_end": 1788274369364655360,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "0d4f75bb-56fb-4e22-bae9-773534ba6cba",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e5b640f6-e5d7-4068-b010-34284a62ea24/resourceGroups/azure-westus3-general-e5b640f6-e5d7-4068-b010-34284a62ea24/providers/Microsoft.Compute/virtualMachines/qYTYhtnZeYwk7h",
    "host.id": "7c277410-99f7-4a2b-b14f-77960d305712",
    "host.name": "qYTYhtnZeYwk7h",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3935,
    "process.parent_pid": 2864,
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
  "trace_id": "c8d1b233045154ba993cc3bbab2cedd8",
  "span_id": "d1fd717d2704436d",
  "parent_span_id": "2222d45f6cb2b636",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274364476692992,
  "time_end": 1788274365457341440,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "0d4f75bb-56fb-4e22-bae9-773534ba6cba",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e5b640f6-e5d7-4068-b010-34284a62ea24/resourceGroups/azure-westus3-general-e5b640f6-e5d7-4068-b010-34284a62ea24/providers/Microsoft.Compute/virtualMachines/qYTYhtnZeYwk7h",
    "host.id": "7c277410-99f7-4a2b-b14f-77960d305712",
    "host.name": "qYTYhtnZeYwk7h",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3935,
    "process.parent_pid": 2864,
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
  "trace_id": "c8d1b233045154ba993cc3bbab2cedd8",
  "span_id": "84aeab526508d6a7",
  "parent_span_id": "2222d45f6cb2b636",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274369368792832,
  "time_end": 1788274369375587840,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "0d4f75bb-56fb-4e22-bae9-773534ba6cba",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e5b640f6-e5d7-4068-b010-34284a62ea24/resourceGroups/azure-westus3-general-e5b640f6-e5d7-4068-b010-34284a62ea24/providers/Microsoft.Compute/virtualMachines/qYTYhtnZeYwk7h",
    "host.id": "7c277410-99f7-4a2b-b14f-77960d305712",
    "host.name": "qYTYhtnZeYwk7h",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3935,
    "process.parent_pid": 2864,
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
