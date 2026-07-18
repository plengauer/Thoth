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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "5617a6bdcabfdce9",
  "parent_span_id": "f4492a6f051439d5",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783277585648633856,
  "time_end": 1783277586692596224,
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
      "00-1e6bf06a39c5ec68915ee1dd04adfe35-f4492a6f051439d5-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 05 Jul 2026 18:53:06 GMT"
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
      "W/\"7487a4ecf4ca632ab0b919e72edd08a098794b66d9751f5cad45d75049970d0e\""
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
      "1783278600"
    ],
    "http.response.header.x-github-request-id": [
      "9411:2548E:30A8B7E:AD1F5C8:6A4AA811"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "fdbd10ef-a205-4fa2-aebe-76b249e9491c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 5431,
    "process.parent_pid": 4120,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "550db85a826eba38",
  "parent_span_id": "d6e6b3daac058729",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783277587059444736,
  "time_end": 1783277587839660288,
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
      "00-1e6bf06a39c5ec68915ee1dd04adfe35-d6e6b3daac058729-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 05 Jul 2026 18:53:07 GMT"
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
      "W/\"0f0527f59e63d42b2546d36b583d36e94efd05daa6288a5f39c2f3ba5bf9883a\""
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
      "1783278600"
    ],
    "http.response.header.x-github-request-id": [
      "9412:139C25:32A9781:B482EF1:6A4AA813"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "0b87d2d3-6c98-410c-98ef-3379974bd9e2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 6992,
    "process.parent_pid": 4120,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "60c8816dc5097325",
  "parent_span_id": "81e15dfb30ec825c",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783277588206954752,
  "time_end": 1783277588892953856,
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
      "00-1e6bf06a39c5ec68915ee1dd04adfe35-81e15dfb30ec825c-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 05 Jul 2026 18:53:08 GMT"
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
      "W/\"766fc8c8a3e525094e2d1a33b2cbde5a1dbe8cbb6c420d872dbd5f6bcfd8e52c\""
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
      "1783278600"
    ],
    "http.response.header.x-github-request-id": [
      "9413:1C82D7:30B35EF:AD3D5C4:6A4AA814"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "051ec4f4-dbcd-4d43-9b05-a5b421e84a0c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 7977,
    "process.parent_pid": 4120,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "993d47a2290ff13f",
  "parent_span_id": "ae3f69afc50382b7",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783277589272694784,
  "time_end": 1783277589937293568,
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
      "00-1e6bf06a39c5ec68915ee1dd04adfe35-ae3f69afc50382b7-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 05 Jul 2026 18:53:09 GMT"
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
      "W/\"ef3e790cbe429202fc4b94d76606183989fe702ec8349192df839582ef1cf6a6\""
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
      "1783278600"
    ],
    "http.response.header.x-github-request-id": [
      "9414:2224CE:30E85F3:ADCA068:6A4AA815"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1041b834-9456-4e7d-9577-f5d44d5255f7",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 8962,
    "process.parent_pid": 4120,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "6e7419a3b024ae72",
  "parent_span_id": "6269666cc0305e79",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783277590762458880,
  "time_end": 1783277591816295936,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.112.4",
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "49891f6c-b057-4cb0-b3a5-8baa227e407b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9949,
    "process.parent_pid": 4111,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "5affcb7a2e4fa7c2",
  "parent_span_id": "6269666cc0305e79",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783277590971695616,
  "time_end": 1783277591915387392,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-07-05T19%3A44%3A55Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-07-05T18%3A44%3A41Z&ske=2026-07-05T19%3A44%3A55Z&sks=b&skv=2018-11-09&sig=WwZSppK1ZJg%2BRmKvuLTzimXU77471kMvZdDi4Oo74FE%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MzI3Nzg5MCwibmJmIjoxNzgzMjc3NTkwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.ATYulr3ei5iUWHvYtSM2rxdSYuMRxVGdXhkqiTfzfWQ&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-07-05T19%3A44%3A55Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-07-05T18%3A44%3A41Z&ske=2026-07-05T19%3A44%3A55Z&sks=b&skv=2018-11-09&sig=WwZSppK1ZJg%2BRmKvuLTzimXU77471kMvZdDi4Oo74FE%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MzI3Nzg5MCwibmJmIjoxNzgzMjc3NTkwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.ATYulr3ei5iUWHvYtSM2rxdSYuMRxVGdXhkqiTfzfWQ&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "49891f6c-b057-4cb0-b3a5-8baa227e407b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9949,
    "process.parent_pid": 4111,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "24a197ad5d7e49fa",
  "parent_span_id": "6269666cc0305e79",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783277591865121024,
  "time_end": 1783277592117200384,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.112.4",
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "49891f6c-b057-4cb0-b3a5-8baa227e407b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9949,
    "process.parent_pid": 4111,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "5bdfb8598c8aa0d5",
  "parent_span_id": "6269666cc0305e79",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783277592076634880,
  "time_end": 1783277592251240448,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-07-05T19%3A47%3A36Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-07-05T18%3A47%3A17Z&ske=2026-07-05T19%3A47%3A36Z&sks=b&skv=2018-11-09&sig=gQNi2x2mPbzb0JXDhiYglM%2BujDCf%2FmL7LqI7y4bCEs4%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MzI3Nzg5MiwibmJmIjoxNzgzMjc3NTkyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.pNOdeeAvvwaVzi-_iKGZoMK-f2ZR9msNvuvTLcgbH1I&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-07-05T19%3A47%3A36Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-07-05T18%3A47%3A17Z&ske=2026-07-05T19%3A47%3A36Z&sks=b&skv=2018-11-09&sig=gQNi2x2mPbzb0JXDhiYglM%2BujDCf%2FmL7LqI7y4bCEs4%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MzI3Nzg5MiwibmJmIjoxNzgzMjc3NTkyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.pNOdeeAvvwaVzi-_iKGZoMK-f2ZR9msNvuvTLcgbH1I&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "49891f6c-b057-4cb0-b3a5-8baa227e407b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9949,
    "process.parent_pid": 4111,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "f21230ba32e0381a",
  "parent_span_id": "6269666cc0305e79",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783277592235646208,
  "time_end": 1783277592493452800,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.112.4",
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "49891f6c-b057-4cb0-b3a5-8baa227e407b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9949,
    "process.parent_pid": 4111,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "1089014e6730dcdc",
  "parent_span_id": "6269666cc0305e79",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783277592453928704,
  "time_end": 1783277592541568256,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-07-05T19%3A29%3A11Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-07-05T18%3A28%3A52Z&ske=2026-07-05T19%3A29%3A11Z&sks=b&skv=2018-11-09&sig=a3WZN9J0haslYAd%2FtXcVdSkjJGkbXHXyMph1zUPB4XQ%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MzI3Nzg5MiwibmJmIjoxNzgzMjc3NTkyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.pNOdeeAvvwaVzi-_iKGZoMK-f2ZR9msNvuvTLcgbH1I&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-07-05T19%3A29%3A11Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-07-05T18%3A28%3A52Z&ske=2026-07-05T19%3A29%3A11Z&sks=b&skv=2018-11-09&sig=a3WZN9J0haslYAd%2FtXcVdSkjJGkbXHXyMph1zUPB4XQ%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MzI3Nzg5MiwibmJmIjoxNzgzMjc3NTkyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.pNOdeeAvvwaVzi-_iKGZoMK-f2ZR9msNvuvTLcgbH1I&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "49891f6c-b057-4cb0-b3a5-8baa227e407b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9949,
    "process.parent_pid": 4111,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "a5dd7fda2432d5eb",
  "parent_span_id": "fd80ba21325e3ca3",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1783277580607415552,
  "time_end": 1783277584276126464,
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
      "Sun, 05 Jul 2026 18:53:01 GMT"
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
      "W/\"5a81fbbf41117a07da0d95b2589e3631c078302d0341247f6cde6c8d60fcc283\""
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
      "1783278600"
    ],
    "http.response.header.x-github-request-id": [
      "9410:139C25:32A7A11:B47C5D3:6A4AA80C"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "f09f8d3366620619",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1783277580312349184,
  "time_end": 1783277592550447360,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "f4492a6f051439d5",
  "parent_span_id": "08fff0577474c84c",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277585528408832,
  "time_end": 1783277586743920128,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "fdbd10ef-a205-4fa2-aebe-76b249e9491c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 5431,
    "process.parent_pid": 4120,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "d6e6b3daac058729",
  "parent_span_id": "08fff0577474c84c",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277586940734208,
  "time_end": 1783277587890260992,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "0b87d2d3-6c98-410c-98ef-3379974bd9e2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 6992,
    "process.parent_pid": 4120,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "81e15dfb30ec825c",
  "parent_span_id": "08fff0577474c84c",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277588081127680,
  "time_end": 1783277588944692992,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "051ec4f4-dbcd-4d43-9b05-a5b421e84a0c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 7977,
    "process.parent_pid": 4120,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "ae3f69afc50382b7",
  "parent_span_id": "08fff0577474c84c",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277589144212480,
  "time_end": 1783277589988511744,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1041b834-9456-4e7d-9577-f5d44d5255f7",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 8962,
    "process.parent_pid": 4120,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "fa1b9e9382c75acc",
  "parent_span_id": "f09f8d3366620619",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580350135552,
  "time_end": 1783277584283770368,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "febb17ebc2fdc9a9",
  "parent_span_id": "f09f8d3366620619",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580342125312,
  "time_end": 1783277584291632640,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "c2387ad262db5797",
  "parent_span_id": "f09f8d3366620619",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580351544064,
  "time_end": 1783277584299478272,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "74e8058279dd9ca0",
  "parent_span_id": "f09f8d3366620619",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580348232448,
  "time_end": 1783277584293559808,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "f4257f621ffe5ca2",
  "parent_span_id": "f09f8d3366620619",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580367722752,
  "time_end": 1783277589998664704,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "4ed565f1c0245e0b",
  "parent_span_id": "f09f8d3366620619",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580347936256,
  "time_end": 1783277584281780480,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "c2e3ea6787c78fd8",
  "parent_span_id": "f09f8d3366620619",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580341894144,
  "time_end": 1783277584297508096,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "457be3130bf13e0f",
  "parent_span_id": "f09f8d3366620619",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1783277580358749696,
  "time_end": 1783277590001486592,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "e3a91dab7ceb103f",
  "parent_span_id": "f09f8d3366620619",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580354123264,
  "time_end": 1783277584289705472,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "f972e9e7e1ba291e",
  "parent_span_id": "f09f8d3366620619",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580363305728,
  "time_end": 1783277589995491584,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "10f5f9b4d63a9c45",
  "parent_span_id": "f09f8d3366620619",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580360787200,
  "time_end": 1783277589996476928,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "095728276c4c7e90",
  "parent_span_id": "f09f8d3366620619",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1783277580336570880,
  "time_end": 1783277584277649152,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "84ec9b06a2bd55e8",
  "parent_span_id": "f09f8d3366620619",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580331604224,
  "time_end": 1783277580393916928,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "fd80ba21325e3ca3",
  "parent_span_id": "095728276c4c7e90",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1783277580423782656,
  "time_end": 1783277584276150272,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "8e9e0586f26c6e3b",
  "parent_span_id": "be0e8d10919bfc00",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277584891900928,
  "time_end": 1783277584905052160,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "a566bfeb-a8e5-4490-b055-9f499deb5916",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 4827,
    "process.parent_pid": 4091,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "5655685e7ffad614",
  "parent_span_id": "f09f8d3366620619",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580353651456,
  "time_end": 1783277584295523072,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "e1551a07f556c78c",
  "parent_span_id": "f09f8d3366620619",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580342022912,
  "time_end": 1783277584287694336,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "7a90db6848a2e6a1",
  "parent_span_id": "f09f8d3366620619",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580329081088,
  "time_end": 1783277584285767936,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "c937726af1b5d9ad",
  "parent_span_id": "f09f8d3366620619",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580338379776,
  "time_end": 1783277584279749888,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "6269666cc0305e79",
  "parent_span_id": "fe37d586280d4a4a",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277590633929728,
  "time_end": 1783277592545369088,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "49891f6c-b057-4cb0-b3a5-8baa227e407b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9949,
    "process.parent_pid": 4111,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "08fff0577474c84c",
  "parent_span_id": "f09f8d3366620619",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580358539264,
  "time_end": 1783277589992528640,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "be0e8d10919bfc00",
  "parent_span_id": "f09f8d3366620619",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580348088832,
  "time_end": 1783277584909641984,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
  "trace_id": "1e6bf06a39c5ec68915ee1dd04adfe35",
  "span_id": "fe37d586280d4a4a",
  "parent_span_id": "f09f8d3366620619",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1783277580358916096,
  "time_end": 1783277592549569024,
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
    "telemetry.sdk.version": "5.59.0",
    "service.instance.id": "1b266303-0fc1-431a-adea-74629a8d6d0a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westcentralus",
    "cloud.resource_id": "/subscriptions/207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/resourceGroups/azure-westcentralus-general-207f8ae4-227d-4a7c-94b1-1e94a5ad8a8d/providers/Microsoft.Compute/virtualMachines/sTFfPzh8K6fQve",
    "host.id": "44062cb4-6cd1-4aea-b4c6-123a1351ed60",
    "host.name": "sTFfPzh8K6fQve",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 2862,
    "process.parent_pid": 2662,
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
