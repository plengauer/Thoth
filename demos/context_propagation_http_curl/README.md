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
  "trace_id": "256ad53ef605c83e1c7f5a11ee3fd646",
  "span_id": "b46baa3591dd28dc",
  "parent_span_id": "acd7dbe03183af97",
  "name": "GET",
  "kind": "CLIENT",
  "status": "ERROR",
  "time_start": 1786793425917754880,
  "time_end": 1786793426691387136,
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
      "00-256ad53ef605c83e1c7f5a11ee3fd646-acd7dbe03183af97-03"
    ],
    "http.response.status_code": 418
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "1e6f69f1-84e0-4206-a27d-83456cf081bd",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/aac8431c-26b6-4605-99c4-fd23a0a9443d/resourceGroups/azure-westus2-general-aac8431c-26b6-4605-99c4-fd23a0a9443d/providers/Microsoft.Compute/virtualMachines/AtFo6s9BX9rBud",
    "host.id": "5a9ab662-69ee-48af-bb1d-5e7802a0c82b",
    "host.name": "AtFo6s9BX9rBud",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3394,
    "process.parent_pid": 2790,
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
  "trace_id": "256ad53ef605c83e1c7f5a11ee3fd646",
  "span_id": "2be9c009799782d1",
  "parent_span_id": "b46baa3591dd28dc",
  "name": "GET",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786793426557125632,
  "time_end": 1786793426647412480,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 57312,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 57312,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "37b11ee2-befb-4148-a737-05419f11e93c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/aac8431c-26b6-4605-99c4-fd23a0a9443d/resourceGroups/azure-westus2-general-aac8431c-26b6-4605-99c4-fd23a0a9443d/providers/Microsoft.Compute/virtualMachines/AtFo6s9BX9rBud",
    "host.id": "5a9ab662-69ee-48af-bb1d-5e7802a0c82b",
    "host.name": "AtFo6s9BX9rBud",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4294,
    "process.parent_pid": 4293,
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
      "trace_id": "2a0ed431ab028d2d7a9c4801e53c9f11",
      "span_id": "dbd398d587f3f2a8",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "256ad53ef605c83e1c7f5a11ee3fd646",
  "span_id": "6a015ec0807d71f7",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786793425861692160,
  "time_end": 1786793426692771072,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "1e6f69f1-84e0-4206-a27d-83456cf081bd",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/aac8431c-26b6-4605-99c4-fd23a0a9443d/resourceGroups/azure-westus2-general-aac8431c-26b6-4605-99c4-fd23a0a9443d/providers/Microsoft.Compute/virtualMachines/AtFo6s9BX9rBud",
    "host.id": "5a9ab662-69ee-48af-bb1d-5e7802a0c82b",
    "host.name": "AtFo6s9BX9rBud",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3394,
    "process.parent_pid": 2790,
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
  "trace_id": "256ad53ef605c83e1c7f5a11ee3fd646",
  "span_id": "acd7dbe03183af97",
  "parent_span_id": "6a015ec0807d71f7",
  "name": "curl http://127.0.0.1:12345",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793425868890880,
  "time_end": 1786793426692570368,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "1e6f69f1-84e0-4206-a27d-83456cf081bd",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/aac8431c-26b6-4605-99c4-fd23a0a9443d/resourceGroups/azure-westus2-general-aac8431c-26b6-4605-99c4-fd23a0a9443d/providers/Microsoft.Compute/virtualMachines/AtFo6s9BX9rBud",
    "host.id": "5a9ab662-69ee-48af-bb1d-5e7802a0c82b",
    "host.name": "AtFo6s9BX9rBud",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3394,
    "process.parent_pid": 2790,
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
  "trace_id": "256ad53ef605c83e1c7f5a11ee3fd646",
  "span_id": "ecb70a59a27d96ac",
  "parent_span_id": "2be9c009799782d1",
  "name": "printf HTTP/1.1 418 I'm a teapot",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793426567279872,
  "time_end": 1786793426576486912,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "37b11ee2-befb-4148-a737-05419f11e93c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/aac8431c-26b6-4605-99c4-fd23a0a9443d/resourceGroups/azure-westus2-general-aac8431c-26b6-4605-99c4-fd23a0a9443d/providers/Microsoft.Compute/virtualMachines/AtFo6s9BX9rBud",
    "host.id": "5a9ab662-69ee-48af-bb1d-5e7802a0c82b",
    "host.name": "AtFo6s9BX9rBud",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4294,
    "process.parent_pid": 4293,
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
  "trace_id": "2a0ed431ab028d2d7a9c4801e53c9f11",
  "span_id": "dbd398d587f3f2a8",
  "parent_span_id": null,
  "name": "send/receive",
  "kind": "CONSUMER",
  "status": "UNSET",
  "time_start": 1786793426473013504,
  "time_end": 1786793426649608960,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 57312,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 57312
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "37b11ee2-befb-4148-a737-05419f11e93c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus2",
    "cloud.resource_id": "/subscriptions/aac8431c-26b6-4605-99c4-fd23a0a9443d/resourceGroups/azure-westus2-general-aac8431c-26b6-4605-99c4-fd23a0a9443d/providers/Microsoft.Compute/virtualMachines/AtFo6s9BX9rBud",
    "host.id": "5a9ab662-69ee-48af-bb1d-5e7802a0c82b",
    "host.name": "AtFo6s9BX9rBud",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4294,
    "process.parent_pid": 4293,
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
      "trace_id": "256ad53ef605c83e1c7f5a11ee3fd646",
      "span_id": "2be9c009799782d1",
      "attributes": {}
    }
  ],
  "events": []
}
```
