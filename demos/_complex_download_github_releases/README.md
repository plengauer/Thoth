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
```
{
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "721393ad39bd0d7d",
  "parent_span_id": "d1597489e8b76aa8",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763456119749128960,
  "time_end": 1763456120396360448,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.116.5",
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
      "00-b8022842f0c46f536c5513ced117f816-d1597489e8b76aa8-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Tue, 18 Nov 2025 08:55:20 GMT"
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
      "W/\"eca4a90186ca318ce491fc5733cf3e6fcf4bf2afe588957dd5c23101327e4f08\""
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
      "41"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1763456574"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "19"
    ],
    "http.response.header.x-github-request-id": [
      "4801:1488F8:848198:87F589:691C3477"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 5481,
    "process.parent_pid": 4124,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "40142de196cddf56",
  "parent_span_id": "7c1bfc805d6714ae",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763456120764937728,
  "time_end": 1763456121377931520,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.116.5",
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
      "00-b8022842f0c46f536c5513ced117f816-7c1bfc805d6714ae-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Tue, 18 Nov 2025 08:55:21 GMT"
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
      "W/\"75636971f608e8f3beb5a3f49f2ad28a1ee3badd9c0d1c9d5bb161005ab50b4b\""
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
      "40"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1763456574"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "20"
    ],
    "http.response.header.x-github-request-id": [
      "4802:CA82C:84E956:885B85:691C3478"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 6962,
    "process.parent_pid": 4124,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "b8e66fd4e9d43bd1",
  "parent_span_id": "8524eb74a7fc717b",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763456121745997056,
  "time_end": 1763456122401900288,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.116.5",
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
      "00-b8022842f0c46f536c5513ced117f816-8524eb74a7fc717b-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Tue, 18 Nov 2025 08:55:22 GMT"
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
      "W/\"a72f86ef02118ecdbe796a9c81dbe8068c4658fca28ce6fc06578597ab5424d2\""
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
      "39"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1763456574"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "21"
    ],
    "http.response.header.x-github-request-id": [
      "4803:24D5DD:86DA42:8A4CF6:691C3479"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 7858,
    "process.parent_pid": 4124,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "6aad3ae3638cca0b",
  "parent_span_id": "34670aae888459ba",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763456122772554240,
  "time_end": 1763456123235051776,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.116.5",
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
      "00-b8022842f0c46f536c5513ced117f816-34670aae888459ba-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Tue, 18 Nov 2025 08:55:22 GMT"
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
      "W/\"378d665aea2e3c47283533f99afe5f80b237e47104d1f3d6478210c050aa8ae7\""
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
      "38"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1763456574"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "22"
    ],
    "http.response.header.x-github-request-id": [
      "4804:110970:84FDE5:887134:691C347A"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 8754,
    "process.parent_pid": 4124,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "2fa9356a0f5aea6f",
  "parent_span_id": "d79a54f1103e5863",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763456124020394752,
  "time_end": 1763456125038195200,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.116.3",
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 9653,
    "process.parent_pid": 4073,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "23840f615736ea5d",
  "parent_span_id": "d79a54f1103e5863",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763456124222400000,
  "time_end": 1763456125117261568,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-18T09%3A48%3A05Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-18T08%3A47%3A23Z&ske=2025-11-18T09%3A48%3A05Z&sks=b&skv=2018-11-09&sig=%2Bw%2FFTI5hcGdX%2FCI0MEC2AzXyGdtUNHZAptNYhFw2Rro%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MzQ1NjQyNCwibmJmIjoxNzYzNDU2MTI0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.ztKX6zRElHIfO6mRGJPMCb-wNr3lrb-zOgnviFP3bhM&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-18T09%3A48%3A05Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-18T08%3A47%3A23Z&ske=2025-11-18T09%3A48%3A05Z&sks=b&skv=2018-11-09&sig=%2Bw%2FFTI5hcGdX%2FCI0MEC2AzXyGdtUNHZAptNYhFw2Rro%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MzQ1NjQyNCwibmJmIjoxNzYzNDU2MTI0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.ztKX6zRElHIfO6mRGJPMCb-wNr3lrb-zOgnviFP3bhM&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 9653,
    "process.parent_pid": 4073,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "cc2364c6502c6115",
  "parent_span_id": "d79a54f1103e5863",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763456125129419008,
  "time_end": 1763456126146955264,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.116.3",
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 9653,
    "process.parent_pid": 4073,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "756288897745ba10",
  "parent_span_id": "d79a54f1103e5863",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763456125326225152,
  "time_end": 1763456126224548352,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-18T09%3A48%3A27Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-18T08%3A47%3A39Z&ske=2025-11-18T09%3A48%3A27Z&sks=b&skv=2018-11-09&sig=jZac8PBohC0HyziKrHN2Ifjs1MDmP7pDwKLLnYwIv1U%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MzQ1NjQyNSwibmJmIjoxNzYzNDU2MTI1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.hFhHw3Dg5nlBi3aAA2G3KnlKsjIKe4CjlBG9axMCyFE&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-18T09%3A48%3A27Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-18T08%3A47%3A39Z&ske=2025-11-18T09%3A48%3A27Z&sks=b&skv=2018-11-09&sig=jZac8PBohC0HyziKrHN2Ifjs1MDmP7pDwKLLnYwIv1U%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MzQ1NjQyNSwibmJmIjoxNzYzNDU2MTI1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.hFhHw3Dg5nlBi3aAA2G3KnlKsjIKe4CjlBG9axMCyFE&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 9653,
    "process.parent_pid": 4073,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "56e8fdd0f2a6eaa6",
  "parent_span_id": "d79a54f1103e5863",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763456126236404480,
  "time_end": 1763456127253930496,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.116.3",
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 9653,
    "process.parent_pid": 4073,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "99abdca3fee2f81c",
  "parent_span_id": "d79a54f1103e5863",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763456126427569408,
  "time_end": 1763456127312999680,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-18T09%3A49%3A24Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-18T08%3A49%3A16Z&ske=2025-11-18T09%3A49%3A24Z&sks=b&skv=2018-11-09&sig=w1oIwK6ggOmHK6Kk8xo8HBK8jhT1OlVEg%2Fza1zZGqx4%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MzQ1NjQyNiwibmJmIjoxNzYzNDU2MTI2LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.W9LSofBKmUwMyQmkDbkazFsZ_nUpILK1bBxFL5gnD8k&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-18T09%3A49%3A24Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-18T08%3A49%3A16Z&ske=2025-11-18T09%3A49%3A24Z&sks=b&skv=2018-11-09&sig=w1oIwK6ggOmHK6Kk8xo8HBK8jhT1OlVEg%2Fza1zZGqx4%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MzQ1NjQyNiwibmJmIjoxNzYzNDU2MTI2LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.W9LSofBKmUwMyQmkDbkazFsZ_nUpILK1bBxFL5gnD8k&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 9653,
    "process.parent_pid": 4073,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "6c4b44433d42e9bd",
  "parent_span_id": "18d52ae897514514",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1763456114836845824,
  "time_end": 1763456118273883648,
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
      "Tue, 18 Nov 2025 08:55:15 GMT"
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
      "W/\"6531aaad28725ef2be8bc92b40b45c0083cec647a0ea7a1bb6836b322bfa73a2\""
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
      "42"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1763456574"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "18"
    ],
    "http.response.header.x-github-request-id": [
      "4800:CA82C:84D185:8842FD:691C3472"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "040633b8317f63ae",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1763456114481545216,
  "time_end": 1763456127322227456,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "d1597489e8b76aa8",
  "parent_span_id": "24f7b7baa57cd71d",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456119655056896,
  "time_end": 1763456120400272640,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 5481,
    "process.parent_pid": 4124,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "7c1bfc805d6714ae",
  "parent_span_id": "24f7b7baa57cd71d",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456120675148288,
  "time_end": 1763456121381926656,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 6962,
    "process.parent_pid": 4124,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "8524eb74a7fc717b",
  "parent_span_id": "24f7b7baa57cd71d",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456121656304896,
  "time_end": 1763456122405804032,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 7858,
    "process.parent_pid": 4124,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "34670aae888459ba",
  "parent_span_id": "24f7b7baa57cd71d",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456122681980160,
  "time_end": 1763456123238856704,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 8754,
    "process.parent_pid": 4124,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "d91d92e82413c89d",
  "parent_span_id": "040633b8317f63ae",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114505179392,
  "time_end": 1763456118284278272,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "075e393a9325c8ad",
  "parent_span_id": "040633b8317f63ae",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114506300928,
  "time_end": 1763456118292887808,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "dc2d68372d2175f1",
  "parent_span_id": "040633b8317f63ae",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114534653952,
  "time_end": 1763456118301679104,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "b1d51379fa3b3cd7",
  "parent_span_id": "040633b8317f63ae",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114510172416,
  "time_end": 1763456118295082240,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "aad3161fcf2facb5",
  "parent_span_id": "040633b8317f63ae",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114534797568,
  "time_end": 1763456123248899840,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "681bfa710d1bdb20",
  "parent_span_id": "040633b8317f63ae",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114519746816,
  "time_end": 1763456118281959424,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "b036795638e1855f",
  "parent_span_id": "040633b8317f63ae",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114536014080,
  "time_end": 1763456118299542016,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "241c34f0291cb798",
  "parent_span_id": "040633b8317f63ae",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1763456114525938944,
  "time_end": 1763456123252423168,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "79e8c6a4ff998f51",
  "parent_span_id": "040633b8317f63ae",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114520040960,
  "time_end": 1763456118290666752,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "5e2fcaec7bfed98a",
  "parent_span_id": "040633b8317f63ae",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114544686336,
  "time_end": 1763456123246154752,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "5d1749724b60497f",
  "parent_span_id": "040633b8317f63ae",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114536371200,
  "time_end": 1763456123245889024,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "01da7246ca624cc7",
  "parent_span_id": "040633b8317f63ae",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1763456114519607808,
  "time_end": 1763456118277314304,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "ab39c20ca4c5f561",
  "parent_span_id": "040633b8317f63ae",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114496987136,
  "time_end": 1763456114594100992,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "18d52ae897514514",
  "parent_span_id": "01da7246ca624cc7",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1763456114627347968,
  "time_end": 1763456118273904128,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "861db5dfb30cfdb1",
  "parent_span_id": "5881bd8960f70c6a",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456118964187392,
  "time_end": 1763456118981619712,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 4805,
    "process.parent_pid": 4082,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "d6084ee98f8ba991",
  "parent_span_id": "040633b8317f63ae",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114536620544,
  "time_end": 1763456118297238528,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "642e0d104433cfe6",
  "parent_span_id": "040633b8317f63ae",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114513467904,
  "time_end": 1763456118288520960,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "da55c6041a0bea9f",
  "parent_span_id": "040633b8317f63ae",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114525800704,
  "time_end": 1763456118286383616,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "b59a0cfdf0d3787a",
  "parent_span_id": "040633b8317f63ae",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114510008064,
  "time_end": 1763456118279623424,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "d79a54f1103e5863",
  "parent_span_id": "cf26efd55d6ef71c",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456123918499584,
  "time_end": 1763456127316906752,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 9653,
    "process.parent_pid": 4073,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "24f7b7baa57cd71d",
  "parent_span_id": "040633b8317f63ae",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114525636864,
  "time_end": 1763456123243002624,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "5881bd8960f70c6a",
  "parent_span_id": "040633b8317f63ae",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114534987264,
  "time_end": 1763456118986476032,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
  "trace_id": "b8022842f0c46f536c5513ced117f816",
  "span_id": "cf26efd55d6ef71c",
  "parent_span_id": "040633b8317f63ae",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1763456114536198656,
  "time_end": 1763456127321415936,
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
    "telemetry.sdk.version": "5.33.5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/873ffdb0-cf50-4649-8b12-c12b1997de0f/resourceGroups/azure-westus-general-873ffdb0-cf50-4649-8b12-c12b1997de0f/providers/Microsoft.Compute/virtualMachines/lKtgfWsdW3YNgI",
    "host.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "host.name": "lKtgfWsdW3YNgI",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "95a3a1fc-706c-41f8-990d-0bcacb6ca095",
    "process.pid": 2603,
    "process.parent_pid": 2403,
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
