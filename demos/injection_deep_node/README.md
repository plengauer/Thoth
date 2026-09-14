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
  "trace_id": "762e55b9367799aa2226329a1daea82e",
  "span_id": "bebd6a56f0a8cc39",
  "parent_span_id": "3f6913ca99018d43",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789140894440000000,
  "time_end": 1789140894627442185,
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
    "process.pid": 8275,
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
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/f06d6d5f-ea9a-40aa-8f20-a6083de9f29a/resourceGroups/azure-westus2-general-f06d6d5f-ea9a-40aa-8f20-a6083de9f29a/providers/Microsoft.Compute/virtualMachines/tjvQymH0CXuUBF",
    "host.id": "32f4164e-a10f-4df8-8488-e7f80822d457",
    "host.name": "tjvQymH0CXuUBF",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260907.300.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "762e55b9367799aa2226329a1daea82e",
  "span_id": "a4f9699fa2a13960",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1789140890950330368,
  "time_end": 1789140894662009088,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "e8fa3499-76b0-47a3-b791-0119c1887e11",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/f06d6d5f-ea9a-40aa-8f20-a6083de9f29a/resourceGroups/azure-westus2-general-f06d6d5f-ea9a-40aa-8f20-a6083de9f29a/providers/Microsoft.Compute/virtualMachines/tjvQymH0CXuUBF",
    "host.id": "32f4164e-a10f-4df8-8488-e7f80822d457",
    "host.name": "tjvQymH0CXuUBF",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7557,
    "process.parent_pid": 2846,
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
  "trace_id": "762e55b9367799aa2226329a1daea82e",
  "span_id": "03fcab860ab1935e",
  "parent_span_id": "bebd6a56f0a8cc39",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789140894444000000,
  "time_end": 1789140894562978255,
  "attributes": {
    "peer.ipv4": "172.66.147.243",
    "peer[1].ipv4": "104.20.23.154",
    "peer[2].ipv6": "2606:4700:10::6814:179a",
    "peer[3].ipv6": "2606:4700:10::ac42:93f3"
  },
  "resource_attributes": {
    "process.pid": 8275,
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
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/f06d6d5f-ea9a-40aa-8f20-a6083de9f29a/resourceGroups/azure-westus2-general-f06d6d5f-ea9a-40aa-8f20-a6083de9f29a/providers/Microsoft.Compute/virtualMachines/tjvQymH0CXuUBF",
    "host.id": "32f4164e-a10f-4df8-8488-e7f80822d457",
    "host.name": "tjvQymH0CXuUBF",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260907.300.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "762e55b9367799aa2226329a1daea82e",
  "span_id": "3f6913ca99018d43",
  "parent_span_id": "a4f9699fa2a13960",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789140890957283840,
  "time_end": 1789140894661720320,
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
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "e8fa3499-76b0-47a3-b791-0119c1887e11",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/f06d6d5f-ea9a-40aa-8f20-a6083de9f29a/resourceGroups/azure-westus2-general-f06d6d5f-ea9a-40aa-8f20-a6083de9f29a/providers/Microsoft.Compute/virtualMachines/tjvQymH0CXuUBF",
    "host.id": "32f4164e-a10f-4df8-8488-e7f80822d457",
    "host.name": "tjvQymH0CXuUBF",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7557,
    "process.parent_pid": 2846,
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
  "trace_id": "762e55b9367799aa2226329a1daea82e",
  "span_id": "668c7451a64f3c60",
  "parent_span_id": "bebd6a56f0a8cc39",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789140894443000000,
  "time_end": 1789140894571448722,
  "attributes": {
    "network.transport": "tcp",
    "server.address": "example.com",
    "server.port": 80,
    "network.peer.address": "172.66.147.243",
    "network.local.address": "10.1.1.116",
    "network.local.port": 46100
  },
  "resource_attributes": {
    "process.pid": 8275,
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
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/f06d6d5f-ea9a-40aa-8f20-a6083de9f29a/resourceGroups/azure-westus2-general-f06d6d5f-ea9a-40aa-8f20-a6083de9f29a/providers/Microsoft.Compute/virtualMachines/tjvQymH0CXuUBF",
    "host.id": "32f4164e-a10f-4df8-8488-e7f80822d457",
    "host.name": "tjvQymH0CXuUBF",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260907.300.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
```
