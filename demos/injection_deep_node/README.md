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
```
## Full Trace
```
{
  "trace_id": "c9aa8676aa18ced04a12110652579f2c",
  "span_id": "1bddd593bda08d16",
  "parent_span_id": "4047582db3aa6a2e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1760084820898000000,
  "time_end": 1760084821241165467,
  "attributes": {
    "http.url": "https://example.com/",
    "http.method": "GET",
    "http.target": "/",
    "net.peer.name": "example.com",
    "http.host": "example.com:443",
    "net.peer.ip": "23.192.228.80",
    "net.peer.port": 443,
    "http.response_content_length_uncompressed": 513,
    "http.status_code": 200,
    "http.status_text": "OK",
    "http.flavor": "1.1",
    "net.transport": "ip_tcp"
  },
  "resource_attributes": {
    "process.pid": 8405,
    "process.executable.name": "node",
    "process.executable.path": "/usr/local/bin/node",
    "process.command_args": [
      "/usr/local/bin/node",
      "--require",
      "/usr/share/opentelemetry_shell/agent.instrumentation.node/20/deep.inject.js",
      "--require",
      "/usr/share/opentelemetry_shell/agent.instrumentation.node/20/deep.instrument.js",
      "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js"
    ],
    "process.runtime.version": "20.19.5",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "vcs.system": "git",
    "vcs.commit.id": "7c14689221465ae18278072bd083c47bb2f9032a",
    "vcs.branch.name": "main",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/cb04078a-85c2-468a-8c11-b69e668269bb/resourceGroups/azure-westcentralus-general-cb04078a-85c2-468a-8c11-b69e668269bb/providers/Microsoft.Compute/virtualMachines/rd45YegytYDqia",
    "host.id": "67f17175-5987-4985-a15c-8245d12e8c72",
    "host.name": "rd45YegytYDqia",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20250929.60.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.1.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "c9aa8676aa18ced04a12110652579f2c",
  "span_id": "a2a4869b7215e26d",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1760084818601971712,
  "time_end": 1760084821645732864,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.30.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/cb04078a-85c2-468a-8c11-b69e668269bb/resourceGroups/azure-westcentralus-general-cb04078a-85c2-468a-8c11-b69e668269bb/providers/Microsoft.Compute/virtualMachines/rd45YegytYDqia",
    "host.id": "67f17175-5987-4985-a15c-8245d12e8c72",
    "host.name": "rd45YegytYDqia",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 7591,
    "process.parent_pid": 2518,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "c9aa8676aa18ced04a12110652579f2c",
  "span_id": "4047582db3aa6a2e",
  "parent_span_id": "a2a4869b7215e26d",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1760084818614450432,
  "time_end": 1760084821645582848,
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
    "telemetry.sdk.version": "5.30.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/cb04078a-85c2-468a-8c11-b69e668269bb/resourceGroups/azure-westcentralus-general-cb04078a-85c2-468a-8c11-b69e668269bb/providers/Microsoft.Compute/virtualMachines/rd45YegytYDqia",
    "host.id": "67f17175-5987-4985-a15c-8245d12e8c72",
    "host.name": "rd45YegytYDqia",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 7591,
    "process.parent_pid": 2518,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": ""
  },
  "links": [],
  "events": []
}
```
