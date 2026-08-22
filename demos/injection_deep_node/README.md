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
  "trace_id": "5bab2a03bcba4ac9f2496c0644dbe4c0",
  "span_id": "7980824ee2018bb7",
  "parent_span_id": "12549fc0c40bf150",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787428953712000000,
  "time_end": 1787428953902010923,
  "attributes": {
    "http.request.method": "GET",
    "server.address": "example.com",
    "server.port": 80,
    "url.full": "http://example.com/",
    "http.response.status_code": 200,
    "network.peer.address": "104.20.23.154",
    "network.peer.port": 80,
    "network.protocol.version": "1.1"
  },
  "resource_attributes": {
    "process.pid": 8439,
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
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/8a20fc55-20c8-4075-bc46-beb692867e71/resourceGroups/azure-northcentralus-general-8a20fc55-20c8-4075-bc46-beb692867e71/providers/Microsoft.Compute/virtualMachines/xZd86Zhmu1B1LR",
    "host.id": "273b2af5-6055-4bea-b4ad-b83243b6a393",
    "host.name": "xZd86Zhmu1B1LR",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260816.277.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "5bab2a03bcba4ac9f2496c0644dbe4c0",
  "span_id": "f620ba0950300c4a",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1787428952319687680,
  "time_end": 1787428953943300096,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "d6a01ece-e780-4522-a538-1786c09dfb14",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/8a20fc55-20c8-4075-bc46-beb692867e71/resourceGroups/azure-northcentralus-general-8a20fc55-20c8-4075-bc46-beb692867e71/providers/Microsoft.Compute/virtualMachines/xZd86Zhmu1B1LR",
    "host.id": "273b2af5-6055-4bea-b4ad-b83243b6a393",
    "host.name": "xZd86Zhmu1B1LR",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7722,
    "process.parent_pid": 2960,
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
  "trace_id": "5bab2a03bcba4ac9f2496c0644dbe4c0",
  "span_id": "8455692cbc6e302d",
  "parent_span_id": "7980824ee2018bb7",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787428953716000000,
  "time_end": 1787428953825162551,
  "attributes": {
    "peer.ipv4": "104.20.23.154",
    "peer[1].ipv4": "172.66.147.243",
    "peer[2].ipv6": "2606:4700:10::6814:179a",
    "peer[3].ipv6": "2606:4700:10::ac42:93f3"
  },
  "resource_attributes": {
    "process.pid": 8439,
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
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/8a20fc55-20c8-4075-bc46-beb692867e71/resourceGroups/azure-northcentralus-general-8a20fc55-20c8-4075-bc46-beb692867e71/providers/Microsoft.Compute/virtualMachines/xZd86Zhmu1B1LR",
    "host.id": "273b2af5-6055-4bea-b4ad-b83243b6a393",
    "host.name": "xZd86Zhmu1B1LR",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260816.277.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "5bab2a03bcba4ac9f2496c0644dbe4c0",
  "span_id": "12549fc0c40bf150",
  "parent_span_id": "f620ba0950300c4a",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787428952327568640,
  "time_end": 1787428953943060736,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "d6a01ece-e780-4522-a538-1786c09dfb14",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/8a20fc55-20c8-4075-bc46-beb692867e71/resourceGroups/azure-northcentralus-general-8a20fc55-20c8-4075-bc46-beb692867e71/providers/Microsoft.Compute/virtualMachines/xZd86Zhmu1B1LR",
    "host.id": "273b2af5-6055-4bea-b4ad-b83243b6a393",
    "host.name": "xZd86Zhmu1B1LR",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7722,
    "process.parent_pid": 2960,
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
  "trace_id": "5bab2a03bcba4ac9f2496c0644dbe4c0",
  "span_id": "3ccafd4e2eacc1e0",
  "parent_span_id": "7980824ee2018bb7",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787428953715000000,
  "time_end": 1787428953839541461,
  "attributes": {
    "network.transport": "tcp",
    "server.address": "example.com",
    "server.port": 80,
    "network.peer.address": "104.20.23.154",
    "network.local.address": "10.1.0.72",
    "network.local.port": 56582
  },
  "resource_attributes": {
    "process.pid": 8439,
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
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/8a20fc55-20c8-4075-bc46-beb692867e71/resourceGroups/azure-northcentralus-general-8a20fc55-20c8-4075-bc46-beb692867e71/providers/Microsoft.Compute/virtualMachines/xZd86Zhmu1B1LR",
    "host.id": "273b2af5-6055-4bea-b4ad-b83243b6a393",
    "host.name": "xZd86Zhmu1B1LR",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260816.277.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
```
