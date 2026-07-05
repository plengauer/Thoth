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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "20036a1023ba45f7",
  "parent_span_id": "7d00c5f1783bbf02",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678149225675520,
  "time_end": 1782678150059344128,
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
      "00-df669cf6899f02fce29084336966a1a7-7d00c5f1783bbf02-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 28 Jun 2026 20:22:29 GMT"
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
      "W/\"8817958e4e275bef152d9be7503f93940ad2cd421bf14ee2fd1e78199d9415ae\""
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
      "52"
    ],
    "http.response.header.x-ratelimit-used": [
      "8"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1782678861"
    ],
    "http.response.header.x-github-request-id": [
      "9819:28849C:3A38CD7:D2D4D36:6A418285"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "17b5b66c-af08-42f7-a875-fad3d3a45ba7",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 5583,
    "process.parent_pid": 4270,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "25898e938302bd60",
  "parent_span_id": "abaf9b359dfaaec7",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678150418482688,
  "time_end": 1782678151088448000,
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
      "00-df669cf6899f02fce29084336966a1a7-abaf9b359dfaaec7-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 28 Jun 2026 20:22:30 GMT"
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
      "W/\"05cea1f4e87111e5240e3c26f1d7897d1a78e1af3b3994ea2af158218f311773\""
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
      "51"
    ],
    "http.response.header.x-ratelimit-used": [
      "9"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1782678861"
    ],
    "http.response.header.x-github-request-id": [
      "981A:332634:39706BB:CFF9BDD:6A418286"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "3b4f52d7-5a98-4759-a208-8418df688dd0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 7144,
    "process.parent_pid": 4270,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "dda95babbbbf2d22",
  "parent_span_id": "ae3a060e95656802",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678151442520064,
  "time_end": 1782678152171016704,
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
      "00-df669cf6899f02fce29084336966a1a7-ae3a060e95656802-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 28 Jun 2026 20:22:31 GMT"
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
      "W/\"79e0cbd0e8373093832aa47f56329623d0fdb08ee18cbb11d329323d5fe5ee66\""
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
      "50"
    ],
    "http.response.header.x-ratelimit-used": [
      "10"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1782678861"
    ],
    "http.response.header.x-github-request-id": [
      "981B:CCB3A:37B1871:C9E41AB:6A418287"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "8c0407be-2c78-4cbf-b5d4-4cb906029d5c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 8128,
    "process.parent_pid": 4270,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "28a95ce85533c79a",
  "parent_span_id": "e98bfb08a78ca23a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678152520711168,
  "time_end": 1782678153099517952,
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
      "00-df669cf6899f02fce29084336966a1a7-e98bfb08a78ca23a-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 28 Jun 2026 20:22:32 GMT"
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
      "W/\"f822f4d268963f40b9fb28301889ec1eb7fc5b479b8945142cbe4f0c6dcd4284\""
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
      "49"
    ],
    "http.response.header.x-ratelimit-used": [
      "11"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1782678861"
    ],
    "http.response.header.x-github-request-id": [
      "981C:CA3FA:3AC87F3:D4FD81C:6A418288"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "853efd63-8ac8-41a9-b41d-4bb7de9ca0e8",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9112,
    "process.parent_pid": 4270,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "98c93f74ed9c24b0",
  "parent_span_id": "8de7a21b0b70ff5a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678153600119808,
  "time_end": 1782678153783628544,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "0a9f8984-ecf7-4333-bf79-d14cb5938849",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9685,
    "process.parent_pid": 4257,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "2c45509a6c973e6a",
  "parent_span_id": "8de7a21b0b70ff5a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678153723564800,
  "time_end": 1782678153879756032,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.108.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-06-28T21%3A04%3A24Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-06-28T20%3A03%3A51Z&ske=2026-06-28T21%3A04%3A24Z&sks=b&skv=2018-11-09&sig=TlW1iLKhsleTRX33380x9WkCDpjmtJ83vPFXXLi2IDg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MjY3ODQ1MywibmJmIjoxNzgyNjc4MTUzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.m_FLZD4hlzAc-t0Vanzac2lEl-vubJzyaK_ywmNVicw&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-06-28T21%3A04%3A24Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-06-28T20%3A03%3A51Z&ske=2026-06-28T21%3A04%3A24Z&sks=b&skv=2018-11-09&sig=TlW1iLKhsleTRX33380x9WkCDpjmtJ83vPFXXLi2IDg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MjY3ODQ1MywibmJmIjoxNzgyNjc4MTUzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.m_FLZD4hlzAc-t0Vanzac2lEl-vubJzyaK_ywmNVicw&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "0a9f8984-ecf7-4333-bf79-d14cb5938849",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9685,
    "process.parent_pid": 4257,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "7d56181013306059",
  "parent_span_id": "8de7a21b0b70ff5a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678153806227200,
  "time_end": 1782678153994353152,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "0a9f8984-ecf7-4333-bf79-d14cb5938849",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9685,
    "process.parent_pid": 4257,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "9977a3685a053e54",
  "parent_span_id": "8de7a21b0b70ff5a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678153930575360,
  "time_end": 1782678154091330560,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.108.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-06-28T20%3A57%3A55Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-06-28T19%3A57%3A05Z&ske=2026-06-28T20%3A57%3A55Z&sks=b&skv=2018-11-09&sig=8MzhMKAylItH35fSQ1yaLU0a2FllP8VEzBaOcq673hY%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MjY3ODQ1MywibmJmIjoxNzgyNjc4MTUzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.m_FLZD4hlzAc-t0Vanzac2lEl-vubJzyaK_ywmNVicw&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-06-28T20%3A57%3A55Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-06-28T19%3A57%3A05Z&ske=2026-06-28T20%3A57%3A55Z&sks=b&skv=2018-11-09&sig=8MzhMKAylItH35fSQ1yaLU0a2FllP8VEzBaOcq673hY%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MjY3ODQ1MywibmJmIjoxNzgyNjc4MTUzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.m_FLZD4hlzAc-t0Vanzac2lEl-vubJzyaK_ywmNVicw&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "0a9f8984-ecf7-4333-bf79-d14cb5938849",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9685,
    "process.parent_pid": 4257,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "f07a949a3a9b8249",
  "parent_span_id": "8de7a21b0b70ff5a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678153998068736,
  "time_end": 1782678154182832640,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "0a9f8984-ecf7-4333-bf79-d14cb5938849",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9685,
    "process.parent_pid": 4257,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "5aea8bc779ec5bdc",
  "parent_span_id": "8de7a21b0b70ff5a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678154120675584,
  "time_end": 1782678154224160256,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.108.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-06-28T21%3A11%3A39Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-06-28T20%3A11%3A35Z&ske=2026-06-28T21%3A11%3A39Z&sks=b&skv=2018-11-09&sig=R1GCdHof6UOTvdy2y46uGJ5J0AkYWgPAkUCqRVYhOb4%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MjY3ODQ1NCwibmJmIjoxNzgyNjc4MTU0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.Ht2RWBWEbbrD6O43JjgOBpKUtkdjQ5FAKOWMOTVSHsY&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-06-28T21%3A11%3A39Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-06-28T20%3A11%3A35Z&ske=2026-06-28T21%3A11%3A39Z&sks=b&skv=2018-11-09&sig=R1GCdHof6UOTvdy2y46uGJ5J0AkYWgPAkUCqRVYhOb4%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MjY3ODQ1NCwibmJmIjoxNzgyNjc4MTU0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.Ht2RWBWEbbrD6O43JjgOBpKUtkdjQ5FAKOWMOTVSHsY&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "0a9f8984-ecf7-4333-bf79-d14cb5938849",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9685,
    "process.parent_pid": 4257,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "fdbf801ca4c73673",
  "parent_span_id": "7cfe03cef2e91473",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1782678144209469184,
  "time_end": 1782678147892049920,
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
      "Sun, 28 Jun 2026 20:22:24 GMT"
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
      "W/\"1645ad4e9d31ec31a453b9b55efbf9d3e5048b5e3fca04a43a838434e037da23\""
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
      "1782678861"
    ],
    "http.response.header.x-github-request-id": [
      "9818:F16DB:3A3463D:D2C6619:6A418280"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "6053289123c641bf",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1782678143932579072,
  "time_end": 1782678154232807680,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "7d00c5f1783bbf02",
  "parent_span_id": "356de7d8935f8ad6",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678149155126016,
  "time_end": 1782678150112212224,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "17b5b66c-af08-42f7-a875-fad3d3a45ba7",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 5583,
    "process.parent_pid": 4270,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "abaf9b359dfaaec7",
  "parent_span_id": "356de7d8935f8ad6",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678150341144832,
  "time_end": 1782678151144045056,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "3b4f52d7-5a98-4759-a208-8418df688dd0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 7144,
    "process.parent_pid": 4270,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "ae3a060e95656802",
  "parent_span_id": "356de7d8935f8ad6",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678151375006976,
  "time_end": 1782678152226181120,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "8c0407be-2c78-4cbf-b5d4-4cb906029d5c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 8128,
    "process.parent_pid": 4270,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "e98bfb08a78ca23a",
  "parent_span_id": "356de7d8935f8ad6",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678152453592832,
  "time_end": 1782678153155611136,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "853efd63-8ac8-41a9-b41d-4bb7de9ca0e8",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9112,
    "process.parent_pid": 4270,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "e48f001b2d6410d0",
  "parent_span_id": "6053289123c641bf",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143971165184,
  "time_end": 1782678147897093888,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "b69294105d535d00",
  "parent_span_id": "6053289123c641bf",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143982888192,
  "time_end": 1782678147904120576,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "3aa5c690769c94f4",
  "parent_span_id": "6053289123c641bf",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143983153664,
  "time_end": 1782678147911345664,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "4e5ca2e857c9173e",
  "parent_span_id": "6053289123c641bf",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143982650624,
  "time_end": 1782678147905841920,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "282f4e65706e40d3",
  "parent_span_id": "6053289123c641bf",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143959092480,
  "time_end": 1782678153166985216,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "28f60d6f6e2e71c8",
  "parent_span_id": "6053289123c641bf",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143962529280,
  "time_end": 1782678147895249664,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "dee8590991ca8cc3",
  "parent_span_id": "6053289123c641bf",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143982500608,
  "time_end": 1782678147909516800,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "1f07c91cb83a40b8",
  "parent_span_id": "6053289123c641bf",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1782678143962716672,
  "time_end": 1782678153168470016,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "b89a8c7c1c707c82",
  "parent_span_id": "6053289123c641bf",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143982788864,
  "time_end": 1782678147902409728,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "040a38a75e085a61",
  "parent_span_id": "6053289123c641bf",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143975230208,
  "time_end": 1782678152865577216,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "3199966053f2565b",
  "parent_span_id": "6053289123c641bf",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143980470528,
  "time_end": 1782678153162969344,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "af43ddfa68f95e12",
  "parent_span_id": "6053289123c641bf",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1782678143955632128,
  "time_end": 1782678147892118784,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "21b7ca9c51be7956",
  "parent_span_id": "6053289123c641bf",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143964658944,
  "time_end": 1782678144032179456,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "7cfe03cef2e91473",
  "parent_span_id": "af43ddfa68f95e12",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1782678144031982848,
  "time_end": 1782678147892071168,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "6ecff691f8a8c9dc",
  "parent_span_id": "1bf81ea5a21e690f",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678148501391616,
  "time_end": 1782678148514645504,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "4557733d-245c-4276-afa9-2efee89d4507",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 4979,
    "process.parent_pid": 4263,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "81c0711e02d48e8d",
  "parent_span_id": "6053289123c641bf",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143974897664,
  "time_end": 1782678147907626240,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "4f31ff18a53c8f37",
  "parent_span_id": "6053289123c641bf",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143970106624,
  "time_end": 1782678147900617984,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "01a1f388cd93459c",
  "parent_span_id": "6053289123c641bf",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143955385856,
  "time_end": 1782678147898840576,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "e348c60c63cd7ea0",
  "parent_span_id": "6053289123c641bf",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143965029888,
  "time_end": 1782678147893463552,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "8de7a21b0b70ff5a",
  "parent_span_id": "957983dc70323a98",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678153519334912,
  "time_end": 1782678154228258816,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "0a9f8984-ecf7-4333-bf79-d14cb5938849",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 9685,
    "process.parent_pid": 4257,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "356de7d8935f8ad6",
  "parent_span_id": "6053289123c641bf",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143982337536,
  "time_end": 1782678153159670016,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "1bf81ea5a21e690f",
  "parent_span_id": "6053289123c641bf",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143962359296,
  "time_end": 1782678148518497536,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
  "trace_id": "df669cf6899f02fce29084336966a1a7",
  "span_id": "957983dc70323a98",
  "parent_span_id": "6053289123c641bf",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1782678143975092480,
  "time_end": 1782678154232008704,
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
    "telemetry.sdk.version": "5.58.0",
    "service.instance.id": "e4fa1c86-5edc-4095-94d6-93d681e23f7c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/1b791c10-9d42-4d3f-bacc-dce4c14bf905/resourceGroups/azure-northcentralus-general-1b791c10-9d42-4d3f-bacc-dce4c14bf905/providers/Microsoft.Compute/virtualMachines/gui3ryrLz5hViX",
    "host.id": "9c61ed27-284c-4d38-89cd-022dedd3e722",
    "host.name": "gui3ryrLz5hViX",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1018-azure",
    "process.pid": 3015,
    "process.parent_pid": 2815,
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
