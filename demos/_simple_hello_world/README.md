# Demo "Hello world"
This is a script as easy as it gets, i.e., a simple hello world. It shows some very simple span with the default attributes.
## Script
```sh
. otel.sh
echo hello world
```
## Trace Structure Overview
```
bash -e demo.sh
  echo hello world
```
## Full Trace
```
{
  "trace_id": "6e77b899094288fead22468759031660",
  "span_id": "61ec12dd270bf3ff",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1759515320177814528,
  "time_end": 1759515320204722432,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.28.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/82ce5a7f-a438-4f36-be1a-128870947580/resourceGroups/azure-northcentralus-general-82ce5a7f-a438-4f36-be1a-128870947580/providers/Microsoft.Compute/virtualMachines/P2Yf1WlaVqnFWJ",
    "host.id": "fa3f3c9e-4ffc-4dec-9815-a88a1f25c6ff",
    "host.name": "P2Yf1WlaVqnFWJ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 2457,
    "process.parent_pid": 2357,
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
  "trace_id": "6e77b899094288fead22468759031660",
  "span_id": "2c4922a35f69800b",
  "parent_span_id": "61ec12dd270bf3ff",
  "name": "echo hello world",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759515320189723136,
  "time_end": 1759515320204587520,
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
    "telemetry.sdk.version": "5.28.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/82ce5a7f-a438-4f36-be1a-128870947580/resourceGroups/azure-northcentralus-general-82ce5a7f-a438-4f36-be1a-128870947580/providers/Microsoft.Compute/virtualMachines/P2Yf1WlaVqnFWJ",
    "host.id": "fa3f3c9e-4ffc-4dec-9815-a88a1f25c6ff",
    "host.name": "P2Yf1WlaVqnFWJ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 2457,
    "process.parent_pid": 2357,
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
