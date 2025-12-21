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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "84f4da7d8102da8d",
  "parent_span_id": "0ce5b2e429d0e04e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1766306434225874944,
  "time_end": 1766306434742010624,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.114.6",
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
      "00-3b81bfd39fce7dd5ea07790922e5e960-0ce5b2e429d0e04e-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 21 Dec 2025 08:40:34 GMT"
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
      "W/\"d863239505f0b601fcf61d9c8fe12042effb59db819bc1b65985982da1abb228\""
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
      "50"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1766308730"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "10"
    ],
    "http.response.header.x-github-request-id": [
      "33C1:33DFBF:13B5005:5635D88:6947B282"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 5365,
    "process.parent_pid": 3987,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "832a136b3afc4aee",
  "parent_span_id": "cc3e1ab7509b27d3",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1766306435099100672,
  "time_end": 1766306435718089472,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.114.6",
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
      "00-3b81bfd39fce7dd5ea07790922e5e960-cc3e1ab7509b27d3-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 21 Dec 2025 08:40:35 GMT"
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
      "W/\"6fe2820dcccd024910a1487fcfffb1c17663b53e24aa97825c5b529260875668\""
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
      "49"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1766308730"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "11"
    ],
    "http.response.header.x-github-request-id": [
      "33C2:2203F0:1253A31:4FC1A5B:6947B283"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 6816,
    "process.parent_pid": 3987,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "cb304d4c0ccbe1b1",
  "parent_span_id": "f17fb8dd0547e2c7",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1766306436068267520,
  "time_end": 1766306436597570304,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.114.6",
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
      "00-3b81bfd39fce7dd5ea07790922e5e960-f17fb8dd0547e2c7-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 21 Dec 2025 08:40:36 GMT"
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
      "W/\"7c03c8d38de1ff63e65247180d04c2cdf253f2193f247982739b1b62a8046aa9\""
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
      "48"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1766308730"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "12"
    ],
    "http.response.header.x-github-request-id": [
      "33C3:3FA892:13123BC:53AB808:6947B284"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 7680,
    "process.parent_pid": 3987,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "30e5d3a65b9d4ee1",
  "parent_span_id": "d5b31bc0937c8641",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1766306436953206016,
  "time_end": 1766306437429494784,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.113.5",
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
      "00-3b81bfd39fce7dd5ea07790922e5e960-d5b31bc0937c8641-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sun, 21 Dec 2025 08:40:37 GMT"
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
      "W/\"61e156a081eb32928ce4030fa9eef5f2ac0cbef1a04f62d97df3a385811e02ee\""
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
      "47"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1766306982"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "13"
    ],
    "http.response.header.x-github-request-id": [
      "33C0:6B235:D45453:3A11898:6947B284"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 8544,
    "process.parent_pid": 3987,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "f8e3b486cc6360da",
  "parent_span_id": "6b08af3ea2a89a6a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1766306437906262272,
  "time_end": 1766306437999055104,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 8905,
    "process.parent_pid": 3982,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "3e4195c91957feda",
  "parent_span_id": "6b08af3ea2a89a6a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1766306437991612160,
  "time_end": 1766306438035310848,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-21T09%3A33%3A26Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-21T08%3A32%3A32Z&ske=2025-12-21T09%3A33%3A26Z&sks=b&skv=2018-11-09&sig=fg1f9N4p7J4t3sfbP4pN%2FD6gmqsqWX8hAOvfIwGK2vs%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NjMwNjczNywibmJmIjoxNzY2MzA2NDM3LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.19aIDRvm5R9CnCcMclYK-6i-Q-p7XBf3w5o2Bo9FBp8&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-21T09%3A33%3A26Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-21T08%3A32%3A32Z&ske=2025-12-21T09%3A33%3A26Z&sks=b&skv=2018-11-09&sig=fg1f9N4p7J4t3sfbP4pN%2FD6gmqsqWX8hAOvfIwGK2vs%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NjMwNjczNywibmJmIjoxNzY2MzA2NDM3LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.19aIDRvm5R9CnCcMclYK-6i-Q-p7XBf3w5o2Bo9FBp8&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 8905,
    "process.parent_pid": 3982,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "19bf3f8bcc451470",
  "parent_span_id": "6b08af3ea2a89a6a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1766306438010929408,
  "time_end": 1766306438109518336,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 8905,
    "process.parent_pid": 3982,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "1ba88921fdbf71da",
  "parent_span_id": "6b08af3ea2a89a6a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1766306438095297024,
  "time_end": 1766306438146051328,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-21T09%3A25%3A41Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-21T08%3A25%3A21Z&ske=2025-12-21T09%3A25%3A41Z&sks=b&skv=2018-11-09&sig=f60IOLfyrr2vrC47LSA23niMmcMe96gZGXL0jVmFvp4%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NjMwNjczOCwibmJmIjoxNzY2MzA2NDM4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.s43ysZur_xoC0EWxvqEyNxo822ZuBL-Ag6gm6UDewuk&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-21T09%3A25%3A41Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-21T08%3A25%3A21Z&ske=2025-12-21T09%3A25%3A41Z&sks=b&skv=2018-11-09&sig=f60IOLfyrr2vrC47LSA23niMmcMe96gZGXL0jVmFvp4%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NjMwNjczOCwibmJmIjoxNzY2MzA2NDM4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.s43ysZur_xoC0EWxvqEyNxo822ZuBL-Ag6gm6UDewuk&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 8905,
    "process.parent_pid": 3982,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "6b824b636b209c2d",
  "parent_span_id": "6b08af3ea2a89a6a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1766306438110704384,
  "time_end": 1766306438225266432,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 8905,
    "process.parent_pid": 3982,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "040cb6d1a12fe36b",
  "parent_span_id": "6b08af3ea2a89a6a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1766306438209825536,
  "time_end": 1766306438245980672,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-21T09%3A21%3A49Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-21T08%3A21%3A05Z&ske=2025-12-21T09%3A21%3A49Z&sks=b&skv=2018-11-09&sig=VorH79ug4R6wlQ1%2FE1j1VqbEspp8cm09bK9%2F2AfTaXU%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NjMwNjczOCwibmJmIjoxNzY2MzA2NDM4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.s43ysZur_xoC0EWxvqEyNxo822ZuBL-Ag6gm6UDewuk&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-21T09%3A21%3A49Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-21T08%3A21%3A05Z&ske=2025-12-21T09%3A21%3A49Z&sks=b&skv=2018-11-09&sig=VorH79ug4R6wlQ1%2FE1j1VqbEspp8cm09bK9%2F2AfTaXU%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NjMwNjczOCwibmJmIjoxNzY2MzA2NDM4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.s43ysZur_xoC0EWxvqEyNxo822ZuBL-Ag6gm6UDewuk&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 8905,
    "process.parent_pid": 3982,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "674c2dbd28b8c6eb",
  "parent_span_id": "6a2e1dd980825871",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1766306429370001152,
  "time_end": 1766306432746270720,
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
      "Sun, 21 Dec 2025 08:40:29 GMT"
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
      "W/\"c0e8230fe8111b5c30d219c097477d49d44141bb2f6e6526fbf7f127397e48fb\""
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
      "51"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1766308730"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "9"
    ],
    "http.response.header.x-github-request-id": [
      "33C0:25416:142AC99:58926AD:6947B27D"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "5bfa89ee24035989",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1766306429042450432,
  "time_end": 1766306438255407360,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "0ce5b2e429d0e04e",
  "parent_span_id": "139ef58d850aba7b",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306434157764352,
  "time_end": 1766306434745921280,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 5365,
    "process.parent_pid": 3987,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "cc3e1ab7509b27d3",
  "parent_span_id": "139ef58d850aba7b",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306435034822144,
  "time_end": 1766306435722018304,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 6816,
    "process.parent_pid": 3987,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "f17fb8dd0547e2c7",
  "parent_span_id": "139ef58d850aba7b",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306436006479360,
  "time_end": 1766306436601639936,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 7680,
    "process.parent_pid": 3987,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "d5b31bc0937c8641",
  "parent_span_id": "139ef58d850aba7b",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306436892192000,
  "time_end": 1766306437433834240,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 8544,
    "process.parent_pid": 3987,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "1ce0de5a6d49dc0b",
  "parent_span_id": "5bfa89ee24035989",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429073586688,
  "time_end": 1766306432753613568,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "7782c553233dbb66",
  "parent_span_id": "5bfa89ee24035989",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429090580992,
  "time_end": 1766306432762406656,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "571cd6fff740e44b",
  "parent_span_id": "5bfa89ee24035989",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429087293952,
  "time_end": 1766306432771136768,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "e026dab26ffc4d19",
  "parent_span_id": "5bfa89ee24035989",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429086333696,
  "time_end": 1766306432764579584,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "888592d71ea0fdeb",
  "parent_span_id": "5bfa89ee24035989",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429106939392,
  "time_end": 1766306437445492480,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "56a777c3893e73e1",
  "parent_span_id": "5bfa89ee24035989",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429080129536,
  "time_end": 1766306432751441920,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "081fe8e69985751b",
  "parent_span_id": "5bfa89ee24035989",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429087138304,
  "time_end": 1766306432769015808,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "081469de14570956",
  "parent_span_id": "5bfa89ee24035989",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1766306429096963584,
  "time_end": 1766306437448584192,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "cd7620ed6f4b7527",
  "parent_span_id": "5bfa89ee24035989",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429090797312,
  "time_end": 1766306432760246528,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "354391269ad918af",
  "parent_span_id": "5bfa89ee24035989",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429083514880,
  "time_end": 1766306437085300992,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "687aef3c5d7e810a",
  "parent_span_id": "5bfa89ee24035989",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429085852672,
  "time_end": 1766306437442089216,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "03e2ffd4d1d5c9c4",
  "parent_span_id": "5bfa89ee24035989",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1766306429067698176,
  "time_end": 1766306432746898432,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "1b76db4e7b0f453a",
  "parent_span_id": "5bfa89ee24035989",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429077226240,
  "time_end": 1766306429153236224,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "6a2e1dd980825871",
  "parent_span_id": "03e2ffd4d1d5c9c4",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1766306429172130816,
  "time_end": 1766306432746292736,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "6db8ed7d2afb0b79",
  "parent_span_id": "20b11e5c89a30141",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306433450885120,
  "time_end": 1766306433465435648,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 4697,
    "process.parent_pid": 3961,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "081bfa6635a46a7a",
  "parent_span_id": "5bfa89ee24035989",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429078606080,
  "time_end": 1766306432766818560,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "60f61b39be06f5c8",
  "parent_span_id": "5bfa89ee24035989",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429074451456,
  "time_end": 1766306432758071296,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "ace8d65bb5a6b1a8",
  "parent_span_id": "5bfa89ee24035989",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429080462592,
  "time_end": 1766306432755857152,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "60498b99ce283c70",
  "parent_span_id": "5bfa89ee24035989",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429066907648,
  "time_end": 1766306432749147136,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "6b08af3ea2a89a6a",
  "parent_span_id": "a31fcb41742f93e5",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306437843786752,
  "time_end": 1766306438250331904,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 8905,
    "process.parent_pid": 3982,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "139ef58d850aba7b",
  "parent_span_id": "5bfa89ee24035989",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429077378816,
  "time_end": 1766306437438545408,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "20b11e5c89a30141",
  "parent_span_id": "5bfa89ee24035989",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429083371520,
  "time_end": 1766306433470246144,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
  "trace_id": "3b81bfd39fce7dd5ea07790922e5e960",
  "span_id": "a31fcb41742f93e5",
  "parent_span_id": "5bfa89ee24035989",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1766306429096567040,
  "time_end": 1766306438254541056,
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
    "telemetry.sdk.version": "5.38.2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "eastus",
    "cloud.resource_id": "/subscriptions/04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/resourceGroups/azure-eastus-general-04e9ceb6-2c8a-41f5-b9b9-075dc51b81be/providers/Microsoft.Compute/virtualMachines/342WEA8Uks24Yg",
    "host.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "host.name": "342WEA8Uks24Yg",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "8048162d-4d2c-4ec5-9a92-43a63f07afd9",
    "process.pid": 2679,
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
