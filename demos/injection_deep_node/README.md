# Demo "Deep injection into a Node.js app"
This script uses a node.js app and configures opentelemetry to inject into the app and continue tracing.
## Script
```sh
export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE
. otel.sh
 node index.js
```
## Trace Structure Overview
```
bash -e demo.sh
  node index.js
    GET
```
## Full Trace
```
{
  "trace_id": "3db18148ad4ddfb27f1589340dd23440",
  "span_id": "da19f0aff42cd18d",
  "parent_span_id": "e301287b79f864a4",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1759628664613000000,
  "time_end": 1759628664756803214,
  "attributes": {
    "http.url": "https://example.com/",
    "http.method": "GET",
    "http.target": "/",
    "net.peer.name": "example.com",
    "http.host": "example.com:443",
    "net.peer.ip": "23.215.0.136",
    "net.peer.port": 443,
    "http.response_content_length_uncompressed": 1256,
    "http.status_code": 200,
    "http.status_text": "OK",
    "http.flavor": "1.1",
    "net.transport": "ip_tcp"
  },
  "resource_attributes": {
    "process.pid": 8332,
    "process.executable.name": "node",
    "process.executable.path": "/usr/local/bin/node",
    "process.command_args": [
      "/usr/local/bin/node",
      "--require",
      "/usr/share/opentelemetry_shell/agent.instrumentation.node/20/deep.inject.js",
      "--require",
      "/usr/share/opentelemetry_shell/agent.instrumentation.node/20/deep.instrument.js",
      "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js"
    ],
    "process.runtime.version": "20.19.5",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "vcs.system": "git",
    "vcs.commit.id": "31fc2218d60e7238d896afe72ac3f631967e361a",
    "vcs.branch.name": "main",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/89e93311-e5b3-4fdf-9625-4c5eabe92b63/resourceGroups/azure-eastus-general-89e93311-e5b3-4fdf-9625-4c5eabe92b63/providers/Microsoft.Compute/virtualMachines/Qph7gVf9TbrX4N",
    "host.id": "139caf48-dbed-45e7-a9e9-b32a2ff4caa2",
    "host.name": "Qph7gVf9TbrX4N",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20250929.60.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.1.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "3db18148ad4ddfb27f1589340dd23440",
  "span_id": "fac21cdba8b99620",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1759628661434580992,
  "time_end": 1759628665356005888,
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
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/89e93311-e5b3-4fdf-9625-4c5eabe92b63/resourceGroups/azure-eastus-general-89e93311-e5b3-4fdf-9625-4c5eabe92b63/providers/Microsoft.Compute/virtualMachines/Qph7gVf9TbrX4N",
    "host.id": "139caf48-dbed-45e7-a9e9-b32a2ff4caa2",
    "host.name": "Qph7gVf9TbrX4N",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 7518,
    "process.parent_pid": 2356,
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
  "trace_id": "3db18148ad4ddfb27f1589340dd23440",
  "span_id": "e301287b79f864a4",
  "parent_span_id": "fac21cdba8b99620",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759628661447179264,
  "time_end": 1759628665355858944,
  "attributes": {
    "shell.command_line": "node index.js",
    "shell.command": "node",
    "shell.command.type": "file",
    "shell.command.name": "node",
    "subprocess.executable.path": "/usr/local/bin/node",
    "subprocess.executable.name": "node",
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
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/89e93311-e5b3-4fdf-9625-4c5eabe92b63/resourceGroups/azure-eastus-general-89e93311-e5b3-4fdf-9625-4c5eabe92b63/providers/Microsoft.Compute/virtualMachines/Qph7gVf9TbrX4N",
    "host.id": "139caf48-dbed-45e7-a9e9-b32a2ff4caa2",
    "host.name": "Qph7gVf9TbrX4N",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 7518,
    "process.parent_pid": 2356,
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
