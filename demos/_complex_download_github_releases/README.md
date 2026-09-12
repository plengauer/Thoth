# Demo "Download GitHub releases"
This script takes a github repository (hard-coded for demo purposes), and downloads the last 3 GitHub releases of version 1.x. It showcases context propgation (via netcat, curl, and wget) and auto-injection into inner commands (via xargs and parallel). Netcat is used for an initial head request to configure pagination, curl to make the inidivdual API requests, and wget for the actual downloads.
## Script
```bash
. otel.sh
repository=plengauer/Thoth
per_page=100
host=api.github.com
path="/repos/$repository/releases?per_page=$per_page"
url=https://"$host""$path"
printf "HEAD $path HTTP/1.1\r\nConnection: close\r\nUser-Agent: ncat\r\nHost: $host\r\n\r\n" | ncat --ssl -i 3 --no-shutdown "$host" 443 | tr '[:upper:]' '[:lower:]' |
  grep '^link: ' | cut -d ' ' -f 2- | tr -d ' <>' | tr ',' '\n' |
  grep 'rel="last"' | cut -d ';' -f1 | cut -d '?' -f 2- | tr '&' '\n' |
  grep '^page=' | cut -d = -f 2 |
  xargs seq 1 | xargs -I '{}' curl --no-progress-meter --fail --retry 16 --retry-all-errors "$url"\&page={} |
  jq '.[].assets[].browser_download_url' -r | grep '.deb$' | grep '_1.' | head --lines=3 |
  xargs wget
```
## Trace Structure Overview
```bash
bash -e demo.sh
  printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\r\nConnection: close\r\nUser-Agent: ncat\r\nHost: api.github.com\r\n\r\n
  ncat --ssl -i 3 --no-shutdown api.github.com 443
    send/receive
      HEAD
  tr [:upper:] [:lower:]
  grep ^link:
  cut -d   -f 2-
  tr -d  <>
  tr , \n
  grep rel="last"
  cut -d ; -f1
  cut -d ? -f 2-
  tr & \n
  grep ^page=
  cut -d = -f 2
  xargs seq 1
    seq 1 4
  xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}
    curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1
      GET
    curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2
      GET
    curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3
      GET
    curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4
      GET
  head --lines=3
  jq .[].assets[].browser_download_url -r
  head --lines=3
  grep .deb$
  grep _1.
  xargs wget
    wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb
      GET
      GET
      GET
      GET
      GET
      GET
```
## Full Trace
```json
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "bf87b6e7bc535135",
  "parent_span_id": "94d371c5960907b3",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789141138595523072,
  "time_end": 1789141139319284992,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.114.5",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443,
    "url.full": "https://api.github.com:443/repos/plengauer/Thoth/releases?per_page=100&page=1",
    "url.path": "/repos/plengauer/Thoth/releases",
    "url.query": "per_page=100&page=1",
    "url.scheme": "https",
    "http.request.method": "GET",
    "http.request.header.host": [
      "api.github.com"
    ],
    "user_agent.original": "curl/8.5.0",
    "http.request.header.user-agent": [
      "curl/8.5.0"
    ],
    "http.request.header.accept": [
      "*/*"
    ],
    "http.request.header.traceparent": [
      "00-50b40d792b2160881fa7ed352406e035-94d371c5960907b3-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 11 Sep 2026 15:38:59 GMT"
    ],
    "http.response.header.content-type": [
      "application/json; charset=utf-8"
    ],
    "http.response.header.cache-control": [
      "public, max-age=60, s-maxage=60"
    ],
    "http.response.header.vary": [
      "Accept,Accept-Encoding, Accept, X-Requested-With"
    ],
    "http.response.header.etag": [
      "W/\"46d781726ddf241bf193df57822a80d19a21d94fc26905c05ef576f7b80bfd8a\""
    ],
    "http.response.header.x-github-media-type": [
      "github.v3; format=json"
    ],
    "http.response.header.link": [
      "<https://api.github.com/repositories/692042935/releases?per_page=100&page=2>; rel=\"next\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=4>; rel=\"last\""
    ],
    "http.response.header.x-github-api-version-selected": [
      "2022-11-28"
    ],
    "http.response.header.access-control-expose-headers": [
      "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset, Warning"
    ],
    "http.response.header.access-control-allow-origin": [
      "*"
    ],
    "http.response.header.strict-transport-security": [
      "max-age=31536000; includeSubdomains; preload"
    ],
    "http.response.header.x-frame-options": [
      "deny"
    ],
    "http.response.header.x-content-type-options": [
      "nosniff"
    ],
    "http.response.header.x-xss-protection": [
      "0"
    ],
    "http.response.header.referrer-policy": [
      "origin-when-cross-origin, strict-origin-when-cross-origin"
    ],
    "http.response.header.content-security-policy": [
      "default-src 'none'"
    ],
    "http.response.header.server": [
      "github.com"
    ],
    "http.response.header.accept-ranges": [
      "bytes"
    ],
    "http.response.header.x-ratelimit-limit": [
      "60"
    ],
    "http.response.header.x-ratelimit-remaining": [
      "58"
    ],
    "http.response.header.x-ratelimit-used": [
      "2"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1789144733"
    ],
    "http.response.header.x-github-request-id": [
      "2C61:C2390:22D0611:71B4413:6AA42092"
    ],
    "http.response.header.x-github-edge-region": [
      "sea"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "9df43e80-ef9e-4d1b-9ea2-6b81f00a6415",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5261,
    "process.parent_pid": 3963,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "ac04a4ccb083f6e8",
  "parent_span_id": "f8ae9210d46a27cf",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274390394159104,
  "time_end": 1788274390400819712,
  "attributes": {
    "shell.command_line": "seq 1 4",
    "shell.command": "seq",
    "shell.command.type": "file",
    "shell.command.name": "seq",
    "subprocess.executable.path": "/usr/bin/seq",
    "subprocess.executable.name": "seq",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 506,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "1898f2cd-1b9e-4ff2-a5cd-0cabdbca21f3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4721,
    "process.parent_pid": 4018,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs seq 1",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "7ff2b4558c2aa8aa",
  "parent_span_id": "0afb0434099fce23",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789141139600921600,
  "time_end": 1789141140351961856,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.114.5",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443,
    "url.full": "https://api.github.com:443/repos/plengauer/Thoth/releases?per_page=100&page=3",
    "url.path": "/repos/plengauer/Thoth/releases",
    "url.query": "per_page=100&page=3",
    "url.scheme": "https",
    "http.request.method": "GET",
    "http.request.header.host": [
      "api.github.com"
    ],
    "user_agent.original": "curl/8.5.0",
    "http.request.header.user-agent": [
      "curl/8.5.0"
    ],
    "http.request.header.accept": [
      "*/*"
    ],
    "http.request.header.traceparent": [
      "00-50b40d792b2160881fa7ed352406e035-0afb0434099fce23-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 11 Sep 2026 15:39:00 GMT"
    ],
    "http.response.header.content-type": [
      "application/json; charset=utf-8"
    ],
    "http.response.header.cache-control": [
      "public, max-age=60, s-maxage=60"
    ],
    "http.response.header.vary": [
      "Accept,Accept-Encoding, Accept, X-Requested-With"
    ],
    "http.response.header.etag": [
      "W/\"95f04fb140ff452e1df7927df4ec5fc686c818d929c505a82de80f35a2a67fe7\""
    ],
    "http.response.header.x-github-media-type": [
      "github.v3; format=json"
    ],
    "http.response.header.link": [
      "<https://api.github.com/repositories/692042935/releases?per_page=100&page=2>; rel=\"prev\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=4>; rel=\"next\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=4>; rel=\"last\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=1>; rel=\"first\""
    ],
    "http.response.header.x-github-api-version-selected": [
      "2022-11-28"
    ],
    "http.response.header.access-control-expose-headers": [
      "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset, Warning"
    ],
    "http.response.header.access-control-allow-origin": [
      "*"
    ],
    "http.response.header.strict-transport-security": [
      "max-age=31536000; includeSubdomains; preload"
    ],
    "http.response.header.x-frame-options": [
      "deny"
    ],
    "http.response.header.x-content-type-options": [
      "nosniff"
    ],
    "http.response.header.x-xss-protection": [
      "0"
    ],
    "http.response.header.referrer-policy": [
      "origin-when-cross-origin, strict-origin-when-cross-origin"
    ],
    "http.response.header.content-security-policy": [
      "default-src 'none'"
    ],
    "http.response.header.server": [
      "github.com"
    ],
    "http.response.header.accept-ranges": [
      "bytes"
    ],
    "http.response.header.x-ratelimit-limit": [
      "60"
    ],
    "http.response.header.x-ratelimit-remaining": [
      "57"
    ],
    "http.response.header.x-ratelimit-used": [
      "3"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1789144733"
    ],
    "http.response.header.x-github-request-id": [
      "2C62:E7010:229BAC0:711EA55:6AA42093"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3a45e74b-acd8-4d4b-8cb9-734ea38d1394",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 6804,
    "process.parent_pid": 3963,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "b3fd0431cece15b8",
  "parent_span_id": "594369784d111d13",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789141140662060288,
  "time_end": 1789141141322442496,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.114.5",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443,
    "url.full": "https://api.github.com:443/repos/plengauer/Thoth/releases?per_page=100&page=3",
    "url.path": "/repos/plengauer/Thoth/releases",
    "url.query": "per_page=100&page=3",
    "url.scheme": "https",
    "http.request.method": "GET",
    "http.request.header.host": [
      "api.github.com"
    ],
    "user_agent.original": "curl/8.5.0",
    "http.request.header.user-agent": [
      "curl/8.5.0"
    ],
    "http.request.header.accept": [
      "*/*"
    ],
    "http.request.header.traceparent": [
      "00-50b40d792b2160881fa7ed352406e035-594369784d111d13-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 11 Sep 2026 15:39:01 GMT"
    ],
    "http.response.header.content-type": [
      "application/json; charset=utf-8"
    ],
    "http.response.header.cache-control": [
      "public, max-age=60, s-maxage=60"
    ],
    "http.response.header.vary": [
      "Accept,Accept-Encoding, Accept, X-Requested-With"
    ],
    "http.response.header.etag": [
      "W/\"ce0cf560a9662bc752fa377f52f1197c590830c32d46001732c60ad626094517\""
    ],
    "http.response.header.x-github-media-type": [
      "github.v3; format=json"
    ],
    "http.response.header.link": [
      "<https://api.github.com/repositories/692042935/releases?per_page=100&page=2>; rel=\"prev\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=4>; rel=\"next\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=4>; rel=\"last\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=1>; rel=\"first\""
    ],
    "http.response.header.x-github-api-version-selected": [
      "2022-11-28"
    ],
    "http.response.header.access-control-expose-headers": [
      "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset, Warning"
    ],
    "http.response.header.access-control-allow-origin": [
      "*"
    ],
    "http.response.header.strict-transport-security": [
      "max-age=31536000; includeSubdomains; preload"
    ],
    "http.response.header.x-frame-options": [
      "deny"
    ],
    "http.response.header.x-content-type-options": [
      "nosniff"
    ],
    "http.response.header.x-xss-protection": [
      "0"
    ],
    "http.response.header.referrer-policy": [
      "origin-when-cross-origin, strict-origin-when-cross-origin"
    ],
    "http.response.header.content-security-policy": [
      "default-src 'none'"
    ],
    "http.response.header.server": [
      "github.com"
    ],
    "http.response.header.accept-ranges": [
      "bytes"
    ],
    "http.response.header.x-ratelimit-limit": [
      "60"
    ],
    "http.response.header.x-ratelimit-remaining": [
      "56"
    ],
    "http.response.header.x-ratelimit-used": [
      "4"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1789144733"
    ],
    "http.response.header.x-github-request-id": [
      "2C63:185261:238EF3A:73C11C0:6AA42094"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "8b622c22-f4cb-4855-ae6c-99894cee288f",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7774,
    "process.parent_pid": 3963,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "81dd67547bd41448",
  "parent_span_id": "04df69f76f98aebc",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789141141612244480,
  "time_end": 1789141142252402432,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.114.5",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443,
    "url.full": "https://api.github.com:443/repos/plengauer/Thoth/releases?per_page=100&page=4",
    "url.path": "/repos/plengauer/Thoth/releases",
    "url.query": "per_page=100&page=4",
    "url.scheme": "https",
    "http.request.method": "GET",
    "http.request.header.host": [
      "api.github.com"
    ],
    "user_agent.original": "curl/8.5.0",
    "http.request.header.user-agent": [
      "curl/8.5.0"
    ],
    "http.request.header.accept": [
      "*/*"
    ],
    "http.request.header.traceparent": [
      "00-50b40d792b2160881fa7ed352406e035-04df69f76f98aebc-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 11 Sep 2026 15:39:01 GMT"
    ],
    "http.response.header.content-type": [
      "application/json; charset=utf-8"
    ],
    "http.response.header.cache-control": [
      "public, max-age=60, s-maxage=60"
    ],
    "http.response.header.vary": [
      "Accept,Accept-Encoding, Accept, X-Requested-With"
    ],
    "http.response.header.etag": [
      "W/\"e06743255211c7b6614555717920ac18efdc55271a62f7074e40591cc16fc28c\""
    ],
    "http.response.header.x-github-media-type": [
      "github.v3; format=json"
    ],
    "http.response.header.link": [
      "<https://api.github.com/repositories/692042935/releases?per_page=100&page=3>; rel=\"prev\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=1>; rel=\"first\""
    ],
    "http.response.header.x-github-api-version-selected": [
      "2022-11-28"
    ],
    "http.response.header.access-control-expose-headers": [
      "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset, Warning"
    ],
    "http.response.header.access-control-allow-origin": [
      "*"
    ],
    "http.response.header.strict-transport-security": [
      "max-age=31536000; includeSubdomains; preload"
    ],
    "http.response.header.x-frame-options": [
      "deny"
    ],
    "http.response.header.x-content-type-options": [
      "nosniff"
    ],
    "http.response.header.x-xss-protection": [
      "0"
    ],
    "http.response.header.referrer-policy": [
      "origin-when-cross-origin, strict-origin-when-cross-origin"
    ],
    "http.response.header.content-security-policy": [
      "default-src 'none'"
    ],
    "http.response.header.server": [
      "github.com"
    ],
    "http.response.header.accept-ranges": [
      "bytes"
    ],
    "http.response.header.x-ratelimit-limit": [
      "60"
    ],
    "http.response.header.x-ratelimit-remaining": [
      "55"
    ],
    "http.response.header.x-ratelimit-used": [
      "5"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1789144733"
    ],
    "http.response.header.x-github-request-id": [
      "2C64:E412E:22F5A99:722DDD7:6AA42095"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "ce77c6c2-4c57-49dc-a7a3-0cc428a7d309",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8803,
    "process.parent_pid": 3963,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "cc06801c7c974e4e",
  "parent_span_id": "47c837c478997f8f",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789141142885305600,
  "time_end": 1789141143929731584,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.113.3",
    "network.peer.port": 443,
    "server.address": "github.com",
    "server.port": 443,
    "url.full": "https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb",
    "url.path": "/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb",
    "url.scheme": "https",
    "user_agent.original": "wget",
    "http.request.method": "GET",
    "http.response.status_code": 302
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "889de66b-b324-401e-97ce-2e8968f9f9df",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9775,
    "process.parent_pid": 3960,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "ed6c75a6b0061b1c",
  "parent_span_id": "47c837c478997f8f",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789141143036622336,
  "time_end": 1789141143997179136,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-11T16%3A32%3A55Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-11T15%3A31%3A58Z&ske=2026-09-11T16%3A32%3A55Z&sks=b&skv=2018-11-09&sig=dB3P1iZNYVVWkbTIFd16xSZrjPCyxgsIfslfGM%2FAIK0%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4OTE0MTQ0MiwibmJmIjoxNzg5MTQxMTQyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.LMNsA4w9zuyvmNhF-yH3rRPu6BsqVTZ5qcp50_VZULQ&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-11T16%3A32%3A55Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-11T15%3A31%3A58Z&ske=2026-09-11T16%3A32%3A55Z&sks=b&skv=2018-11-09&sig=dB3P1iZNYVVWkbTIFd16xSZrjPCyxgsIfslfGM%2FAIK0%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4OTE0MTQ0MiwibmJmIjoxNzg5MTQxMTQyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.LMNsA4w9zuyvmNhF-yH3rRPu6BsqVTZ5qcp50_VZULQ&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.scheme": "https",
    "user_agent.original": "wget",
    "http.request.method": "GET",
    "http.response.status_code": 200,
    "http.response.header.content-type": [
      "application/octet-stream"
    ],
    "http.response.body.size": 7202,
    "http.response.header.content-length": [
      "7202"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "889de66b-b324-401e-97ce-2e8968f9f9df",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9775,
    "process.parent_pid": 3960,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "8d08e76ffa42938b",
  "parent_span_id": "47c837c478997f8f",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789141143960006144,
  "time_end": 1789141144161321216,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.113.3",
    "network.peer.port": 443,
    "server.address": "github.com",
    "server.port": 443,
    "url.full": "https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb",
    "url.path": "/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb",
    "url.scheme": "https",
    "user_agent.original": "wget",
    "http.request.method": "GET",
    "http.response.status_code": 302
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "889de66b-b324-401e-97ce-2e8968f9f9df",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9775,
    "process.parent_pid": 3960,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "9015646b60818b5f",
  "parent_span_id": "47c837c478997f8f",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789141144136699648,
  "time_end": 1789141144250795776,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-11T16%3A28%3A15Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-11T15%3A27%3A45Z&ske=2026-09-11T16%3A28%3A15Z&sks=b&skv=2018-11-09&sig=FHcjGlP%2B%2FEi3%2B4hQbnf%2FHIq7i5K0d0wpZrwc6Ox3Eg8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4OTE0MTQ0NCwibmJmIjoxNzg5MTQxMTQ0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.EEj04TpSmzZtL2NjU2tsj6bdVfQ5xoX2-fDlGn-_GKI&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-11T16%3A28%3A15Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-11T15%3A27%3A45Z&ske=2026-09-11T16%3A28%3A15Z&sks=b&skv=2018-11-09&sig=FHcjGlP%2B%2FEi3%2B4hQbnf%2FHIq7i5K0d0wpZrwc6Ox3Eg8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4OTE0MTQ0NCwibmJmIjoxNzg5MTQxMTQ0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.EEj04TpSmzZtL2NjU2tsj6bdVfQ5xoX2-fDlGn-_GKI&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.scheme": "https",
    "user_agent.original": "wget",
    "http.request.method": "GET",
    "http.response.status_code": 200,
    "http.response.header.content-type": [
      "application/octet-stream"
    ],
    "http.response.body.size": 7184,
    "http.response.header.content-length": [
      "7184"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "889de66b-b324-401e-97ce-2e8968f9f9df",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9775,
    "process.parent_pid": 3960,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "6cb1f6e9258748de",
  "parent_span_id": "47c837c478997f8f",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789141144248969216,
  "time_end": 1789141144461148160,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.113.3",
    "network.peer.port": 443,
    "server.address": "github.com",
    "server.port": 443,
    "url.full": "https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
    "url.path": "/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
    "url.scheme": "https",
    "user_agent.original": "wget",
    "http.request.method": "GET",
    "http.response.status_code": 302
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "889de66b-b324-401e-97ce-2e8968f9f9df",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9775,
    "process.parent_pid": 3960,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "553731eccff1c33b",
  "parent_span_id": "47c837c478997f8f",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789141144435692032,
  "time_end": 1789141144508887552,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-11T16%3A24%3A14Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-11T15%3A24%3A09Z&ske=2026-09-11T16%3A24%3A14Z&sks=b&skv=2018-11-09&sig=StiqU%2BwvywIXoPFDO6Wyr8D%2Fgu%2BsrS%2BY0g5MHQThDS4%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4OTE0MTQ0NCwibmJmIjoxNzg5MTQxMTQ0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.EEj04TpSmzZtL2NjU2tsj6bdVfQ5xoX2-fDlGn-_GKI&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-11T16%3A24%3A14Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-11T15%3A24%3A09Z&ske=2026-09-11T16%3A24%3A14Z&sks=b&skv=2018-11-09&sig=StiqU%2BwvywIXoPFDO6Wyr8D%2Fgu%2BsrS%2BY0g5MHQThDS4%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4OTE0MTQ0NCwibmJmIjoxNzg5MTQxMTQ0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.EEj04TpSmzZtL2NjU2tsj6bdVfQ5xoX2-fDlGn-_GKI&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.scheme": "https",
    "user_agent.original": "wget",
    "http.request.method": "GET",
    "http.response.status_code": 200,
    "http.response.header.content-type": [
      "application/octet-stream"
    ],
    "http.response.body.size": 7176,
    "http.response.header.content-length": [
      "7176"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "889de66b-b324-401e-97ce-2e8968f9f9df",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9775,
    "process.parent_pid": 3960,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "e63dbbe270b096b7",
  "parent_span_id": "f0ffce898a74f0ba",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1789141133799372288,
  "time_end": 1789141137461607424,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443,
    "network.protocol.name": "http",
    "network.protocol.version": "1.1",
    "url.full": "http://api.github.com:443/repos/plengauer/Thoth/releases?per_page=100",
    "url.path": "/repos/plengauer/Thoth/releases",
    "url.query": "per_page=100",
    "url.scheme": "http",
    "http.request.method": "HEAD",
    "http.request.body.size": 0,
    "user_agent.original": "netcat",
    "http.request.header.connection": [
      "close"
    ],
    "http.request.header.user-agent": [
      "ncat"
    ],
    "http.request.header.host": [
      "api.github.com"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 11 Sep 2026 15:38:54 GMT"
    ],
    "http.response.header.content-type": [
      "application/json; charset=utf-8"
    ],
    "http.response.header.cache-control": [
      "public, max-age=60, s-maxage=60"
    ],
    "http.response.header.vary": [
      "Accept,Accept-Encoding, Accept, X-Requested-With"
    ],
    "http.response.header.etag": [
      "W/\"8322013cbec797f02f646f46e7aa30121e85b8845bbdb15438c66bfb0e58434d\""
    ],
    "http.response.header.x-github-media-type": [
      "github.v3; format=json"
    ],
    "http.response.header.link": [
      "<https://api.github.com/repositories/692042935/releases?per_page=100&page=2>; rel=\"next\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=4>; rel=\"last\""
    ],
    "http.response.header.x-github-api-version-selected": [
      "2022-11-28"
    ],
    "http.response.header.access-control-expose-headers": [
      "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset, Warning"
    ],
    "http.response.header.access-control-allow-origin": [
      "*"
    ],
    "http.response.header.strict-transport-security": [
      "max-age=31536000; includeSubdomains; preload"
    ],
    "http.response.header.x-frame-options": [
      "deny"
    ],
    "http.response.header.x-content-type-options": [
      "nosniff"
    ],
    "http.response.header.x-xss-protection": [
      "0"
    ],
    "http.response.header.referrer-policy": [
      "origin-when-cross-origin, strict-origin-when-cross-origin"
    ],
    "http.response.header.content-security-policy": [
      "default-src 'none'"
    ],
    "http.response.header.server": [
      "github.com"
    ],
    "http.response.header.accept-ranges": [
      "bytes"
    ],
    "http.response.header.x-ratelimit-limit": [
      "60"
    ],
    "http.response.header.x-ratelimit-remaining": [
      "59"
    ],
    "http.response.header.x-ratelimit-used": [
      "1"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1789144733"
    ],
    "http.response.header.x-github-request-id": [
      "2C60:48436:2242F92:6F6469C:6AA4208D"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "80d1907ba0482af3",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1789141133576966912,
  "time_end": 1789141144512740352,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "94d371c5960907b3",
  "parent_span_id": "2b964e4b1a5e4428",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141138488929024,
  "time_end": 1789141139353180928,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 506,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "9df43e80-ef9e-4d1b-9ea2-6b81f00a6415",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5261,
    "process.parent_pid": 3963,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "0afb0434099fce23",
  "parent_span_id": "2b964e4b1a5e4428",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141139510933760,
  "time_end": 1789141140386254592,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 506,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3a45e74b-acd8-4d4b-8cb9-734ea38d1394",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 6804,
    "process.parent_pid": 3963,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "594369784d111d13",
  "parent_span_id": "2b964e4b1a5e4428",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141140549432064,
  "time_end": 1789141141356450304,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 506,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "8b622c22-f4cb-4855-ae6c-99894cee288f",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7774,
    "process.parent_pid": 3963,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "04df69f76f98aebc",
  "parent_span_id": "2b964e4b1a5e4428",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141141517146880,
  "time_end": 1789141142286154752,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 506,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "ce77c6c2-4c57-49dc-a7a3-0cc428a7d309",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8803,
    "process.parent_pid": 3963,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "32d658fd61151a7a",
  "parent_span_id": "80d1907ba0482af3",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133595207168,
  "time_end": 1789141137461861632,
  "attributes": {
    "shell.command_line": "cut -d   -f 2-",
    "shell.command": "cut",
    "shell.command.type": "file",
    "shell.command.name": "cut",
    "subprocess.executable.path": "/usr/bin/cut",
    "subprocess.executable.name": "cut",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 8
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "7cef76d27fe940ea",
  "parent_span_id": "80d1907ba0482af3",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133586833664,
  "time_end": 1789141137465412352,
  "attributes": {
    "shell.command_line": "cut -d ; -f1",
    "shell.command": "cut",
    "shell.command.type": "file",
    "shell.command.name": "cut",
    "subprocess.executable.path": "/usr/bin/cut",
    "subprocess.executable.name": "cut",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 9
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "790a33669dc00acf",
  "parent_span_id": "80d1907ba0482af3",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133601804288,
  "time_end": 1789141137469137152,
  "attributes": {
    "shell.command_line": "cut -d = -f 2",
    "shell.command": "cut",
    "shell.command.type": "file",
    "shell.command.name": "cut",
    "subprocess.executable.path": "/usr/bin/cut",
    "subprocess.executable.name": "cut",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 10
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "c2386e6a5eac9f81",
  "parent_span_id": "80d1907ba0482af3",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133606635776,
  "time_end": 1789141137466346752,
  "attributes": {
    "shell.command_line": "cut -d ? -f 2-",
    "shell.command": "cut",
    "shell.command.type": "file",
    "shell.command.name": "cut",
    "subprocess.executable.path": "/usr/bin/cut",
    "subprocess.executable.name": "cut",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 9
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "e90358a6369af17f",
  "parent_span_id": "80d1907ba0482af3",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133605022464,
  "time_end": 1789141142290492160,
  "attributes": {
    "shell.command_line": "grep .deb$",
    "shell.command": "grep",
    "shell.command.type": "file",
    "shell.command.name": "grep",
    "subprocess.executable.path": "/usr/bin/grep",
    "subprocess.executable.name": "grep",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 12
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "e4fc2e19dc161efc",
  "parent_span_id": "80d1907ba0482af3",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133601946624,
  "time_end": 1789141137461700352,
  "attributes": {
    "shell.command_line": "grep ^link:",
    "shell.command": "grep",
    "shell.command.type": "file",
    "shell.command.name": "grep",
    "subprocess.executable.path": "/usr/bin/grep",
    "subprocess.executable.name": "grep",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 8
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "8d7923d4a1232c21",
  "parent_span_id": "80d1907ba0482af3",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133606356224,
  "time_end": 1789141137468119296,
  "attributes": {
    "shell.command_line": "grep ^page=",
    "shell.command": "grep",
    "shell.command.type": "file",
    "shell.command.name": "grep",
    "subprocess.executable.path": "/usr/bin/grep",
    "subprocess.executable.name": "grep",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 10
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "9ee70d87216b2daf",
  "parent_span_id": "80d1907ba0482af3",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1789141133602016000,
  "time_end": 1789141142291572992,
  "attributes": {
    "shell.command_line": "grep _1.",
    "shell.command": "grep",
    "shell.command.type": "file",
    "shell.command.name": "grep",
    "subprocess.executable.path": "/usr/bin/grep",
    "subprocess.executable.name": "grep",
    "shell.command.exit_code": 2,
    "code.filepath": "demo.sh",
    "code.lineno": 12
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "228fbe8e65141da1",
  "parent_span_id": "80d1907ba0482af3",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133606429952,
  "time_end": 1789141137464545536,
  "attributes": {
    "shell.command_line": "grep rel=\"last\"",
    "shell.command": "grep",
    "shell.command.type": "file",
    "shell.command.name": "grep",
    "subprocess.executable.path": "/usr/bin/grep",
    "subprocess.executable.name": "grep",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 9
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "ac71061369d24c23",
  "parent_span_id": "80d1907ba0482af3",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133615411200,
  "time_end": 1789141142289061632,
  "attributes": {
    "shell.command_line": "head --lines=3",
    "shell.command": "head",
    "shell.command.type": "file",
    "shell.command.name": "head",
    "subprocess.executable.path": "/usr/bin/head",
    "subprocess.executable.name": "head",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 12
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "ce8080477b62f696",
  "parent_span_id": "80d1907ba0482af3",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133601424384,
  "time_end": 1789141142289090816,
  "attributes": {
    "shell.command_line": "jq .[].assets[].browser_download_url -r",
    "shell.command": "jq",
    "shell.command.type": "file",
    "shell.command.name": "jq",
    "subprocess.executable.path": "/usr/bin/jq",
    "subprocess.executable.name": "jq",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 12
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "d0ba942dcf350a6b",
  "parent_span_id": "80d1907ba0482af3",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1789141133587269888,
  "time_end": 1789141137461666048,
  "attributes": {
    "shell.command_line": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
    "shell.command": "ncat",
    "shell.command.type": "file",
    "shell.command.name": "ncat",
    "subprocess.executable.path": "/usr/bin/ncat",
    "subprocess.executable.name": "ncat",
    "shell.command.exit_code": 1,
    "code.filepath": "demo.sh",
    "code.lineno": 7
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "500d124478c4aa97",
  "parent_span_id": "80d1907ba0482af3",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133586194432,
  "time_end": 1789141133615527680,
  "attributes": {
    "shell.command_line": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
    "shell.command": "printf",
    "shell.command.type": "builtin",
    "shell.command.name": "printf",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 7
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "f0ffce898a74f0ba",
  "parent_span_id": "d0ba942dcf350a6b",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1789141133621193728,
  "time_end": 1789141137461629184,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "d37179118ca13501",
  "parent_span_id": "bdb907211db46948",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141137976385024,
  "time_end": 1789141137983557888,
  "attributes": {
    "shell.command_line": "seq 1 4",
    "shell.command": "seq",
    "shell.command.type": "file",
    "shell.command.name": "seq",
    "subprocess.executable.path": "/usr/bin/seq",
    "subprocess.executable.name": "seq",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 506,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "4e183691-1f31-4f4d-8d37-476b5fc667fe",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4663,
    "process.parent_pid": 3949,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs seq 1",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "513591f141a46461",
  "parent_span_id": "80d1907ba0482af3",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133601690368,
  "time_end": 1789141137467174400,
  "attributes": {
    "shell.command_line": "tr & \\n",
    "shell.command": "tr",
    "shell.command.type": "file",
    "shell.command.name": "tr",
    "subprocess.executable.path": "/usr/bin/tr",
    "subprocess.executable.name": "tr",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 9
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "5653c8a5b7e8f6f9",
  "parent_span_id": "80d1907ba0482af3",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133608890368,
  "time_end": 1789141137463597056,
  "attributes": {
    "shell.command_line": "tr , \\n",
    "shell.command": "tr",
    "shell.command.type": "file",
    "shell.command.name": "tr",
    "subprocess.executable.path": "/usr/bin/tr",
    "subprocess.executable.name": "tr",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 8
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "33128e7a67baee07",
  "parent_span_id": "80d1907ba0482af3",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133601588992,
  "time_end": 1789141137462653952,
  "attributes": {
    "shell.command_line": "tr -d  <>",
    "shell.command": "tr",
    "shell.command.type": "file",
    "shell.command.name": "tr",
    "subprocess.executable.path": "/usr/bin/tr",
    "subprocess.executable.name": "tr",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 8
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "6343c86f3b8eee69",
  "parent_span_id": "80d1907ba0482af3",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133587412736,
  "time_end": 1789141137461683968,
  "attributes": {
    "shell.command_line": "tr [:upper:] [:lower:]",
    "shell.command": "tr",
    "shell.command.type": "file",
    "shell.command.name": "tr",
    "subprocess.executable.path": "/usr/bin/tr",
    "subprocess.executable.name": "tr",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 7
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "47c837c478997f8f",
  "parent_span_id": "7ab3bd9a28acb787",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141142779328768,
  "time_end": 1789141144509875456,
  "attributes": {
    "shell.command_line": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
    "shell.command": "wget",
    "shell.command.type": "file",
    "shell.command.name": "wget",
    "subprocess.executable.path": "/usr/bin/wget",
    "subprocess.executable.name": "wget",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 506,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "889de66b-b324-401e-97ce-2e8968f9f9df",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9775,
    "process.parent_pid": 3960,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc"
  },
  "links": [],
  "events": []
}
{
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "2b964e4b1a5e4428",
  "parent_span_id": "80d1907ba0482af3",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133606251264,
  "time_end": 1789141142287509248,
  "attributes": {
    "shell.command_line": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
    "shell.command": "xargs",
    "shell.command.type": "file",
    "shell.command.name": "xargs",
    "subprocess.executable.path": "/usr/bin/xargs",
    "subprocess.executable.name": "xargs",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 11
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "bdb907211db46948",
  "parent_span_id": "80d1907ba0482af3",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133601873664,
  "time_end": 1789141137986132992,
  "attributes": {
    "shell.command_line": "xargs seq 1",
    "shell.command": "xargs",
    "shell.command.type": "file",
    "shell.command.name": "xargs",
    "subprocess.executable.path": "/usr/bin/xargs",
    "subprocess.executable.name": "xargs",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 11
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
  "trace_id": "50b40d792b2160881fa7ed352406e035",
  "span_id": "7ab3bd9a28acb787",
  "parent_span_id": "80d1907ba0482af3",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1789141133608758016,
  "time_end": 1789141144511442944,
  "attributes": {
    "shell.command_line": "xargs wget",
    "shell.command": "xargs",
    "shell.command.type": "file",
    "shell.command.name": "xargs",
    "subprocess.executable.path": "/usr/bin/xargs",
    "subprocess.executable.name": "xargs",
    "shell.command.exit_code": 0,
    "code.filepath": "demo.sh",
    "code.lineno": 13
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.0",
    "service.instance.id": "3e7a932c-6247-4681-bfb6-d09ee972e1a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/568248ca-7c30-4686-b991-00f308e5d14f/resourceGroups/azure-centralus-general-568248ca-7c30-4686-b991-00f308e5d14f/providers/Microsoft.Compute/virtualMachines/AW8yZHUWCXjtvI",
    "host.id": "8d343d0d-3da1-4929-a658-5aa832d703e1",
    "host.name": "AW8yZHUWCXjtvI",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2819,
    "process.parent_pid": 2616,
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
```
