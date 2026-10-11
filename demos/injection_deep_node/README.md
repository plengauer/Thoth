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
  "trace_id": "d9e1fb3da8cf6a293b1492b8b45a979f",
  "span_id": "fdabf76ac3a00c26",
  "parent_span_id": "eebb87a025d532c2",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1791638640134000000,
  "time_end": 1791638640330158706,
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
    "process.pid": 8301,
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
    "process.runtime.version": "22.23.3",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/578bfb9a-d217-425a-bd22-0d0a83261d0e/resourceGroups/azure-centralus-general-578bfb9a-d217-425a-bd22-0d0a83261d0e/providers/Microsoft.Compute/virtualMachines/RV6PHfDpEB5yh9",
    "host.id": "ce002be7-3741-47e8-a767-de935cd2660b",
    "host.name": "RV6PHfDpEB5yh9",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20261004.327.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.11.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "d9e1fb3da8cf6a293b1492b8b45a979f",
  "span_id": "f19ba1bafb593d78",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1791638638837316864,
  "time_end": 1791638640379849984,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "c16861c4-15e0-44ff-b017-021990f9baea",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/578bfb9a-d217-425a-bd22-0d0a83261d0e/resourceGroups/azure-centralus-general-578bfb9a-d217-425a-bd22-0d0a83261d0e/providers/Microsoft.Compute/virtualMachines/RV6PHfDpEB5yh9",
    "host.id": "ce002be7-3741-47e8-a767-de935cd2660b",
    "host.name": "RV6PHfDpEB5yh9",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7584,
    "process.parent_pid": 2884,
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
  "trace_id": "d9e1fb3da8cf6a293b1492b8b45a979f",
  "span_id": "188669d41590f0cd",
  "parent_span_id": "fdabf76ac3a00c26",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1791638640139000000,
  "time_end": 1791638640248665161,
  "attributes": {
    "peer.ipv4": "104.20.23.154",
    "peer[1].ipv4": "172.66.147.243",
    "peer[2].ipv6": "2606:4700:10::ac42:93f3",
    "peer[3].ipv6": "2606:4700:10::6814:179a"
  },
  "resource_attributes": {
    "process.pid": 8301,
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
    "process.runtime.version": "22.23.3",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/578bfb9a-d217-425a-bd22-0d0a83261d0e/resourceGroups/azure-centralus-general-578bfb9a-d217-425a-bd22-0d0a83261d0e/providers/Microsoft.Compute/virtualMachines/RV6PHfDpEB5yh9",
    "host.id": "ce002be7-3741-47e8-a767-de935cd2660b",
    "host.name": "RV6PHfDpEB5yh9",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20261004.327.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.11.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "d9e1fb3da8cf6a293b1492b8b45a979f",
  "span_id": "eebb87a025d532c2",
  "parent_span_id": "f19ba1bafb593d78",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638638844648704,
  "time_end": 1791638640379110656,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "c16861c4-15e0-44ff-b017-021990f9baea",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/578bfb9a-d217-425a-bd22-0d0a83261d0e/resourceGroups/azure-centralus-general-578bfb9a-d217-425a-bd22-0d0a83261d0e/providers/Microsoft.Compute/virtualMachines/RV6PHfDpEB5yh9",
    "host.id": "ce002be7-3741-47e8-a767-de935cd2660b",
    "host.name": "RV6PHfDpEB5yh9",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7584,
    "process.parent_pid": 2884,
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
  "trace_id": "d9e1fb3da8cf6a293b1492b8b45a979f",
  "span_id": "9944434e6bc65862",
  "parent_span_id": "fdabf76ac3a00c26",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638640138000000,
  "time_end": 1791638640260948988,
  "attributes": {
    "network.transport": "tcp",
    "server.address": "example.com",
    "server.port": 80,
    "network.peer.address": "104.20.23.154",
    "network.local.address": "10.1.0.141",
    "network.local.port": 35724
  },
  "resource_attributes": {
    "process.pid": 8301,
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
    "process.runtime.version": "22.23.3",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/578bfb9a-d217-425a-bd22-0d0a83261d0e/resourceGroups/azure-centralus-general-578bfb9a-d217-425a-bd22-0d0a83261d0e/providers/Microsoft.Compute/virtualMachines/RV6PHfDpEB5yh9",
    "host.id": "ce002be7-3741-47e8-a767-de935cd2660b",
    "host.name": "RV6PHfDpEB5yh9",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20261004.327.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.11.0"
  },
  "links": [],
  "events": []
}
```
