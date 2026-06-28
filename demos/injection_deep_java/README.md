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
  "trace_id": "f6f69740394364ef0ee22e844391e42f",
  "span_id": "3fdd214728d930f1",
  "parent_span_id": "c51878ee12d9a938",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678129274448226,
  "time_end": 1782678129366561928,
  "attributes": {
    "server.address": "example.com",
    "network.protocol.version": "1.1",
    "http.request.method": "GET",
    "server.port": 80,
    "http.response.status_code": 200,
    "thread.name": "main",
    "url.full": "http://example.com",
    "thread.id": 1
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "runnervmmklqx",
    "os.description": "Linux 6.17.0-1018-azure",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.command_args": [
      "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/gradlehttppropagationagent.jar",
      "Main"
    ],
    "process.executable.path": "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
    "process.pid": 4653,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.19+10",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.19+10",
    "service.instance.id": "58d976b4-5edb-4cc6-a9ac-d5da44c24398",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.29.0",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.63.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "f6f69740394364ef0ee22e844391e42f",
  "span_id": "1def256d0a8e976f",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1782678124858044928,
  "time_end": 1782678129568332288,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "46195e6c-ab80-40a9-b492-fc5aeda1b437",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/89d77390-53da-461d-981a-b0557a162247/resourceGroups/azure-westus3-general-89d77390-53da-461d-981a-b0557a162247/providers/Microsoft.Compute/virtualMachines/i5xavFs5drB7kv",
    "host.id": "a03de259-3568-45be-885f-e700cbeaad2d",
    "host.name": "i5xavFs5drB7kv",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3899,
    "process.parent_pid": 2809,
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
  "trace_id": "f6f69740394364ef0ee22e844391e42f",
  "span_id": "c51878ee12d9a938",
  "parent_span_id": "1def256d0a8e976f",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678125755841280,
  "time_end": 1782678129551124992,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "46195e6c-ab80-40a9-b492-fc5aeda1b437",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/89d77390-53da-461d-981a-b0557a162247/resourceGroups/azure-westus3-general-89d77390-53da-461d-981a-b0557a162247/providers/Microsoft.Compute/virtualMachines/i5xavFs5drB7kv",
    "host.id": "a03de259-3568-45be-885f-e700cbeaad2d",
    "host.name": "i5xavFs5drB7kv",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3899,
    "process.parent_pid": 2809,
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
  "trace_id": "f6f69740394364ef0ee22e844391e42f",
  "span_id": "51496b4e90ecb722",
  "parent_span_id": "1def256d0a8e976f",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678124869195008,
  "time_end": 1782678125751913216,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "46195e6c-ab80-40a9-b492-fc5aeda1b437",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/89d77390-53da-461d-981a-b0557a162247/resourceGroups/azure-westus3-general-89d77390-53da-461d-981a-b0557a162247/providers/Microsoft.Compute/virtualMachines/i5xavFs5drB7kv",
    "host.id": "a03de259-3568-45be-885f-e700cbeaad2d",
    "host.name": "i5xavFs5drB7kv",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3899,
    "process.parent_pid": 2809,
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
  "trace_id": "f6f69740394364ef0ee22e844391e42f",
  "span_id": "b8cd31c7f1c59cd8",
  "parent_span_id": "1def256d0a8e976f",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678129555551744,
  "time_end": 1782678129568174848,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "46195e6c-ab80-40a9-b492-fc5aeda1b437",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/89d77390-53da-461d-981a-b0557a162247/resourceGroups/azure-westus3-general-89d77390-53da-461d-981a-b0557a162247/providers/Microsoft.Compute/virtualMachines/i5xavFs5drB7kv",
    "host.id": "a03de259-3568-45be-885f-e700cbeaad2d",
    "host.name": "i5xavFs5drB7kv",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3899,
    "process.parent_pid": 2809,
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
