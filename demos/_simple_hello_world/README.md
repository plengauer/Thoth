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
  "trace_id": "91e9ea4292334a78585bebc5e32d7395",
  "span_id": "a7f7e9ef8a3e39eb",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786793443319409152,
  "time_end": 1786793443332753152,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "3e894c5f-f70e-40b1-a542-68202768c36d",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/c93eba9a-a17d-48dc-ad0d-f1b16163bf14/resourceGroups/azure-westus-general-c93eba9a-a17d-48dc-ad0d-f1b16163bf14/providers/Microsoft.Compute/virtualMachines/4zXNv2QZMzGTRa",
    "host.id": "eef1e011-f6f0-409a-bfb2-1b13c0cb1a9a",
    "host.name": "4zXNv2QZMzGTRa",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2912,
    "process.parent_pid": 2812,
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
  "trace_id": "91e9ea4292334a78585bebc5e32d7395",
  "span_id": "93485c9ba92917f0",
  "parent_span_id": "a7f7e9ef8a3e39eb",
  "name": "echo hello world",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793443326475008,
  "time_end": 1786793443332602624,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "3e894c5f-f70e-40b1-a542-68202768c36d",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/c93eba9a-a17d-48dc-ad0d-f1b16163bf14/resourceGroups/azure-westus-general-c93eba9a-a17d-48dc-ad0d-f1b16163bf14/providers/Microsoft.Compute/virtualMachines/4zXNv2QZMzGTRa",
    "host.id": "eef1e011-f6f0-409a-bfb2-1b13c0cb1a9a",
    "host.name": "4zXNv2QZMzGTRa",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2912,
    "process.parent_pid": 2812,
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
