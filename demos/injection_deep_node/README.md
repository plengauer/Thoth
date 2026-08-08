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
  "trace_id": "228df80738f562b5eec6b4c0539b7438",
  "span_id": "c0fe46c39bb3ef7b",
  "parent_span_id": "a976a5b221e27dce",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786148050348000000,
  "time_end": 1786148050517038303,
  "attributes": {
    "http.url": "http://example.com/",
    "http.method": "GET",
    "http.target": "/",
    "net.peer.name": "example.com",
    "http.host": "example.com:80",
    "net.peer.ip": "172.66.147.243",
    "net.peer.port": 80,
    "http.status_code": 200,
    "http.status_text": "OK",
    "http.flavor": "1.1",
    "net.transport": "ip_tcp"
  },
  "resource_attributes": {
    "process.pid": 8352,
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
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-westus2-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/53IAbK1bB8CUw2",
    "host.id": "682f64f0-0d69-4ddc-98c4-07dca8cab384",
    "host.name": "53IAbK1bB8CUw2",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260720.247.2",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.8.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "228df80738f562b5eec6b4c0539b7438",
  "span_id": "67bdcd4c4cf2614c",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786148047273039104,
  "time_end": 1786148050551763456,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "0c785959-fead-4acb-b960-bd58989ff0e9",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-westus2-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/53IAbK1bB8CUw2",
    "host.id": "682f64f0-0d69-4ddc-98c4-07dca8cab384",
    "host.name": "53IAbK1bB8CUw2",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 7625,
    "process.parent_pid": 2860,
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
  "trace_id": "228df80738f562b5eec6b4c0539b7438",
  "span_id": "c692525e8fb8b8ed",
  "parent_span_id": "c0fe46c39bb3ef7b",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786148050356000000,
  "time_end": 1786148050457664794,
  "attributes": {
    "peer.ipv4": "172.66.147.243",
    "peer[1].ipv4": "104.20.23.154",
    "peer[2].ipv6": "2606:4700:10::6814:179a",
    "peer[3].ipv6": "2606:4700:10::ac42:93f3"
  },
  "resource_attributes": {
    "process.pid": 8352,
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
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-westus2-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/53IAbK1bB8CUw2",
    "host.id": "682f64f0-0d69-4ddc-98c4-07dca8cab384",
    "host.name": "53IAbK1bB8CUw2",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260720.247.2",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.8.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "228df80738f562b5eec6b4c0539b7438",
  "span_id": "a976a5b221e27dce",
  "parent_span_id": "67bdcd4c4cf2614c",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786148047284220928,
  "time_end": 1786148050551573760,
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
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "0c785959-fead-4acb-b960-bd58989ff0e9",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-westus2-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/53IAbK1bB8CUw2",
    "host.id": "682f64f0-0d69-4ddc-98c4-07dca8cab384",
    "host.name": "53IAbK1bB8CUw2",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 7625,
    "process.parent_pid": 2860,
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
  "trace_id": "228df80738f562b5eec6b4c0539b7438",
  "span_id": "d66b771a3f98f0e4",
  "parent_span_id": "c0fe46c39bb3ef7b",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786148050354000000,
  "time_end": 1786148050465336573,
  "attributes": {
    "net.transport": "ip_tcp",
    "net.peer.name": "example.com",
    "net.peer.port": 80,
    "net.peer.ip": "172.66.147.243",
    "net.host.ip": "10.1.0.118",
    "net.host.port": 43472
  },
  "resource_attributes": {
    "process.pid": 8352,
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
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-westus2-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/53IAbK1bB8CUw2",
    "host.id": "682f64f0-0d69-4ddc-98c4-07dca8cab384",
    "host.name": "53IAbK1bB8CUw2",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260720.247.2",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.8.0"
  },
  "links": [],
  "events": []
}
```
