# Demo "Context Propagation with curl"
This script shows context propagation via HTTP from a client (curl) to a server (ncat).
## Script
```sh
otel4netcat_http ncat -l -c 'printf "HTTP/1.1 418 I'\''m a teapot\r\n\r\n"' 12345 & # fake http server
sleep 5
. otel.sh
curl http://127.0.0.1:12345
```
## Trace Structure Overview
```
send/receive
bash -e demo.sh
  curl http://127.0.0.1:12345
    GET
      GET
        printf HTTP/1.1 418 I'm a teapot
```
## Full Trace
```
{
  "trace_id": "909dcbc3e0e7e1a45df33990e2264368",
  "span_id": "e3faebc1ea37b6cf",
  "parent_span_id": "80f4656a43ffed72",
  "name": "GET",
  "kind": "CLIENT",
  "status": "ERROR",
  "time_start": 1763806186180678912,
  "time_end": 1763806186982928384,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "http",
    "network.protocol.version": "1.1",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 12345,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "url.full": "http://127.0.0.1:12345/",
    "url.path": "/",
    "url.scheme": "http",
    "http.request.method": "GET",
    "http.request.header.host": [
      "127.0.0.1:12345"
    ],
    "user_agent.original": "curl/8.5.0",
    "http.request.header.user-agent": [
      "curl/8.5.0"
    ],
    "http.request.header.accept": [
      "*/*"
    ],
    "http.request.header.traceparent": [
      "00-909dcbc3e0e7e1a45df33990e2264368-e3faebc1ea37b6cf-01"
    ],
    "http.response.status_code": 418
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/88e1176b-6f3d-4789-b097-47787cd24789/resourceGroups/azure-eastus-general-88e1176b-6f3d-4789-b097-47787cd24789/providers/Microsoft.Compute/virtualMachines/iAWAqVnIh6xdgf",
    "host.id": "3a57a563-473e-4a0b-a561-35beb0f36ba2",
    "host.name": "iAWAqVnIh6xdgf",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3a57a563-473e-4a0b-a561-35beb0f36ba2",
    "process.pid": 3082,
    "process.parent_pid": 2517,
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
  "trace_id": "909dcbc3e0e7e1a45df33990e2264368",
  "span_id": "08808c5f639564d0",
  "parent_span_id": "e3faebc1ea37b6cf",
  "name": "GET",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1763806186847592704,
  "time_end": 1763806186936519680,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 41758,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 41758,
    "network.protocol.name": "http",
    "network.protocol.version": "1.1",
    "url.full": "http://:12345/",
    "url.path": "/",
    "url.scheme": "http",
    "http.request.method": "GET",
    "http.request.body.size": 0,
    "http.response.status_code": 418,
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/88e1176b-6f3d-4789-b097-47787cd24789/resourceGroups/azure-eastus-general-88e1176b-6f3d-4789-b097-47787cd24789/providers/Microsoft.Compute/virtualMachines/iAWAqVnIh6xdgf",
    "host.id": "3a57a563-473e-4a0b-a561-35beb0f36ba2",
    "host.name": "iAWAqVnIh6xdgf",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3a57a563-473e-4a0b-a561-35beb0f36ba2",
    "process.pid": 4051,
    "process.parent_pid": 4049,
    "process.executable.name": "dash",
    "process.executable.path": "/usr/bin/dash",
    "process.command_line": "/bin/sh -e /usr/bin/otel4netcat_handler printf HTTP/1.1 418 I'm a teapot",
    "process.command": "/bin/sh",
    "process.owner": "runner",
    "process.runtime.name": "dash",
    "process.runtime.description": "Debian Almquist Shell",
    "process.runtime.version": "0.5.12-6ubuntu5",
    "process.runtime.options": "e"
  },
  "links": [
    {
      "trace_id": "900101f96b558a747b8d5929ccac187c",
      "span_id": "5ee68fb10df0d60d",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "909dcbc3e0e7e1a45df33990e2264368",
  "span_id": "02c7eec87a663c5f",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1763806186117126144,
  "time_end": 1763806186986460928,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/88e1176b-6f3d-4789-b097-47787cd24789/resourceGroups/azure-eastus-general-88e1176b-6f3d-4789-b097-47787cd24789/providers/Microsoft.Compute/virtualMachines/iAWAqVnIh6xdgf",
    "host.id": "3a57a563-473e-4a0b-a561-35beb0f36ba2",
    "host.name": "iAWAqVnIh6xdgf",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3a57a563-473e-4a0b-a561-35beb0f36ba2",
    "process.pid": 3082,
    "process.parent_pid": 2517,
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
  "trace_id": "909dcbc3e0e7e1a45df33990e2264368",
  "span_id": "80f4656a43ffed72",
  "parent_span_id": "02c7eec87a663c5f",
  "name": "curl http://127.0.0.1:12345",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763806186129125376,
  "time_end": 1763806186986278912,
  "attributes": {
    "shell.command_line": "curl http://127.0.0.1:12345",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 4
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/88e1176b-6f3d-4789-b097-47787cd24789/resourceGroups/azure-eastus-general-88e1176b-6f3d-4789-b097-47787cd24789/providers/Microsoft.Compute/virtualMachines/iAWAqVnIh6xdgf",
    "host.id": "3a57a563-473e-4a0b-a561-35beb0f36ba2",
    "host.name": "iAWAqVnIh6xdgf",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3a57a563-473e-4a0b-a561-35beb0f36ba2",
    "process.pid": 3082,
    "process.parent_pid": 2517,
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
  "trace_id": "909dcbc3e0e7e1a45df33990e2264368",
  "span_id": "361868f37322c256",
  "parent_span_id": "08808c5f639564d0",
  "name": "printf HTTP/1.1 418 I'm a teapot",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763806186857378816,
  "time_end": 1763806186866608128,
  "attributes": {
    "shell.command_line": "printf HTTP/1.1 418 I'm a teapot",
    "shell.command": "printf",
    "shell.command.type": "builtin",
    "shell.command.name": "printf",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel4netcat_handler"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/88e1176b-6f3d-4789-b097-47787cd24789/resourceGroups/azure-eastus-general-88e1176b-6f3d-4789-b097-47787cd24789/providers/Microsoft.Compute/virtualMachines/iAWAqVnIh6xdgf",
    "host.id": "3a57a563-473e-4a0b-a561-35beb0f36ba2",
    "host.name": "iAWAqVnIh6xdgf",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3a57a563-473e-4a0b-a561-35beb0f36ba2",
    "process.pid": 4051,
    "process.parent_pid": 4049,
    "process.executable.name": "dash",
    "process.executable.path": "/usr/bin/dash",
    "process.command_line": "/bin/sh -e /usr/bin/otel4netcat_handler printf HTTP/1.1 418 I'm a teapot",
    "process.command": "/bin/sh",
    "process.owner": "runner",
    "process.runtime.name": "dash",
    "process.runtime.description": "Debian Almquist Shell",
    "process.runtime.version": "0.5.12-6ubuntu5",
    "process.runtime.options": "e"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "900101f96b558a747b8d5929ccac187c",
  "span_id": "5ee68fb10df0d60d",
  "parent_span_id": null,
  "name": "send/receive",
  "kind": "CONSUMER",
  "status": "UNSET",
  "time_start": 1763806186768383744,
  "time_end": 1763806186938698240,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 41758,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 41758
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/88e1176b-6f3d-4789-b097-47787cd24789/resourceGroups/azure-eastus-general-88e1176b-6f3d-4789-b097-47787cd24789/providers/Microsoft.Compute/virtualMachines/iAWAqVnIh6xdgf",
    "host.id": "3a57a563-473e-4a0b-a561-35beb0f36ba2",
    "host.name": "iAWAqVnIh6xdgf",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3a57a563-473e-4a0b-a561-35beb0f36ba2",
    "process.pid": 4051,
    "process.parent_pid": 4049,
    "process.executable.name": "dash",
    "process.executable.path": "/usr/bin/dash",
    "process.command_line": "/bin/sh -e /usr/bin/otel4netcat_handler printf HTTP/1.1 418 I'm a teapot",
    "process.command": "/bin/sh",
    "process.owner": "runner",
    "process.runtime.name": "dash",
    "process.runtime.description": "Debian Almquist Shell",
    "process.runtime.version": "0.5.12-6ubuntu5",
    "process.runtime.options": "e"
  },
  "links": [
    {
      "trace_id": "909dcbc3e0e7e1a45df33990e2264368",
      "span_id": "08808c5f639564d0",
      "attributes": {}
    }
  ],
  "events": []
}
```
