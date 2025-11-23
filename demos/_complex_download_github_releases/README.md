# Demo "Download GitHub releases"
This script takes a github repository (hard-coded for demo purposes), and downloads the last 3 GitHub releases of version 1.x. It showcases context propgation (via netcat, curl, and wget) and auto-injection into inner commands (via xargs and parallel). Netcat is used for an initial head request to configure pagination, curl to make the inidivdual API requests, and wget for the actual downloads.
## Script
```sh
. otel.sh
repository=plengauer/Thoth
per_page=100
host=api.github.com
path="/repos/$repository/releases?per_page=$per_page"
url=https://"$host""$path"
printf "HEAD $path HTTP/1.1\r\nConnection: close\r\nUser-Agent: ncat\r\nHost: $host\r\n\r\n" | ncat --ssl -i 3 --no-shutdown "$host" 443 | tr '[:upper:]' '[:lower:]' \
  | grep '^link: ' | cut -d ' '  -f 2- | tr -d ' <>' | tr ',' '\n' \
  | grep 'rel="last"' | cut -d ';' -f1 | cut -d '?' -f 2- | tr '&' '\n' \
  | grep '^page=' | cut -d = -f 2 \
  | xargs seq 1 | xargs -I '{}' curl --no-progress-meter --fail --retry 16 --retry-all-errors "$url"\&page={} \
  | jq '.[].assets[].browser_download_url' -r | grep '.deb$' | grep '_1.' | head --lines=3 \
  | xargs wget
```
## Trace Structure Overview
```
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
```
{
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "d6bf7f8252fb6b94",
  "parent_span_id": "af654b0861d184b7",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763807034934296320,
  "time_end": 1763807035672000256,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.116.5",
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
      "00-603d6b9023f56fa9119c50b9c6a507cd-af654b0861d184b7-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 22 Nov 2025 10:23:55 GMT"
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
      "W/\"409237ff9f231408f1aadc8107e0ffffd371f69e946f9c7caccceaecc3a31f47\""
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
      "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset"
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
    "http.response.header.x-ratelimit-reset": [
      "1763809351"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "3"
    ],
    "http.response.header.x-github-request-id": [
      "A801:7178B:3C1489A:3DA760C:69218F3A"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 5272,
    "process.parent_pid": 3903,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "5478ac4e62e572d4",
  "parent_span_id": "8c350f6e17db807c",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763807036053464576,
  "time_end": 1763807036764638208,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.116.5",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443,
    "url.full": "https://api.github.com:443/repos/plengauer/Thoth/releases?per_page=100&page=2",
    "url.path": "/repos/plengauer/Thoth/releases",
    "url.query": "per_page=100&page=2",
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
      "00-603d6b9023f56fa9119c50b9c6a507cd-8c350f6e17db807c-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 22 Nov 2025 10:23:56 GMT"
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
      "W/\"daf400f93fc6034f486aaf608fd4eb18d754fe9dd7411d64e386d2d8f0c21f35\""
    ],
    "http.response.header.x-github-media-type": [
      "github.v3; format=json"
    ],
    "http.response.header.link": [
      "<https://api.github.com/repositories/692042935/releases?per_page=100&page=1>; rel=\"prev\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=3>; rel=\"next\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=4>; rel=\"last\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=1>; rel=\"first\""
    ],
    "http.response.header.x-github-api-version-selected": [
      "2022-11-28"
    ],
    "http.response.header.access-control-expose-headers": [
      "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset"
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
    "http.response.header.x-ratelimit-reset": [
      "1763809351"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "4"
    ],
    "http.response.header.x-github-request-id": [
      "A802:3790DA:3A759AD:3C01230:69218F3C"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 6721,
    "process.parent_pid": 3903,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "bd8b02a8e766d813",
  "parent_span_id": "497b07e24329c102",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763807037148546304,
  "time_end": 1763807037763729152,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.116.5",
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
      "00-603d6b9023f56fa9119c50b9c6a507cd-497b07e24329c102-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 22 Nov 2025 10:23:57 GMT"
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
      "W/\"c5cefecb03102e88a8ca0aa0688ff439604e448c16094403a57f7aeb5da226c6\""
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
      "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset"
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
    "http.response.header.x-ratelimit-reset": [
      "1763809351"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "5"
    ],
    "http.response.header.x-github-request-id": [
      "A803:2741C0:3829416:39B4EE7:69218F3D"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 7585,
    "process.parent_pid": 3903,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "1477172c5d2bb1eb",
  "parent_span_id": "84247c87691963cf",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763807038153336576,
  "time_end": 1763807038680553216,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.116.5",
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
      "00-603d6b9023f56fa9119c50b9c6a507cd-84247c87691963cf-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 22 Nov 2025 10:23:58 GMT"
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
      "W/\"9c76edb6008e43646b29a074d87a4d5aaf6c454bd36b136811486fc6db844a08\""
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
      "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset"
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
      "54"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1763809351"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "6"
    ],
    "http.response.header.x-github-request-id": [
      "A804:2B78A4:3952BEF:3ADF0E1:69218F3E"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 8449,
    "process.parent_pid": 3903,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "665242fa1fab8f8a",
  "parent_span_id": "8a661b86cb62be26",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763807039518505472,
  "time_end": 1763807040529748736,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.116.4",
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 9316,
    "process.parent_pid": 3883,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "fdf2c569476cb722",
  "parent_span_id": "8a661b86cb62be26",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763807039754861056,
  "time_end": 1763807040589595392,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-22T11%3A09%3A45Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-22T10%3A09%3A37Z&ske=2025-11-22T11%3A09%3A45Z&sks=b&skv=2018-11-09&sig=LIEgreAazO%2FVgs5BCyPggXDvOBXHXYxJdv6f22T8EEU%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MzgwNzMzOSwibmJmIjoxNzYzODA3MDM5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.O-PYbRTjVZthxdIoRziAUtlh1NEkr9coDX4NNSa_g4A&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-22T11%3A09%3A45Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-22T10%3A09%3A37Z&ske=2025-11-22T11%3A09%3A45Z&sks=b&skv=2018-11-09&sig=LIEgreAazO%2FVgs5BCyPggXDvOBXHXYxJdv6f22T8EEU%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MzgwNzMzOSwibmJmIjoxNzYzODA3MDM5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.O-PYbRTjVZthxdIoRziAUtlh1NEkr9coDX4NNSa_g4A&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.scheme": "https",
    "user_agent.original": "wget",
    "http.request.method": "GET",
    "http.response.status_code": 200,
    "http.response.header.content-type": [
      "application/octet-stream"
    ],
    "http.response.header.content-length": [
      "7202"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 9316,
    "process.parent_pid": 3883,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "2a65068fff04b445",
  "parent_span_id": "8a661b86cb62be26",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763807040608491520,
  "time_end": 1763807041620159488,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.116.4",
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 9316,
    "process.parent_pid": 3883,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "473ba6739874b36b",
  "parent_span_id": "8a661b86cb62be26",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763807040829564416,
  "time_end": 1763807041683579392,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-22T11%3A11%3A14Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-22T10%3A10%3A56Z&ske=2025-11-22T11%3A11%3A14Z&sks=b&skv=2018-11-09&sig=jqXiNAYfPeKoyCzUj63LKU7hsxwpUS6mcZyCWvZa2CU%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MzgwNzM0MCwibmJmIjoxNzYzODA3MDQwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.f0xaGA72C4ZyAJAQG2r_i8f7AHw4CWiLgNPzE1p7J08&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-22T11%3A11%3A14Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-22T10%3A10%3A56Z&ske=2025-11-22T11%3A11%3A14Z&sks=b&skv=2018-11-09&sig=jqXiNAYfPeKoyCzUj63LKU7hsxwpUS6mcZyCWvZa2CU%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MzgwNzM0MCwibmJmIjoxNzYzODA3MDQwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.f0xaGA72C4ZyAJAQG2r_i8f7AHw4CWiLgNPzE1p7J08&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.scheme": "https",
    "user_agent.original": "wget",
    "http.request.method": "GET",
    "http.response.status_code": 200,
    "http.response.header.content-type": [
      "application/octet-stream"
    ],
    "http.response.header.content-length": [
      "7184"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 9316,
    "process.parent_pid": 3883,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "7bba52c49a243504",
  "parent_span_id": "8a661b86cb62be26",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763807041702298624,
  "time_end": 1763807042714474752,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.116.4",
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 9316,
    "process.parent_pid": 3883,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "1444cd96497b464e",
  "parent_span_id": "8a661b86cb62be26",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763807041924596480,
  "time_end": 1763807042759129600,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-22T11%3A09%3A17Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-22T10%3A08%3A41Z&ske=2025-11-22T11%3A09%3A17Z&sks=b&skv=2018-11-09&sig=TxlL27EP0iu6CUYfv%2FGZTYESKLuisneBFiI8%2BGGpM2E%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MzgwNzM0MSwibmJmIjoxNzYzODA3MDQxLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.WHjY-k7kkl_XlJMCtWMkx2N-Uv8Btgftsh9PQ-tyk18&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-22T11%3A09%3A17Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-22T10%3A08%3A41Z&ske=2025-11-22T11%3A09%3A17Z&sks=b&skv=2018-11-09&sig=TxlL27EP0iu6CUYfv%2FGZTYESKLuisneBFiI8%2BGGpM2E%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MzgwNzM0MSwibmJmIjoxNzYzODA3MDQxLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.WHjY-k7kkl_XlJMCtWMkx2N-Uv8Btgftsh9PQ-tyk18&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.scheme": "https",
    "user_agent.original": "wget",
    "http.request.method": "GET",
    "http.response.status_code": 200,
    "http.response.header.content-type": [
      "application/octet-stream"
    ],
    "http.response.header.content-length": [
      "7176"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 9316,
    "process.parent_pid": 3883,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "f9e004df0377a09e",
  "parent_span_id": "18a0364f56e31e24",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763807029872667136,
  "time_end": 1763807033384753408,
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
      "Sat, 22 Nov 2025 10:23:50 GMT"
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
      "W/\"e1ccd51bedcf5581c7aa7f06c376c17828adb2522c24080de14c6d0faf042563\""
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
      "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset"
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
    "http.response.header.x-ratelimit-reset": [
      "1763809351"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "2"
    ],
    "http.response.header.x-github-request-id": [
      "A800:27D8E1:3A827A9:3C0DD82:69218F35"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "a01e3ae34f6665e9",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1763807029546444288,
  "time_end": 1763807042768490240,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "af654b0861d184b7",
  "parent_span_id": "9d6de96d3c136d0e",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807034839987968,
  "time_end": 1763807035675966464,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 466,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 5272,
    "process.parent_pid": 3903,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "8c350f6e17db807c",
  "parent_span_id": "9d6de96d3c136d0e",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807035965568000,
  "time_end": 1763807036768783872,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 466,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 6721,
    "process.parent_pid": 3903,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "497b07e24329c102",
  "parent_span_id": "9d6de96d3c136d0e",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807037059882240,
  "time_end": 1763807037767683584,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 466,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 7585,
    "process.parent_pid": 3903,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "84247c87691963cf",
  "parent_span_id": "9d6de96d3c136d0e",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807038064322304,
  "time_end": 1763807038684738304,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 466,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 8449,
    "process.parent_pid": 3903,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "d3095861a254364a",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029582007296,
  "time_end": 1763807033395631104,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "dfc2bcc6320c08d9",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029583577344,
  "time_end": 1763807033404710144,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "640977142a10afa5",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029596731648,
  "time_end": 1763807033414042368,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "ce0d135fa0906bc1",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029585710848,
  "time_end": 1763807033407172864,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "7d26484e1e063c75",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029590734848,
  "time_end": 1763807038694676736,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "60b0685cc218f020",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029567985664,
  "time_end": 1763807033393267456,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "f490d1283f26f6fa",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029586427136,
  "time_end": 1763807033411854080,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "52a64b8ab3f2b76f",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1763807029587922944,
  "time_end": 1763807038697950208,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "b73760f1f8dcb02b",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029571813120,
  "time_end": 1763807033402517760,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "e4bba9f3bf6ba659",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029613289984,
  "time_end": 1763807038691500544,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "70b7152166979e76",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029580090112,
  "time_end": 1763807038692057856,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "9da8acf391e70c8c",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1763807029567302656,
  "time_end": 1763807033388476672,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "35806aaa0dd63720",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029569943552,
  "time_end": 1763807029636965632,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "18a0364f56e31e24",
  "parent_span_id": "9da8acf391e70c8c",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1763807029672521472,
  "time_end": 1763807033384774912,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "3d41836273cab6b3",
  "parent_span_id": "1e8bee46d8dc91cb",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807034117179904,
  "time_end": 1763807034133011456,
  "attributes": {
    "shell.command_line": "seq 1 4",
    "shell.command": "seq",
    "shell.command.type": "file",
    "shell.command.name": "seq",
    "subprocess.executable.path": "/usr/bin/seq",
    "subprocess.executable.name": "seq",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 466,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 4604,
    "process.parent_pid": 3864,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "91619a929319069b",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029588295168,
  "time_end": 1763807033409510144,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "08eb45a1dca14200",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029576727040,
  "time_end": 1763807033400257536,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "ed8718bfa64b36ae",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029576588544,
  "time_end": 1763807033397863168,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "3278f823391f6e31",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029575011584,
  "time_end": 1763807033390831872,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "8a661b86cb62be26",
  "parent_span_id": "d71c2a6b3b41f97c",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807039404328704,
  "time_end": 1763807042763489024,
  "attributes": {
    "shell.command_line": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
    "shell.command": "wget",
    "shell.command.type": "file",
    "shell.command.name": "wget",
    "subprocess.executable.path": "/usr/bin/wget",
    "subprocess.executable.name": "wget",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 466,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 9316,
    "process.parent_pid": 3883,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "9d6de96d3c136d0e",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029596554496,
  "time_end": 1763807038688722176,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "1e8bee46d8dc91cb",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029585562624,
  "time_end": 1763807034138508544,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
  "trace_id": "603d6b9023f56fa9119c50b9c6a507cd",
  "span_id": "d71c2a6b3b41f97c",
  "parent_span_id": "a01e3ae34f6665e9",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763807029616814336,
  "time_end": 1763807042767772416,
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
    "telemetry.sdk.version": "5.36.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/da51cace-5e92-43ef-8578-ca7d1dc44d5f/resourceGroups/azure-westcentralus-general-da51cace-5e92-43ef-8578-ca7d1dc44d5f/providers/Microsoft.Compute/virtualMachines/dAhXGpCZ2JLE1O",
    "host.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "host.name": "dAhXGpCZ2JLE1O",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "ff341e4d-5ac3-4bdb-a603-8ef5cdb6c258",
    "process.pid": 2586,
    "process.parent_pid": 2388,
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
