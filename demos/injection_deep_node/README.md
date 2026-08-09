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
  "trace_id": "2579a127758cce4d72a6e7510456e5f3",
  "span_id": "dba37625a206f50a",
  "parent_span_id": "98a93d38b5682b41",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264566876000000,
  "time_end": 1786264567059906838,
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
    "process.pid": 8349,
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
    "cloud.resource_id": "/subscriptions/5a50fa72-d73a-46dc-92e5-ea717ae0b562/resourceGroups/azure-westus3-general-5a50fa72-d73a-46dc-92e5-ea717ae0b562/providers/Microsoft.Compute/virtualMachines/8A3yeeLPoRMaaV",
    "host.id": "7dcc78d6-113a-498d-9aa5-a6fec75e93e9",
    "host.name": "8A3yeeLPoRMaaV",
    "host.type": "Standard_D4ads_v5",
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
  "trace_id": "2579a127758cce4d72a6e7510456e5f3",
  "span_id": "c07ba4aeef1bf6a3",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786264565518384640,
  "time_end": 1786264567098203904,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "4e0c0bc4-d168-4ad5-a6a4-f37016cdb03e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/5a50fa72-d73a-46dc-92e5-ea717ae0b562/resourceGroups/azure-westus3-general-5a50fa72-d73a-46dc-92e5-ea717ae0b562/providers/Microsoft.Compute/virtualMachines/8A3yeeLPoRMaaV",
    "host.id": "7dcc78d6-113a-498d-9aa5-a6fec75e93e9",
    "host.name": "8A3yeeLPoRMaaV",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 7622,
    "process.parent_pid": 2862,
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
  "trace_id": "2579a127758cce4d72a6e7510456e5f3",
  "span_id": "5721802bfd1f7da0",
  "parent_span_id": "dba37625a206f50a",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264566880000000,
  "time_end": 1786264566989173992,
  "attributes": {
    "peer.ipv4": "172.66.147.243",
    "peer[1].ipv4": "104.20.23.154",
    "peer[2].ipv6": "2606:4700:10::6814:179a",
    "peer[3].ipv6": "2606:4700:10::ac42:93f3"
  },
  "resource_attributes": {
    "process.pid": 8349,
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
    "cloud.resource_id": "/subscriptions/5a50fa72-d73a-46dc-92e5-ea717ae0b562/resourceGroups/azure-westus3-general-5a50fa72-d73a-46dc-92e5-ea717ae0b562/providers/Microsoft.Compute/virtualMachines/8A3yeeLPoRMaaV",
    "host.id": "7dcc78d6-113a-498d-9aa5-a6fec75e93e9",
    "host.name": "8A3yeeLPoRMaaV",
    "host.type": "Standard_D4ads_v5",
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
  "trace_id": "2579a127758cce4d72a6e7510456e5f3",
  "span_id": "98a93d38b5682b41",
  "parent_span_id": "c07ba4aeef1bf6a3",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264565529632768,
  "time_end": 1786264567098023680,
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
    "service.instance.id": "4e0c0bc4-d168-4ad5-a6a4-f37016cdb03e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/5a50fa72-d73a-46dc-92e5-ea717ae0b562/resourceGroups/azure-westus3-general-5a50fa72-d73a-46dc-92e5-ea717ae0b562/providers/Microsoft.Compute/virtualMachines/8A3yeeLPoRMaaV",
    "host.id": "7dcc78d6-113a-498d-9aa5-a6fec75e93e9",
    "host.name": "8A3yeeLPoRMaaV",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 7622,
    "process.parent_pid": 2862,
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
  "trace_id": "2579a127758cce4d72a6e7510456e5f3",
  "span_id": "38e600827a315fc1",
  "parent_span_id": "dba37625a206f50a",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264566879000000,
  "time_end": 1786264567044229806,
  "attributes": {
    "net.transport": "ip_tcp",
    "net.peer.name": "example.com",
    "net.peer.port": 80,
    "net.peer.ip": "104.20.23.154",
    "net.host.ip": "10.1.0.165",
    "net.host.port": 51158
  },
  "resource_attributes": {
    "process.pid": 8349,
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
    "cloud.resource_id": "/subscriptions/5a50fa72-d73a-46dc-92e5-ea717ae0b562/resourceGroups/azure-westus3-general-5a50fa72-d73a-46dc-92e5-ea717ae0b562/providers/Microsoft.Compute/virtualMachines/8A3yeeLPoRMaaV",
    "host.id": "7dcc78d6-113a-498d-9aa5-a6fec75e93e9",
    "host.name": "8A3yeeLPoRMaaV",
    "host.type": "Standard_D4ads_v5",
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
