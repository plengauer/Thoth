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
printf "HEAD $path HTTP/1.1\r\nConnection: close\r\nUser-Agent: ncat\r\nHost: $host\r\n\r\n" | ncat --ssl -i 3 --no-shutdown "$host" 443 | tr '[:upper:]' '[:lower:]' \
  | grep '^link: ' | cut -d ' '  -f 2- | tr -d ' <>' | tr ',' '\n' \
  | grep 'rel="last"' | cut -d ';' -f1 | cut -d '?' -f 2- | tr '&' '\n' \
  | grep '^page=' | cut -d = -f 2 \
  | xargs seq 1 | xargs -I '{}' curl --no-progress-meter --fail --retry 16 --retry-all-errors "$url"\&page={} \
  | jq '.[].assets[].browser_download_url' -r | grep '.deb$' | grep '_1.' | head --lines=3 \
  | xargs wget
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
```json
{
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "33b8278f598c4701",
  "parent_span_id": "662e78302e4bad87",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264469090758912,
  "time_end": 1786264469871231232,
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
      "00-faed026d960b16ed77ac794bae9e4d0a-662e78302e4bad87-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 09 Aug 2026 08:34:29 GMT"
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
      "W/\"06b3c10e949aaa544f468cc68883f68adc1582e3c817559321bad3511e2943e2\""
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
      "53"
    ],
    "http.response.header.x-ratelimit-used": [
      "7"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1786265551"
    ],
    "http.response.header.x-github-request-id": [
      "6829:24E63A:89A0F6:1D23400:6A783B95"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "2275cfa7-e050-4a59-bfbf-d7f1532c25c0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 6271,
    "process.parent_pid": 4933,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "66fc222d9b273838",
  "parent_span_id": "dc61a7e7b378213f",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264470209007872,
  "time_end": 1786264470953544704,
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
      "00-faed026d960b16ed77ac794bae9e4d0a-dc61a7e7b378213f-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 09 Aug 2026 08:34:30 GMT"
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
      "W/\"ac388033f83a5269ff6c67fece8a75b096b8ed39f05018169d4cc4128904cc17\""
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
      "52"
    ],
    "http.response.header.x-ratelimit-used": [
      "8"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1786265551"
    ],
    "http.response.header.x-github-request-id": [
      "682A:1391CC:8BFAD2:1DC6B08:6A783B96"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "8dec90d9-53cc-4d41-a106-6fdcd74464a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 7853,
    "process.parent_pid": 4933,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "9c844704df744211",
  "parent_span_id": "00b4489625bdfea8",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264471302160640,
  "time_end": 1786264471996829952,
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
      "00-faed026d960b16ed77ac794bae9e4d0a-00b4489625bdfea8-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 09 Aug 2026 08:34:31 GMT"
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
      "W/\"239641792038523608f6a780f63fdf7df7e94e3890ddf95c5de82c9c28c75f18\""
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
      "51"
    ],
    "http.response.header.x-ratelimit-used": [
      "9"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1786265551"
    ],
    "http.response.header.x-github-request-id": [
      "682B:297C61:8901E9:1D0E15B:6A783B97"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "086f7f83-26f3-4d7a-b81d-70851086e68a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 8858,
    "process.parent_pid": 4933,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "2d38f5c678de0388",
  "parent_span_id": "02edd6de0514e55c",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264472336871680,
  "time_end": 1786264472978133760,
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
      "00-faed026d960b16ed77ac794bae9e4d0a-02edd6de0514e55c-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 09 Aug 2026 08:34:32 GMT"
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
      "W/\"32be03f049c32e21f080e40bd58939abe972c928add95bcf7f991786388cf5f2\""
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
      "50"
    ],
    "http.response.header.x-ratelimit-used": [
      "10"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1786265551"
    ],
    "http.response.header.x-github-request-id": [
      "682C:57EDF:879512:1CC8AFB:6A783B98"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "56db3eee-771f-4101-81ab-569864c169f8",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 9864,
    "process.parent_pid": 4933,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "acf58d4d6ea75057",
  "parent_span_id": "c373554b9d1fc20a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264473435904256,
  "time_end": 1786264473655297792,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.114.3",
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "f479fc0f-2f5c-4abc-9f28-6dad5e08fa10",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 10306,
    "process.parent_pid": 4928,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "195e2317cacd10be",
  "parent_span_id": "c373554b9d1fc20a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264473582394880,
  "time_end": 1786264473767392512,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.108.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-09T09%3A10%3A06Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-09T08%3A09%3A17Z&ske=2026-08-09T09%3A10%3A06Z&sks=b&skv=2018-11-09&sig=icOlUx3IfWcuaBZs2yZvC11wvkUrdfN%2BR7D5r0KdHo8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NjI2NDc3MywibmJmIjoxNzg2MjY0NDczLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.r80RbdzyTOEJ5mP19Wqrc7QxjW0muH4SK84HSLW60r0&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-09T09%3A10%3A06Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-09T08%3A09%3A17Z&ske=2026-08-09T09%3A10%3A06Z&sks=b&skv=2018-11-09&sig=icOlUx3IfWcuaBZs2yZvC11wvkUrdfN%2BR7D5r0KdHo8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NjI2NDc3MywibmJmIjoxNzg2MjY0NDczLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.r80RbdzyTOEJ5mP19Wqrc7QxjW0muH4SK84HSLW60r0&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "f479fc0f-2f5c-4abc-9f28-6dad5e08fa10",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 10306,
    "process.parent_pid": 4928,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "47f99b580b8b8aa8",
  "parent_span_id": "c373554b9d1fc20a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264473593985792,
  "time_end": 1786264473865763072,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.114.3",
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "f479fc0f-2f5c-4abc-9f28-6dad5e08fa10",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 10306,
    "process.parent_pid": 4928,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "ad980d76fc6859a6",
  "parent_span_id": "c373554b9d1fc20a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264473786014720,
  "time_end": 1786264473975893504,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.108.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-09T09%3A23%3A20Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-09T08%3A22%3A53Z&ske=2026-08-09T09%3A23%3A20Z&sks=b&skv=2018-11-09&sig=LMDhw32tMO9QyxSJL7gWXXrVlFO61gLRw2WX3w0jkrg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NjI2NDc3MywibmJmIjoxNzg2MjY0NDczLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.r80RbdzyTOEJ5mP19Wqrc7QxjW0muH4SK84HSLW60r0&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-09T09%3A23%3A20Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-09T08%3A22%3A53Z&ske=2026-08-09T09%3A23%3A20Z&sks=b&skv=2018-11-09&sig=LMDhw32tMO9QyxSJL7gWXXrVlFO61gLRw2WX3w0jkrg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NjI2NDc3MywibmJmIjoxNzg2MjY0NDczLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.r80RbdzyTOEJ5mP19Wqrc7QxjW0muH4SK84HSLW60r0&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "f479fc0f-2f5c-4abc-9f28-6dad5e08fa10",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 10306,
    "process.parent_pid": 4928,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "7ac653e1b4bd40e6",
  "parent_span_id": "c373554b9d1fc20a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264473797159936,
  "time_end": 1786264474075447808,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.114.3",
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "f479fc0f-2f5c-4abc-9f28-6dad5e08fa10",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 10306,
    "process.parent_pid": 4928,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "5a33c723dc7cc0d4",
  "parent_span_id": "c373554b9d1fc20a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264473999514112,
  "time_end": 1786264474113858048,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.108.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-09T09%3A26%3A30Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-09T08%3A25%3A41Z&ske=2026-08-09T09%3A26%3A30Z&sks=b&skv=2018-11-09&sig=GSJcwTArV1TA7ajwbir5KZb0EnTZTZB2dv%2Fr5nAbBq4%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NjI2NDc3MywibmJmIjoxNzg2MjY0NDczLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.r80RbdzyTOEJ5mP19Wqrc7QxjW0muH4SK84HSLW60r0&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-09T09%3A26%3A30Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-09T08%3A25%3A41Z&ske=2026-08-09T09%3A26%3A30Z&sks=b&skv=2018-11-09&sig=GSJcwTArV1TA7ajwbir5KZb0EnTZTZB2dv%2Fr5nAbBq4%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NjI2NDc3MywibmJmIjoxNzg2MjY0NDczLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.r80RbdzyTOEJ5mP19Wqrc7QxjW0muH4SK84HSLW60r0&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "f479fc0f-2f5c-4abc-9f28-6dad5e08fa10",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 10306,
    "process.parent_pid": 4928,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "8c7e649f174a161b",
  "parent_span_id": "527fc9d79ad5c380",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786264464013572352,
  "time_end": 1786264467553106432,
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
      "Sun, 09 Aug 2026 08:34:24 GMT"
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
      "W/\"c3142c2455a4ede3bccf52e7b184f9744af758cd703755b87b28b0066a026f90\""
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
      "54"
    ],
    "http.response.header.x-ratelimit-used": [
      "6"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1786265551"
    ],
    "http.response.header.x-github-request-id": [
      "6828:7668B:8AF386:1D764F8:6A783B8F"
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "539dd93c26c8f0b4",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786264463667112448,
  "time_end": 1786264474123598336,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "662e78302e4bad87",
  "parent_span_id": "fc2d168b6b290c8d",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264469028024064,
  "time_end": 1786264469930340608,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 482,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "2275cfa7-e050-4a59-bfbf-d7f1532c25c0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 6271,
    "process.parent_pid": 4933,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "dc61a7e7b378213f",
  "parent_span_id": "fc2d168b6b290c8d",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264470145630464,
  "time_end": 1786264471012924928,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 482,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "8dec90d9-53cc-4d41-a106-6fdcd74464a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 7853,
    "process.parent_pid": 4933,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "00b4489625bdfea8",
  "parent_span_id": "fc2d168b6b290c8d",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264471234349312,
  "time_end": 1786264472057351168,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 482,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "086f7f83-26f3-4d7a-b81d-70851086e68a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 8858,
    "process.parent_pid": 4933,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "02edd6de0514e55c",
  "parent_span_id": "fc2d168b6b290c8d",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264472277534208,
  "time_end": 1786264473054664448,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 482,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "56db3eee-771f-4101-81ab-569864c169f8",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 9864,
    "process.parent_pid": 4933,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "4d22dbbb55c57041",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463685419520,
  "time_end": 1786264467560876032,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "9602d5b7447cadbf",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463706691840,
  "time_end": 1786264467570043136,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "5a996a11a899b1f5",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463720179456,
  "time_end": 1786264467579310080,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "6d5b79bca1b3c8fa",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463709352960,
  "time_end": 1786264467572375552,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "0e564db378a09e2e",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463718877952,
  "time_end": 1786264473068145152,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "495f5d73b27d54bc",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463706413312,
  "time_end": 1786264467558501120,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "d02a6dd3f0d128ea",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463713397248,
  "time_end": 1786264467577048064,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "89eb423e55c96bb8",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1786264463721979136,
  "time_end": 1786264473071500800,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "79fd45cdf02899ec",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463686796800,
  "time_end": 1786264467567749632,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "5860af858b398715",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463715320832,
  "time_end": 1786264472589839104,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "cb6d339b890d9136",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463723194624,
  "time_end": 1786264473064265216,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "1a23cc8b5b00d934",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1786264463708414464,
  "time_end": 1786264467553911296,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "a2c4fb59b629484d",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463682213120,
  "time_end": 1786264463761900288,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "527fc9d79ad5c380",
  "parent_span_id": "1a23cc8b5b00d934",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1786264463807263488,
  "time_end": 1786264467553133056,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "4595c39ad534151a",
  "parent_span_id": "068a755ddb169727",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264468275483904,
  "time_end": 1786264468291249920,
  "attributes": {
    "shell.command_line": "seq 1 4",
    "shell.command": "seq",
    "shell.command.type": "file",
    "shell.command.name": "seq",
    "subprocess.executable.path": "/usr/bin/seq",
    "subprocess.executable.name": "seq",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 482,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "35d27e1c-0dd4-48d7-b5ac-8675d1dd32af",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 5667,
    "process.parent_pid": 4929,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "89648f052fd81254",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463719005952,
  "time_end": 1786264467574746368,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "98e233e92a4e0b78",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463692657920,
  "time_end": 1786264467565498368,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "c353c4cd2ae59dcd",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463706558976,
  "time_end": 1786264467563205120,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "dbad1d5da5d05826",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463706128128,
  "time_end": 1786264467556194816,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "c373554b9d1fc20a",
  "parent_span_id": "8496c4ea2318dd43",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264473375375872,
  "time_end": 1786264474118290944,
  "attributes": {
    "shell.command_line": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
    "shell.command": "wget",
    "shell.command.type": "file",
    "shell.command.name": "wget",
    "subprocess.executable.path": "/usr/bin/wget",
    "subprocess.executable.name": "wget",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 482,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "f479fc0f-2f5c-4abc-9f28-6dad5e08fa10",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 10306,
    "process.parent_pid": 4928,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "fc2d168b6b290c8d",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463718726144,
  "time_end": 1786264473060236544,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "068a755ddb169727",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463736846336,
  "time_end": 1786264468296351744,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
  "trace_id": "faed026d960b16ed77ac794bae9e4d0a",
  "span_id": "8496c4ea2318dd43",
  "parent_span_id": "539dd93c26c8f0b4",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786264463713166848,
  "time_end": 1786264474122704128,
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
    "telemetry.sdk.version": "5.60.0",
    "service.instance.id": "e34f022e-81ed-4b2e-bb70-f606043daf38",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/6adfad35-19a7-4172-83a9-2c8d8ea953bb/resourceGroups/azure-eastus-general-6adfad35-19a7-4172-83a9-2c8d8ea953bb/providers/Microsoft.Compute/virtualMachines/3MFv5LCkZWZrFy",
    "host.id": "99ec3751-a9b0-4c65-bcfa-e97e5b6344ab",
    "host.name": "3MFv5LCkZWZrFy",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1020-azure",
    "process.pid": 3691,
    "process.parent_pid": 3493,
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
