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
  "trace_id": "e374321e80825fe91a66dd8b1907d889",
  "span_id": "a008721bf3404f52",
  "parent_span_id": "78fc720d5db3fcbf",
  "name": "GET",
  "kind": "CLIENT",
  "status": "ERROR",
  "time_start": 1787425159571549696,
  "time_end": 1787425160407027200,
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
      "00-e374321e80825fe91a66dd8b1907d889-78fc720d5db3fcbf-03"
    ],
    "http.response.status_code": 418
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.1",
    "service.instance.id": "737d56e1-3b50-43f7-8d06-e86ad1e83bfc",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/5b657522-5fd8-413b-b73f-a58e557af882/resourceGroups/azure-eastus-general-5b657522-5fd8-413b-b73f-a58e557af882/providers/Microsoft.Compute/virtualMachines/wBUKH0S2dTGAsB",
    "host.id": "6ee932f2-688c-4c31-a47f-3709ba0abfc4",
    "host.name": "wBUKH0S2dTGAsB",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3544,
    "process.parent_pid": 2964,
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
  "trace_id": "e374321e80825fe91a66dd8b1907d889",
  "span_id": "cd57ada7a3655289",
  "parent_span_id": "a008721bf3404f52",
  "name": "GET",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1787425160261564928,
  "time_end": 1787425160358548992,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 55024,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 55024,
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
    "telemetry.sdk.version": "5.61.1",
    "service.instance.id": "38bf8b45-ffc0-441e-aac3-df249844b5db",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/5b657522-5fd8-413b-b73f-a58e557af882/resourceGroups/azure-eastus-general-5b657522-5fd8-413b-b73f-a58e557af882/providers/Microsoft.Compute/virtualMachines/wBUKH0S2dTGAsB",
    "host.id": "6ee932f2-688c-4c31-a47f-3709ba0abfc4",
    "host.name": "wBUKH0S2dTGAsB",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4442,
    "process.parent_pid": 4441,
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
      "trace_id": "2663cb99103133c10c332b875d011ef7",
      "span_id": "197c46d6f0ccd0f2",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "e374321e80825fe91a66dd8b1907d889",
  "span_id": "7e88274ef52bd23c",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1787425159514840832,
  "time_end": 1787425160408602112,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.1",
    "service.instance.id": "737d56e1-3b50-43f7-8d06-e86ad1e83bfc",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/5b657522-5fd8-413b-b73f-a58e557af882/resourceGroups/azure-eastus-general-5b657522-5fd8-413b-b73f-a58e557af882/providers/Microsoft.Compute/virtualMachines/wBUKH0S2dTGAsB",
    "host.id": "6ee932f2-688c-4c31-a47f-3709ba0abfc4",
    "host.name": "wBUKH0S2dTGAsB",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3544,
    "process.parent_pid": 2964,
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
  "trace_id": "e374321e80825fe91a66dd8b1907d889",
  "span_id": "78fc720d5db3fcbf",
  "parent_span_id": "7e88274ef52bd23c",
  "name": "curl http://127.0.0.1:12345",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787425159522633984,
  "time_end": 1787425160408399872,
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
    "telemetry.sdk.version": "5.61.1",
    "service.instance.id": "737d56e1-3b50-43f7-8d06-e86ad1e83bfc",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/5b657522-5fd8-413b-b73f-a58e557af882/resourceGroups/azure-eastus-general-5b657522-5fd8-413b-b73f-a58e557af882/providers/Microsoft.Compute/virtualMachines/wBUKH0S2dTGAsB",
    "host.id": "6ee932f2-688c-4c31-a47f-3709ba0abfc4",
    "host.name": "wBUKH0S2dTGAsB",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3544,
    "process.parent_pid": 2964,
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
  "trace_id": "e374321e80825fe91a66dd8b1907d889",
  "span_id": "916b15736baaccb8",
  "parent_span_id": "cd57ada7a3655289",
  "name": "printf HTTP/1.1 418 I'm a teapot",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787425160272289792,
  "time_end": 1787425160281876736,
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
    "telemetry.sdk.version": "5.61.1",
    "service.instance.id": "38bf8b45-ffc0-441e-aac3-df249844b5db",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/5b657522-5fd8-413b-b73f-a58e557af882/resourceGroups/azure-eastus-general-5b657522-5fd8-413b-b73f-a58e557af882/providers/Microsoft.Compute/virtualMachines/wBUKH0S2dTGAsB",
    "host.id": "6ee932f2-688c-4c31-a47f-3709ba0abfc4",
    "host.name": "wBUKH0S2dTGAsB",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4442,
    "process.parent_pid": 4441,
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
  "trace_id": "2663cb99103133c10c332b875d011ef7",
  "span_id": "197c46d6f0ccd0f2",
  "parent_span_id": null,
  "name": "send/receive",
  "kind": "CONSUMER",
  "status": "UNSET",
  "time_start": 1787425160171105024,
  "time_end": 1787425160361020160,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 55024,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 55024
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.1",
    "service.instance.id": "38bf8b45-ffc0-441e-aac3-df249844b5db",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/5b657522-5fd8-413b-b73f-a58e557af882/resourceGroups/azure-eastus-general-5b657522-5fd8-413b-b73f-a58e557af882/providers/Microsoft.Compute/virtualMachines/wBUKH0S2dTGAsB",
    "host.id": "6ee932f2-688c-4c31-a47f-3709ba0abfc4",
    "host.name": "wBUKH0S2dTGAsB",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4442,
    "process.parent_pid": 4441,
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
      "trace_id": "e374321e80825fe91a66dd8b1907d889",
      "span_id": "cd57ada7a3655289",
      "attributes": {}
    }
  ],
  "events": []
}
```
