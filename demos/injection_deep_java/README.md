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
  "trace_id": "76b525963bfa66315ccc6b8592ed7070",
  "span_id": "b42adcacd1fdfbe5",
  "parent_span_id": "b7c7aadab6c9425b",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1755632829404058369,
  "time_end": 1755632829598095830,
  "attributes": {
    "thread.id": 1,
    "thread.name": "main",
    "http.response.status_code": 200,
    "url.full": "http://example.com",
    "network.protocol.version": "1.1",
    "http.request.method": "GET",
    "server.address": "example.com"
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "pkrvmubgrv54qmi",
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
    "process.pid": 4822,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.16+8",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.16+8",
    "service.instance.id": "bca4b9e9-1c28-45fd-b6da-43c1a2a80939",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.19.0",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.53.0"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "76b525963bfa66315ccc6b8592ed7070",
  "span_id": "3bfdfe97ef805164",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1755632826077879808,
  "time_end": 1755632829769942016,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.24.2",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4022,
    "process.parent_pid": 2404,
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
  "trace_id": "76b525963bfa66315ccc6b8592ed7070",
  "span_id": "b7c7aadab6c9425b",
  "parent_span_id": "3bfdfe97ef805164",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1755632826670863360,
  "time_end": 1755632829747793152,
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
    "telemetry.sdk.version": "5.24.2",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4022,
    "process.parent_pid": 2404,
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
  "trace_id": "76b525963bfa66315ccc6b8592ed7070",
  "span_id": "d6f2f6da05a744e4",
  "parent_span_id": "3bfdfe97ef805164",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1755632826090169344,
  "time_end": 1755632826666405376,
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
    "telemetry.sdk.version": "5.24.2",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4022,
    "process.parent_pid": 2404,
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
  "trace_id": "76b525963bfa66315ccc6b8592ed7070",
  "span_id": "af2f8e9bd0eaa94c",
  "parent_span_id": "3bfdfe97ef805164",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1755632829752185856,
  "time_end": 1755632829769763328,
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
    "telemetry.sdk.version": "5.24.2",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 4022,
    "process.parent_pid": 2404,
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
