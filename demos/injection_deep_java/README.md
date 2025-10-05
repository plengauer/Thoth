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
  "trace_id": "c0f872d14816f1b2557416bffc642660",
  "span_id": "0682783cf6bb78d9",
  "parent_span_id": "cb99ac9894df058a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1759628465755013436,
  "time_end": 1759628466111918265,
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
    "process.pid": 4915,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.16+8",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.16+8",
    "service.instance.id": "81ab9045-fdbb-4cda-b857-0fe83b620dcf",
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
  "trace_id": "c0f872d14816f1b2557416bffc642660",
  "span_id": "6f84cb3616beb42b",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1759628453979056896,
  "time_end": 1759628466321366272,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.28.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/7c4991a6-0a46-4685-af62-c986a91dd61b/resourceGroups/azure-westus3-general-7c4991a6-0a46-4685-af62-c986a91dd61b/providers/Microsoft.Compute/virtualMachines/i10LB4Uhyw4oxK",
    "host.id": "38be125e-931f-4856-9f4f-d79b0f7481ae",
    "host.name": "i10LB4Uhyw4oxK",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 4061,
    "process.parent_pid": 2349,
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
  "trace_id": "c0f872d14816f1b2557416bffc642660",
  "span_id": "cb99ac9894df058a",
  "parent_span_id": "6f84cb3616beb42b",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759628457928112640,
  "time_end": 1759628466299809536,
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
    "telemetry.sdk.version": "5.28.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/7c4991a6-0a46-4685-af62-c986a91dd61b/resourceGroups/azure-westus3-general-7c4991a6-0a46-4685-af62-c986a91dd61b/providers/Microsoft.Compute/virtualMachines/i10LB4Uhyw4oxK",
    "host.id": "38be125e-931f-4856-9f4f-d79b0f7481ae",
    "host.name": "i10LB4Uhyw4oxK",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 4061,
    "process.parent_pid": 2349,
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
  "trace_id": "c0f872d14816f1b2557416bffc642660",
  "span_id": "15d44cc127f7f86d",
  "parent_span_id": "6f84cb3616beb42b",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759628453991439872,
  "time_end": 1759628457923742720,
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
    "telemetry.sdk.version": "5.28.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/7c4991a6-0a46-4685-af62-c986a91dd61b/resourceGroups/azure-westus3-general-7c4991a6-0a46-4685-af62-c986a91dd61b/providers/Microsoft.Compute/virtualMachines/i10LB4Uhyw4oxK",
    "host.id": "38be125e-931f-4856-9f4f-d79b0f7481ae",
    "host.name": "i10LB4Uhyw4oxK",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 4061,
    "process.parent_pid": 2349,
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
  "trace_id": "c0f872d14816f1b2557416bffc642660",
  "span_id": "77c605d1bc50315b",
  "parent_span_id": "6f84cb3616beb42b",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759628466304084224,
  "time_end": 1759628466321163520,
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
    "telemetry.sdk.version": "5.28.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/7c4991a6-0a46-4685-af62-c986a91dd61b/resourceGroups/azure-westus3-general-7c4991a6-0a46-4685-af62-c986a91dd61b/providers/Microsoft.Compute/virtualMachines/i10LB4Uhyw4oxK",
    "host.id": "38be125e-931f-4856-9f4f-d79b0f7481ae",
    "host.name": "i10LB4Uhyw4oxK",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 4061,
    "process.parent_pid": 2349,
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
