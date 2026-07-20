# Demo "Deep injection into a Node.js app"
This script uses a node.js app and configures opentelemetry to inject into the app and continue tracing.
## Script
```sh
export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE
. otel.sh
 node index.js
```
## Trace Structure Overview
```
bash -e demo.sh
  node index.js
    GET
      dns.lookup
      tcp.connect
```
## Full Trace
```
{
  "trace_id": "da4429a1a3b1c59d7bfe7701bcf04bd2",
  "span_id": "55ab591a1810f839",
  "parent_span_id": "a3f87430304c5113",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783555277544000000,
  "time_end": 1783555277673090650,
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
    "process.pid": 8404,
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
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/3f4e1856-2ec0-430d-9a24-99890b54d9c5/resourceGroups/azure-eastus-general-3f4e1856-2ec0-430d-9a24-99890b54d9c5/providers/Microsoft.Compute/virtualMachines/RGVSkFwQKd20VW",
    "host.id": "0c81a8f9-df74-494e-ac72-86e026263fbf",
    "host.name": "RGVSkFwQKd20VW",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260628.225.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.8.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "da4429a1a3b1c59d7bfe7701bcf04bd2",
  "span_id": "5e33b3144dc81845",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1783555276088791808,
  "time_end": 1783555277751219712,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "95b74cd6-0be2-48cc-9d27-8918d5cacb06",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/3f4e1856-2ec0-430d-9a24-99890b54d9c5/resourceGroups/azure-eastus-general-3f4e1856-2ec0-430d-9a24-99890b54d9c5/providers/Microsoft.Compute/virtualMachines/RGVSkFwQKd20VW",
    "host.id": "0c81a8f9-df74-494e-ac72-86e026263fbf",
    "host.name": "RGVSkFwQKd20VW",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 7676,
    "process.parent_pid": 2897,
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
  "trace_id": "da4429a1a3b1c59d7bfe7701bcf04bd2",
  "span_id": "1fece0f9a2bc8de2",
  "parent_span_id": "55ab591a1810f839",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783555277548000000,
  "time_end": 1783555277649629067,
  "attributes": {
    "peer.ipv4": "104.20.23.154",
    "peer[1].ipv4": "172.66.147.243",
    "peer[2].ipv6": "2606:4700:10::6814:179a",
    "peer[3].ipv6": "2606:4700:10::ac42:93f3"
  },
  "resource_attributes": {
    "process.pid": 8404,
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
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/3f4e1856-2ec0-430d-9a24-99890b54d9c5/resourceGroups/azure-eastus-general-3f4e1856-2ec0-430d-9a24-99890b54d9c5/providers/Microsoft.Compute/virtualMachines/RGVSkFwQKd20VW",
    "host.id": "0c81a8f9-df74-494e-ac72-86e026263fbf",
    "host.name": "RGVSkFwQKd20VW",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260628.225.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.8.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "da4429a1a3b1c59d7bfe7701bcf04bd2",
  "span_id": "a3f87430304c5113",
  "parent_span_id": "5e33b3144dc81845",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783555276099738368,
  "time_end": 1783555277751008256,
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
    "service.instance.id": "95b74cd6-0be2-48cc-9d27-8918d5cacb06",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/3f4e1856-2ec0-430d-9a24-99890b54d9c5/resourceGroups/azure-eastus-general-3f4e1856-2ec0-430d-9a24-99890b54d9c5/providers/Microsoft.Compute/virtualMachines/RGVSkFwQKd20VW",
    "host.id": "0c81a8f9-df74-494e-ac72-86e026263fbf",
    "host.name": "RGVSkFwQKd20VW",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 7676,
    "process.parent_pid": 2897,
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
  "trace_id": "da4429a1a3b1c59d7bfe7701bcf04bd2",
  "span_id": "2f535ec54c1a56f6",
  "parent_span_id": "55ab591a1810f839",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783555277547000000,
  "time_end": 1783555277659649662,
  "attributes": {
    "net.transport": "ip_tcp",
    "net.peer.name": "example.com",
    "net.peer.port": 80,
    "net.peer.ip": "104.20.23.154",
    "net.host.ip": "10.1.0.167",
    "net.host.port": 49596
  },
  "resource_attributes": {
    "process.pid": 8404,
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
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/3f4e1856-2ec0-430d-9a24-99890b54d9c5/resourceGroups/azure-eastus-general-3f4e1856-2ec0-430d-9a24-99890b54d9c5/providers/Microsoft.Compute/virtualMachines/RGVSkFwQKd20VW",
    "host.id": "0c81a8f9-df74-494e-ac72-86e026263fbf",
    "host.name": "RGVSkFwQKd20VW",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260628.225.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.8.0"
  },
  "links": [],
  "events": []
}
```
