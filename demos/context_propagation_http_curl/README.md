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
  "trace_id": "7657e775fcbd86255a9e2952dc38ab45",
  "span_id": "7adf5fe614ee46ad",
  "parent_span_id": "2afc2c1d7ac1c47c",
  "name": "GET",
  "kind": "CLIENT",
  "status": "ERROR",
  "time_start": 1754704279830352384,
  "time_end": 1754704280494116096,
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
      "00-7657e775fcbd86255a9e2952dc38ab45-7adf5fe614ee46ad-01"
    ],
    "http.response.status_code": 418
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3468,
    "process.parent_pid": 2360,
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
  "trace_id": "7657e775fcbd86255a9e2952dc38ab45",
  "span_id": "97b4e0b8d7b58940",
  "parent_span_id": "7adf5fe614ee46ad",
  "name": "GET",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1754704280380212480,
  "time_end": 1754704280454812416,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 38016,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 38016,
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
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4429,
    "process.parent_pid": 4426,
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
      "trace_id": "1d2dc958ba593539c952eef9e83bd7c2",
      "span_id": "1208b642a7b4af30",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "7657e775fcbd86255a9e2952dc38ab45",
  "span_id": "80dfa254fad336e2",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1754704279786400512,
  "time_end": 1754704280497030656,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3468,
    "process.parent_pid": 2360,
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
  "trace_id": "7657e775fcbd86255a9e2952dc38ab45",
  "span_id": "2afc2c1d7ac1c47c",
  "parent_span_id": "80dfa254fad336e2",
  "name": "curl http://127.0.0.1:12345",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754704279796046080,
  "time_end": 1754704280496888320,
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
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3468,
    "process.parent_pid": 2360,
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
  "trace_id": "7657e775fcbd86255a9e2952dc38ab45",
  "span_id": "80b4b2b09e1f3a95",
  "parent_span_id": "97b4e0b8d7b58940",
  "name": "printf HTTP/1.1 418 I'm a teapot",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754704280388879104,
  "time_end": 1754704280403031296,
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
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4429,
    "process.parent_pid": 4426,
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
  "trace_id": "1d2dc958ba593539c952eef9e83bd7c2",
  "span_id": "1208b642a7b4af30",
  "parent_span_id": null,
  "name": "send/receive",
  "kind": "CONSUMER",
  "status": "UNSET",
  "time_start": 1754704280320028416,
  "time_end": 1754704280456410368,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 38016,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 38016
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4429,
    "process.parent_pid": 4426,
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
      "trace_id": "7657e775fcbd86255a9e2952dc38ab45",
      "span_id": "97b4e0b8d7b58940",
      "attributes": {}
    }
  ],
  "events": []
}
```
