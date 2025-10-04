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
  "trace_id": "1392b410f26e3d995fe78971c21dca4b",
  "span_id": "6fcd506a9a889e58",
  "parent_span_id": "231c6b28d490a3a7",
  "name": "GET",
  "kind": "CLIENT",
  "status": "ERROR",
  "time_start": 1759515945790904832,
  "time_end": 1759515946636706048,
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
      "00-1392b410f26e3d995fe78971c21dca4b-6fcd506a9a889e58-01"
    ],
    "http.response.status_code": 418
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
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/0659987e-e6fb-47bb-b30d-b23dee528698/resourceGroups/azure-eastus2-general-0659987e-e6fb-47bb-b30d-b23dee528698/providers/Microsoft.Compute/virtualMachines/myqczkFxV91qQa",
    "host.id": "7e125e8a-edf0-4b8e-be78-903fac1296ac",
    "host.name": "myqczkFxV91qQa",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3552,
    "process.parent_pid": 2427,
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
  "trace_id": "1392b410f26e3d995fe78971c21dca4b",
  "span_id": "63a2d264656b559c",
  "parent_span_id": "6fcd506a9a889e58",
  "name": "GET",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1759515946495260160,
  "time_end": 1759515946594335232,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 45172,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 45172,
    "network.protocol.name": "http",
    "network.protocol.version": "1.1",
    "url.full": "http://:12345/",
    "url.path": "/",
    "url.scheme": "http",
    "http.request.method": "GET",
    "http.request.body.size": 0,
    "http.request.header.host": [
      "127.0.0.1:12345"
    ],
    "http.request.header.user-agent": [
      "curl/8.5.0"
    ],
    "http.response.status_code": 418,
    "http.response.body.size": 0
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
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/0659987e-e6fb-47bb-b30d-b23dee528698/resourceGroups/azure-eastus2-general-0659987e-e6fb-47bb-b30d-b23dee528698/providers/Microsoft.Compute/virtualMachines/myqczkFxV91qQa",
    "host.id": "7e125e8a-edf0-4b8e-be78-903fac1296ac",
    "host.name": "myqczkFxV91qQa",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 4587,
    "process.parent_pid": 4584,
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
      "trace_id": "a17d6db3892a5e3ad815f42068c9491c",
      "span_id": "8245d1391015946e",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "1392b410f26e3d995fe78971c21dca4b",
  "span_id": "6873b7d3bbf44eb5",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1759515945701877504,
  "time_end": 1759515946640245248,
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
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/0659987e-e6fb-47bb-b30d-b23dee528698/resourceGroups/azure-eastus2-general-0659987e-e6fb-47bb-b30d-b23dee528698/providers/Microsoft.Compute/virtualMachines/myqczkFxV91qQa",
    "host.id": "7e125e8a-edf0-4b8e-be78-903fac1296ac",
    "host.name": "myqczkFxV91qQa",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3552,
    "process.parent_pid": 2427,
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
  "trace_id": "1392b410f26e3d995fe78971c21dca4b",
  "span_id": "231c6b28d490a3a7",
  "parent_span_id": "6873b7d3bbf44eb5",
  "name": "curl http://127.0.0.1:12345",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759515945714308352,
  "time_end": 1759515946640096768,
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
    "telemetry.sdk.version": "5.28.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/0659987e-e6fb-47bb-b30d-b23dee528698/resourceGroups/azure-eastus2-general-0659987e-e6fb-47bb-b30d-b23dee528698/providers/Microsoft.Compute/virtualMachines/myqczkFxV91qQa",
    "host.id": "7e125e8a-edf0-4b8e-be78-903fac1296ac",
    "host.name": "myqczkFxV91qQa",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3552,
    "process.parent_pid": 2427,
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
  "trace_id": "1392b410f26e3d995fe78971c21dca4b",
  "span_id": "28dc7c5b2d12c8f8",
  "parent_span_id": "63a2d264656b559c",
  "name": "printf HTTP/1.1 418 I'm a teapot",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759515946506830336,
  "time_end": 1759515946525151488,
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
    "telemetry.sdk.version": "5.28.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/0659987e-e6fb-47bb-b30d-b23dee528698/resourceGroups/azure-eastus2-general-0659987e-e6fb-47bb-b30d-b23dee528698/providers/Microsoft.Compute/virtualMachines/myqczkFxV91qQa",
    "host.id": "7e125e8a-edf0-4b8e-be78-903fac1296ac",
    "host.name": "myqczkFxV91qQa",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 4587,
    "process.parent_pid": 4584,
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
  "trace_id": "a17d6db3892a5e3ad815f42068c9491c",
  "span_id": "8245d1391015946e",
  "parent_span_id": null,
  "name": "send/receive",
  "kind": "CONSUMER",
  "status": "UNSET",
  "time_start": 1759515946417254912,
  "time_end": 1759515946596509184,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 45172,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 45172
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
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/0659987e-e6fb-47bb-b30d-b23dee528698/resourceGroups/azure-eastus2-general-0659987e-e6fb-47bb-b30d-b23dee528698/providers/Microsoft.Compute/virtualMachines/myqczkFxV91qQa",
    "host.id": "7e125e8a-edf0-4b8e-be78-903fac1296ac",
    "host.name": "myqczkFxV91qQa",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 4587,
    "process.parent_pid": 4584,
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
      "trace_id": "1392b410f26e3d995fe78971c21dca4b",
      "span_id": "63a2d264656b559c",
      "attributes": {}
    }
  ],
  "events": []
}
```
