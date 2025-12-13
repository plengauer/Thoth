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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "383e0df36bda5b26",
  "parent_span_id": "97ab7efce661d1ca",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1765503629783582720,
  "time_end": 1765503630330763520,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.112.6",
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
      "00-26a0f2820046584e1bc30cb521502c5d-97ab7efce661d1ca-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 12 Dec 2025 01:40:30 GMT"
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
      "W/\"f06f396839b51cd720c41d3283640509427bef16d33ffc87d9c25951f372bfda\""
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
      "1765503819"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "3"
    ],
    "http.response.header.x-github-request-id": [
      "1029:27D044:10248A:4585C1:693B728D"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 5366,
    "process.parent_pid": 3997,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "331bc7675edfcf9e",
  "parent_span_id": "0d93cebccdd4dee4",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1765503630672813312,
  "time_end": 1765503631282901248,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.112.6",
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
      "00-26a0f2820046584e1bc30cb521502c5d-0d93cebccdd4dee4-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 12 Dec 2025 01:40:31 GMT"
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
      "W/\"27c7571f4f50d426b620a6cbeabf42d5325256ad1f3a3cb41eca144b6d350083\""
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
      "1765503819"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "4"
    ],
    "http.response.header.x-github-request-id": [
      "102A:C56EC:F43CF:4119E9:693B728E"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 6815,
    "process.parent_pid": 3997,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "4d58e2da93bb1356",
  "parent_span_id": "19e3935d38f6b898",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1765503631628675328,
  "time_end": 1765503632195951360,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.112.6",
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
      "00-26a0f2820046584e1bc30cb521502c5d-19e3935d38f6b898-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 12 Dec 2025 01:40:31 GMT"
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
      "W/\"a3ebde1f0de4e82a72068621995902de006ddb3b531e7b86917fd9042163c23d\""
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
      "1765503819"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "5"
    ],
    "http.response.header.x-github-request-id": [
      "102B:3E10D:EF94A:40401D:693B728F"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 7679,
    "process.parent_pid": 3997,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "3e9f84a6429b42a0",
  "parent_span_id": "841dad47f33faec5",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1765503632541271808,
  "time_end": 1765503633005437440,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.112.6",
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
      "00-26a0f2820046584e1bc30cb521502c5d-841dad47f33faec5-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 12 Dec 2025 01:40:32 GMT"
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
      "W/\"7a5a25aaa8d3adb3983843b22da1cb6fa4babc94e222befb3adda0aeb60ac63f\""
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
      "1765503819"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "6"
    ],
    "http.response.header.x-github-request-id": [
      "102C:1FADAD:F86B5:42A7EF:693B7290"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 8543,
    "process.parent_pid": 3997,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "a31c62cc2c407e6a",
  "parent_span_id": "caa1c7e5a0e3d110",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1765503633773581824,
  "time_end": 1765503633878560768,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 9410,
    "process.parent_pid": 3977,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "9ffa40c2479ffe68",
  "parent_span_id": "caa1c7e5a0e3d110",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1765503633875236096,
  "time_end": 1765503633923271936,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.109.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-12T02%3A24%3A55Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-12T01%3A24%3A10Z&ske=2025-12-12T02%3A24%3A55Z&sks=b&skv=2018-11-09&sig=G1971lqaBoE1WUY%2BLq9lBLnUPJQX2pESE048JGof0yg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NTUwMzkzMywibmJmIjoxNzY1NTAzNjMzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ._aaJnAhT3fKCo3NApdjSdotdKjWJn4C31vmnRo14E2M&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-12T02%3A24%3A55Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-12T01%3A24%3A10Z&ske=2025-12-12T02%3A24%3A55Z&sks=b&skv=2018-11-09&sig=G1971lqaBoE1WUY%2BLq9lBLnUPJQX2pESE048JGof0yg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NTUwMzkzMywibmJmIjoxNzY1NTAzNjMzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ._aaJnAhT3fKCo3NApdjSdotdKjWJn4C31vmnRo14E2M&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 9410,
    "process.parent_pid": 3977,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "635832e7611b38ec",
  "parent_span_id": "caa1c7e5a0e3d110",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1765503633909100544,
  "time_end": 1765503634036262656,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 9410,
    "process.parent_pid": 3977,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "1b0171889d8b2cb0",
  "parent_span_id": "caa1c7e5a0e3d110",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1765503634029536512,
  "time_end": 1765503634072411392,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.109.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-12T02%3A27%3A37Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-12T01%3A27%3A01Z&ske=2025-12-12T02%3A27%3A37Z&sks=b&skv=2018-11-09&sig=a645zOm3VqGfBWPyim%2BdwQKUjynmKDVqHpq%2BqNtwpCw%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NTUwMzkzNCwibmJmIjoxNzY1NTAzNjM0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ._O6F7Bcg6JtQJAv6buzxh2HrM6HCE6FAZOQ_HWsIb04&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-12T02%3A27%3A37Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-12T01%3A27%3A01Z&ske=2025-12-12T02%3A27%3A37Z&sks=b&skv=2018-11-09&sig=a645zOm3VqGfBWPyim%2BdwQKUjynmKDVqHpq%2BqNtwpCw%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NTUwMzkzNCwibmJmIjoxNzY1NTAzNjM0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ._O6F7Bcg6JtQJAv6buzxh2HrM6HCE6FAZOQ_HWsIb04&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 9410,
    "process.parent_pid": 3977,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "c1e8e4ae42975c7b",
  "parent_span_id": "caa1c7e5a0e3d110",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1765503634057165312,
  "time_end": 1765503634152524800,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 9410,
    "process.parent_pid": 3977,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "a1ee4a2730db0d4a",
  "parent_span_id": "caa1c7e5a0e3d110",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1765503634145883648,
  "time_end": 1765503634173683200,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.109.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-12T02%3A26%3A59Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-12T01%3A26%3A19Z&ske=2025-12-12T02%3A26%3A59Z&sks=b&skv=2018-11-09&sig=ubGnbXiH37v325iA8AQmklvffynj2R9kR%2B0MGty%2FP10%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NTUwMzkzNCwibmJmIjoxNzY1NTAzNjM0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ._O6F7Bcg6JtQJAv6buzxh2HrM6HCE6FAZOQ_HWsIb04&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-12T02%3A26%3A59Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-12T01%3A26%3A19Z&ske=2025-12-12T02%3A26%3A59Z&sks=b&skv=2018-11-09&sig=ubGnbXiH37v325iA8AQmklvffynj2R9kR%2B0MGty%2FP10%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NTUwMzkzNCwibmJmIjoxNzY1NTAzNjM0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ._O6F7Bcg6JtQJAv6buzxh2HrM6HCE6FAZOQ_HWsIb04&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 9410,
    "process.parent_pid": 3977,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "693e66d197e4f01a",
  "parent_span_id": "6f15fd20dc593c16",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1765503624868397568,
  "time_end": 1765503628312780800,
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
      "Fri, 12 Dec 2025 01:40:25 GMT"
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
      "W/\"badb188a26709ecaeb05c4ab62101bb4945da9c028b37ab38436689fefc4867a\""
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
      "1765503819"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "2"
    ],
    "http.response.header.x-github-request-id": [
      "1028:1A7DEA:EDA07:3FB966:693B7288"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "88857fb7fdb49342",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1765503624550852608,
  "time_end": 1765503634183120384,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "97ab7efce661d1ca",
  "parent_span_id": "c55688eaa42c9a42",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503629716392192,
  "time_end": 1765503630334564864,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 5366,
    "process.parent_pid": 3997,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "0d93cebccdd4dee4",
  "parent_span_id": "c55688eaa42c9a42",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503630609858048,
  "time_end": 1765503631286880768,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 6815,
    "process.parent_pid": 3997,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "19e3935d38f6b898",
  "parent_span_id": "c55688eaa42c9a42",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503631566122240,
  "time_end": 1765503632200037376,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 7679,
    "process.parent_pid": 3997,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "841dad47f33faec5",
  "parent_span_id": "c55688eaa42c9a42",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503632477876480,
  "time_end": 1765503633009309184,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 8543,
    "process.parent_pid": 3997,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "7ace550425b4e0da",
  "parent_span_id": "88857fb7fdb49342",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624592405248,
  "time_end": 1765503628322861568,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "4a14b0c885cbf0f8",
  "parent_span_id": "88857fb7fdb49342",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624575244288,
  "time_end": 1765503628331474176,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "c253a602a0b9c74e",
  "parent_span_id": "88857fb7fdb49342",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624592587776,
  "time_end": 1765503628340127488,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "88e85e6be639dc11",
  "parent_span_id": "88857fb7fdb49342",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624599272704,
  "time_end": 1765503628333569024,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "e1b00cd8ae135680",
  "parent_span_id": "88857fb7fdb49342",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624588665856,
  "time_end": 1765503633019692288,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "0e3768f9b9345f63",
  "parent_span_id": "88857fb7fdb49342",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624586234624,
  "time_end": 1765503628320734720,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "653a4de8ab2c1e26",
  "parent_span_id": "88857fb7fdb49342",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624601289984,
  "time_end": 1765503628337958400,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "3d9606649c6ae5de",
  "parent_span_id": "88857fb7fdb49342",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1765503624599452416,
  "time_end": 1765503633022813696,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "3a4c6e72a154495e",
  "parent_span_id": "88857fb7fdb49342",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624581342464,
  "time_end": 1765503628329358336,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "fa1eac42f197bf8e",
  "parent_span_id": "88857fb7fdb49342",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624592262912,
  "time_end": 1765503633015848192,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "d89bf3bce796b284",
  "parent_span_id": "88857fb7fdb49342",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624593625856,
  "time_end": 1765503633016688896,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "32d6200b6442e6cb",
  "parent_span_id": "88857fb7fdb49342",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1765503624573110784,
  "time_end": 1765503628316260864,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "38dede2cd71b58c5",
  "parent_span_id": "88857fb7fdb49342",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624577955328,
  "time_end": 1765503624661479936,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "6f15fd20dc593c16",
  "parent_span_id": "32d6200b6442e6cb",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1765503624671516160,
  "time_end": 1765503628312840704,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "1363358c7afe60ef",
  "parent_span_id": "b0c62f0059f8863b",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503629015293696,
  "time_end": 1765503629029746176,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 4697,
    "process.parent_pid": 3945,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "74f3a68750830068",
  "parent_span_id": "88857fb7fdb49342",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624592718592,
  "time_end": 1765503628335690752,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "f747b95ba51823d5",
  "parent_span_id": "88857fb7fdb49342",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624588990976,
  "time_end": 1765503628327210240,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "1990dc972e6d6a5b",
  "parent_span_id": "88857fb7fdb49342",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624584020992,
  "time_end": 1765503628324983040,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "d48dbde55ca8d48e",
  "parent_span_id": "88857fb7fdb49342",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624566658560,
  "time_end": 1765503628318439680,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "caa1c7e5a0e3d110",
  "parent_span_id": "a6273a064d8ea5c5",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503633704537344,
  "time_end": 1765503634177785344,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 9410,
    "process.parent_pid": 3977,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "c55688eaa42c9a42",
  "parent_span_id": "88857fb7fdb49342",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624595327232,
  "time_end": 1765503633013256192,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "b0c62f0059f8863b",
  "parent_span_id": "88857fb7fdb49342",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624590551040,
  "time_end": 1765503629034006272,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
  "trace_id": "26a0f2820046584e1bc30cb521502c5d",
  "span_id": "a6273a064d8ea5c5",
  "parent_span_id": "88857fb7fdb49342",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1765503624593499392,
  "time_end": 1765503634182304000,
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
    "telemetry.sdk.version": "5.37.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus2",
    "cloud.resource_id": "/subscriptions/7d54d716-fbcd-46a4-bc44-2bc4227140d9/resourceGroups/azure-eastus2-general-7d54d716-fbcd-46a4-bc44-2bc4227140d9/providers/Microsoft.Compute/virtualMachines/oFsVbXxJ3RFURs",
    "host.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "host.name": "oFsVbXxJ3RFURs",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "686979cd-ccf8-4cfb-977d-16cb3de6ce15",
    "process.pid": 2680,
    "process.parent_pid": 2479,
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
