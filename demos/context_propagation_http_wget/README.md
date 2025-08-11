# Demo "Context Propagation with wget"
This script shows context propagation via HTTP from a client (wget) to a server (ncat).
## Script
```sh
otel4netcat_http ncat -l -c 'printf "HTTP/1.1 418 I'\''m a teapot\r\n\r\n"' 12345 & # fake http server
sleep 5
. otel.sh
wget http://127.0.0.1:12345 || true
```
## Trace Structure Overview
```
send/receive
bash -e demo.sh
  wget http://127.0.0.1:12345
    GET
      GET
        printf HTTP/1.1 418 I'm a teapot
  true
```
## Full Trace
```
{
  "trace_id": "b478c3b7066b6148ec12e7fe9ad21c88",
  "span_id": "53cdcf8e6cc126e0",
  "parent_span_id": "b96f658aa5342725",
  "name": "GET",
  "kind": "CLIENT",
  "status": "ERROR",
  "time_start": 1754949976778805760,
  "time_end": 1754949977525202176,
  "attributes": {
    "network.protocol.name": "http",
    "network.transport": "tcp",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 12345,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "url.full": "http://127.0.0.1:12345/",
    "url.path": "/",
    "url.scheme": "http",
    "user_agent.original": "wget",
    "http.request.method": "GET",
    "http.response.status_code": 418
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.23.0",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3460,
    "process.parent_pid": 2359,
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
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "b478c3b7066b6148ec12e7fe9ad21c88",
  "span_id": "6f508b88def2e19d",
  "parent_span_id": "53cdcf8e6cc126e0",
  "name": "GET",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1754949977429392128,
  "time_end": 1754949977529145344,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 49314,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 49314,
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
      "Wget/1.21.4"
    ],
    "http.response.status_code": 418,
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.23.0",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4448,
    "process.parent_pid": 4444,
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
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [
    {
      "trace_id": "2c2a1286e03a53185bce6ae7df3bc86a",
      "span_id": "ab7c9ce9809011c2",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "b478c3b7066b6148ec12e7fe9ad21c88",
  "span_id": "2885d8dfe550d5e8",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1754949976731760896,
  "time_end": 1754949977551297280,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.23.0",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3460,
    "process.parent_pid": 2359,
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
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "b478c3b7066b6148ec12e7fe9ad21c88",
  "span_id": "991290886837cdd8",
  "parent_span_id": "6f508b88def2e19d",
  "name": "printf HTTP/1.1 418 I'm a teapot",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754949977440919040,
  "time_end": 1754949977459318016,
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
    "telemetry.sdk.version": "5.23.0",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4448,
    "process.parent_pid": 4444,
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
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "2c2a1286e03a53185bce6ae7df3bc86a",
  "span_id": "ab7c9ce9809011c2",
  "parent_span_id": null,
  "name": "send/receive",
  "kind": "CONSUMER",
  "status": "UNSET",
  "time_start": 1754949977336378368,
  "time_end": 1754949977531286272,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 49314,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 49314
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.23.0",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4448,
    "process.parent_pid": 4444,
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
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [
    {
      "trace_id": "b478c3b7066b6148ec12e7fe9ad21c88",
      "span_id": "6f508b88def2e19d",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "b478c3b7066b6148ec12e7fe9ad21c88",
  "span_id": "65f7d69b461dce9b",
  "parent_span_id": "2885d8dfe550d5e8",
  "name": "true",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754949977534673408,
  "time_end": 1754949977551051776,
  "attributes": {
    "shell.command_line": "true",
    "shell.command": "true",
    "shell.command.type": "builtin",
    "shell.command.name": "true",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 4
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.23.0",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3460,
    "process.parent_pid": 2359,
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
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "b478c3b7066b6148ec12e7fe9ad21c88",
  "span_id": "b96f658aa5342725",
  "parent_span_id": "2885d8dfe550d5e8",
  "name": "wget http://127.0.0.1:12345",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1754949976743780096,
  "time_end": 1754949977529474048,
  "attributes": {
    "shell.command_line": "wget http://127.0.0.1:12345",
    "shell.command": "wget",
    "shell.command.type": "file",
    "shell.command.name": "wget",
    "subprocess.executable.path": "/usr/bin/wget",
    "subprocess.executable.name": "wget",
    "shell.command.exit_code": 8,
    "code.filepath": "demo.sh",
    "code.lineno": 4
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.23.0",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3460,
    "process.parent_pid": 2359,
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
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
```
