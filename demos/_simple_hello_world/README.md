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
  "trace_id": "14d61bfb9319f34f8a0b1dd8d545b7aa",
  "span_id": "a31cbc3d45fc579a",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786148052740488704,
  "time_end": 1786148052765776896,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "e88d67dc-718c-4df2-8b1a-b928513962d4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6c8d4243-98e7-42e0-99e1-e84a92038c6e/resourceGroups/azure-eastus-general-6c8d4243-98e7-42e0-99e1-e84a92038c6e/providers/Microsoft.Compute/virtualMachines/xKqEaFG7foAoEG",
    "host.id": "8b1eb3c6-aea8-42b2-b8e6-e099135e9546",
    "host.name": "xKqEaFG7foAoEG",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 2954,
    "process.parent_pid": 2853,
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
  "trace_id": "14d61bfb9319f34f8a0b1dd8d545b7aa",
  "span_id": "b40034022a79cae5",
  "parent_span_id": "a31cbc3d45fc579a",
  "name": "echo hello world",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786148052752781056,
  "time_end": 1786148052765551104,
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
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "e88d67dc-718c-4df2-8b1a-b928513962d4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6c8d4243-98e7-42e0-99e1-e84a92038c6e/resourceGroups/azure-eastus-general-6c8d4243-98e7-42e0-99e1-e84a92038c6e/providers/Microsoft.Compute/virtualMachines/xKqEaFG7foAoEG",
    "host.id": "8b1eb3c6-aea8-42b2-b8e6-e099135e9546",
    "host.name": "xKqEaFG7foAoEG",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 2954,
    "process.parent_pid": 2853,
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
