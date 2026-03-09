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
  head --lines=3
  xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}
    curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1
      GET
    curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2
      GET
    curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3
      GET
    curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4
      GET
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "5b7f6c1478fe6493",
  "parent_span_id": "17d23f0de09869d8",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772892834295040768,
  "time_end": 1772892835058021632,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.112.5",
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
      "00-cc872ed1ab48cd65ea3c4255ab4338bd-17d23f0de09869d8-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 07 Mar 2026 14:13:54 GMT"
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
      "W/\"36fba2ffaa3cb0409f19f11e3f927754256b8603953e91758389c361b988cf0a\""
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
    "http.response.header.x-ratelimit-used": [
      "3"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1772892871"
    ],
    "http.response.header.x-github-request-id": [
      "EC41:3C7385:2157FF:8B7E10:69AC32A2"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 5347,
    "process.parent_pid": 4021,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "14e98b26e4419f3b",
  "parent_span_id": "7ac939a95a9dff2e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772892835433504256,
  "time_end": 1772892836110733568,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.112.5",
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
      "00-cc872ed1ab48cd65ea3c4255ab4338bd-7ac939a95a9dff2e-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 07 Mar 2026 14:13:55 GMT"
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
      "W/\"cc1705f42a53411c7f42d98fcbef954f3feae2aa64d27738ae4e4e29cd42565c\""
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
    "http.response.header.x-ratelimit-used": [
      "4"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1772892871"
    ],
    "http.response.header.x-github-request-id": [
      "EC42:14EA25:21093F:8AFFFA:69AC32A3"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 6936,
    "process.parent_pid": 4021,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "d4996d66ea20edba",
  "parent_span_id": "06fd4021b6a4a6d3",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772892836490559744,
  "time_end": 1772892837179963648,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.112.5",
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
      "00-cc872ed1ab48cd65ea3c4255ab4338bd-06fd4021b6a4a6d3-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 07 Mar 2026 14:13:56 GMT"
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
      "W/\"c4b6f7d1f38b7ffce30d0de99d3f6c859cce57684c4e12f6c33553c35b8403bc\""
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
    "http.response.header.x-ratelimit-used": [
      "5"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1772892871"
    ],
    "http.response.header.x-github-request-id": [
      "EC43:108ECD:21503E:8BE53E:69AC32A4"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 7957,
    "process.parent_pid": 4021,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "7d94a4e9f5f10f67",
  "parent_span_id": "96928a060152be2a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772892837546425088,
  "time_end": 1772892838215816448,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.112.5",
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
      "00-cc872ed1ab48cd65ea3c4255ab4338bd-96928a060152be2a-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 07 Mar 2026 14:13:57 GMT"
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
      "W/\"a21ab241e5908c2ca0830e2de0a10494b5f86600f024a5a0e87ceda8258e2f76\""
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
    "http.response.header.x-ratelimit-used": [
      "6"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1772892871"
    ],
    "http.response.header.x-github-request-id": [
      "EC44:EA672:1FE9A5:8607DF:69AC32A5"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 8966,
    "process.parent_pid": 4021,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "b38d3cb65aae9fcd",
  "parent_span_id": "f01b17ec61632dab",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772892838647620864,
  "time_end": 1772892838813133824,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.114.4",
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 9392,
    "process.parent_pid": 4007,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "4e2dab3e2b572cbd",
  "parent_span_id": "f01b17ec61632dab",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772892838746396416,
  "time_end": 1772892838930925568,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-07T14%3A48%3A20Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-07T13%3A48%3A08Z&ske=2026-03-07T14%3A48%3A20Z&sks=b&skv=2018-11-09&sig=zfyAtVdQ5jF%2F9s%2BbUtYRaJHWtwPKMtH0da%2BmS87ybqA%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3Mjg5MzEzOCwibmJmIjoxNzcyODkyODM4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.tHTkBhYycCeMiGE9pcr-1YoYkdT9A_wMKGEO6Ujz2Q4&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-07T14%3A48%3A20Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-07T13%3A48%3A08Z&ske=2026-03-07T14%3A48%3A20Z&sks=b&skv=2018-11-09&sig=zfyAtVdQ5jF%2F9s%2BbUtYRaJHWtwPKMtH0da%2BmS87ybqA%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3Mjg5MzEzOCwibmJmIjoxNzcyODkyODM4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.tHTkBhYycCeMiGE9pcr-1YoYkdT9A_wMKGEO6Ujz2Q4&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 9392,
    "process.parent_pid": 4007,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "6d3a5b665ce86fe7",
  "parent_span_id": "f01b17ec61632dab",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772892838774007808,
  "time_end": 1772892839033611520,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.114.4",
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 9392,
    "process.parent_pid": 4007,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "6ddd3d2585d2be6e",
  "parent_span_id": "f01b17ec61632dab",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772892838951744768,
  "time_end": 1772892839151557888,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-07T15%3A13%3A23Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-07T14%3A13%3A17Z&ske=2026-03-07T15%3A13%3A23Z&sks=b&skv=2018-11-09&sig=aUzvLjZM9iCcAqF%2FS6wtFF3V55BrYJaubxQ%2FPFnQVIQ%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3Mjg5MzEzOCwibmJmIjoxNzcyODkyODM4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.tHTkBhYycCeMiGE9pcr-1YoYkdT9A_wMKGEO6Ujz2Q4&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-07T15%3A13%3A23Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-07T14%3A13%3A17Z&ske=2026-03-07T15%3A13%3A23Z&sks=b&skv=2018-11-09&sig=aUzvLjZM9iCcAqF%2FS6wtFF3V55BrYJaubxQ%2FPFnQVIQ%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3Mjg5MzEzOCwibmJmIjoxNzcyODkyODM4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.tHTkBhYycCeMiGE9pcr-1YoYkdT9A_wMKGEO6Ujz2Q4&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 9392,
    "process.parent_pid": 4007,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "a7d42365e8216733",
  "parent_span_id": "f01b17ec61632dab",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772892838977363712,
  "time_end": 1772892839255353856,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.114.4",
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 9392,
    "process.parent_pid": 4007,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "6ebec345b7110df6",
  "parent_span_id": "f01b17ec61632dab",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772892839142988288,
  "time_end": 1772892839297372416,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-07T15%3A12%3A25Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-07T14%3A11%3A32Z&ske=2026-03-07T15%3A12%3A25Z&sks=b&skv=2018-11-09&sig=yYTZWTqbFYRI3dNg%2FfGPUOjOyG6fWQTcgSf7GvkKfEM%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3Mjg5MzEzOSwibmJmIjoxNzcyODkyODM5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.RplnXfdVSpb9DnVpFxeMV78LEVS7Fp3EW8Zil4FuRrQ&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-07T15%3A12%3A25Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-07T14%3A11%3A32Z&ske=2026-03-07T15%3A12%3A25Z&sks=b&skv=2018-11-09&sig=yYTZWTqbFYRI3dNg%2FfGPUOjOyG6fWQTcgSf7GvkKfEM%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3Mjg5MzEzOSwibmJmIjoxNzcyODkyODM5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.RplnXfdVSpb9DnVpFxeMV78LEVS7Fp3EW8Zil4FuRrQ&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 9392,
    "process.parent_pid": 4007,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "08afb316b3772ecb",
  "parent_span_id": "f675bbbdfe571407",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772892829388826112,
  "time_end": 1772892832810353920,
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
      "Sat, 07 Mar 2026 14:13:49 GMT"
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
      "W/\"ef59dda9aa8733024dd8ee832dd2200c539634b46dc16f675297e84d2ab191e1\""
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
    "http.response.header.x-ratelimit-used": [
      "2"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1772892871"
    ],
    "http.response.header.x-github-request-id": [
      "EC40:3B93CA:1FA618:85143F:69AC329D"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "f239e6b442be7f2f",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1772892829013528576,
  "time_end": 1772892839308419328,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "17d23f0de09869d8",
  "parent_span_id": "58b463af6b1d533e",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892834223852032,
  "time_end": 1772892835120338944,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 464,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 5347,
    "process.parent_pid": 4021,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "7ac939a95a9dff2e",
  "parent_span_id": "58b463af6b1d533e",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892835356247040,
  "time_end": 1772892836174270976,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 464,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 6936,
    "process.parent_pid": 4021,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "06fd4021b6a4a6d3",
  "parent_span_id": "58b463af6b1d533e",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892836415619072,
  "time_end": 1772892837241885440,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 464,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 7957,
    "process.parent_pid": 4021,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "96928a060152be2a",
  "parent_span_id": "58b463af6b1d533e",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892837477941504,
  "time_end": 1772892838286359808,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 464,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 8966,
    "process.parent_pid": 4021,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "8ab658ef463859e6",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829059988480,
  "time_end": 1772892832818893056,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "059109edeb41ae06",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829070767616,
  "time_end": 1772892832828661248,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "36fcdfe63ad9bb9c",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829050487808,
  "time_end": 1772892832838277632,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "ed82a57f330eb9cf",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829055279616,
  "time_end": 1772892832831047936,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "96f3c8f5e5882aea",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829053772800,
  "time_end": 1772892838299409152,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "a01acb43ffec78f1",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829073402112,
  "time_end": 1772892832816490496,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "df5e04b059967032",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829089368576,
  "time_end": 1772892832835859456,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "030099558601a34a",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1772892829046656512,
  "time_end": 1772892838302841344,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "676f639f2f403449",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829069024512,
  "time_end": 1772892832826263808,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "171069178a90bed6",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829069236224,
  "time_end": 1772892837784051200,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "d6c7d04e308628c2",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829048459264,
  "time_end": 1772892838295980800,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "5b248aba6261e589",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1772892829061650944,
  "time_end": 1772892832811617280,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "4099c6e499a36806",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829044469248,
  "time_end": 1772892829134644736,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "f675bbbdfe571407",
  "parent_span_id": "5b248aba6261e589",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1772892829164950272,
  "time_end": 1772892832810376704,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "7ff9f91b1a269f6c",
  "parent_span_id": "2aa955799489884c",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892833512929280,
  "time_end": 1772892833529586176,
  "attributes": {
    "shell.command_line": "seq 1 4",
    "shell.command": "seq",
    "shell.command.type": "file",
    "shell.command.name": "seq",
    "subprocess.executable.path": "/usr/bin/seq",
    "subprocess.executable.name": "seq",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 464,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 4738,
    "process.parent_pid": 4028,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "3b6a16816e68089a",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829069651456,
  "time_end": 1772892832833453824,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "962e6ff25e2f934e",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829068662272,
  "time_end": 1772892832823849728,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "1557cd173e7a2f4a",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829055447040,
  "time_end": 1772892832821441792,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "1cc7ff572a7c4100",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829047520000,
  "time_end": 1772892832814083584,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "f01b17ec61632dab",
  "parent_span_id": "56b76c0d0d306c1b",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892838564069376,
  "time_end": 1772892839302294528,
  "attributes": {
    "shell.command_line": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
    "shell.command": "wget",
    "shell.command.type": "file",
    "shell.command.name": "wget",
    "subprocess.executable.path": "/usr/bin/wget",
    "subprocess.executable.name": "wget",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 464,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 9392,
    "process.parent_pid": 4007,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "58b463af6b1d533e",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829057243648,
  "time_end": 1772892838292184320,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "2aa955799489884c",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829069504000,
  "time_end": 1772892833534724608,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
  "trace_id": "cc872ed1ab48cd65ea3c4255ab4338bd",
  "span_id": "56b76c0d0d306c1b",
  "parent_span_id": "f239e6b442be7f2f",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772892829070916096,
  "time_end": 1772892839307233792,
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
    "telemetry.sdk.version": "5.47.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/445a2aba-d0ef-42d0-8783-0a2eb944ea9a/resourceGroups/azure-eastus2-general-445a2aba-d0ef-42d0-8783-0a2eb944ea9a/providers/Microsoft.Compute/virtualMachines/ER6FDkm5sPE7DI",
    "host.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "host.name": "ER6FDkm5sPE7DI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "6446b5a0-69b0-473d-bce6-20ee52baff27",
    "process.pid": 2765,
    "process.parent_pid": 2565,
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
