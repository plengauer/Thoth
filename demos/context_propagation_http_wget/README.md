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
  "trace_id": "49fb1a01ddcce1ce417cba7bf93c4383",
  "span_id": "b4fbc625cefa6623",
  "parent_span_id": "67e6ff2fb4b0f467",
  "name": "GET",
  "kind": "CLIENT",
  "status": "ERROR",
  "time_start": 1754895293750952960,
  "time_end": 1754895294495189760,
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
    "telemetry.sdk.version": "5.22.7",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3524,
    "process.parent_pid": 2397,
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
  "trace_id": "49fb1a01ddcce1ce417cba7bf93c4383",
  "span_id": "ec69d5f070a89fab",
  "parent_span_id": "b4fbc625cefa6623",
  "name": "GET",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1754895294399936000,
  "time_end": 1754895294499158784,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 55696,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 55696,
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
    "telemetry.sdk.version": "5.22.7",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4514,
    "process.parent_pid": 4510,
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
      "trace_id": "f5b672064872d1bba14e8907906ed441",
      "span_id": "6a131b2d681e6b98",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "49fb1a01ddcce1ce417cba7bf93c4383",
  "span_id": "eee6b41b4bb51eae",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1754895293702561024,
  "time_end": 1754895294521147392,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.22.7",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3524,
    "process.parent_pid": 2397,
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
  "trace_id": "49fb1a01ddcce1ce417cba7bf93c4383",
  "span_id": "f1d9fb207303f616",
  "parent_span_id": "ec69d5f070a89fab",
  "name": "printf HTTP/1.1 418 I'm a teapot",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754895294411163136,
  "time_end": 1754895294429844736,
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
    "telemetry.sdk.version": "5.22.7",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4514,
    "process.parent_pid": 4510,
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
  "trace_id": "f5b672064872d1bba14e8907906ed441",
  "span_id": "6a131b2d681e6b98",
  "parent_span_id": null,
  "name": "send/receive",
  "kind": "CONSUMER",
  "status": "UNSET",
  "time_start": 1754895294308057088,
  "time_end": 1754895294501172224,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 55696,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 55696
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.22.7",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4514,
    "process.parent_pid": 4510,
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
      "trace_id": "49fb1a01ddcce1ce417cba7bf93c4383",
      "span_id": "ec69d5f070a89fab",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "49fb1a01ddcce1ce417cba7bf93c4383",
  "span_id": "d6a809267e9041c3",
  "parent_span_id": "eee6b41b4bb51eae",
  "name": "true",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754895294504193536,
  "time_end": 1754895294520934656,
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
    "telemetry.sdk.version": "5.22.7",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3524,
    "process.parent_pid": 2397,
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
  "trace_id": "49fb1a01ddcce1ce417cba7bf93c4383",
  "span_id": "67e6ff2fb4b0f467",
  "parent_span_id": "eee6b41b4bb51eae",
  "name": "wget http://127.0.0.1:12345",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1754895293715426560,
  "time_end": 1754895294499303680,
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
    "telemetry.sdk.version": "5.22.7",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3524,
    "process.parent_pid": 2397,
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
