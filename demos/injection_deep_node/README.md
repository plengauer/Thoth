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
  "trace_id": "7091fcccb949001c1349bb4631de9c46",
  "span_id": "097371093d68343b",
  "parent_span_id": "9410bab626fb0105",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790364030684000000,
  "time_end": 1790364030825154472,
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
    "process.pid": 8232,
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
    "cloud.resource_id": "/subscriptions/5a3abe5b-592d-48a8-8e93-2ad9d11c7c5f/resourceGroups/azure-eastus-general-5a3abe5b-592d-48a8-8e93-2ad9d11c7c5f/providers/Microsoft.Compute/virtualMachines/GQ3gAQDjCjEfBH",
    "host.id": "9ab83c92-5bca-4061-9cf3-d8fd94c7462b",
    "host.name": "GQ3gAQDjCjEfBH",
    "host.type": "Standard_D4ads_v5",
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
  "trace_id": "7091fcccb949001c1349bb4631de9c46",
  "span_id": "4dab44485c02e703",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1790364029206310400,
  "time_end": 1790364030862297600,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "9806c5a9-c781-4b96-a62c-372da60d29e0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/5a3abe5b-592d-48a8-8e93-2ad9d11c7c5f/resourceGroups/azure-eastus-general-5a3abe5b-592d-48a8-8e93-2ad9d11c7c5f/providers/Microsoft.Compute/virtualMachines/GQ3gAQDjCjEfBH",
    "host.id": "9ab83c92-5bca-4061-9cf3-d8fd94c7462b",
    "host.name": "GQ3gAQDjCjEfBH",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7515,
    "process.parent_pid": 2840,
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
  "trace_id": "7091fcccb949001c1349bb4631de9c46",
  "span_id": "e2e72f4137194468",
  "parent_span_id": "097371093d68343b",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790364030688000000,
  "time_end": 1790364030795784731,
  "attributes": {
    "peer.ipv4": "104.20.23.154",
    "peer[1].ipv4": "172.66.147.243",
    "peer[2].ipv6": "2606:4700:10::6814:179a",
    "peer[3].ipv6": "2606:4700:10::ac42:93f3"
  },
  "resource_attributes": {
    "process.pid": 8232,
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
    "cloud.resource_id": "/subscriptions/5a3abe5b-592d-48a8-8e93-2ad9d11c7c5f/resourceGroups/azure-eastus-general-5a3abe5b-592d-48a8-8e93-2ad9d11c7c5f/providers/Microsoft.Compute/virtualMachines/GQ3gAQDjCjEfBH",
    "host.id": "9ab83c92-5bca-4061-9cf3-d8fd94c7462b",
    "host.name": "GQ3gAQDjCjEfBH",
    "host.type": "Standard_D4ads_v5",
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
  "trace_id": "7091fcccb949001c1349bb4631de9c46",
  "span_id": "9410bab626fb0105",
  "parent_span_id": "4dab44485c02e703",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790364029213179136,
  "time_end": 1790364030862036480,
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
    "service.instance.id": "9806c5a9-c781-4b96-a62c-372da60d29e0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/5a3abe5b-592d-48a8-8e93-2ad9d11c7c5f/resourceGroups/azure-eastus-general-5a3abe5b-592d-48a8-8e93-2ad9d11c7c5f/providers/Microsoft.Compute/virtualMachines/GQ3gAQDjCjEfBH",
    "host.id": "9ab83c92-5bca-4061-9cf3-d8fd94c7462b",
    "host.name": "GQ3gAQDjCjEfBH",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7515,
    "process.parent_pid": 2840,
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
  "trace_id": "7091fcccb949001c1349bb4631de9c46",
  "span_id": "a3e4ff2fe1ad32fe",
  "parent_span_id": "097371093d68343b",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790364030687000000,
  "time_end": 1790364030803976260,
  "attributes": {
    "network.transport": "tcp",
    "server.address": "example.com",
    "server.port": 80,
    "network.peer.address": "104.20.23.154",
    "network.local.address": "10.1.0.141",
    "network.local.port": 48944
  },
  "resource_attributes": {
    "process.pid": 8232,
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
    "cloud.resource_id": "/subscriptions/5a3abe5b-592d-48a8-8e93-2ad9d11c7c5f/resourceGroups/azure-eastus-general-5a3abe5b-592d-48a8-8e93-2ad9d11c7c5f/providers/Microsoft.Compute/virtualMachines/GQ3gAQDjCjEfBH",
    "host.id": "9ab83c92-5bca-4061-9cf3-d8fd94c7462b",
    "host.name": "GQ3gAQDjCjEfBH",
    "host.type": "Standard_D4ads_v5",
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
