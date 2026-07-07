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
  "trace_id": "192a9ca52078446c7814fa82360e1fcd",
  "span_id": "bbcbee28d2a9bc79",
  "parent_span_id": "f3a88325536d70a2",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678275484000000,
  "time_end": 1782678275621227812,
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
    "process.pid": 8217,
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
    "process.runtime.version": "22.23.0",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/920a69fd-e4dc-4112-bdd4-c3465b314e64/resourceGroups/azure-westcentralus-general-920a69fd-e4dc-4112-bdd4-c3465b314e64/providers/Microsoft.Compute/virtualMachines/48CgiilTfIkagx",
    "host.id": "ea6827b1-2d46-4736-90cf-3b9520642917",
    "host.name": "48CgiilTfIkagx",
    "host.type": "Standard_D4ads_v6",
    "os.version": "20260622.220.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.8.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "192a9ca52078446c7814fa82360e1fcd",
  "span_id": "9225b2043045d012",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1782678273472820224,
  "time_end": 1782678275646892800,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "1faefa30-a59c-4757-95ed-199a386bf634",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/920a69fd-e4dc-4112-bdd4-c3465b314e64/resourceGroups/azure-westcentralus-general-920a69fd-e4dc-4112-bdd4-c3465b314e64/providers/Microsoft.Compute/virtualMachines/48CgiilTfIkagx",
    "host.id": "ea6827b1-2d46-4736-90cf-3b9520642917",
    "host.name": "48CgiilTfIkagx",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 7489,
    "process.parent_pid": 2700,
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
  "trace_id": "192a9ca52078446c7814fa82360e1fcd",
  "span_id": "82a2397892305069",
  "parent_span_id": "bbcbee28d2a9bc79",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678275487000000,
  "time_end": 1782678275568032719,
  "attributes": {
    "peer.ipv4": "172.66.147.243",
    "peer[1].ipv4": "104.20.23.154",
    "peer[2].ipv6": "2606:4700:10::ac42:93f3",
    "peer[3].ipv6": "2606:4700:10::6814:179a"
  },
  "resource_attributes": {
    "process.pid": 8217,
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
    "process.runtime.version": "22.23.0",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/920a69fd-e4dc-4112-bdd4-c3465b314e64/resourceGroups/azure-westcentralus-general-920a69fd-e4dc-4112-bdd4-c3465b314e64/providers/Microsoft.Compute/virtualMachines/48CgiilTfIkagx",
    "host.id": "ea6827b1-2d46-4736-90cf-3b9520642917",
    "host.name": "48CgiilTfIkagx",
    "host.type": "Standard_D4ads_v6",
    "os.version": "20260622.220.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.8.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "192a9ca52078446c7814fa82360e1fcd",
  "span_id": "f3a88325536d70a2",
  "parent_span_id": "9225b2043045d012",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678273483014912,
  "time_end": 1782678275646738432,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "1faefa30-a59c-4757-95ed-199a386bf634",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/920a69fd-e4dc-4112-bdd4-c3465b314e64/resourceGroups/azure-westcentralus-general-920a69fd-e4dc-4112-bdd4-c3465b314e64/providers/Microsoft.Compute/virtualMachines/48CgiilTfIkagx",
    "host.id": "ea6827b1-2d46-4736-90cf-3b9520642917",
    "host.name": "48CgiilTfIkagx",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 7489,
    "process.parent_pid": 2700,
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
  "trace_id": "192a9ca52078446c7814fa82360e1fcd",
  "span_id": "1a92e6e7247579d8",
  "parent_span_id": "bbcbee28d2a9bc79",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678275486000000,
  "time_end": 1782678275596071159,
  "attributes": {
    "net.transport": "ip_tcp",
    "net.peer.name": "example.com",
    "net.peer.port": 80,
    "net.peer.ip": "172.66.147.243",
    "net.host.ip": "10.1.0.162",
    "net.host.port": 36430
  },
  "resource_attributes": {
    "process.pid": 8217,
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
    "process.runtime.version": "22.23.0",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/920a69fd-e4dc-4112-bdd4-c3465b314e64/resourceGroups/azure-westcentralus-general-920a69fd-e4dc-4112-bdd4-c3465b314e64/providers/Microsoft.Compute/virtualMachines/48CgiilTfIkagx",
    "host.id": "ea6827b1-2d46-4736-90cf-3b9520642917",
    "host.name": "48CgiilTfIkagx",
    "host.type": "Standard_D4ads_v6",
    "os.version": "20260622.220.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.8.0"
  },
  "links": [],
  "events": []
}
```
