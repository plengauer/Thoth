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
  "trace_id": "a4870f5d425334306242dbf5607b6df8",
  "span_id": "69970998beae89f3",
  "parent_span_id": "526c7a8a61c06106",
  "name": "GET",
  "kind": "CLIENT",
  "status": "ERROR",
  "time_start": 1759628351139332096,
  "time_end": 1759628351966627072,
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
      "00-a4870f5d425334306242dbf5607b6df8-69970998beae89f3-01"
    ],
    "http.response.status_code": 418
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
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/bbb33765-98d9-4a5c-b07b-2cec4c995d31/resourceGroups/azure-westus-general-bbb33765-98d9-4a5c-b07b-2cec4c995d31/providers/Microsoft.Compute/virtualMachines/qVxFLZakI6mj9f",
    "host.id": "635b6b54-ce18-4c11-a310-327338dfd6a6",
    "host.name": "qVxFLZakI6mj9f",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3619,
    "process.parent_pid": 2422,
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
  "trace_id": "a4870f5d425334306242dbf5607b6df8",
  "span_id": "0e46c5cb79f233e9",
  "parent_span_id": "69970998beae89f3",
  "name": "GET",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1759628351827647232,
  "time_end": 1759628351924745216,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 49054,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 49054,
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
    "telemetry.sdk.version": "5.28.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/bbb33765-98d9-4a5c-b07b-2cec4c995d31/resourceGroups/azure-westus-general-bbb33765-98d9-4a5c-b07b-2cec4c995d31/providers/Microsoft.Compute/virtualMachines/qVxFLZakI6mj9f",
    "host.id": "635b6b54-ce18-4c11-a310-327338dfd6a6",
    "host.name": "qVxFLZakI6mj9f",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 4655,
    "process.parent_pid": 4653,
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
      "trace_id": "95e2cdc8f2af30a0ea76ddac287c9fb2",
      "span_id": "aa3815d6eefbfc82",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "a4870f5d425334306242dbf5607b6df8",
  "span_id": "56a73149fb35b252",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1759628351085602816,
  "time_end": 1759628351970226944,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.28.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/bbb33765-98d9-4a5c-b07b-2cec4c995d31/resourceGroups/azure-westus-general-bbb33765-98d9-4a5c-b07b-2cec4c995d31/providers/Microsoft.Compute/virtualMachines/qVxFLZakI6mj9f",
    "host.id": "635b6b54-ce18-4c11-a310-327338dfd6a6",
    "host.name": "qVxFLZakI6mj9f",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3619,
    "process.parent_pid": 2422,
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
  "trace_id": "a4870f5d425334306242dbf5607b6df8",
  "span_id": "526c7a8a61c06106",
  "parent_span_id": "56a73149fb35b252",
  "name": "curl http://127.0.0.1:12345",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759628351097751296,
  "time_end": 1759628351970051840,
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
    "telemetry.sdk.version": "5.28.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/bbb33765-98d9-4a5c-b07b-2cec4c995d31/resourceGroups/azure-westus-general-bbb33765-98d9-4a5c-b07b-2cec4c995d31/providers/Microsoft.Compute/virtualMachines/qVxFLZakI6mj9f",
    "host.id": "635b6b54-ce18-4c11-a310-327338dfd6a6",
    "host.name": "qVxFLZakI6mj9f",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 3619,
    "process.parent_pid": 2422,
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
  "trace_id": "a4870f5d425334306242dbf5607b6df8",
  "span_id": "2308b32e3ed8fb71",
  "parent_span_id": "0e46c5cb79f233e9",
  "name": "printf HTTP/1.1 418 I'm a teapot",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1759628351838659840,
  "time_end": 1759628351857134080,
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
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/bbb33765-98d9-4a5c-b07b-2cec4c995d31/resourceGroups/azure-westus-general-bbb33765-98d9-4a5c-b07b-2cec4c995d31/providers/Microsoft.Compute/virtualMachines/qVxFLZakI6mj9f",
    "host.id": "635b6b54-ce18-4c11-a310-327338dfd6a6",
    "host.name": "qVxFLZakI6mj9f",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 4655,
    "process.parent_pid": 4653,
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
  "trace_id": "95e2cdc8f2af30a0ea76ddac287c9fb2",
  "span_id": "aa3815d6eefbfc82",
  "parent_span_id": null,
  "name": "send/receive",
  "kind": "CONSUMER",
  "status": "UNSET",
  "time_start": 1759628351749478144,
  "time_end": 1759628351926841088,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 49054,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 49054
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
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/bbb33765-98d9-4a5c-b07b-2cec4c995d31/resourceGroups/azure-westus-general-bbb33765-98d9-4a5c-b07b-2cec4c995d31/providers/Microsoft.Compute/virtualMachines/qVxFLZakI6mj9f",
    "host.id": "635b6b54-ce18-4c11-a310-327338dfd6a6",
    "host.name": "qVxFLZakI6mj9f",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "",
    "process.pid": 4655,
    "process.parent_pid": 4653,
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
      "trace_id": "a4870f5d425334306242dbf5607b6df8",
      "span_id": "0e46c5cb79f233e9",
      "attributes": {}
    }
  ],
  "events": []
}
```
