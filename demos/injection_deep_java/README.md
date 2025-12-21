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
  "trace_id": "23de5af00e493b703f86cfbe9c5a86a3",
  "span_id": "17bd17cbcd8ee9b6",
  "parent_span_id": "163dbb32a48a5af7",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1764539056972334840,
  "time_end": 1764539057209183652,
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
    "host.name": "runnervmg1sw1",
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
    "process.pid": 4289,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.17+10",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.17+10",
    "service.instance.id": "1a24576f-2563-4665-a57b-ebced8398170",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.22.0",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.56.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "23de5af00e493b703f86cfbe9c5a86a3",
  "span_id": "5f79371d6975bc7b",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1764539052022781952,
  "time_end": 1764539057453031680,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/8739ee50-1e98-4c80-88ee-fce828560fdd/resourceGroups/azure-eastus2-general-8739ee50-1e98-4c80-88ee-fce828560fdd/providers/Microsoft.Compute/virtualMachines/a0MZ4HB0Hbzvya",
    "host.id": "db430942-dc49-4710-90cb-6c41a3a68d40",
    "host.name": "a0MZ4HB0Hbzvya",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "db430942-dc49-4710-90cb-6c41a3a68d40",
    "process.pid": 3467,
    "process.parent_pid": 2390,
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
  "trace_id": "23de5af00e493b703f86cfbe9c5a86a3",
  "span_id": "163dbb32a48a5af7",
  "parent_span_id": "5f79371d6975bc7b",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1764539053487088640,
  "time_end": 1764539057433370880,
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
    "telemetry.sdk.version": "5.36.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/8739ee50-1e98-4c80-88ee-fce828560fdd/resourceGroups/azure-eastus2-general-8739ee50-1e98-4c80-88ee-fce828560fdd/providers/Microsoft.Compute/virtualMachines/a0MZ4HB0Hbzvya",
    "host.id": "db430942-dc49-4710-90cb-6c41a3a68d40",
    "host.name": "a0MZ4HB0Hbzvya",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "db430942-dc49-4710-90cb-6c41a3a68d40",
    "process.pid": 3467,
    "process.parent_pid": 2390,
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
  "trace_id": "23de5af00e493b703f86cfbe9c5a86a3",
  "span_id": "fa0f514c34829139",
  "parent_span_id": "5f79371d6975bc7b",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1764539052033975552,
  "time_end": 1764539053482513920,
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
    "telemetry.sdk.version": "5.36.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/8739ee50-1e98-4c80-88ee-fce828560fdd/resourceGroups/azure-eastus2-general-8739ee50-1e98-4c80-88ee-fce828560fdd/providers/Microsoft.Compute/virtualMachines/a0MZ4HB0Hbzvya",
    "host.id": "db430942-dc49-4710-90cb-6c41a3a68d40",
    "host.name": "a0MZ4HB0Hbzvya",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "db430942-dc49-4710-90cb-6c41a3a68d40",
    "process.pid": 3467,
    "process.parent_pid": 2390,
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
  "trace_id": "23de5af00e493b703f86cfbe9c5a86a3",
  "span_id": "a4bc1deae4fa3457",
  "parent_span_id": "5f79371d6975bc7b",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1764539057438272768,
  "time_end": 1764539057452881664,
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
    "telemetry.sdk.version": "5.36.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/8739ee50-1e98-4c80-88ee-fce828560fdd/resourceGroups/azure-eastus2-general-8739ee50-1e98-4c80-88ee-fce828560fdd/providers/Microsoft.Compute/virtualMachines/a0MZ4HB0Hbzvya",
    "host.id": "db430942-dc49-4710-90cb-6c41a3a68d40",
    "host.name": "a0MZ4HB0Hbzvya",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "db430942-dc49-4710-90cb-6c41a3a68d40",
    "process.pid": 3467,
    "process.parent_pid": 2390,
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
