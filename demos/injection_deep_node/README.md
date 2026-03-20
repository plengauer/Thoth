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
  "trace_id": "1b98cd75edb0700c7698bd6a01b9581f",
  "span_id": "143c15a9f8067f75",
  "parent_span_id": "f84c39371bdab4cc",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1773124747064000000,
  "time_end": 1773124747102249612,
  "attributes": {
    "http.url": "http://example.com/",
    "http.method": "GET",
    "http.target": "/",
    "net.peer.name": "example.com",
    "http.host": "example.com:80",
    "net.peer.ip": "104.18.27.120",
    "net.peer.port": 80,
    "http.status_code": 200,
    "http.status_text": "OK",
    "http.flavor": "1.1",
    "net.transport": "ip_tcp"
  },
  "resource_attributes": {
    "process.pid": 7737,
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
    "process.runtime.version": "20.20.0",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "vcs.system": "git",
    "vcs.commit.id": "3863925db919310045f636380cc799b60ed41c92",
    "vcs.branch.name": "release",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/a31b1e14-00c8-41ad-bb0d-00cdf1be01c7/resourceGroups/azure-eastus2-general-a31b1e14-00c8-41ad-bb0d-00cdf1be01c7/providers/Microsoft.Compute/virtualMachines/gA7kjWm36uCpAC",
    "host.id": "0d0e69a4-59dd-4072-b8d7-ba312783c7c7",
    "host.name": "gA7kjWm36uCpAC",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260302.42.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.5.1"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "1b98cd75edb0700c7698bd6a01b9581f",
  "span_id": "bc3793788a5600c9",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1773124745394706688,
  "time_end": 1773124747133016832,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/a31b1e14-00c8-41ad-bb0d-00cdf1be01c7/resourceGroups/azure-eastus2-general-a31b1e14-00c8-41ad-bb0d-00cdf1be01c7/providers/Microsoft.Compute/virtualMachines/gA7kjWm36uCpAC",
    "host.id": "0d0e69a4-59dd-4072-b8d7-ba312783c7c7",
    "host.name": "gA7kjWm36uCpAC",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "0d0e69a4-59dd-4072-b8d7-ba312783c7c7",
    "process.pid": 7003,
    "process.parent_pid": 2552,
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
  "trace_id": "1b98cd75edb0700c7698bd6a01b9581f",
  "span_id": "450d93f820309362",
  "parent_span_id": "143c15a9f8067f75",
  "name": "dns.lookup",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1773124747069000000,
  "time_end": 1773124747073653055,
  "attributes": {
    "peer.ipv4": "104.18.27.120",
    "peer[1].ipv4": "104.18.26.120",
    "peer[2].ipv6": "2606:4700::6812:1b78",
    "peer[3].ipv6": "2606:4700::6812:1a78"
  },
  "resource_attributes": {
    "process.pid": 7737,
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
    "process.runtime.version": "20.20.0",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "vcs.system": "git",
    "vcs.commit.id": "3863925db919310045f636380cc799b60ed41c92",
    "vcs.branch.name": "release",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/a31b1e14-00c8-41ad-bb0d-00cdf1be01c7/resourceGroups/azure-eastus2-general-a31b1e14-00c8-41ad-bb0d-00cdf1be01c7/providers/Microsoft.Compute/virtualMachines/gA7kjWm36uCpAC",
    "host.id": "0d0e69a4-59dd-4072-b8d7-ba312783c7c7",
    "host.name": "gA7kjWm36uCpAC",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260302.42.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.5.1"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "1b98cd75edb0700c7698bd6a01b9581f",
  "span_id": "f84c39371bdab4cc",
  "parent_span_id": "bc3793788a5600c9",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1773124745406986240,
  "time_end": 1773124747132846848,
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
    "telemetry.sdk.version": "5.47.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/a31b1e14-00c8-41ad-bb0d-00cdf1be01c7/resourceGroups/azure-eastus2-general-a31b1e14-00c8-41ad-bb0d-00cdf1be01c7/providers/Microsoft.Compute/virtualMachines/gA7kjWm36uCpAC",
    "host.id": "0d0e69a4-59dd-4072-b8d7-ba312783c7c7",
    "host.name": "gA7kjWm36uCpAC",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "0d0e69a4-59dd-4072-b8d7-ba312783c7c7",
    "process.pid": 7003,
    "process.parent_pid": 2552,
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
  "trace_id": "1b98cd75edb0700c7698bd6a01b9581f",
  "span_id": "6d091f02d459f082",
  "parent_span_id": "143c15a9f8067f75",
  "name": "tcp.connect",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1773124747068000000,
  "time_end": 1773124747084247217,
  "attributes": {
    "net.transport": "ip_tcp",
    "net.peer.name": "example.com",
    "net.peer.port": 80,
    "net.peer.ip": "104.18.27.120",
    "net.host.ip": "10.1.0.58",
    "net.host.port": 36282
  },
  "resource_attributes": {
    "process.pid": 7737,
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
    "process.runtime.version": "20.20.0",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "vcs.system": "git",
    "vcs.commit.id": "3863925db919310045f636380cc799b60ed41c92",
    "vcs.branch.name": "release",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure.vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/a31b1e14-00c8-41ad-bb0d-00cdf1be01c7/resourceGroups/azure-eastus2-general-a31b1e14-00c8-41ad-bb0d-00cdf1be01c7/providers/Microsoft.Compute/virtualMachines/gA7kjWm36uCpAC",
    "host.id": "0d0e69a4-59dd-4072-b8d7-ba312783c7c7",
    "host.name": "gA7kjWm36uCpAC",
    "host.type": "Standard_D4ads_v5",
    "os.version": "20260302.42.1",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.5.1"
  },
  "links": [],
  "events": []
}
```
