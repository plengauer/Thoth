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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "a6927e52288d7a4c",
  "parent_span_id": "c6621dd51699a797",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790363996587095296,
  "time_end": 1790363997382052608,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.113.6",
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
      "00-ac465ce6bce9fb80a4ceb2b737965741-c6621dd51699a797-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 25 Sep 2026 19:19:57 GMT"
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
      "W/\"c7e5b9bddc2821a534b7834c72166ed98628f4f305a1de283611b2a01306b6e9\""
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
      "1790364644"
    ],
    "http.response.header.x-github-request-id": [
      "5431:324B71:B1BA62:24849A9:6AB6C95C"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "f6fa0188-15d2-4877-9ccc-cd8db105e157",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5489,
    "process.parent_pid": 4192,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "1e2e108d3ee568a0",
  "parent_span_id": "1270179e7cc61a9e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790363997728707328,
  "time_end": 1790363998427966464,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.113.6",
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
      "00-ac465ce6bce9fb80a4ceb2b737965741-1270179e7cc61a9e-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 25 Sep 2026 19:19:58 GMT"
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
      "W/\"18392e73234de9f6289fa74e10a9aec0a6269bb7366d91acbc839dcab741c547\""
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
      "1790364644"
    ],
    "http.response.header.x-github-request-id": [
      "5433:132D1E:B4442D:24FAE57:6AB6C95D"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "9d454bb9-0bab-424d-a0a5-229d45b9b612",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7032,
    "process.parent_pid": 4192,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "14df53102bfd581a",
  "parent_span_id": "e333a048d7a867fe",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790363998793571840,
  "time_end": 1790363999522418944,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.113.6",
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
      "00-ac465ce6bce9fb80a4ceb2b737965741-e333a048d7a867fe-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 25 Sep 2026 19:19:59 GMT"
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
      "W/\"ee54d37f16fe448d30985db255e94ccdd8c00807328d126de1e19565dcbdb3cb\""
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
      "1790364644"
    ],
    "http.response.header.x-github-request-id": [
      "5434:E037F:AFB7D3:24322CE:6AB6C95E"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "5641ee15-283c-49ce-899b-baba82d165ee",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8003,
    "process.parent_pid": 4192,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "6a1bd91bfa310080",
  "parent_span_id": "64dc3fb493f1c39d",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790363999866598400,
  "time_end": 1790364000553003520,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.113.6",
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
      "00-ac465ce6bce9fb80a4ceb2b737965741-64dc3fb493f1c39d-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 25 Sep 2026 19:20:00 GMT"
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
      "W/\"93c24e5862ab0b5f2c7a4ded57febae11feead05ab7100bd8068da9a0ee3d65b\""
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
      "1790364644"
    ],
    "http.response.header.x-github-request-id": [
      "5432:1D2F68:B69B45:257F53C:6AB6C95F"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "e64f8cb7-9039-48d5-b316-fbf2481e334a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8973,
    "process.parent_pid": 4192,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "ee9b0512865850f8",
  "parent_span_id": "07e066045553c8ce",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790364001085741056,
  "time_end": 1790364002152115456,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "a913d13c-3122-40a2-b398-325666f5e6ea",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9537,
    "process.parent_pid": 4184,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "3aa70ede1c65b7c7",
  "parent_span_id": "07e066045553c8ce",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790364001219643648,
  "time_end": 1790364002240834304,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-25T20%3A15%3A26Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-25T19%3A15%3A07Z&ske=2026-09-25T20%3A15%3A26Z&sks=b&skv=2018-11-09&sig=J0jNweFOicC5kI6nh4cLnxU4e%2BuEm10TpbxCp4k%2BYaQ%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MDM2NDMwMSwibmJmIjoxNzkwMzY0MDAxLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.Wppi9se3ayuDmcyM0Jss3pdxzgFdl-jtjyESHdc5qaM&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-25T20%3A15%3A26Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-25T19%3A15%3A07Z&ske=2026-09-25T20%3A15%3A26Z&sks=b&skv=2018-11-09&sig=J0jNweFOicC5kI6nh4cLnxU4e%2BuEm10TpbxCp4k%2BYaQ%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MDM2NDMwMSwibmJmIjoxNzkwMzY0MDAxLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.Wppi9se3ayuDmcyM0Jss3pdxzgFdl-jtjyESHdc5qaM&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "a913d13c-3122-40a2-b398-325666f5e6ea",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9537,
    "process.parent_pid": 4184,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "3dda5a26ff4a634d",
  "parent_span_id": "07e066045553c8ce",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790364002151737856,
  "time_end": 1790364002335329280,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "a913d13c-3122-40a2-b398-325666f5e6ea",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9537,
    "process.parent_pid": 4184,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "270971b1d3b424f0",
  "parent_span_id": "07e066045553c8ce",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790364002280384512,
  "time_end": 1790364002419981312,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-25T20%3A17%3A37Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-25T19%3A17%3A37Z&ske=2026-09-25T20%3A17%3A37Z&sks=b&skv=2018-11-09&sig=fyCob7dWyLTWBHngV4sPuD7ywwKf2YB5F796S4SUk0A%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MDM2NDMwMiwibmJmIjoxNzkwMzY0MDAyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.-ElWA8mhlKJk9nK5dCCZZXFblEKxPrlBfa42suP7YmE&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-25T20%3A17%3A37Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-25T19%3A17%3A37Z&ske=2026-09-25T20%3A17%3A37Z&sks=b&skv=2018-11-09&sig=fyCob7dWyLTWBHngV4sPuD7ywwKf2YB5F796S4SUk0A%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MDM2NDMwMiwibmJmIjoxNzkwMzY0MDAyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.-ElWA8mhlKJk9nK5dCCZZXFblEKxPrlBfa42suP7YmE&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "a913d13c-3122-40a2-b398-325666f5e6ea",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9537,
    "process.parent_pid": 4184,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "ef0049d8237f0231",
  "parent_span_id": "07e066045553c8ce",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790364002353186048,
  "time_end": 1790364002561346816,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "a913d13c-3122-40a2-b398-325666f5e6ea",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9537,
    "process.parent_pid": 4184,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "fd02d2a265709b0b",
  "parent_span_id": "07e066045553c8ce",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790364002510249728,
  "time_end": 1790364002589101824,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-25T20%3A16%3A17Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-25T19%3A15%3A25Z&ske=2026-09-25T20%3A16%3A17Z&sks=b&skv=2018-11-09&sig=gU3rM1NEtSgXGcuebyh2L%2BgevCmfOCg77tChYFPkPpg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MDM2NDMwMiwibmJmIjoxNzkwMzY0MDAyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.-ElWA8mhlKJk9nK5dCCZZXFblEKxPrlBfa42suP7YmE&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-25T20%3A16%3A17Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-25T19%3A15%3A25Z&ske=2026-09-25T20%3A16%3A17Z&sks=b&skv=2018-11-09&sig=gU3rM1NEtSgXGcuebyh2L%2BgevCmfOCg77tChYFPkPpg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MDM2NDMwMiwibmJmIjoxNzkwMzY0MDAyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.-ElWA8mhlKJk9nK5dCCZZXFblEKxPrlBfa42suP7YmE&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "a913d13c-3122-40a2-b398-325666f5e6ea",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9537,
    "process.parent_pid": 4184,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "6013d59575e0affd",
  "parent_span_id": "67bf629069a7b901",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1790363991600062720,
  "time_end": 1790363995227654400,
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
      "Fri, 25 Sep 2026 19:19:52 GMT"
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
      "W/\"0b35e61392c137611a51d6acbc32e9c2f3df5689e44af66128157f002a29b686\""
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
      "1790364644"
    ],
    "http.response.header.x-github-request-id": [
      "5430:1258CD:C56539:2A1795E:6AB6C957"
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "e55a52db3677fecf",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1790363991330898432,
  "time_end": 1790364002593259264,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "c6621dd51699a797",
  "parent_span_id": "860f803e25a6cc79",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363996497070592,
  "time_end": 1790363997427491584,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "f6fa0188-15d2-4877-9ccc-cd8db105e157",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5489,
    "process.parent_pid": 4192,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "1270179e7cc61a9e",
  "parent_span_id": "860f803e25a6cc79",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363997655652352,
  "time_end": 1790363998474637312,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "9d454bb9-0bab-424d-a0a5-229d45b9b612",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7032,
    "process.parent_pid": 4192,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "e333a048d7a867fe",
  "parent_span_id": "860f803e25a6cc79",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363998705203712,
  "time_end": 1790363999567460608,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "5641ee15-283c-49ce-899b-baba82d165ee",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8003,
    "process.parent_pid": 4192,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "64dc3fb493f1c39d",
  "parent_span_id": "860f803e25a6cc79",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363999792065024,
  "time_end": 1790364000599811584,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "e64f8cb7-9039-48d5-b316-fbf2481e334a",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8973,
    "process.parent_pid": 4192,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "e8b8e5f3cb447252",
  "parent_span_id": "e55a52db3677fecf",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991363043584,
  "time_end": 1790363995228873984,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "56de2f7a4b4e0cad",
  "parent_span_id": "e55a52db3677fecf",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991350039296,
  "time_end": 1790363995233052416,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "f15946abf3c2a1ae",
  "parent_span_id": "e55a52db3677fecf",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991369996032,
  "time_end": 1790363995237378048,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "5d23deacbcd9e281",
  "parent_span_id": "e55a52db3677fecf",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991352771072,
  "time_end": 1790363995234193920,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "6663c23d1a46f2e5",
  "parent_span_id": "e55a52db3677fecf",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991377957376,
  "time_end": 1790364000606514688,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "6cdc2c3f257dba46",
  "parent_span_id": "e55a52db3677fecf",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991344524800,
  "time_end": 1790363995227774720,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "81cf25e9c9e8f080",
  "parent_span_id": "e55a52db3677fecf",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991365567232,
  "time_end": 1790363995236366336,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "14b9bcbfe300e449",
  "parent_span_id": "e55a52db3677fecf",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1790363991366245376,
  "time_end": 1790364000607912448,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "4846341aa48d68bc",
  "parent_span_id": "e55a52db3677fecf",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991364248832,
  "time_end": 1790363995232043008,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "2d84109069fbd60b",
  "parent_span_id": "e55a52db3677fecf",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991366144256,
  "time_end": 1790364000311474688,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "89726a72e8686fd2",
  "parent_span_id": "e55a52db3677fecf",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991358787584,
  "time_end": 1790364000604610304,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "90682fc47eac8ea5",
  "parent_span_id": "e55a52db3677fecf",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1790363991342913792,
  "time_end": 1790363995227727360,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "1156cefa4efca4cb",
  "parent_span_id": "e55a52db3677fecf",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991358652160,
  "time_end": 1790363991400995584,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "67bf629069a7b901",
  "parent_span_id": "90682fc47eac8ea5",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1790363991403440896,
  "time_end": 1790363995227678720,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "11d939beff940623",
  "parent_span_id": "34471191fc5f0fe5",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363995851858176,
  "time_end": 1790363995860633344,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "47453d99-4013-48a6-a019-c026ee3c845b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4891,
    "process.parent_pid": 4187,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "7adcbcd495e437c6",
  "parent_span_id": "e55a52db3677fecf",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991365987584,
  "time_end": 1790363995235290624,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "da2cf40c63eb653c",
  "parent_span_id": "e55a52db3677fecf",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991342258176,
  "time_end": 1790363995231026432,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "540b9965ec88d5ae",
  "parent_span_id": "e55a52db3677fecf",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991348017152,
  "time_end": 1790363995229982976,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "b760be88ccc931f1",
  "parent_span_id": "e55a52db3677fecf",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991344348416,
  "time_end": 1790363995227750912,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "07e066045553c8ce",
  "parent_span_id": "6f0ac939f5e02509",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790364000991314432,
  "time_end": 1790364002591193344,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "a913d13c-3122-40a2-b398-325666f5e6ea",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9537,
    "process.parent_pid": 4184,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "860f803e25a6cc79",
  "parent_span_id": "e55a52db3677fecf",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991365697792,
  "time_end": 1790364000601302528,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "34471191fc5f0fe5",
  "parent_span_id": "e55a52db3677fecf",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991374757120,
  "time_end": 1790363995862359296,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
  "trace_id": "ac465ce6bce9fb80a4ceb2b737965741",
  "span_id": "6f0ac939f5e02509",
  "parent_span_id": "e55a52db3677fecf",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1790363991365790720,
  "time_end": 1790364002592218112,
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
    "telemetry.sdk.version": "5.62.1",
    "service.instance.id": "4f468a66-5c16-4d01-bf49-c508649b2d09",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/38f3619c-c663-4549-b587-f4ea34f3cdc8/resourceGroups/azure-northcentralus-general-38f3619c-c663-4549-b587-f4ea34f3cdc8/providers/Microsoft.Compute/virtualMachines/VB1vZTJYzEWsvE",
    "host.id": "b222703f-c1f9-4dd0-99bb-9b613f0bedc6",
    "host.name": "VB1vZTJYzEWsvE",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3048,
    "process.parent_pid": 2849,
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
