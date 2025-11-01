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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "6d69b8ab5ec00d28",
  "parent_span_id": "e8ca2afd5861ba5b",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1761975349948307200,
  "time_end": 1761975350622480640,
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
      "00-f5fa9aec22075d3238d36e8f5107dee5-e8ca2afd5861ba5b-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 01 Nov 2025 05:35:50 GMT"
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
      "W/\"51a9438c595ac4f7aa88fec3596216ccb71b453137151d02ec3369844fa7122e\""
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
      "1761977234"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "3"
    ],
    "http.response.header.x-github-request-id": [
      "1C01:D7F3C:32DF498:DA25CE6:69059C35"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 6021,
    "process.parent_pid": 4649,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "60e7318f4658865a",
  "parent_span_id": "c62018a1349c2395",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1761975350991465216,
  "time_end": 1761975351570099712,
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
      "00-f5fa9aec22075d3238d36e8f5107dee5-c62018a1349c2395-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 01 Nov 2025 05:35:51 GMT"
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
      "W/\"8ad4a6a27bc7add01bdee19b5a259336860589b941b94481e5fe5d6c2ee19332\""
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
      "1761977234"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "4"
    ],
    "http.response.header.x-github-request-id": [
      "1C02:383250:311277B:D13625E:69059C36"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 7502,
    "process.parent_pid": 4649,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "19aa13b5d544d9c4",
  "parent_span_id": "5a0ce82fe4beb0ad",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1761975351936987648,
  "time_end": 1761975352493332224,
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
      "00-f5fa9aec22075d3238d36e8f5107dee5-5a0ce82fe4beb0ad-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 01 Nov 2025 05:35:52 GMT"
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
      "W/\"d5a675b8b166336f22e22cadd1726357e0557c7862a07eef81e784411c4a8c9b\""
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
      "1761977234"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "5"
    ],
    "http.response.header.x-github-request-id": [
      "1C03:655B2:33211AC:DBE25AA:69059C37"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 8399,
    "process.parent_pid": 4649,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "405a5b81b7120bbb",
  "parent_span_id": "187eba1991fd7193",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1761975352863007744,
  "time_end": 1761975353347408128,
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
      "00-f5fa9aec22075d3238d36e8f5107dee5-187eba1991fd7193-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 01 Nov 2025 05:35:53 GMT"
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
      "W/\"0a56f15fa3cba4c69ccf7c5d48c96aee4fea80d13ecdeb14510dc24c91f1854b\""
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
      "1761977234"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "6"
    ],
    "http.response.header.x-github-request-id": [
      "1C04:4EC0A:32BFD81:D80D12C:69059C38"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 9295,
    "process.parent_pid": 4649,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "d891ba0e16199c82",
  "parent_span_id": "c4c064ca2fb548cd",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1761975354178116864,
  "time_end": 1761975355197065216,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.112.3",
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 10194,
    "process.parent_pid": 4580,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "60f8e5598defd862",
  "parent_span_id": "c4c064ca2fb548cd",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1761975354294683904,
  "time_end": 1761975355230806528,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.108.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-01T06%3A24%3A55Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-01T05%3A23%3A59Z&ske=2025-11-01T06%3A24%3A55Z&sks=b&skv=2018-11-09&sig=1X6YewNwoQxgeLGFQYYfjR5RHrD7NQvv7FyIDE993Ok%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MTk3NTY1NCwibmJmIjoxNzYxOTc1MzU0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.A46C3TarUvTvLoMHXpZ7jYGEX_EZNvSa_HX8zlS4QY0&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-01T06%3A24%3A55Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-01T05%3A23%3A59Z&ske=2025-11-01T06%3A24%3A55Z&sks=b&skv=2018-11-09&sig=1X6YewNwoQxgeLGFQYYfjR5RHrD7NQvv7FyIDE993Ok%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MTk3NTY1NCwibmJmIjoxNzYxOTc1MzU0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.A46C3TarUvTvLoMHXpZ7jYGEX_EZNvSa_HX8zlS4QY0&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 10194,
    "process.parent_pid": 4580,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "bf4a9f3f9dca3510",
  "parent_span_id": "c4c064ca2fb548cd",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1761975355241084928,
  "time_end": 1761975356259354368,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.112.3",
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 10194,
    "process.parent_pid": 4580,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "22bfe14348bbb479",
  "parent_span_id": "c4c064ca2fb548cd",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1761975355375678976,
  "time_end": 1761975356300274944,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.108.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-01T06%3A25%3A20Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-01T05%3A24%3A51Z&ske=2025-11-01T06%3A25%3A20Z&sks=b&skv=2018-11-09&sig=SEePljTqm%2BoGNxXNvy8lsnopQPAfIB5pQ6UWamelwwg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MTk3NTY1NSwibmJmIjoxNzYxOTc1MzU1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.oCfGkALWP8va4Sp7uvU2A09zRzt2NQBLcK2G21FYclo&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-01T06%3A25%3A20Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-01T05%3A24%3A51Z&ske=2025-11-01T06%3A25%3A20Z&sks=b&skv=2018-11-09&sig=SEePljTqm%2BoGNxXNvy8lsnopQPAfIB5pQ6UWamelwwg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MTk3NTY1NSwibmJmIjoxNzYxOTc1MzU1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.oCfGkALWP8va4Sp7uvU2A09zRzt2NQBLcK2G21FYclo&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 10194,
    "process.parent_pid": 4580,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "5feb137ee89b4730",
  "parent_span_id": "c4c064ca2fb548cd",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1761975356311655680,
  "time_end": 1761975357330201344,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.112.3",
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 10194,
    "process.parent_pid": 4580,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "2abdb7976ff7cea9",
  "parent_span_id": "c4c064ca2fb548cd",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1761975356427653376,
  "time_end": 1761975357350235136,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.108.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-01T06%3A24%3A00Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-01T05%3A23%3A10Z&ske=2025-11-01T06%3A24%3A00Z&sks=b&skv=2018-11-09&sig=zZXudtxHLHFWKY5TTjIoeEdsgr0hf87SahI3YWxS%2BDY%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MTk3NTY1NiwibmJmIjoxNzYxOTc1MzU2LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.mutWMWfyblEXGJCyQT_Pyc5L4t9Q-mAM6Pbhl2WLOEQ&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-01T06%3A24%3A00Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-01T05%3A23%3A10Z&ske=2025-11-01T06%3A24%3A00Z&sks=b&skv=2018-11-09&sig=zZXudtxHLHFWKY5TTjIoeEdsgr0hf87SahI3YWxS%2BDY%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MTk3NTY1NiwibmJmIjoxNzYxOTc1MzU2LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.mutWMWfyblEXGJCyQT_Pyc5L4t9Q-mAM6Pbhl2WLOEQ&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 10194,
    "process.parent_pid": 4580,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "da8a502d991527ec",
  "parent_span_id": "a1a9c6efcd9c0590",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1761975345022475008,
  "time_end": 1761975348461129984,
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
      "Sat, 01 Nov 2025 05:35:45 GMT"
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
      "W/\"fad5dc856fb3240cc9641f3c5ba3a40d10ef634ef5ffd4ee2a2d5a89dfae5177\""
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
      "1761977234"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "2"
    ],
    "http.response.header.x-github-request-id": [
      "1C00:383250:311157D:D131845:69059C31"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "8a221f0ec2407c0e",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1761975344661904384,
  "time_end": 1761975357394440704,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "e8ca2afd5861ba5b",
  "parent_span_id": "63fb614be81acea0",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975349858448640,
  "time_end": 1761975350626575616,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 6021,
    "process.parent_pid": 4649,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "c62018a1349c2395",
  "parent_span_id": "63fb614be81acea0",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975350901069568,
  "time_end": 1761975351574153472,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 7502,
    "process.parent_pid": 4649,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "5a0ce82fe4beb0ad",
  "parent_span_id": "63fb614be81acea0",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975351849514240,
  "time_end": 1761975352497507840,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 8399,
    "process.parent_pid": 4649,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "187eba1991fd7193",
  "parent_span_id": "63fb614be81acea0",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975352772757760,
  "time_end": 1761975353351481344,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 9295,
    "process.parent_pid": 4649,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "c5ef071c8e28fd47",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344698758912,
  "time_end": 1761975348471805440,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "9557458a9f180fc1",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344698423552,
  "time_end": 1761975348481373952,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "7b6338130c0196db",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344713668352,
  "time_end": 1761975348491006720,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "fd1fb0bae8a6ca42",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344699181056,
  "time_end": 1761975348483765760,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "8dfed295d927f947",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344699051008,
  "time_end": 1761975353395478784,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "4a112bda922d1dd1",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344701001728,
  "time_end": 1761975348469460992,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "c6b929580579db0c",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344714897920,
  "time_end": 1761975348488648448,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "8018db0f16d3b290",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1761975344709978368,
  "time_end": 1761975353398744576,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "92cc8fcd4f2b16c5",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344711754752,
  "time_end": 1761975348478943488,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "60cadb0453511857",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344698617856,
  "time_end": 1761975353392539904,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "8d4bf4bb9f55a361",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344706454528,
  "time_end": 1761975353392806656,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "13ffa7f5bc800bc8",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1761975344689927680,
  "time_end": 1761975348464640768,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "1900668ecd582efd",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344679357440,
  "time_end": 1761975344796380672,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "a1a9c6efcd9c0590",
  "parent_span_id": "13ffa7f5bc800bc8",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1761975344820516608,
  "time_end": 1761975348461152000,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "ffaf245cb0665bbd",
  "parent_span_id": "f2b1f72778c233d4",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975349159481344,
  "time_end": 1761975349186147840,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 5345,
    "process.parent_pid": 4591,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "90c4a0552b9a8d92",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344711504384,
  "time_end": 1761975348486300416,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "e47fba81588e4964",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344698912256,
  "time_end": 1761975348476558080,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "8484a003a26eeb74",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344701273856,
  "time_end": 1761975348474164480,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "223ddf59d4f199c5",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344710110720,
  "time_end": 1761975348467026176,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "c4c064ca2fb548cd",
  "parent_span_id": "fd581617b5f1fef3",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975354068533760,
  "time_end": 1761975357354996992,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 10194,
    "process.parent_pid": 4580,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "63fb614be81acea0",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344711258624,
  "time_end": 1761975353389597696,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "f2b1f72778c233d4",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344710258176,
  "time_end": 1761975349229872128,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
  "trace_id": "f5fa9aec22075d3238d36e8f5107dee5",
  "span_id": "fd581617b5f1fef3",
  "parent_span_id": "8a221f0ec2407c0e",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1761975344709816064,
  "time_end": 1761975357393727744,
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
    "telemetry.sdk.version": "5.32.0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/9c2ea559-c319-4281-97af-f54cdcab3f73/resourceGroups/azure-northcentralus-general-9c2ea559-c319-4281-97af-f54cdcab3f73/providers/Microsoft.Compute/virtualMachines/Ih4jhca4WAIpNl",
    "host.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "host.name": "Ih4jhca4WAIpNl",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "282a6bb7-8b39-46d8-b2b6-7de45452fdc2",
    "process.pid": 3143,
    "process.parent_pid": 2360,
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
