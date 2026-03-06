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
  "trace_id": "3c06964ca70f6a2a0cbf978fd7fc83c4",
  "span_id": "edf6e19716eee886",
  "parent_span_id": "5b3ac8da6cac0ab0",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772722316566806935,
  "time_end": 1772722316643191649,
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
    "host.name": "runnervm0kj6c",
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
    "process.pid": 4398,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.18+8",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.18+8",
    "service.instance.id": "34d61219-1085-47c1-a240-b4399edec60a",
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
  "trace_id": "3c06964ca70f6a2a0cbf978fd7fc83c4",
  "span_id": "973700151f9274e6",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1772722312240320512,
  "time_end": 1772722316837383680,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/32794b7c-d828-44a0-89f3-66c642761435/resourceGroups/azure-northcentralus-general-32794b7c-d828-44a0-89f3-66c642761435/providers/Microsoft.Compute/virtualMachines/pTIqKouq6wkDF9",
    "host.id": "4c095ef5-b3d1-4fb9-98f3-eb39b76bcc2b",
    "host.name": "pTIqKouq6wkDF9",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "4c095ef5-b3d1-4fb9-98f3-eb39b76bcc2b",
    "process.pid": 3637,
    "process.parent_pid": 2556,
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
  "trace_id": "3c06964ca70f6a2a0cbf978fd7fc83c4",
  "span_id": "5b3ac8da6cac0ab0",
  "parent_span_id": "973700151f9274e6",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722313214626816,
  "time_end": 1772722316814782208,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/32794b7c-d828-44a0-89f3-66c642761435/resourceGroups/azure-northcentralus-general-32794b7c-d828-44a0-89f3-66c642761435/providers/Microsoft.Compute/virtualMachines/pTIqKouq6wkDF9",
    "host.id": "4c095ef5-b3d1-4fb9-98f3-eb39b76bcc2b",
    "host.name": "pTIqKouq6wkDF9",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "4c095ef5-b3d1-4fb9-98f3-eb39b76bcc2b",
    "process.pid": 3637,
    "process.parent_pid": 2556,
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
  "trace_id": "3c06964ca70f6a2a0cbf978fd7fc83c4",
  "span_id": "76cca7287d747d08",
  "parent_span_id": "973700151f9274e6",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722312253123584,
  "time_end": 1772722313209660672,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/32794b7c-d828-44a0-89f3-66c642761435/resourceGroups/azure-northcentralus-general-32794b7c-d828-44a0-89f3-66c642761435/providers/Microsoft.Compute/virtualMachines/pTIqKouq6wkDF9",
    "host.id": "4c095ef5-b3d1-4fb9-98f3-eb39b76bcc2b",
    "host.name": "pTIqKouq6wkDF9",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "4c095ef5-b3d1-4fb9-98f3-eb39b76bcc2b",
    "process.pid": 3637,
    "process.parent_pid": 2556,
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
  "trace_id": "3c06964ca70f6a2a0cbf978fd7fc83c4",
  "span_id": "610fe8da8c4b57de",
  "parent_span_id": "973700151f9274e6",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722316820251648,
  "time_end": 1772722316837169664,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/32794b7c-d828-44a0-89f3-66c642761435/resourceGroups/azure-northcentralus-general-32794b7c-d828-44a0-89f3-66c642761435/providers/Microsoft.Compute/virtualMachines/pTIqKouq6wkDF9",
    "host.id": "4c095ef5-b3d1-4fb9-98f3-eb39b76bcc2b",
    "host.name": "pTIqKouq6wkDF9",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "4c095ef5-b3d1-4fb9-98f3-eb39b76bcc2b",
    "process.pid": 3637,
    "process.parent_pid": 2556,
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
