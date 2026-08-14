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
  "trace_id": "66b7d5244e287145bf81d2211e73b8f3",
  "span_id": "a1d1d74acebcddf3",
  "parent_span_id": "7d3800d0538b6314",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786604864916000000,
  "time_end": 1786604865027622553,
  "attributes": {
    "http.url": "http://example.com/",
    "http.method": "GET",
    "http.target": "/",
    "net.peer.name": "example.com",
    "http.host": "example.com:80",
    "net.peer.ip": "104.20.23.154",
    "net.peer.port": 80,
    "http.status_code": 200,
    "http.status_text": "OK",
    "http.flavor": "1.1",
    "net.transport": "ip_tcp"
  },
  "resource_attributes": {
    "process.pid": 8315,
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
    "process.runtime.version": "22.23.1",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/462b9216-9ffd-4850-8a08-054b6a3ed688/resourceGroups/azure-westus3-general-462b9216-9ffd-4850-8a08-054b6a3ed688/providers/Microsoft.Compute/virtualMachines/LH6xQh3Khp3xrZ",
    "host.id": "5603aad8-34c0-4da2-bca3-e64413e43d17",
    "host.name": "LH6xQh3Khp3xrZ",
    "host.type": "Standard_D4ads_v6",
    "os.version": "20260720.247.2",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "66b7d5244e287145bf81d2211e73b8f3",
  "span_id": "e02ffcace875dd38",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786604862883200512,
  "time_end": 1786604865055078144,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e672ff5b-0663-4f34-bc39-36a36975d400",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/462b9216-9ffd-4850-8a08-054b6a3ed688/resourceGroups/azure-westus3-general-462b9216-9ffd-4850-8a08-054b6a3ed688/providers/Microsoft.Compute/virtualMachines/LH6xQh3Khp3xrZ",
    "host.id": "5603aad8-34c0-4da2-bca3-e64413e43d17",
    "host.name": "LH6xQh3Khp3xrZ",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 7588,
    "process.parent_pid": 2807,
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
  "trace_id": "66b7d5244e287145bf81d2211e73b8f3",
  "span_id": "f3ce5abfaf0387d6",
  "parent_span_id": "a1d1d74acebcddf3",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786604864920000000,
  "time_end": 1786604864995281386,
  "attributes": {
    "peer.ipv4": "104.20.23.154",
    "peer[1].ipv4": "172.66.147.243",
    "peer[2].ipv6": "2606:4700:10::6814:179a",
    "peer[3].ipv6": "2606:4700:10::ac42:93f3"
  },
  "resource_attributes": {
    "process.pid": 8315,
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
    "process.runtime.version": "22.23.1",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/462b9216-9ffd-4850-8a08-054b6a3ed688/resourceGroups/azure-westus3-general-462b9216-9ffd-4850-8a08-054b6a3ed688/providers/Microsoft.Compute/virtualMachines/LH6xQh3Khp3xrZ",
    "host.id": "5603aad8-34c0-4da2-bca3-e64413e43d17",
    "host.name": "LH6xQh3Khp3xrZ",
    "host.type": "Standard_D4ads_v6",
    "os.version": "20260720.247.2",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "66b7d5244e287145bf81d2211e73b8f3",
  "span_id": "7d3800d0538b6314",
  "parent_span_id": "e02ffcace875dd38",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786604862893207552,
  "time_end": 1786604865054917888,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e672ff5b-0663-4f34-bc39-36a36975d400",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/462b9216-9ffd-4850-8a08-054b6a3ed688/resourceGroups/azure-westus3-general-462b9216-9ffd-4850-8a08-054b6a3ed688/providers/Microsoft.Compute/virtualMachines/LH6xQh3Khp3xrZ",
    "host.id": "5603aad8-34c0-4da2-bca3-e64413e43d17",
    "host.name": "LH6xQh3Khp3xrZ",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 7588,
    "process.parent_pid": 2807,
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
  "trace_id": "66b7d5244e287145bf81d2211e73b8f3",
  "span_id": "1bf1d4e9b7fa98c5",
  "parent_span_id": "a1d1d74acebcddf3",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786604864919000000,
  "time_end": 1786604865012746310,
  "attributes": {
    "net.transport": "ip_tcp",
    "net.peer.name": "example.com",
    "net.peer.port": 80,
    "net.peer.ip": "104.20.23.154",
    "net.host.ip": "10.1.0.53",
    "net.host.port": 33726
  },
  "resource_attributes": {
    "process.pid": 8315,
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
    "process.runtime.version": "22.23.1",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/462b9216-9ffd-4850-8a08-054b6a3ed688/resourceGroups/azure-westus3-general-462b9216-9ffd-4850-8a08-054b6a3ed688/providers/Microsoft.Compute/virtualMachines/LH6xQh3Khp3xrZ",
    "host.id": "5603aad8-34c0-4da2-bca3-e64413e43d17",
    "host.name": "LH6xQh3Khp3xrZ",
    "host.type": "Standard_D4ads_v6",
    "os.version": "20260720.247.2",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.10.0"
  },
  "links": [],
  "events": []
}
```
