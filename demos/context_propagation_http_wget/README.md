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
  "trace_id": "ab94f6c0bd89650104464a761be0d6de",
  "span_id": "3d51c88182e5a387",
  "parent_span_id": "5a837d6eb740c41b",
  "name": "GET",
  "kind": "CLIENT",
  "status": "ERROR",
  "time_start": 1754729725807351040,
  "time_end": 1754729726543369984,
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
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3469,
    "process.parent_pid": 2354,
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
  "trace_id": "ab94f6c0bd89650104464a761be0d6de",
  "span_id": "7619e102a1ea8e23",
  "parent_span_id": "3d51c88182e5a387",
  "name": "GET",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1754729726447855360,
  "time_end": 1754729726547645952,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 40720,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 40720,
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
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4456,
    "process.parent_pid": 4452,
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
      "trace_id": "03337e6d3e74cda84c8425eef8796363",
      "span_id": "88018eb247287de9",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "ab94f6c0bd89650104464a761be0d6de",
  "span_id": "da79d36c439cdbb0",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1754729725760771840,
  "time_end": 1754729726568198400,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3469,
    "process.parent_pid": 2354,
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
  "trace_id": "ab94f6c0bd89650104464a761be0d6de",
  "span_id": "09febc0f46efa920",
  "parent_span_id": "7619e102a1ea8e23",
  "name": "printf HTTP/1.1 418 I'm a teapot",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754729726459138816,
  "time_end": 1754729726477787904,
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
    "process.pid": 4456,
    "process.parent_pid": 4452,
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
  "trace_id": "03337e6d3e74cda84c8425eef8796363",
  "span_id": "88018eb247287de9",
  "parent_span_id": null,
  "name": "send/receive",
  "kind": "CONSUMER",
  "status": "UNSET",
  "time_start": 1754729726356411904,
  "time_end": 1754729726549748224,
  "attributes": {
    "network.transport": "TCP",
    "network.peer.address": "127.0.0.1",
    "network.peer.port": 40720,
    "server.address": "127.0.0.1",
    "server.port": 12345,
    "client.address": "127.0.0.1",
    "client.port": 40720
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4456,
    "process.parent_pid": 4452,
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
      "trace_id": "ab94f6c0bd89650104464a761be0d6de",
      "span_id": "7619e102a1ea8e23",
      "attributes": {}
    }
  ],
  "events": []
}
{
  "trace_id": "ab94f6c0bd89650104464a761be0d6de",
  "span_id": "2e80355b999a0351",
  "parent_span_id": "da79d36c439cdbb0",
  "name": "true",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754729726552411648,
  "time_end": 1754729726568051456,
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
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3469,
    "process.parent_pid": 2354,
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
  "trace_id": "ab94f6c0bd89650104464a761be0d6de",
  "span_id": "5a837d6eb740c41b",
  "parent_span_id": "da79d36c439cdbb0",
  "name": "wget http://127.0.0.1:12345",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1754729725772864768,
  "time_end": 1754729726547383808,
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
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3469,
    "process.parent_pid": 2354,
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
