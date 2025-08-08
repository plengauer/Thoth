# Demo "Deep injection into a Java app"
This script uses a java app and configures opentelemetry to inject into the app and continue tracing.
## Script
```sh
export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE
. otel.sh
javac Main.java
java Main
rm Main.class
```
## Trace Structure Overview
```
bash -e demo.sh
  javac Main.java
  java Main
    GET
  rm Main.class
```
## Full Trace
```
{
  "trace_id": "bd4a16edf93043d3d81d7d195cd2bac0",
  "span_id": "63041f295397cb82",
  "parent_span_id": "a9219e2c8fd8e73f",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1754640394876412410,
  "time_end": 1754640395076515445,
  "attributes": {
    "thread.name": "main",
    "url.full": "http://example.com",
    "thread.id": 1,
    "http.response.status_code": 200,
    "server.address": "example.com",
    "http.request.method": "GET",
    "network.protocol.version": "1.1"
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "pkrvmjbmru5nbw0",
    "os.description": "Linux 6.11.0-1018-azure",
    "os.type": "linux",
    "process.command_args": [
      "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/opentelemetry-javaagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/rootcontextagent.jar",
      "-javaagent:/usr/share/opentelemetry_shell/agent.instrumentation.java/subprocessinjectionagent.jar",
      "Main"
    ],
    "process.executable.path": "/usr/lib/jvm/temurin-17-jdk-amd64/bin/java",
    "process.pid": 4798,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.16+8",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.16+8",
    "service.instance.id": "391bb9ca-2470-4077-abd9-ab8486b85425",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.18.1",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.52.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "bd4a16edf93043d3d81d7d195cd2bac0",
  "span_id": "91dcde9f15e2bf2f",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1754640390670146816,
  "time_end": 1754640395273289216,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.22.6",
    "github.actions.workflow.sha": "455708a5b885527fd05b0fbd8b75f84f7a7141de",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3998,
    "process.parent_pid": 2381,
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
  "trace_id": "bd4a16edf93043d3d81d7d195cd2bac0",
  "span_id": "a9219e2c8fd8e73f",
  "parent_span_id": "91dcde9f15e2bf2f",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754640391679823616,
  "time_end": 1754640395251202816,
  "attributes": {
    "shell.command_line": "java Main",
    "shell.command": "java",
    "shell.command.type": "file",
    "shell.command.name": "java",
    "subprocess.executable.path": "/usr/bin/java",
    "subprocess.executable.name": "java",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 4
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.22.6",
    "github.actions.workflow.sha": "455708a5b885527fd05b0fbd8b75f84f7a7141de",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3998,
    "process.parent_pid": 2381,
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
  "trace_id": "bd4a16edf93043d3d81d7d195cd2bac0",
  "span_id": "0f2d53d3ea954ffc",
  "parent_span_id": "91dcde9f15e2bf2f",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754640390683392768,
  "time_end": 1754640391675404032,
  "attributes": {
    "shell.command_line": "javac Main.java",
    "shell.command": "javac",
    "shell.command.type": "file",
    "shell.command.name": "javac",
    "subprocess.executable.path": "/usr/bin/javac",
    "subprocess.executable.name": "javac",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 3
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.22.6",
    "github.actions.workflow.sha": "455708a5b885527fd05b0fbd8b75f84f7a7141de",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3998,
    "process.parent_pid": 2381,
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
  "trace_id": "bd4a16edf93043d3d81d7d195cd2bac0",
  "span_id": "4637ed7b046c2bec",
  "parent_span_id": "91dcde9f15e2bf2f",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754640395255764736,
  "time_end": 1754640395273157632,
  "attributes": {
    "shell.command_line": "rm Main.class",
    "shell.command": "rm",
    "shell.command.type": "file",
    "shell.command.name": "rm",
    "subprocess.executable.path": "/usr/bin/rm",
    "subprocess.executable.name": "rm",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 5
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.22.6",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.22.6",
    "github.actions.workflow.sha": "455708a5b885527fd05b0fbd8b75f84f7a7141de",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3998,
    "process.parent_pid": 2381,
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
