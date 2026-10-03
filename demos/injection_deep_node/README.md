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
  "trace_id": "4de0ee6b06675bec8b9d4032c3a3c1f7",
  "span_id": "68c6e7bef591649d",
  "parent_span_id": "c556cb4ce6555854",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790827504002000000,
  "time_end": 1790827504111160495,
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
    "process.pid": 8120,
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
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/32794b7c-d828-44a0-89f3-66c642761435/resourceGroups/azure-eastus-general-32794b7c-d828-44a0-89f3-66c642761435/providers/Microsoft.Compute/virtualMachines/67eQpL7h5kPWxg",
    "host.id": "c423ea41-9999-499b-ab0f-ac72cae047c1",
    "host.name": "67eQpL7h5kPWxg",
    "host.type": "Standard_D4ads_v6",
    "os.version": "20260920.314.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "4de0ee6b06675bec8b9d4032c3a3c1f7",
  "span_id": "3951a6e8d6c2181f",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1790827502683476480,
  "time_end": 1790827504142236672,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "2358b332-14a1-4ae2-953a-a1061a0cd567",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/32794b7c-d828-44a0-89f3-66c642761435/resourceGroups/azure-eastus-general-32794b7c-d828-44a0-89f3-66c642761435/providers/Microsoft.Compute/virtualMachines/67eQpL7h5kPWxg",
    "host.id": "c423ea41-9999-499b-ab0f-ac72cae047c1",
    "host.name": "67eQpL7h5kPWxg",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7399,
    "process.parent_pid": 2670,
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
  "trace_id": "4de0ee6b06675bec8b9d4032c3a3c1f7",
  "span_id": "40ef44b9999b326e",
  "parent_span_id": "68c6e7bef591649d",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790827504006000000,
  "time_end": 1790827504078934163,
  "attributes": {
    "peer.ipv4": "172.66.147.243",
    "peer[1].ipv4": "104.20.23.154",
    "peer[2].ipv6": "2606:4700:10::ac42:93f3",
    "peer[3].ipv6": "2606:4700:10::6814:179a"
  },
  "resource_attributes": {
    "process.pid": 8120,
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
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/32794b7c-d828-44a0-89f3-66c642761435/resourceGroups/azure-eastus-general-32794b7c-d828-44a0-89f3-66c642761435/providers/Microsoft.Compute/virtualMachines/67eQpL7h5kPWxg",
    "host.id": "c423ea41-9999-499b-ab0f-ac72cae047c1",
    "host.name": "67eQpL7h5kPWxg",
    "host.type": "Standard_D4ads_v6",
    "os.version": "20260920.314.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "4de0ee6b06675bec8b9d4032c3a3c1f7",
  "span_id": "c556cb4ce6555854",
  "parent_span_id": "3951a6e8d6c2181f",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790827502689325824,
  "time_end": 1790827504142057984,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "2358b332-14a1-4ae2-953a-a1061a0cd567",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/32794b7c-d828-44a0-89f3-66c642761435/resourceGroups/azure-eastus-general-32794b7c-d828-44a0-89f3-66c642761435/providers/Microsoft.Compute/virtualMachines/67eQpL7h5kPWxg",
    "host.id": "c423ea41-9999-499b-ab0f-ac72cae047c1",
    "host.name": "67eQpL7h5kPWxg",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7399,
    "process.parent_pid": 2670,
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
  "trace_id": "4de0ee6b06675bec8b9d4032c3a3c1f7",
  "span_id": "f21da2deee0267d3",
  "parent_span_id": "68c6e7bef591649d",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790827504005000000,
  "time_end": 1790827504085952185,
  "attributes": {
    "network.transport": "tcp",
    "server.address": "example.com",
    "server.port": 80,
    "network.peer.address": "172.66.147.243",
    "network.local.address": "10.1.0.85",
    "network.local.port": 46236
  },
  "resource_attributes": {
    "process.pid": 8120,
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
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/32794b7c-d828-44a0-89f3-66c642761435/resourceGroups/azure-eastus-general-32794b7c-d828-44a0-89f3-66c642761435/providers/Microsoft.Compute/virtualMachines/67eQpL7h5kPWxg",
    "host.id": "c423ea41-9999-499b-ab0f-ac72cae047c1",
    "host.name": "67eQpL7h5kPWxg",
    "host.type": "Standard_D4ads_v6",
    "os.version": "20260920.314.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
```
