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
bash -e demo.sh
  printf GET / HTTP/1.1\r\n\r\n
  ncat --no-shutdown 127.0.0.1 12345
    send/receive
      GET
        GET
          printf HTTP/1.1 418 I'm a teapot
```
## Full Trace
```
{
  "trace_id": "cae72fd558bf1198ffb3e697b2be516d",
  "span_id": "c1d8e33ed2e25102",
  "parent_span_id": "684d5aa80fc6c9c9",
  "name": "GET",
  "kind": "CLIENT",
  "status": "ERROR",
  "time_start": 1783555114715322112,
  "time_end": 1783555115593104896,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 12345,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "network.protocol.name": "http",
    "network.protocol.version": "1.1",
    "url.full": "http://127.0.0.1:12345/",
    "url.path": "/",
    "url.scheme": "http",
    "http.request.method": "GET",
    "http.request.body.size": 0,
    "user_agent.original": "netcat",
    "http.response.status_code": 418,
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "9b206908-cf6a-457a-8fff-1a7e7ee00cf2",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3626,
    "process.parent_pid": 2913,
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
  "trace_id": "cae72fd558bf1198ffb3e697b2be516d",
  "span_id": "511feca706b1be54",
  "parent_span_id": "c1d8e33ed2e25102",
  "name": "GET",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1783555115410310912,
  "time_end": 1783555115506454272,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 51694,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 51694,
    "network.protocol.name": "http",
    "network.protocol.version": "1.1",
    "url.full": "http://:12345/",
    "url.path": "/",
    "url.scheme": "http",
    "http.request.method": "GET",
    "http.request.body.size": 0,
    "http.request.header.traceparent": [
      "00-cae72fd558bf1198ffb3e697b2be516d-c1d8e33ed2e25102-03"
    ],
    "http.response.status_code": 418,
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "65787302-35a2-4f78-a6fd-4531745ea190",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/9648c4b9-218e-43f7-b0bd-165c29675343/resourceGroups/azure-eastus-general-9648c4b9-218e-43f7-b0bd-165c29675343/providers/Microsoft.Compute/virtualMachines/4vrOr8dzIib87F",
    "host.id": "1f824821-2415-4509-8790-05cd9a860199",
    "host.name": "4vrOr8dzIib87F",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 4611,
    "process.parent_pid": 4610,
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
      "trace_id": "25f89edb16dd32f3383f98c17989017b",
      "span_id": "a63de5cebeb7a018",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "cae72fd558bf1198ffb3e697b2be516d",
  "span_id": "bea7b53acdb03bf5",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1783555114601721600,
  "time_end": 1783555115598803200,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "9b206908-cf6a-457a-8fff-1a7e7ee00cf2",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3626,
    "process.parent_pid": 2913,
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
  "trace_id": "cae72fd558bf1198ffb3e697b2be516d",
  "span_id": "2a60a4c6bc566b7b",
  "parent_span_id": "bea7b53acdb03bf5",
  "name": "ncat --no-shutdown 127.0.0.1 12345",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783555114613913344,
  "time_end": 1783555115598129408,
  "attributes": {
    "shell.command_line": "ncat --no-shutdown 127.0.0.1 12345",
    "shell.command": "ncat",
    "shell.command.type": "file",
    "shell.command.name": "ncat",
    "subprocess.executable.path": "/usr/bin/ncat",
    "subprocess.executable.name": "ncat",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 4
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "9b206908-cf6a-457a-8fff-1a7e7ee00cf2",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3626,
    "process.parent_pid": 2913,
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
  "trace_id": "cae72fd558bf1198ffb3e697b2be516d",
  "span_id": "c266a98316195d0b",
  "parent_span_id": "bea7b53acdb03bf5",
  "name": "printf GET / HTTP/1.1\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783555114613710592,
  "time_end": 1783555114625844736,
  "attributes": {
    "shell.command_line": "printf GET / HTTP/1.1\\r\\n\\r\\n",
    "shell.command": "printf",
    "shell.command.type": "builtin",
    "shell.command.name": "printf",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 4
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "9b206908-cf6a-457a-8fff-1a7e7ee00cf2",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3626,
    "process.parent_pid": 2913,
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
  "trace_id": "cae72fd558bf1198ffb3e697b2be516d",
  "span_id": "27015b7c17836fef",
  "parent_span_id": "511feca706b1be54",
  "name": "printf HTTP/1.1 418 I'm a teapot",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783555115424628224,
  "time_end": 1783555115433506048,
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
    "service.instance.id": "65787302-35a2-4f78-a6fd-4531745ea190",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/9648c4b9-218e-43f7-b0bd-165c29675343/resourceGroups/azure-eastus-general-9648c4b9-218e-43f7-b0bd-165c29675343/providers/Microsoft.Compute/virtualMachines/4vrOr8dzIib87F",
    "host.id": "1f824821-2415-4509-8790-05cd9a860199",
    "host.name": "4vrOr8dzIib87F",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 4611,
    "process.parent_pid": 4610,
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
  "trace_id": "cae72fd558bf1198ffb3e697b2be516d",
  "span_id": "684d5aa80fc6c9c9",
  "parent_span_id": "2a60a4c6bc566b7b",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1783555114632034048,
  "time_end": 1783555115593670144,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 12345,
    "server.address": "127.0.0.1",
    "server.port": 12345
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "9b206908-cf6a-457a-8fff-1a7e7ee00cf2",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3626,
    "process.parent_pid": 2913,
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
  "trace_id": "25f89edb16dd32f3383f98c17989017b",
  "span_id": "a63de5cebeb7a018",
  "parent_span_id": null,
  "name": "send/receive",
  "kind": "CONSUMER",
  "status": "UNSET",
  "time_start": 1783555115337187584,
  "time_end": 1783555115508811520,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 51694,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 51694
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.1",
    "service.instance.id": "65787302-35a2-4f78-a6fd-4531745ea190",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/9648c4b9-218e-43f7-b0bd-165c29675343/resourceGroups/azure-eastus-general-9648c4b9-218e-43f7-b0bd-165c29675343/providers/Microsoft.Compute/virtualMachines/4vrOr8dzIib87F",
    "host.id": "1f824821-2415-4509-8790-05cd9a860199",
    "host.name": "4vrOr8dzIib87F",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 4611,
    "process.parent_pid": 4610,
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
      "trace_id": "cae72fd558bf1198ffb3e697b2be516d",
      "span_id": "511feca706b1be54",
      "attributes": {}
    }
  ],
  "events": []
}
```
