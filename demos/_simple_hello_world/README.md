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
  "trace_id": "2f7395da237bb37c32f048b01594d36c",
  "span_id": "5b36435ba7fa8b9e",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1759593110948932352,
  "time_end": 1759593110977190656,
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
    "cloud.resource_id": "/subscriptions/8cc76987-cb84-42dc-b6c0-c55f5e4f28a1/resourceGroups/azure-westus3-general-8cc76987-cb84-42dc-b6c0-c55f5e4f28a1/providers/Microsoft.Compute/virtualMachines/kq7TH5NI5lV15x",
    "host.id": "cec1e32b-6ee7-4268-a2d7-dc6db77128a6",
    "host.name": "kq7TH5NI5lV15x",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 2490,
    "process.parent_pid": 2393,
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
  "trace_id": "2f7395da237bb37c32f048b01594d36c",
  "span_id": "a2a2ce65d49858ab",
  "parent_span_id": "5b36435ba7fa8b9e",
  "name": "echo hello world",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759593110961717504,
  "time_end": 1759593110977024256,
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
    "telemetry.sdk.version": "5.28.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/8cc76987-cb84-42dc-b6c0-c55f5e4f28a1/resourceGroups/azure-westus3-general-8cc76987-cb84-42dc-b6c0-c55f5e4f28a1/providers/Microsoft.Compute/virtualMachines/kq7TH5NI5lV15x",
    "host.id": "cec1e32b-6ee7-4268-a2d7-dc6db77128a6",
    "host.name": "kq7TH5NI5lV15x",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 2490,
    "process.parent_pid": 2393,
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
