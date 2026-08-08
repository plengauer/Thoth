# Demo "Context Propagation with curl"
This script shows context propagation via HTTP from a client (curl) to a server (ncat).
## Script
```bash
otel4netcat_http ncat -l -c 'printf "HTTP/1.1 418 I'\''m a teapot\r\n\r\n"' 12345 & # fake http server
sleep 5
. otel.sh
curl http://127.0.0.1:12345
```
## Trace Structure Overview
```bash
send/receive
bash -e demo.sh
  curl http://127.0.0.1:12345
    GET
      GET
        printf HTTP/1.1 418 I'm a teapot
```
## Full Trace
```json
{
  "trace_id": "0a060d4e5203e72b960b1d141f834889",
  "span_id": "fcd4865a59fcf627",
  "parent_span_id": "58207c951d3ea028",
  "name": "GET",
  "kind": "CLIENT",
  "status": "ERROR",
  "time_start": 1786147796381661952,
  "time_end": 1786147797161170432,
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
      "00-0a060d4e5203e72b960b1d141f834889-58207c951d3ea028-03"
    ],
    "http.response.status_code": 418
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "8cd16bde-24b4-4411-84b4-a67dc7cfef96",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/d092a286-2a62-424c-b333-339c167835d4/resourceGroups/azure-westus3-general-d092a286-2a62-424c-b333-339c167835d4/providers/Microsoft.Compute/virtualMachines/q0TvAAxDnICSpi",
    "host.id": "8e2f6b79-754a-4c1a-85b6-3cd5e8154f04",
    "host.name": "q0TvAAxDnICSpi",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3522,
    "process.parent_pid": 2947,
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
  "trace_id": "0a060d4e5203e72b960b1d141f834889",
  "span_id": "4f4917ee67ee7f99",
  "parent_span_id": "fcd4865a59fcf627",
  "name": "GET",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786147797030834432,
  "time_end": 1786147797120913152,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 57392,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 57392,
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
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "e6a439a6-d2eb-4e5c-bc41-a05cbe6d5801",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/d092a286-2a62-424c-b333-339c167835d4/resourceGroups/azure-westus3-general-d092a286-2a62-424c-b333-339c167835d4/providers/Microsoft.Compute/virtualMachines/q0TvAAxDnICSpi",
    "host.id": "8e2f6b79-754a-4c1a-85b6-3cd5e8154f04",
    "host.name": "q0TvAAxDnICSpi",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 4433,
    "process.parent_pid": 4432,
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
      "trace_id": "3bbecbb3c9339d8b2804ec2e52c6b770",
      "span_id": "a2142ecf04eab019",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "0a060d4e5203e72b960b1d141f834889",
  "span_id": "c126475414c49f63",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786147796316202752,
  "time_end": 1786147797164541440,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "8cd16bde-24b4-4411-84b4-a67dc7cfef96",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/d092a286-2a62-424c-b333-339c167835d4/resourceGroups/azure-westus3-general-d092a286-2a62-424c-b333-339c167835d4/providers/Microsoft.Compute/virtualMachines/q0TvAAxDnICSpi",
    "host.id": "8e2f6b79-754a-4c1a-85b6-3cd5e8154f04",
    "host.name": "q0TvAAxDnICSpi",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3522,
    "process.parent_pid": 2947,
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
  "trace_id": "0a060d4e5203e72b960b1d141f834889",
  "span_id": "58207c951d3ea028",
  "parent_span_id": "c126475414c49f63",
  "name": "curl http://127.0.0.1:12345",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786147796327577600,
  "time_end": 1786147797164378624,
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
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "8cd16bde-24b4-4411-84b4-a67dc7cfef96",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/d092a286-2a62-424c-b333-339c167835d4/resourceGroups/azure-westus3-general-d092a286-2a62-424c-b333-339c167835d4/providers/Microsoft.Compute/virtualMachines/q0TvAAxDnICSpi",
    "host.id": "8e2f6b79-754a-4c1a-85b6-3cd5e8154f04",
    "host.name": "q0TvAAxDnICSpi",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3522,
    "process.parent_pid": 2947,
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
  "trace_id": "0a060d4e5203e72b960b1d141f834889",
  "span_id": "a76144865b678001",
  "parent_span_id": "4f4917ee67ee7f99",
  "name": "printf HTTP/1.1 418 I'm a teapot",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786147797040560640,
  "time_end": 1786147797049467136,
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
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "e6a439a6-d2eb-4e5c-bc41-a05cbe6d5801",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/d092a286-2a62-424c-b333-339c167835d4/resourceGroups/azure-westus3-general-d092a286-2a62-424c-b333-339c167835d4/providers/Microsoft.Compute/virtualMachines/q0TvAAxDnICSpi",
    "host.id": "8e2f6b79-754a-4c1a-85b6-3cd5e8154f04",
    "host.name": "q0TvAAxDnICSpi",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 4433,
    "process.parent_pid": 4432,
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
  "trace_id": "3bbecbb3c9339d8b2804ec2e52c6b770",
  "span_id": "a2142ecf04eab019",
  "parent_span_id": null,
  "name": "send/receive",
  "kind": "CONSUMER",
  "status": "UNSET",
  "time_start": 1786147796943464192,
  "time_end": 1786147797123267328,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 57392,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 57392
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "e6a439a6-d2eb-4e5c-bc41-a05cbe6d5801",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/d092a286-2a62-424c-b333-339c167835d4/resourceGroups/azure-westus3-general-d092a286-2a62-424c-b333-339c167835d4/providers/Microsoft.Compute/virtualMachines/q0TvAAxDnICSpi",
    "host.id": "8e2f6b79-754a-4c1a-85b6-3cd5e8154f04",
    "host.name": "q0TvAAxDnICSpi",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 4433,
    "process.parent_pid": 4432,
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
      "trace_id": "0a060d4e5203e72b960b1d141f834889",
      "span_id": "4f4917ee67ee7f99",
      "attributes": {}
    }
  ],
  "events": []
}
```
