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
  "trace_id": "459ff35be9b12ac61e7956148c19e335",
  "span_id": "d7275b6762e013da",
  "parent_span_id": "75cd7956851d3b84",
  "name": "GET",
  "kind": "CLIENT",
  "status": "ERROR",
  "time_start": 1754846650803675929,
  "time_end": 1754846785145005229,
  "attributes": {
    "thread.name": "main",
    "url.full": "http://example.com",
    "thread.id": 1,
    "server.address": "example.com",
    "error.type": "java.net.ConnectException",
    "http.request.method": "GET",
    "network.protocol.version": "1.1"
  },
  "resource_attributes": {
    "host.arch": "amd64",
    "host.name": "pkrvmsl9tci6h6u",
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
    "process.pid": 4795,
    "process.runtime.description": "Eclipse Adoptium OpenJDK 64-Bit Server VM 17.0.16+8",
    "process.runtime.name": "OpenJDK Runtime Environment",
    "process.runtime.version": "17.0.16+8",
    "service.instance.id": "43deb501-5ea3-4fa4-806a-ba39978abf3e",
    "service.name": "unknown_service:java",
    "telemetry.distro.name": "opentelemetry-java-instrumentation",
    "telemetry.distro.version": "2.18.1",
    "telemetry.sdk.language": "java",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "1.52.0"
  },
  "links": [],
  "events": [
    {
      "name": "exception",
      "time": 1754846785143209685,
      "attributes": {
        "exception.stacktrace": "java.net.ConnectException: Connection timed out\n\tat java.base/sun.nio.ch.Net.connect0(Native Method)\n\tat java.base/sun.nio.ch.Net.connect(Net.java:579)\n\tat java.base/sun.nio.ch.Net.connect(Net.java:568)\n\tat java.base/sun.nio.ch.NioSocketImpl.connect(NioSocketImpl.java:593)\n\tat java.base/java.net.Socket.connect(Socket.java:633)\n\tat java.base/java.net.Socket.connect(Socket.java:583)\n\tat java.base/sun.net.NetworkClient.doConnect(NetworkClient.java:183)\n\tat java.base/sun.net.www.http.HttpClient.openServer(HttpClient.java:533)\n\tat java.base/sun.net.www.http.HttpClient.openServer(HttpClient.java:638)\n\tat java.base/sun.net.www.http.HttpClient.<init>(HttpClient.java:283)\n\tat java.base/sun.net.www.http.HttpClient.New(HttpClient.java:386)\n\tat java.base/sun.net.www.http.HttpClient.New(HttpClient.java:408)\n\tat java.base/sun.net.www.protocol.http.HttpURLConnection.getNewHttpClient(HttpURLConnection.java:1325)\n\tat java.base/sun.net.www.protocol.http.HttpURLConnection.plainConnect0(HttpURLConnection.java:1258)\n\tat java.base/sun.net.www.protocol.http.HttpURLConnection.plainConnect(HttpURLConnection.java:1144)\n\tat java.base/sun.net.www.protocol.http.HttpURLConnection.connect(HttpURLConnection.java:1073)\n\tat java.base/sun.net.www.protocol.http.HttpURLConnection.getInputStream0(HttpURLConnection.java:1703)\n\tat java.base/sun.net.www.protocol.http.HttpURLConnection.getInputStream(HttpURLConnection.java:1627)\n\tat Main.main(Main.java:12)\n",
        "exception.type": "java.net.ConnectException",
        "exception.message": "Connection timed out"
      }
    }
  ]
}
{
  "trace_id": "459ff35be9b12ac61e7956148c19e335",
  "span_id": "1fb774545d2adcca",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1754846646481617920,
  "time_end": 1754846785202398464,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.22.7",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3996,
    "process.parent_pid": 2362,
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
  "trace_id": "459ff35be9b12ac61e7956148c19e335",
  "span_id": "75cd7956851d3b84",
  "parent_span_id": "1fb774545d2adcca",
  "name": "java Main",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754846647552576512,
  "time_end": 1754846785181254656,
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
    "telemetry.sdk.version": "5.22.7",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3996,
    "process.parent_pid": 2362,
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
  "trace_id": "459ff35be9b12ac61e7956148c19e335",
  "span_id": "36296205387e90a8",
  "parent_span_id": "1fb774545d2adcca",
  "name": "javac Main.java",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754846646493749504,
  "time_end": 1754846647548259072,
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
    "telemetry.sdk.version": "5.22.7",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3996,
    "process.parent_pid": 2362,
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
  "trace_id": "459ff35be9b12ac61e7956148c19e335",
  "span_id": "1234800e6756be6e",
  "parent_span_id": "1fb774545d2adcca",
  "name": "rm Main.class",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1754846785185472256,
  "time_end": 1754846785202247168,
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
    "telemetry.sdk.version": "5.22.7",
    "service.name": "unknown_service",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "process.pid": 3996,
    "process.parent_pid": 2362,
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
