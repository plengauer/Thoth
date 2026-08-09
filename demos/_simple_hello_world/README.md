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
  "trace_id": "8f71b22d73d5c53b4bed2110b1ce17b3",
  "span_id": "53a572dec9c040aa",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786264457222538240,
  "time_end": 1786264457248611328,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "d9f5dc76-754a-4a46-abe8-0586df8a3d18",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/4c7eaef4-1854-406f-b0eb-d5c8f20d8c3d/resourceGroups/azure-eastus2-general-4c7eaef4-1854-406f-b0eb-d5c8f20d8c3d/providers/Microsoft.Compute/virtualMachines/LXoqpnqsFrS5Wy",
    "host.id": "ecc6c9b9-9ad5-4ed5-88c1-9f253497c0be",
    "host.name": "LXoqpnqsFrS5Wy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 2874,
    "process.parent_pid": 2775,
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
  "trace_id": "8f71b22d73d5c53b4bed2110b1ce17b3",
  "span_id": "4787e86aa62ca977",
  "parent_span_id": "53a572dec9c040aa",
  "name": "echo hello world",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264457235377664,
  "time_end": 1786264457248448768,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "d9f5dc76-754a-4a46-abe8-0586df8a3d18",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/4c7eaef4-1854-406f-b0eb-d5c8f20d8c3d/resourceGroups/azure-eastus2-general-4c7eaef4-1854-406f-b0eb-d5c8f20d8c3d/providers/Microsoft.Compute/virtualMachines/LXoqpnqsFrS5Wy",
    "host.id": "ecc6c9b9-9ad5-4ed5-88c1-9f253497c0be",
    "host.name": "LXoqpnqsFrS5Wy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 2874,
    "process.parent_pid": 2775,
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
