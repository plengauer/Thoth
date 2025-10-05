# Demo "Context Propagation with netcat"
This script shows context propagation via HTTP from a client (netcat) to a server (ncat).
## Script
```sh
otel4netcat_http ncat -l -c 'printf "HTTP/1.1 418 I'\''m a teapot\r\n\r\n"' 12345 & # inject with special command
sleep 5
. otel.sh
printf 'GET / HTTP/1.1\r\n\r\n' | ncat --no-shutdown 127.0.0.1 12345
```
## Trace Structure Overview
```
send/receive
```
## Full Trace
```
{
  "trace_id": "8e8ea70720a1be8ed1c286174e8dd70a",
  "span_id": "59c573cb7c2858fb",
  "parent_span_id": "ff7a5d36a42a3c5c",
  "name": "GET",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1759628460777708800,
  "time_end": 1759628460876156672,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 50646,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 50646,
    "network.protocol.name": "http",
    "network.protocol.version": "1.1",
    "url.full": "http://:12345/",
    "url.path": "/",
    "url.scheme": "http",
    "http.request.method": "GET",
    "http.request.body.size": 0,
    "http.request.header.traceparent": [
      "00-8e8ea70720a1be8ed1c286174e8dd70a-ff7a5d36a42a3c5c-01"
    ],
    "http.response.status_code": 418,
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.28.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/2ceef434-b1b5-4f4d-9032-bdf6492f11f8/resourceGroups/azure-northcentralus-general-2ceef434-b1b5-4f4d-9032-bdf6492f11f8/providers/Microsoft.Compute/virtualMachines/fQJov3o2fYQaiS",
    "host.id": "733fdcfb-83a3-4e04-903a-820df7954fb2",
    "host.name": "fQJov3o2fYQaiS",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 4704,
    "process.parent_pid": 4701,
    "process.executable.name": "dash",
    "process.executable.path": "/usr/bin/dash",
    "process.command_line": "ncat -l -c printf \"HTTP/1.1 418 I'm a teapot    \" 12345",
    "process.command": "ncat",
    "process.owner": "runner",
    "process.runtime.name": "dash",
    "process.runtime.description": "Debian Almquist Shell",
    "process.runtime.version": "0.5.12-6ubuntu5",
    "process.runtime.options": "e",
    "service.version": "",
    "service.namespace": ""
  },
  "links": [
    {
      "trace_id": "b6636bfaa2415df2e9416e375b21bdde",
      "span_id": "5dddde5b1bbc8af2",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "8e8ea70720a1be8ed1c286174e8dd70a",
  "span_id": "3f86785fe68494dc",
  "parent_span_id": "59c573cb7c2858fb",
  "name": "printf HTTP/1.1 418 I'm a teapot",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759628460789061632,
  "time_end": 1759628460807193088,
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
    "telemetry.sdk.version": "5.28.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/2ceef434-b1b5-4f4d-9032-bdf6492f11f8/resourceGroups/azure-northcentralus-general-2ceef434-b1b5-4f4d-9032-bdf6492f11f8/providers/Microsoft.Compute/virtualMachines/fQJov3o2fYQaiS",
    "host.id": "733fdcfb-83a3-4e04-903a-820df7954fb2",
    "host.name": "fQJov3o2fYQaiS",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 4704,
    "process.parent_pid": 4701,
    "process.executable.name": "dash",
    "process.executable.path": "/usr/bin/dash",
    "process.command_line": "ncat -l -c printf \"HTTP/1.1 418 I'm a teapot    \" 12345",
    "process.command": "ncat",
    "process.owner": "runner",
    "process.runtime.name": "dash",
    "process.runtime.description": "Debian Almquist Shell",
    "process.runtime.version": "0.5.12-6ubuntu5",
    "process.runtime.options": "e",
    "service.version": "",
    "service.namespace": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "b6636bfaa2415df2e9416e375b21bdde",
  "span_id": "5dddde5b1bbc8af2",
  "parent_span_id": null,
  "name": "send/receive",
  "kind": "CONSUMER",
  "status": "UNSET",
  "time_start": 1759628460707741440,
  "time_end": 1759628460878495488,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 50646,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 50646
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.28.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/2ceef434-b1b5-4f4d-9032-bdf6492f11f8/resourceGroups/azure-northcentralus-general-2ceef434-b1b5-4f4d-9032-bdf6492f11f8/providers/Microsoft.Compute/virtualMachines/fQJov3o2fYQaiS",
    "host.id": "733fdcfb-83a3-4e04-903a-820df7954fb2",
    "host.name": "fQJov3o2fYQaiS",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 4704,
    "process.parent_pid": 4701,
    "process.executable.name": "dash",
    "process.executable.path": "/usr/bin/dash",
    "process.command_line": "ncat -l -c printf \"HTTP/1.1 418 I'm a teapot    \" 12345",
    "process.command": "ncat",
    "process.owner": "runner",
    "process.runtime.name": "dash",
    "process.runtime.description": "Debian Almquist Shell",
    "process.runtime.version": "0.5.12-6ubuntu5",
    "process.runtime.options": "e",
    "service.version": "",
    "service.namespace": ""
  },
  "links": [
    {
      "trace_id": "8e8ea70720a1be8ed1c286174e8dd70a",
      "span_id": "59c573cb7c2858fb",
      "attributes": {}
    }
  ],
  "events": []
}
```
