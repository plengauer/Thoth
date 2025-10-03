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
  "trace_id": "a2eb0d74f0e1c79215f07db5c4b3465d",
  "span_id": "09d28f63204b0e78",
  "parent_span_id": "6fb7de03d61b3d6d",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1759515760662000000,
  "time_end": 1759515760977114287,
  "attributes": {
    "http.url": "https://example.com/",
    "http.method": "GET",
    "http.target": "/",
    "net.peer.name": "example.com",
    "http.host": "example.com:443",
    "net.peer.ip": "23.192.228.80",
    "net.peer.port": 443,
    "http.response_content_length_uncompressed": 1256,
    "http.status_code": 200,
    "http.status_text": "OK",
    "http.flavor": "1.1",
    "net.transport": "ip_tcp"
  },
  "resource_attributes": {
    "process.pid": 8200,
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
    "vcs.commit.id": "eb8a05bf4179dfa66c5f14a439f41a41893eb292",
    "vcs.branch.name": "main",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/99a88d45-f2de-4e5e-9d53-5eb3fedf68bd/resourceGroups/azure-northcentralus-general-99a88d45-f2de-4e5e-9d53-5eb3fedf68bd/providers/Microsoft.Compute/virtualMachines/rgnZKnxogJaUdV",
    "host.id": "5bdc2028-0ef1-474c-bb58-622c60d5d601",
    "host.name": "rgnZKnxogJaUdV",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20250922.53.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.1.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "a2eb0d74f0e1c79215f07db5c4b3465d",
  "span_id": "05c3d007313341db",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1759515757403041024,
  "time_end": 1759515761405921024,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.28.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/99a88d45-f2de-4e5e-9d53-5eb3fedf68bd/resourceGroups/azure-northcentralus-general-99a88d45-f2de-4e5e-9d53-5eb3fedf68bd/providers/Microsoft.Compute/virtualMachines/rgnZKnxogJaUdV",
    "host.id": "5bdc2028-0ef1-474c-bb58-622c60d5d601",
    "host.name": "rgnZKnxogJaUdV",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 7387,
    "process.parent_pid": 2377,
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
  "trace_id": "a2eb0d74f0e1c79215f07db5c4b3465d",
  "span_id": "6fb7de03d61b3d6d",
  "parent_span_id": "05c3d007313341db",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759515757415572480,
  "time_end": 1759515761405767424,
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
    "telemetry.sdk.version": "5.28.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/99a88d45-f2de-4e5e-9d53-5eb3fedf68bd/resourceGroups/azure-northcentralus-general-99a88d45-f2de-4e5e-9d53-5eb3fedf68bd/providers/Microsoft.Compute/virtualMachines/rgnZKnxogJaUdV",
    "host.id": "5bdc2028-0ef1-474c-bb58-622c60d5d601",
    "host.name": "rgnZKnxogJaUdV",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 7387,
    "process.parent_pid": 2377,
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
