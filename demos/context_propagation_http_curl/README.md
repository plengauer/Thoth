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
  "trace_id": "8b8a09698b36ffb9c1ccd4f26266c7a5",
  "span_id": "8a9289142a995a2f",
  "parent_span_id": "2b88f1b13854d819",
  "name": "GET",
  "kind": "CLIENT",
  "status": "ERROR",
  "time_start": 1786264528918703616,
  "time_end": 1786264529702554624,
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
      "00-8b8a09698b36ffb9c1ccd4f26266c7a5-2b88f1b13854d819-03"
    ],
    "http.response.status_code": 418
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "dd329bd1-0251-400c-b4d9-80203996c174",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/e44088f9-06c1-439a-9ca7-8e4fd65adcd7/resourceGroups/azure-westus-general-e44088f9-06c1-439a-9ca7-8e4fd65adcd7/providers/Microsoft.Compute/virtualMachines/5ELoJp3epjGTi6",
    "host.id": "41103507-b19d-4020-b691-266e94d5ef86",
    "host.name": "5ELoJp3epjGTi6",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3454,
    "process.parent_pid": 2872,
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
  "trace_id": "8b8a09698b36ffb9c1ccd4f26266c7a5",
  "span_id": "d00f854ba60795e7",
  "parent_span_id": "8a9289142a995a2f",
  "name": "GET",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786264529570785024,
  "time_end": 1786264529660753920,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 34616,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 34616,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "b57eebeb-9c14-4647-84a0-4ca55d968d80",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/e44088f9-06c1-439a-9ca7-8e4fd65adcd7/resourceGroups/azure-westus-general-e44088f9-06c1-439a-9ca7-8e4fd65adcd7/providers/Microsoft.Compute/virtualMachines/5ELoJp3epjGTi6",
    "host.id": "41103507-b19d-4020-b691-266e94d5ef86",
    "host.name": "5ELoJp3epjGTi6",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 4364,
    "process.parent_pid": 4363,
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
      "trace_id": "7397d84f3f0d2c15201172885a19cfa3",
      "span_id": "d29f88a454ad8092",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "8b8a09698b36ffb9c1ccd4f26266c7a5",
  "span_id": "f0560203f17f30b7",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786264528828153600,
  "time_end": 1786264529705921024,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "dd329bd1-0251-400c-b4d9-80203996c174",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/e44088f9-06c1-439a-9ca7-8e4fd65adcd7/resourceGroups/azure-westus-general-e44088f9-06c1-439a-9ca7-8e4fd65adcd7/providers/Microsoft.Compute/virtualMachines/5ELoJp3epjGTi6",
    "host.id": "41103507-b19d-4020-b691-266e94d5ef86",
    "host.name": "5ELoJp3epjGTi6",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3454,
    "process.parent_pid": 2872,
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
  "trace_id": "8b8a09698b36ffb9c1ccd4f26266c7a5",
  "span_id": "2b88f1b13854d819",
  "parent_span_id": "f0560203f17f30b7",
  "name": "curl http://127.0.0.1:12345",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264528839707392,
  "time_end": 1786264529705760000,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "dd329bd1-0251-400c-b4d9-80203996c174",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/e44088f9-06c1-439a-9ca7-8e4fd65adcd7/resourceGroups/azure-westus-general-e44088f9-06c1-439a-9ca7-8e4fd65adcd7/providers/Microsoft.Compute/virtualMachines/5ELoJp3epjGTi6",
    "host.id": "41103507-b19d-4020-b691-266e94d5ef86",
    "host.name": "5ELoJp3epjGTi6",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3454,
    "process.parent_pid": 2872,
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
  "trace_id": "8b8a09698b36ffb9c1ccd4f26266c7a5",
  "span_id": "f70eb7ed0530e812",
  "parent_span_id": "d00f854ba60795e7",
  "name": "printf HTTP/1.1 418 I'm a teapot",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264529580670464,
  "time_end": 1786264529589629184,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "b57eebeb-9c14-4647-84a0-4ca55d968d80",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/e44088f9-06c1-439a-9ca7-8e4fd65adcd7/resourceGroups/azure-westus-general-e44088f9-06c1-439a-9ca7-8e4fd65adcd7/providers/Microsoft.Compute/virtualMachines/5ELoJp3epjGTi6",
    "host.id": "41103507-b19d-4020-b691-266e94d5ef86",
    "host.name": "5ELoJp3epjGTi6",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 4364,
    "process.parent_pid": 4363,
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
  "trace_id": "7397d84f3f0d2c15201172885a19cfa3",
  "span_id": "d29f88a454ad8092",
  "parent_span_id": null,
  "name": "send/receive",
  "kind": "CONSUMER",
  "status": "UNSET",
  "time_start": 1786264529484928000,
  "time_end": 1786264529663237888,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 34616,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 34616
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "b57eebeb-9c14-4647-84a0-4ca55d968d80",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/e44088f9-06c1-439a-9ca7-8e4fd65adcd7/resourceGroups/azure-westus-general-e44088f9-06c1-439a-9ca7-8e4fd65adcd7/providers/Microsoft.Compute/virtualMachines/5ELoJp3epjGTi6",
    "host.id": "41103507-b19d-4020-b691-266e94d5ef86",
    "host.name": "5ELoJp3epjGTi6",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 4364,
    "process.parent_pid": 4363,
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
      "trace_id": "8b8a09698b36ffb9c1ccd4f26266c7a5",
      "span_id": "d00f854ba60795e7",
      "attributes": {}
    }
  ],
  "events": []
}
```
