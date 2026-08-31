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
  "trace_id": "1408bccdb5ae2520e68290bd38ab8e79",
  "span_id": "8c8bbbc583cb0f9d",
  "parent_span_id": "b4b0d951b995de99",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787581860281000000,
  "time_end": 1787581860472540698,
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
    "process.pid": 8382,
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
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/30e523c7-86cb-44e3-aa04-b1e026f6c1cb/resourceGroups/azure-westus-general-30e523c7-86cb-44e3-aa04-b1e026f6c1cb/providers/Microsoft.Compute/virtualMachines/yLH8jufKRrGC4T",
    "host.id": "ee7c78dc-33d7-4500-82f3-bb53786fa0c4",
    "host.name": "yLH8jufKRrGC4T",
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
  "trace_id": "1408bccdb5ae2520e68290bd38ab8e79",
  "span_id": "c74661991d25b50d",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1787581858900189952,
  "time_end": 1787581860507291648,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "4803e46d-b450-4811-9867-f210b99aa2e0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/30e523c7-86cb-44e3-aa04-b1e026f6c1cb/resourceGroups/azure-westus-general-30e523c7-86cb-44e3-aa04-b1e026f6c1cb/providers/Microsoft.Compute/virtualMachines/yLH8jufKRrGC4T",
    "host.id": "ee7c78dc-33d7-4500-82f3-bb53786fa0c4",
    "host.name": "yLH8jufKRrGC4T",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7665,
    "process.parent_pid": 2819,
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
  "trace_id": "1408bccdb5ae2520e68290bd38ab8e79",
  "span_id": "23422835ee4e779c",
  "parent_span_id": "8c8bbbc583cb0f9d",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787581860286000000,
  "time_end": 1787581860400985122,
  "attributes": {
    "peer.ipv4": "104.20.23.154",
    "peer[1].ipv4": "172.66.147.243",
    "peer[2].ipv6": "2606:4700:10::ac42:93f3",
    "peer[3].ipv6": "2606:4700:10::6814:179a"
  },
  "resource_attributes": {
    "process.pid": 8382,
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
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/30e523c7-86cb-44e3-aa04-b1e026f6c1cb/resourceGroups/azure-westus-general-30e523c7-86cb-44e3-aa04-b1e026f6c1cb/providers/Microsoft.Compute/virtualMachines/yLH8jufKRrGC4T",
    "host.id": "ee7c78dc-33d7-4500-82f3-bb53786fa0c4",
    "host.name": "yLH8jufKRrGC4T",
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
  "trace_id": "1408bccdb5ae2520e68290bd38ab8e79",
  "span_id": "b4b0d951b995de99",
  "parent_span_id": "c74661991d25b50d",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787581858907715840,
  "time_end": 1787581860507068672,
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
    "service.instance.id": "4803e46d-b450-4811-9867-f210b99aa2e0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/30e523c7-86cb-44e3-aa04-b1e026f6c1cb/resourceGroups/azure-westus-general-30e523c7-86cb-44e3-aa04-b1e026f6c1cb/providers/Microsoft.Compute/virtualMachines/yLH8jufKRrGC4T",
    "host.id": "ee7c78dc-33d7-4500-82f3-bb53786fa0c4",
    "host.name": "yLH8jufKRrGC4T",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7665,
    "process.parent_pid": 2819,
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
  "trace_id": "1408bccdb5ae2520e68290bd38ab8e79",
  "span_id": "3a9f626b03203374",
  "parent_span_id": "8c8bbbc583cb0f9d",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787581860285000000,
  "time_end": 1787581860414571579,
  "attributes": {
    "network.transport": "tcp",
    "server.address": "example.com",
    "server.port": 80,
    "network.peer.address": "104.20.23.154",
    "network.local.address": "10.1.0.21",
    "network.local.port": 50330
  },
  "resource_attributes": {
    "process.pid": 8382,
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
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/30e523c7-86cb-44e3-aa04-b1e026f6c1cb/resourceGroups/azure-westus-general-30e523c7-86cb-44e3-aa04-b1e026f6c1cb/providers/Microsoft.Compute/virtualMachines/yLH8jufKRrGC4T",
    "host.id": "ee7c78dc-33d7-4500-82f3-bb53786fa0c4",
    "host.name": "yLH8jufKRrGC4T",
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
