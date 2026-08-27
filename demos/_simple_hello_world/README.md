# Demo "Hello world"
This is a script as easy as it gets, i.e., a simple hello world. It shows some very simple span with the default attributes.
## Script
```bash
. otel.sh
echo hello world
```
## Trace Structure Overview
```bash
bash -e demo.sh
  echo hello world
```
## Full Trace
```json
{
  "trace_id": "d2aaec4ee267a51dc69a14ba13ae2a14",
  "span_id": "a74110c056b8bbaa",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1787425158183445248,
  "time_end": 1787425158194674176,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.1",
    "service.instance.id": "949cad4a-f965-4269-9c11-49002b596099",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/78026a10-e417-46be-a899-17d26efb21ab/resourceGroups/azure-westcentralus-general-78026a10-e417-46be-a899-17d26efb21ab/providers/Microsoft.Compute/virtualMachines/AOe8MKTM2N73xG",
    "host.id": "2d781274-8a23-4065-a755-31806ba674fd",
    "host.name": "AOe8MKTM2N73xG",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2808,
    "process.parent_pid": 2705,
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
  "trace_id": "d2aaec4ee267a51dc69a14ba13ae2a14",
  "span_id": "5508ded98a9d6045",
  "parent_span_id": "a74110c056b8bbaa",
  "name": "echo hello world",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787425158189391616,
  "time_end": 1787425158194556416,
  "attributes": {
    "shell.command_line": "echo hello world",
    "shell.command": "echo",
    "shell.command.type": "builtin",
    "shell.command.name": "echo",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 2
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.1",
    "service.instance.id": "949cad4a-f965-4269-9c11-49002b596099",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/78026a10-e417-46be-a899-17d26efb21ab/resourceGroups/azure-westcentralus-general-78026a10-e417-46be-a899-17d26efb21ab/providers/Microsoft.Compute/virtualMachines/AOe8MKTM2N73xG",
    "host.id": "2d781274-8a23-4065-a755-31806ba674fd",
    "host.name": "AOe8MKTM2N73xG",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2808,
    "process.parent_pid": 2705,
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
