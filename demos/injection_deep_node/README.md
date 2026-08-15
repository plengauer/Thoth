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
  "trace_id": "c9db9dae3389d343d9c772edd559f0b3",
  "span_id": "49296bc2ccaf3e41",
  "parent_span_id": "2f3f8ef3c8988abc",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793799242000000,
  "time_end": 1786793799359122146,
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
    "process.pid": 8204,
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
    "cloud.resource_id": "/subscriptions/49d893db-d0aa-494b-a0c2-2a3d1208ca6a/resourceGroups/azure-westus3-general-49d893db-d0aa-494b-a0c2-2a3d1208ca6a/providers/Microsoft.Compute/virtualMachines/5LcixMbNnEuLZ2",
    "host.id": "84c54c64-e34f-40c5-a0a4-15da73388da3",
    "host.name": "5LcixMbNnEuLZ2",
    "host.type": "Standard_D4ds_v6",
    "os.version": "20260810.271.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "c9db9dae3389d343d9c772edd559f0b3",
  "span_id": "e37466d15eb7c0f0",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786793798292958464,
  "time_end": 1786793799386912256,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "c8183d75-999c-480e-bd48-3567228afcec",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/49d893db-d0aa-494b-a0c2-2a3d1208ca6a/resourceGroups/azure-westus3-general-49d893db-d0aa-494b-a0c2-2a3d1208ca6a/providers/Microsoft.Compute/virtualMachines/5LcixMbNnEuLZ2",
    "host.id": "84c54c64-e34f-40c5-a0a4-15da73388da3",
    "host.name": "5LcixMbNnEuLZ2",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7486,
    "process.parent_pid": 2703,
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
  "trace_id": "c9db9dae3389d343d9c772edd559f0b3",
  "span_id": "9622b1e6a41cd1b5",
  "parent_span_id": "49296bc2ccaf3e41",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793799247000000,
  "time_end": 1786793799321110531,
  "attributes": {
    "peer.ipv4": "172.66.147.243",
    "peer[1].ipv4": "104.20.23.154",
    "peer[2].ipv6": "2606:4700:10::6814:179a",
    "peer[3].ipv6": "2606:4700:10::ac42:93f3"
  },
  "resource_attributes": {
    "process.pid": 8204,
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
    "cloud.resource_id": "/subscriptions/49d893db-d0aa-494b-a0c2-2a3d1208ca6a/resourceGroups/azure-westus3-general-49d893db-d0aa-494b-a0c2-2a3d1208ca6a/providers/Microsoft.Compute/virtualMachines/5LcixMbNnEuLZ2",
    "host.id": "84c54c64-e34f-40c5-a0a4-15da73388da3",
    "host.name": "5LcixMbNnEuLZ2",
    "host.type": "Standard_D4ds_v6",
    "os.version": "20260810.271.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "c9db9dae3389d343d9c772edd559f0b3",
  "span_id": "2f3f8ef3c8988abc",
  "parent_span_id": "e37466d15eb7c0f0",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793798300005376,
  "time_end": 1786793799386841600,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "c8183d75-999c-480e-bd48-3567228afcec",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/49d893db-d0aa-494b-a0c2-2a3d1208ca6a/resourceGroups/azure-westus3-general-49d893db-d0aa-494b-a0c2-2a3d1208ca6a/providers/Microsoft.Compute/virtualMachines/5LcixMbNnEuLZ2",
    "host.id": "84c54c64-e34f-40c5-a0a4-15da73388da3",
    "host.name": "5LcixMbNnEuLZ2",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7486,
    "process.parent_pid": 2703,
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
  "trace_id": "c9db9dae3389d343d9c772edd559f0b3",
  "span_id": "8d896410e8aca153",
  "parent_span_id": "49296bc2ccaf3e41",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793799246000000,
  "time_end": 1786793799337103604,
  "attributes": {
    "network.transport": "tcp",
    "server.address": "example.com",
    "server.port": 80,
    "network.peer.address": "172.66.147.243",
    "network.local.address": "10.1.0.130",
    "network.local.port": 42380
  },
  "resource_attributes": {
    "process.pid": 8204,
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
    "cloud.resource_id": "/subscriptions/49d893db-d0aa-494b-a0c2-2a3d1208ca6a/resourceGroups/azure-westus3-general-49d893db-d0aa-494b-a0c2-2a3d1208ca6a/providers/Microsoft.Compute/virtualMachines/5LcixMbNnEuLZ2",
    "host.id": "84c54c64-e34f-40c5-a0a4-15da73388da3",
    "host.name": "5LcixMbNnEuLZ2",
    "host.type": "Standard_D4ds_v6",
    "os.version": "20260810.271.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
```
