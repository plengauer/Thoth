# Demo "Deep injection into a Node.js app"
This script uses a node.js app and configures opentelemetry to inject into the app and continue tracing.
## Script
```bash
export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE
. otel.sh
node index.js
```
## Trace Structure Overview
```bash
bash -e demo.sh
  node index.js
    GET
      dns.lookup
      tcp.connect
```
## Full Trace
```json
{
  "trace_id": "5c1c1f5ae34a484c0229c9dc554a9754",
  "span_id": "a57713f656daaf6e",
  "parent_span_id": "cb4e09da16edd8c1",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274477602000000,
  "time_end": 1788274477931546383,
  "attributes": {
    "http.request.method": "GET",
    "server.address": "example.com",
    "server.port": 80,
    "url.full": "http://example.com/",
    "http.response.status_code": 200,
    "network.peer.address": "172.66.147.243",
    "network.peer.port": 80,
    "network.protocol.version": "1.1"
  },
  "resource_attributes": {
    "process.pid": 8144,
    "process.executable.name": "node",
    "process.executable.path": "/usr/local/bin/node",
    "process.command_args": [
      "/usr/local/bin/node",
      "--require",
      "/usr/share/opentelemetry_shell/agent.instrumentation.node/22/deep.inject.js",
      "--require",
      "/usr/share/opentelemetry_shell/agent.instrumentation.node/22/deep.instrument.js",
      "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js"
    ],
    "process.runtime.version": "22.23.2",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/1b2dcdb6-41ee-47c7-9e8c-c737b612acbc/resourceGroups/azure-westus3-general-1b2dcdb6-41ee-47c7-9e8c-c737b612acbc/providers/Microsoft.Compute/virtualMachines/hYPyjk9e4jGXu2",
    "host.id": "69a86143-a606-4076-a552-307afbcb012e",
    "host.name": "hYPyjk9e4jGXu2",
    "host.type": "Standard_D4ads_v6",
    "os.version": "20260823.283.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "5c1c1f5ae34a484c0229c9dc554a9754",
  "span_id": "fb3d93555ba608a5",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1788274475684509696,
  "time_end": 1788274478078806272,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "c192c653-1b3e-4932-9f52-8d2086c3b4d3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/1b2dcdb6-41ee-47c7-9e8c-c737b612acbc/resourceGroups/azure-westus3-general-1b2dcdb6-41ee-47c7-9e8c-c737b612acbc/providers/Microsoft.Compute/virtualMachines/hYPyjk9e4jGXu2",
    "host.id": "69a86143-a606-4076-a552-307afbcb012e",
    "host.name": "hYPyjk9e4jGXu2",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7425,
    "process.parent_pid": 2636,
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
  "trace_id": "5c1c1f5ae34a484c0229c9dc554a9754",
  "span_id": "7c9887bc5eee0c86",
  "parent_span_id": "a57713f656daaf6e",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274477606000000,
  "time_end": 1788274477690584027,
  "attributes": {
    "peer.ipv4": "172.66.147.243",
    "peer[1].ipv4": "104.20.23.154",
    "peer[2].ipv6": "2606:4700:10::6814:179a",
    "peer[3].ipv6": "2606:4700:10::ac42:93f3"
  },
  "resource_attributes": {
    "process.pid": 8144,
    "process.executable.name": "node",
    "process.executable.path": "/usr/local/bin/node",
    "process.command_args": [
      "/usr/local/bin/node",
      "--require",
      "/usr/share/opentelemetry_shell/agent.instrumentation.node/22/deep.inject.js",
      "--require",
      "/usr/share/opentelemetry_shell/agent.instrumentation.node/22/deep.instrument.js",
      "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js"
    ],
    "process.runtime.version": "22.23.2",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/1b2dcdb6-41ee-47c7-9e8c-c737b612acbc/resourceGroups/azure-westus3-general-1b2dcdb6-41ee-47c7-9e8c-c737b612acbc/providers/Microsoft.Compute/virtualMachines/hYPyjk9e4jGXu2",
    "host.id": "69a86143-a606-4076-a552-307afbcb012e",
    "host.name": "hYPyjk9e4jGXu2",
    "host.type": "Standard_D4ads_v6",
    "os.version": "20260823.283.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "5c1c1f5ae34a484c0229c9dc554a9754",
  "span_id": "cb4e09da16edd8c1",
  "parent_span_id": "fb3d93555ba608a5",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274475690674176,
  "time_end": 1788274478078610688,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "c192c653-1b3e-4932-9f52-8d2086c3b4d3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/1b2dcdb6-41ee-47c7-9e8c-c737b612acbc/resourceGroups/azure-westus3-general-1b2dcdb6-41ee-47c7-9e8c-c737b612acbc/providers/Microsoft.Compute/virtualMachines/hYPyjk9e4jGXu2",
    "host.id": "69a86143-a606-4076-a552-307afbcb012e",
    "host.name": "hYPyjk9e4jGXu2",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7425,
    "process.parent_pid": 2636,
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
  "trace_id": "5c1c1f5ae34a484c0229c9dc554a9754",
  "span_id": "c3b15a606130c1e8",
  "parent_span_id": "a57713f656daaf6e",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274477605000000,
  "time_end": 1788274477708558369,
  "attributes": {
    "network.transport": "tcp",
    "server.address": "example.com",
    "server.port": 80,
    "network.peer.address": "172.66.147.243",
    "network.local.address": "10.1.0.8",
    "network.local.port": 58502
  },
  "resource_attributes": {
    "process.pid": 8144,
    "process.executable.name": "node",
    "process.executable.path": "/usr/local/bin/node",
    "process.command_args": [
      "/usr/local/bin/node",
      "--require",
      "/usr/share/opentelemetry_shell/agent.instrumentation.node/22/deep.inject.js",
      "--require",
      "/usr/share/opentelemetry_shell/agent.instrumentation.node/22/deep.instrument.js",
      "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js"
    ],
    "process.runtime.version": "22.23.2",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/1b2dcdb6-41ee-47c7-9e8c-c737b612acbc/resourceGroups/azure-westus3-general-1b2dcdb6-41ee-47c7-9e8c-c737b612acbc/providers/Microsoft.Compute/virtualMachines/hYPyjk9e4jGXu2",
    "host.id": "69a86143-a606-4076-a552-307afbcb012e",
    "host.name": "hYPyjk9e4jGXu2",
    "host.type": "Standard_D4ads_v6",
    "os.version": "20260823.283.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
```
