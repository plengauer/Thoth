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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "8e901e41283089af",
  "parent_span_id": "4e0a0c951e839ec3",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1791638802977249536,
  "time_end": 1791638803986692352,
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
      "00-b45e43a33b44d17fac43463d11aee488-4e0a0c951e839ec3-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 10 Oct 2026 13:26:43 GMT"
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
      "W/\"67b2cec350f4b2c41e2d474a30e2b6981e09f778d4246881b40651d0807384fe\""
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
      "1791641230"
    ],
    "http.response.header.x-github-request-id": [
      "C809:2355E8:19DABD:537B7F:6ACA3D12"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "00487f0a-fc84-417e-a4ed-db945037f959",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5500,
    "process.parent_pid": 4213,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "6f04cb00a933dae7",
  "parent_span_id": "b362a8fc072ec30c",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1791638804380606976,
  "time_end": 1791638805147060992,
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
      "00-b45e43a33b44d17fac43463d11aee488-b362a8fc072ec30c-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 10 Oct 2026 13:26:44 GMT"
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
      "W/\"185d30190154c40ee955fe4366bf922a278c269f6f040bf69c246365b6e88a67\""
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
      "53"
    ],
    "http.response.header.x-ratelimit-used": [
      "7"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1791641230"
    ],
    "http.response.header.x-github-request-id": [
      "C80A:5A869:18DB5E:5176A5:6ACA3D14"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "9ca6b066-7cb0-41b1-b46d-6d0e28443d5d",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7043,
    "process.parent_pid": 4213,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "428fdf422b8d16c1",
  "parent_span_id": "ff5ad47bc06b1854",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1791638805538969088,
  "time_end": 1791638806317447168,
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
      "00-b45e43a33b44d17fac43463d11aee488-ff5ad47bc06b1854-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 10 Oct 2026 13:26:45 GMT"
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
      "W/\"17c95cd336e03de43b7897fffac31186d552af8df4ac3b614154594ea5ce2cb1\""
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
      "52"
    ],
    "http.response.header.x-ratelimit-used": [
      "8"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1791641230"
    ],
    "http.response.header.x-github-request-id": [
      "C80B:28C9C0:18A2DC:50E7A7:6ACA3D15"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "92ece56d-105c-4a9c-b389-d09e635f2440",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8013,
    "process.parent_pid": 4213,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "579ba9f7061c15c0",
  "parent_span_id": "80060ebd1599b4c4",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1791638806707556608,
  "time_end": 1791638807454569472,
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
      "00-b45e43a33b44d17fac43463d11aee488-80060ebd1599b4c4-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 10 Oct 2026 13:26:47 GMT"
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
      "W/\"471bb69787986e892c2ada07799a24f79852de7075fc77d2259100b2e2fbd3c4\""
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
      "51"
    ],
    "http.response.header.x-ratelimit-used": [
      "9"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1791641230"
    ],
    "http.response.header.x-github-request-id": [
      "C80C:86B65:1B2D71:596072:6ACA3D16"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "acf7571e-051c-450a-8652-22447cb78f4c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8983,
    "process.parent_pid": 4213,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "9fde65b51d1dcd6f",
  "parent_span_id": "c0a4154990417e6d",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1791638808168619008,
  "time_end": 1791638809206234368,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "aef3ec16-a846-409d-a303-b0d7efe25bb5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9818,
    "process.parent_pid": 4205,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "dda015d5c45315fe",
  "parent_span_id": "c0a4154990417e6d",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1791638808393507840,
  "time_end": 1791638809336055552,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-10-10T14%3A23%3A02Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-10-10T13%3A22%3A11Z&ske=2026-10-10T14%3A23%3A02Z&sks=b&skv=2018-11-09&sig=0lyyXOSyF1gPuTjSicRiLMPgCE0qkrBmN4Xq5EwcqUU%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MTYzOTEwOCwibmJmIjoxNzkxNjM4ODA4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.k-Z2Pjw9N49qiQl4x7Dgh0wxJOhqpLQKWZupE5wldYQ&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-10-10T14%3A23%3A02Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-10-10T13%3A22%3A11Z&ske=2026-10-10T14%3A23%3A02Z&sks=b&skv=2018-11-09&sig=0lyyXOSyF1gPuTjSicRiLMPgCE0qkrBmN4Xq5EwcqUU%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MTYzOTEwOCwibmJmIjoxNzkxNjM4ODA4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.k-Z2Pjw9N49qiQl4x7Dgh0wxJOhqpLQKWZupE5wldYQ&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "aef3ec16-a846-409d-a303-b0d7efe25bb5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9818,
    "process.parent_pid": 4205,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "2ab0356d6186fb5c",
  "parent_span_id": "c0a4154990417e6d",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1791638809332344576,
  "time_end": 1791638809642621696,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "aef3ec16-a846-409d-a303-b0d7efe25bb5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9818,
    "process.parent_pid": 4205,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "9783aef6a4e4a42b",
  "parent_span_id": "c0a4154990417e6d",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1791638809590850816,
  "time_end": 1791638809824392960,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-10-10T14%3A26%3A17Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-10-10T13%3A25%3A45Z&ske=2026-10-10T14%3A26%3A17Z&sks=b&skv=2018-11-09&sig=rtOoNI5DpdCZMOWwvf%2FVdYI8W5thJoz%2Bfyzlw4j8l8c%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MTYzOTEwOSwibmJmIjoxNzkxNjM4ODA5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.p3s01ED2A3OdPzCkF3iYhA7eNJnhbt8ZdT3yo09lZqE&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-10-10T14%3A26%3A17Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-10-10T13%3A25%3A45Z&ske=2026-10-10T14%3A26%3A17Z&sks=b&skv=2018-11-09&sig=rtOoNI5DpdCZMOWwvf%2FVdYI8W5thJoz%2Bfyzlw4j8l8c%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MTYzOTEwOSwibmJmIjoxNzkxNjM4ODA5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.p3s01ED2A3OdPzCkF3iYhA7eNJnhbt8ZdT3yo09lZqE&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "aef3ec16-a846-409d-a303-b0d7efe25bb5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9818,
    "process.parent_pid": 4205,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "afa2910a4fddf3dd",
  "parent_span_id": "c0a4154990417e6d",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1791638809818076160,
  "time_end": 1791638810176692736,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "aef3ec16-a846-409d-a303-b0d7efe25bb5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9818,
    "process.parent_pid": 4205,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "6b021129f65ae673",
  "parent_span_id": "c0a4154990417e6d",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1791638810134157056,
  "time_end": 1791638810261887488,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-10-10T14%3A27%3A12Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-10-10T13%3A26%3A49Z&ske=2026-10-10T14%3A27%3A12Z&sks=b&skv=2018-11-09&sig=CtYYbXobAjJNtnbjshiR%2BiZFvQ71En0%2FsBBdmv4ckbg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MTYzOTExMCwibmJmIjoxNzkxNjM4ODEwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.wWMXbemeyp6ife9yTm8JihipbPb_EOwJSNKCU2BsdaI&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-10-10T14%3A27%3A12Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-10-10T13%3A26%3A49Z&ske=2026-10-10T14%3A27%3A12Z&sks=b&skv=2018-11-09&sig=CtYYbXobAjJNtnbjshiR%2BiZFvQ71En0%2FsBBdmv4ckbg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MTYzOTExMCwibmJmIjoxNzkxNjM4ODEwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.wWMXbemeyp6ife9yTm8JihipbPb_EOwJSNKCU2BsdaI&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "aef3ec16-a846-409d-a303-b0d7efe25bb5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9818,
    "process.parent_pid": 4205,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "953397230d3c2bce",
  "parent_span_id": "ca713afb6488839f",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1791638797874017024,
  "time_end": 1791638801550020096,
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
      "Sat, 10 Oct 2026 13:26:38 GMT"
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
      "W/\"8be572eb38641f2863bbb9599621417b5194d2cd6db7799ec6af4fe43b1ff02e\""
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
      "1791641230"
    ],
    "http.response.header.x-github-request-id": [
      "C808:28C9C0:18854F:50869A:6ACA3D0D"
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "a4e373ee094e0b48",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1791638797614179072,
  "time_end": 1791638810265864448,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "4e0a0c951e839ec3",
  "parent_span_id": "13f4b1515443cbfa",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638802827941632,
  "time_end": 1791638804034964224,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "00487f0a-fc84-417e-a4ed-db945037f959",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5500,
    "process.parent_pid": 4213,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "b362a8fc072ec30c",
  "parent_span_id": "13f4b1515443cbfa",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638804246959872,
  "time_end": 1791638805196975360,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "9ca6b066-7cb0-41b1-b46d-6d0e28443d5d",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7043,
    "process.parent_pid": 4213,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "ff5ad47bc06b1854",
  "parent_span_id": "13f4b1515443cbfa",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638805407039232,
  "time_end": 1791638806366136832,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "92ece56d-105c-4a9c-b389-d09e635f2440",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8013,
    "process.parent_pid": 4213,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "80060ebd1599b4c4",
  "parent_span_id": "13f4b1515443cbfa",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638806576405760,
  "time_end": 1791638807504237568,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "acf7571e-051c-450a-8652-22447cb78f4c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8983,
    "process.parent_pid": 4213,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "9b6d2c3dc31b70b7",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797634617344,
  "time_end": 1791638801550266880,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "e44e57a837768907",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797638191616,
  "time_end": 1791638801554595584,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "77d2e0f5889d7dae",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797651657216,
  "time_end": 1791638801558485248,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "71ca83349e7cc6b4",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797642661888,
  "time_end": 1791638801555589376,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "9a3b4ff79b096ba5",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797660429824,
  "time_end": 1791638807510262528,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "fe2baef3dac825ff",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797631216640,
  "time_end": 1791638801550219264,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "bca46295ec4c8a7f",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797651514112,
  "time_end": 1791638801557525504,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "bfc2555595d7db3b",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1791638797652638208,
  "time_end": 1791638807511323648,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "cf5a9a8691b57031",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797651780864,
  "time_end": 1791638801553532928,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "1104c70825bf493f",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797651334400,
  "time_end": 1791638807366521600,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "97db51e1340f808e",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797653190144,
  "time_end": 1791638807508528640,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "cf4c9248572e16d9",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1791638797630636800,
  "time_end": 1791638801550134528,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "5ff05cde36574086",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797638652160,
  "time_end": 1791638797664576768,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "ca713afb6488839f",
  "parent_span_id": "cf4c9248572e16d9",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1791638797693198336,
  "time_end": 1791638801550059264,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "95f359e7ead005e1",
  "parent_span_id": "b8aecc8972871ddd",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638802183906304,
  "time_end": 1791638802193054464,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ec01b315-5458-4d19-b0d3-b4bcab06bbb9",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4902,
    "process.parent_pid": 4189,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "a8ba26b8edef4c08",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797644521216,
  "time_end": 1791638801556539904,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "5eec1583cf39b0b9",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797630359552,
  "time_end": 1791638801552538112,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "2b701f766919c43b",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797644352256,
  "time_end": 1791638801551392512,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "65eec64d60a0c2c3",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797646554368,
  "time_end": 1791638801550174464,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "c0a4154990417e6d",
  "parent_span_id": "7f9d5a8661b0cd97",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638808008504832,
  "time_end": 1791638810263003904,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "aef3ec16-a846-409d-a303-b0d7efe25bb5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9818,
    "process.parent_pid": 4205,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "13f4b1515443cbfa",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797636574720,
  "time_end": 1791638807506004992,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "b8aecc8972871ddd",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797645882880,
  "time_end": 1791638802194939904,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
  "trace_id": "b45e43a33b44d17fac43463d11aee488",
  "span_id": "7f9d5a8661b0cd97",
  "parent_span_id": "a4e373ee094e0b48",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1791638797664926976,
  "time_end": 1791638810265442304,
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
    "telemetry.sdk.version": "5.63.0",
    "service.instance.id": "ab20a105-eac0-4324-893c-71e24fc25089",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/28721fe6-9fb4-4bb4-9746-0a4e2042d79d/resourceGroups/azure-westus3-general-28721fe6-9fb4-4bb4-9746-0a4e2042d79d/providers/Microsoft.Compute/virtualMachines/zg1hnBkJBbv2H6",
    "host.id": "abac1f8b-b386-469d-9b5c-3604f81a71b6",
    "host.name": "zg1hnBkJBbv2H6",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3057,
    "process.parent_pid": 2852,
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
