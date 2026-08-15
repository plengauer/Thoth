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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "f7c9c29670cc8016",
  "parent_span_id": "f708a8b684999aac",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793735051405568,
  "time_end": 1786793735919476992,
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
      "00-d05a3de13e43cd97dda53602ad9e1ad0-f708a8b684999aac-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 15 Aug 2026 11:35:35 GMT"
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
      "W/\"f87a5b8a7bf216a45bb53331d4c10eb493555ebad035b5b75ad5a1c19b9b3129\""
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
      "55"
    ],
    "http.response.header.x-ratelimit-used": [
      "5"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1786795173"
    ],
    "http.response.header.x-github-request-id": [
      "382A:2CA30A:19BCC:55D60:6A804F07"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "29ab36ad-b1d6-44bc-a8e7-a47a69b5a6a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5366,
    "process.parent_pid": 4080,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "85bd21cfd5a6dabe",
  "parent_span_id": "f9207fe8ca250496",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793736297185792,
  "time_end": 1786793737034974208,
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
      "00-d05a3de13e43cd97dda53602ad9e1ad0-f9207fe8ca250496-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 15 Aug 2026 11:35:36 GMT"
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
      "W/\"5e3fe2dfc0d29b5c16034f0f6df4dc190bebe673a8685b45a5aa3daa459e41be\""
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
      "54"
    ],
    "http.response.header.x-ratelimit-used": [
      "6"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1786795173"
    ],
    "http.response.header.x-github-request-id": [
      "382B:DA876:1A43D:56F58:6A804F08"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "d6051fd5-829e-4928-996a-d5e42a8f3730",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 6909,
    "process.parent_pid": 4080,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "c6c79f58c5403c46",
  "parent_span_id": "b2d677668dfaf5af",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793737395011072,
  "time_end": 1786793738046025216,
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
      "00-d05a3de13e43cd97dda53602ad9e1ad0-b2d677668dfaf5af-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 15 Aug 2026 11:35:37 GMT"
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
      "W/\"b7284c8a40570bcb1ea8d22dccf1b1e7939e928cdc7a41a08edde053f4f415f9\""
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
      "53"
    ],
    "http.response.header.x-ratelimit-used": [
      "7"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1786795173"
    ],
    "http.response.header.x-github-request-id": [
      "382C:39FFDC:1A9EF:587F8:6A804F09"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "72e52bf4-fc33-4f39-a30f-87a836cf6dac",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7880,
    "process.parent_pid": 4080,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "fb8409dbcaa5179b",
  "parent_span_id": "845c8f323e22786e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793738407923456,
  "time_end": 1786793739009024256,
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
      "00-d05a3de13e43cd97dda53602ad9e1ad0-845c8f323e22786e-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 15 Aug 2026 11:35:38 GMT"
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
      "W/\"241dda0fcf499bedbe135fd837bea966eb8a0b808117a2ef77f797210e9c2a53\""
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
      "52"
    ],
    "http.response.header.x-ratelimit-used": [
      "8"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1786795173"
    ],
    "http.response.header.x-github-request-id": [
      "3829:12F97A:1983D:547FC:6A804F0A"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "9d18b613-ccaf-437b-aa7a-a45c9915f141",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8850,
    "process.parent_pid": 4080,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "99f814b1d23a8f3d",
  "parent_span_id": "7357c83c7351366e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793739785424384,
  "time_end": 1786793740815056640,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "faf6cb13-472a-441e-a3c1-828048a89498",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9820,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "4b451f46989e40f5",
  "parent_span_id": "7357c83c7351366e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793739985969408,
  "time_end": 1786793740919597056,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-15T12%3A30%3A43Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-15T11%3A29%3A50Z&ske=2026-08-15T12%3A30%3A43Z&sks=b&skv=2018-11-09&sig=V9coF5Qwp7DiiSYOMk4ELNzL36swfFWM69JlMEbks38%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4Njc5NDAzOSwibmJmIjoxNzg2NzkzNzM5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.osBg9WQivwES_fjdWTBBBzNazNT_NBN-44TwCZW9q98&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-15T12%3A30%3A43Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-15T11%3A29%3A50Z&ske=2026-08-15T12%3A30%3A43Z&sks=b&skv=2018-11-09&sig=V9coF5Qwp7DiiSYOMk4ELNzL36swfFWM69JlMEbks38%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4Njc5NDAzOSwibmJmIjoxNzg2NzkzNzM5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.osBg9WQivwES_fjdWTBBBzNazNT_NBN-44TwCZW9q98&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "faf6cb13-472a-441e-a3c1-828048a89498",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9820,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "8af17bd673116b32",
  "parent_span_id": "7357c83c7351366e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793740926963200,
  "time_end": 1786793741993755392,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "faf6cb13-472a-441e-a3c1-828048a89498",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9820,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "4a6b2a4ece175c08",
  "parent_span_id": "7357c83c7351366e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793741108805120,
  "time_end": 1786793742224093440,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-15T12%3A26%3A37Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-15T11%3A26%3A08Z&ske=2026-08-15T12%3A26%3A37Z&sks=b&skv=2018-11-09&sig=ihOqqoB0p8DMuXB3R4AjMM9kbXU3uaM3xmwa%2BAokifI%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4Njc5NDA0MSwibmJmIjoxNzg2NzkzNzQxLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.pnb7no5QHBpV480u0YdbPF07L2HK2JBEECVKP6i3U7o&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-15T12%3A26%3A37Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-15T11%3A26%3A08Z&ske=2026-08-15T12%3A26%3A37Z&sks=b&skv=2018-11-09&sig=ihOqqoB0p8DMuXB3R4AjMM9kbXU3uaM3xmwa%2BAokifI%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4Njc5NDA0MSwibmJmIjoxNzg2NzkzNzQxLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.pnb7no5QHBpV480u0YdbPF07L2HK2JBEECVKP6i3U7o&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "faf6cb13-472a-441e-a3c1-828048a89498",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9820,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "a45bcecfa22a1fc2",
  "parent_span_id": "7357c83c7351366e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793742232483584,
  "time_end": 1786793743298942464,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "faf6cb13-472a-441e-a3c1-828048a89498",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9820,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "6a963b84f36deac1",
  "parent_span_id": "7357c83c7351366e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793742395529728,
  "time_end": 1786793743324849408,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-15T12%3A13%3A04Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-15T11%3A13%3A00Z&ske=2026-08-15T12%3A13%3A04Z&sks=b&skv=2018-11-09&sig=sLSAIXTQyveweuti8H4EyDkWlxmi%2FxeqSmJpH%2BPtZQ0%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4Njc5NDA0MiwibmJmIjoxNzg2NzkzNzQyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.vTUWC1V4kujinwHyXUKD-GvkZibI8PbvFnet0zY5ptY&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-15T12%3A13%3A04Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-15T11%3A13%3A00Z&ske=2026-08-15T12%3A13%3A04Z&sks=b&skv=2018-11-09&sig=sLSAIXTQyveweuti8H4EyDkWlxmi%2FxeqSmJpH%2BPtZQ0%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4Njc5NDA0MiwibmJmIjoxNzg2NzkzNzQyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.vTUWC1V4kujinwHyXUKD-GvkZibI8PbvFnet0zY5ptY&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "faf6cb13-472a-441e-a3c1-828048a89498",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9820,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "54143178bcb2a94d",
  "parent_span_id": "28aa22214a4e82b5",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1786793730155564288,
  "time_end": 1786793733714037504,
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
      "Sat, 15 Aug 2026 11:35:30 GMT"
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
      "W/\"e4ed8f635c36c5f660710c9f543e8039f1fa4fb25a36ba8176bff73eea62a013\""
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
      "56"
    ],
    "http.response.header.x-ratelimit-used": [
      "4"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1786795173"
    ],
    "http.response.header.x-github-request-id": [
      "3828:DA876:1863D:50C23:6A804F02"
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "d5037298685475b2",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1786793729922634752,
  "time_end": 1786793743328892672,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "f708a8b684999aac",
  "parent_span_id": "33e48ae799e01947",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793734900268544,
  "time_end": 1786793735962691328,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 496,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "29ab36ad-b1d6-44bc-a8e7-a47a69b5a6a4",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5366,
    "process.parent_pid": 4080,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "f9207fe8ca250496",
  "parent_span_id": "33e48ae799e01947",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793736155121408,
  "time_end": 1786793737076888064,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 496,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "d6051fd5-829e-4928-996a-d5e42a8f3730",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 6909,
    "process.parent_pid": 4080,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "b2d677668dfaf5af",
  "parent_span_id": "33e48ae799e01947",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793737262015232,
  "time_end": 1786793738088845312,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 496,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "72e52bf4-fc33-4f39-a30f-87a836cf6dac",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7880,
    "process.parent_pid": 4080,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "845c8f323e22786e",
  "parent_span_id": "33e48ae799e01947",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793738275990528,
  "time_end": 1786793739052334592,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 496,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "9d18b613-ccaf-437b-aa7a-a45c9915f141",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8850,
    "process.parent_pid": 4080,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "93ff4b447bb6f611",
  "parent_span_id": "d5037298685475b2",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729954558464,
  "time_end": 1786793733714240256,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "8078cf6d3a3886cb",
  "parent_span_id": "d5037298685475b2",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729936592896,
  "time_end": 1786793733718251008,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "c95dc267429907c0",
  "parent_span_id": "d5037298685475b2",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729944207104,
  "time_end": 1786793733722305792,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "b4dcbaac9feb8df3",
  "parent_span_id": "d5037298685475b2",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729949402112,
  "time_end": 1786793733719341312,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "56ade9a1e25837c5",
  "parent_span_id": "d5037298685475b2",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729949668096,
  "time_end": 1786793739057550848,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "01d1d664b8baf730",
  "parent_span_id": "d5037298685475b2",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729949495040,
  "time_end": 1786793733714208256,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "47e4702f85cf5cc9",
  "parent_span_id": "d5037298685475b2",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729948963584,
  "time_end": 1786793733721345792,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "808ef3b5be2c3fe2",
  "parent_span_id": "d5037298685475b2",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729949591296,
  "time_end": 1786793739058861568,
  "attributes": {
    "shell.command_line": "grep _1.",
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "32ee173d712420ec",
  "parent_span_id": "d5037298685475b2",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729943958528,
  "time_end": 1786793733717286912,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "58eea7db43e64025",
  "parent_span_id": "d5037298685475b2",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729974718976,
  "time_end": 1786793739057525760,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "1afd4407cb89cd5a",
  "parent_span_id": "d5037298685475b2",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729949080320,
  "time_end": 1786793739055807232,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "0e1b7c092201c0ca",
  "parent_span_id": "d5037298685475b2",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1786793729943824896,
  "time_end": 1786793733714132736,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "ef7209f2b5846e9c",
  "parent_span_id": "d5037298685475b2",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729934550784,
  "time_end": 1786793729964414720,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "28aa22214a4e82b5",
  "parent_span_id": "0e1b7c092201c0ca",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1786793729983866112,
  "time_end": 1786793733714076416,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "473d29932c26ad61",
  "parent_span_id": "ee20da4589744e36",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793734324489472,
  "time_end": 1786793734332295936,
  "attributes": {
    "shell.command_line": "seq 1 4",
    "shell.command": "seq",
    "shell.command.type": "file",
    "shell.command.name": "seq",
    "subprocess.executable.path": "/usr/bin/seq",
    "subprocess.executable.name": "seq",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 496,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "6c370bb3-21f6-43e4-aec2-9c89c1cf4cf5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4768,
    "process.parent_pid": 4057,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "dddfabc1d90a1a74",
  "parent_span_id": "d5037298685475b2",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729944049408,
  "time_end": 1786793733720342528,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "af4cf68184b14e54",
  "parent_span_id": "d5037298685475b2",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729944122368,
  "time_end": 1786793733716336384,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "643c51a275e67ce1",
  "parent_span_id": "d5037298685475b2",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729943648768,
  "time_end": 1786793733714916352,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "052c9bb37024ba55",
  "parent_span_id": "d5037298685475b2",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729931552256,
  "time_end": 1786793733714169088,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "7357c83c7351366e",
  "parent_span_id": "e813096517d2e4d1",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793739629731072,
  "time_end": 1786793743326070784,
  "attributes": {
    "shell.command_line": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
    "shell.command": "wget",
    "shell.command.type": "file",
    "shell.command.name": "wget",
    "subprocess.executable.path": "/usr/bin/wget",
    "subprocess.executable.name": "wget",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 496,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "faf6cb13-472a-441e-a3c1-828048a89498",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9820,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "33e48ae799e01947",
  "parent_span_id": "d5037298685475b2",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729949323264,
  "time_end": 1786793739053862912,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "ee20da4589744e36",
  "parent_span_id": "d5037298685475b2",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729949233152,
  "time_end": 1786793734334077696,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
  "trace_id": "d05a3de13e43cd97dda53602ad9e1ad0",
  "span_id": "e813096517d2e4d1",
  "parent_span_id": "d5037298685475b2",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1786793729964641024,
  "time_end": 1786793743327854336,
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
    "telemetry.sdk.version": "5.61.0",
    "service.instance.id": "b1a40a79-e851-4870-a720-29a2d9297326",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/62149a32-202c-421e-969a-a2e515e8b1c7/resourceGroups/azure-westus3-general-62149a32-202c-421e-969a-a2e515e8b1c7/providers/Microsoft.Compute/virtualMachines/doVqASBwqkMms9",
    "host.id": "1013cfb9-b02f-4404-9c06-173b7b60b0d8",
    "host.name": "doVqASBwqkMms9",
    "host.type": "Standard_D4ds_v6",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2925,
    "process.parent_pid": 2724,
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
