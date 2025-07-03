# Demo "Deep injection into a Node.js app"
This script uses a node.js app and configures opentelemetry to inject into the app and continue tracing.
## Script
```sh
export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE
. otel.sh
 node index.js
```
## Trace Structure Overview
```
bash -e demo.sh
  node index.js
    GET
```
## Full Trace
```
{
  "trace_id": "9876368abbe0fb2eabfa35f0d70c1337",
  "span_id": "9e240e8bf8dfc4ce",
  "parent_span_id": "f5cbf15447f0d68c",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1751340273508000000,
  "time_end": 1751340273648214262,
  "attributes": {
    "http.url": "https://example.com/",
    "http.method": "GET",
    "http.target": "/",
    "net.peer.name": "example.com",
    "http.host": "example.com:443",
    "net.peer.ip": "23.192.228.84",
    "net.peer.port": 443,
    "http.response_content_length_uncompressed": 1256,
    "http.status_code": 200,
    "http.status_text": "OK",
    "http.flavor": "1.1",
    "net.transport": "ip_tcp"
  },
  "resource_attributes": {
    "process.pid": 7840,
    "process.executable.name": "node",
    "process.executable.path": "/usr/local/bin/node",
    "process.command_args": [
      "/usr/local/bin/node",
      "--require",
      "/usr/share/opentelemetry_shell/agent.instrumentation.node/20/deep.inject.js",
      "--require",
      "/usr/share/opentelemetry_shell/agent.instrumentation.node/20/deep.instrument.js",
      "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js"
    ],
    "process.runtime.version": "20.19.2",
    "process.runtime.name": "nodejs",
    "process.runtime.description": "Node.js",
    "process.command": "/home/runner/work/Thoth/Thoth/demos/injection_deep_node/index.js",
    "process.owner": "runner",
    "github.workflow": "Refresh Demos",
    "github.run_id": "15988988513",
    "github.run_number": "60",
    "github.actor": "actions-bot-pl",
    "github.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.ref": "refs/tags/v5.21.0",
    "vcs.system": "git",
    "vcs.commit.id": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "vcs.clone.id": "8edcb852-f9af-469f-bee0-7cc9f85dc752",
    "vcs.branch.name": "main",
    "service.name": "unknown_service:node",
    "telemetry.sdk.language": "nodejs",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "2.0.1"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "9876368abbe0fb2eabfa35f0d70c1337",
  "span_id": "77c35110ee3da599",
  "parent_span_id": "",
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1751340269587126016,
  "time_end": 1751340273667190272,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 7081,
    "process.parent_pid": 2157,
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
  "trace_id": "9876368abbe0fb2eabfa35f0d70c1337",
  "span_id": "f5cbf15447f0d68c",
  "parent_span_id": "77c35110ee3da599",
  "name": "node index.js",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340269599580416,
  "time_end": 1751340273667040768,
  "attributes": {
    "shell.command_line": "node index.js",
    "shell.command": "node",
    "shell.command.type": "file",
    "shell.command.name": "node",
    "subprocess.executable.path": "/usr/local/bin/node",
    "subprocess.executable.name": "node",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 3
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 7081,
    "process.parent_pid": 2157,
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
