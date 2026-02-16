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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "9e78eb56dd3f3da2",
  "parent_span_id": "4ba10c5489d00233",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1771261450255028736,
  "time_end": 1771261451046785024,
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
      "00-3993fcea0e5f005b36fc11b9dfd36d5d-4ba10c5489d00233-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 16 Feb 2026 17:04:10 GMT"
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
      "W/\"359108d8ecdc7c894b05c8778b177838138483b9b449aefc79dfa3338b9ac6d8\""
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
      "56"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1771264045"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "4"
    ],
    "http.response.header.x-github-request-id": [
      "9029:13C942:C7DFB:34A819:69934E0A"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 5449,
    "process.parent_pid": 4070,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "1ced336fd265ab31",
  "parent_span_id": "ee9980aeb7d466df",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1771261451446862848,
  "time_end": 1771261452044688896,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.114.5",
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
      "00-3993fcea0e5f005b36fc11b9dfd36d5d-ee9980aeb7d466df-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 16 Feb 2026 17:04:11 GMT"
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
      "W/\"8afcd3c06f606f21c2e98f5c1e94cc28b812454183cfc0aed444b4f35afd4f48\""
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
      "55"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1771264045"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "5"
    ],
    "http.response.header.x-github-request-id": [
      "902A:5A0CE:B1F97:2F3E66:69934E0B"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 6899,
    "process.parent_pid": 4070,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "edbf1fa1346bfa3c",
  "parent_span_id": "d066984acc825838",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1771261452445124352,
  "time_end": 1771261453224003584,
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
      "00-3993fcea0e5f005b36fc11b9dfd36d5d-d066984acc825838-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 16 Feb 2026 17:04:12 GMT"
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
      "W/\"c57a0ac961747247e2d7a773561ab79bd1d68252f5e2883bf1084d7dedfd6dec\""
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
      "54"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1771264045"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "6"
    ],
    "http.response.header.x-github-request-id": [
      "902B:286443:D04F3:3779BE:69934E0C"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 7764,
    "process.parent_pid": 4070,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "ff0a18aa4dfd92e8",
  "parent_span_id": "08f78b709ab40076",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1771261453626438144,
  "time_end": 1771261454176882688,
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
      "00-3993fcea0e5f005b36fc11b9dfd36d5d-08f78b709ab40076-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 16 Feb 2026 17:04:13 GMT"
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
      "W/\"51071b9bc429e15150f92e3f0b4865ece090a244cb336f237c1ec875907c2864\""
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
      "53"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1771264045"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "7"
    ],
    "http.response.header.x-github-request-id": [
      "902C:11A62C:B8AF1:30D539:69934E0D"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 8629,
    "process.parent_pid": 4070,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "b70798fea0d7a9df",
  "parent_span_id": "c5e0c47019449178",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1771261455070124544,
  "time_end": 1771261456079640832,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.113.4",
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 9497,
    "process.parent_pid": 4069,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "bf579ba9975ad435",
  "parent_span_id": "c5e0c47019449178",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1771261455242817280,
  "time_end": 1771261456175000320,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-16T17%3A45%3A52Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-16T16%3A45%3A50Z&ske=2026-02-16T17%3A45%3A52Z&sks=b&skv=2018-11-09&sig=nwBkBYPIsmEgY2um4VRsW3CwUgnMyH73ekSsmFzQ8PU%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MTI2MTc1NSwibmJmIjoxNzcxMjYxNDU1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.HO_UbKz16XYX8BKbD1udx8ttgKR4P71YK4_o70zQpgA&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-16T17%3A45%3A52Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-16T16%3A45%3A50Z&ske=2026-02-16T17%3A45%3A52Z&sks=b&skv=2018-11-09&sig=nwBkBYPIsmEgY2um4VRsW3CwUgnMyH73ekSsmFzQ8PU%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MTI2MTc1NSwibmJmIjoxNzcxMjYxNDU1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.HO_UbKz16XYX8BKbD1udx8ttgKR4P71YK4_o70zQpgA&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 9497,
    "process.parent_pid": 4069,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "b5a830b98f5b8362",
  "parent_span_id": "c5e0c47019449178",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1771261456203190784,
  "time_end": 1771261457208390912,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.113.4",
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 9497,
    "process.parent_pid": 4069,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "b70796bec9860fe9",
  "parent_span_id": "c5e0c47019449178",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1771261456377518592,
  "time_end": 1771261457287402752,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-16T17%3A46%3A20Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-16T16%3A45%3A26Z&ske=2026-02-16T17%3A46%3A20Z&sks=b&skv=2018-11-09&sig=uttusQ%2F1s%2B9y1s0vkKz4Wt8qsIbBjtis5Wk0HE1EjSs%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MTI2MTc1NiwibmJmIjoxNzcxMjYxNDU2LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.aFqlOpyJ7mBY56gBS3NyvcKoSmbLlAAHbWNgLUBxE3U&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-16T17%3A46%3A20Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-16T16%3A45%3A26Z&ske=2026-02-16T17%3A46%3A20Z&sks=b&skv=2018-11-09&sig=uttusQ%2F1s%2B9y1s0vkKz4Wt8qsIbBjtis5Wk0HE1EjSs%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MTI2MTc1NiwibmJmIjoxNzcxMjYxNDU2LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.aFqlOpyJ7mBY56gBS3NyvcKoSmbLlAAHbWNgLUBxE3U&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 9497,
    "process.parent_pid": 4069,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "cc5f4047ec78675a",
  "parent_span_id": "c5e0c47019449178",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1771261457311315456,
  "time_end": 1771261458320822016,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.113.4",
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 9497,
    "process.parent_pid": 4069,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "d7e4b43b2f4936cb",
  "parent_span_id": "c5e0c47019449178",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1771261457475470848,
  "time_end": 1771261458422041856,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-16T17%3A50%3A04Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-16T16%3A49%3A05Z&ske=2026-02-16T17%3A50%3A04Z&sks=b&skv=2018-11-09&sig=da6Px0k1HdjCceirXF2Cg276F2q3L3rCIgRGsStptso%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MTI2MTc1NywibmJmIjoxNzcxMjYxNDU3LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.ozXV2tp2NtfgND-g1bsbE1_Z4jrVb2VSVkg0xkLw3fA&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-16T17%3A50%3A04Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-16T16%3A49%3A05Z&ske=2026-02-16T17%3A50%3A04Z&sks=b&skv=2018-11-09&sig=da6Px0k1HdjCceirXF2Cg276F2q3L3rCIgRGsStptso%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MTI2MTc1NywibmJmIjoxNzcxMjYxNDU3LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.ozXV2tp2NtfgND-g1bsbE1_Z4jrVb2VSVkg0xkLw3fA&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 9497,
    "process.parent_pid": 4069,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "12ba0c9c132729a9",
  "parent_span_id": "30c50cc348555eb0",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1771261445093888256,
  "time_end": 1771261448624567808,
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
      "Mon, 16 Feb 2026 17:04:05 GMT"
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
      "W/\"49ad391bd4a81a99814f0d016e80f34a88da377459341251a1c7a7dc897aaed1\""
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
      "1771264045"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "3"
    ],
    "http.response.header.x-github-request-id": [
      "9028:C1D6C:C10EC:3316FB:69934E05"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "213fde0e0e15bcf2",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1771261444721416704,
  "time_end": 1771261458432461056,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "4ba10c5489d00233",
  "parent_span_id": "6dad9ae9a8811eac",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261450153895936,
  "time_end": 1771261451051307520,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 5449,
    "process.parent_pid": 4070,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "ee9980aeb7d466df",
  "parent_span_id": "6dad9ae9a8811eac",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261451343043584,
  "time_end": 1771261452049195776,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 6899,
    "process.parent_pid": 4070,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "d066984acc825838",
  "parent_span_id": "6dad9ae9a8811eac",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261452342044672,
  "time_end": 1771261453228571648,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 7764,
    "process.parent_pid": 4070,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "08f78b709ab40076",
  "parent_span_id": "6dad9ae9a8811eac",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261453521544704,
  "time_end": 1771261454181300224,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 8629,
    "process.parent_pid": 4070,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "2e0731025e9188bf",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444759648768,
  "time_end": 1771261448633255680,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "a821064c82546478",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444762386176,
  "time_end": 1771261448642801408,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "83ceaec14ae2614c",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444796243712,
  "time_end": 1771261448652545536,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "a0cab4014f92d76b",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444766857472,
  "time_end": 1771261448645199872,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "e7d925cadb5f197f",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444784317696,
  "time_end": 1771261454193777152,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "8d5a7e59c7837c1f",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444767995904,
  "time_end": 1771261448630848256,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "a66271defc6f4c68",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444754063872,
  "time_end": 1771261448650111232,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "774a4753d289347e",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1771261444769843712,
  "time_end": 1771261454197916928,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "0d4d376d652a1db5",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444769087744,
  "time_end": 1771261448640375552,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "de5dc1c4a88ce518",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444783958272,
  "time_end": 1771261454190107392,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "6192cd9ecf0c5139",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444782083584,
  "time_end": 1771261454190245376,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "e0f8bc9324ecc8f0",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1771261444753135616,
  "time_end": 1771261448625778944,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "a8f7c393e9c12305",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444739440384,
  "time_end": 1771261444839310592,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "30c50cc348555eb0",
  "parent_span_id": "e0f8bc9324ecc8f0",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1771261444867901696,
  "time_end": 1771261448624589568,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "c27718ebe9268c01",
  "parent_span_id": "8e66447afc827256",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261449389720320,
  "time_end": 1771261449406216448,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 4781,
    "process.parent_pid": 4048,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "73b663bf726dea45",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444766172928,
  "time_end": 1771261448647636736,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "69789e4b0802e9b7",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444749098752,
  "time_end": 1771261448637998336,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "fa394b730b5ac3a6",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444752784640,
  "time_end": 1771261448635703552,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "c99aeb655035d292",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444752993280,
  "time_end": 1771261448628359424,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "c5e0c47019449178",
  "parent_span_id": "c93e855569e2290c",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261454944963840,
  "time_end": 1771261458427067648,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 9497,
    "process.parent_pid": 4069,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "6dad9ae9a8811eac",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444784154880,
  "time_end": 1771261454186161920,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "8e66447afc827256",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444786306048,
  "time_end": 1771261449411312896,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
  "trace_id": "3993fcea0e5f005b36fc11b9dfd36d5d",
  "span_id": "c93e855569e2290c",
  "parent_span_id": "213fde0e0e15bcf2",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1771261444791021568,
  "time_end": 1771261458431355392,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/840c9adb-d9de-4cec-9e20-b70219039c7c/resourceGroups/azure-centralus-general-840c9adb-d9de-4cec-9e20-b70219039c7c/providers/Microsoft.Compute/virtualMachines/15Q5YbbOtsozXZ",
    "host.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "host.name": "15Q5YbbOtsozXZ",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "eeaf3ebc-2544-4793-81e7-93e2bd547ea7",
    "process.pid": 2762,
    "process.parent_pid": 2564,
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
