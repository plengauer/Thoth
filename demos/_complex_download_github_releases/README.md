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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "da4d124b77eb443b",
  "parent_span_id": "f320e00226af2818",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1770978778499601152,
  "time_end": 1770978779224695040,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.113.5",
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
      "00-14afb1c6d015bd8cd56074e7e2864a4a-f320e00226af2818-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 13 Feb 2026 10:32:58 GMT"
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
      "W/\"efa75454a77632903747c0733beb4c010239480dd1e8db2dd4af74d7058f8e68\""
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
      "55"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1770980137"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "5"
    ],
    "http.response.header.x-github-request-id": [
      "903A:E8555:9A8585:2A55BAE:698EFDDA"
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 5374,
    "process.parent_pid": 3996,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "3bbc1ca825b85c9b",
  "parent_span_id": "e2ea6aaa54baca3f",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1770978779642485504,
  "time_end": 1770978780322466560,
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
      "00-14afb1c6d015bd8cd56074e7e2864a4a-e2ea6aaa54baca3f-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 13 Feb 2026 10:33:00 GMT"
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
      "W/\"d6c367e85fae830c4c59c3220b0ec3a165ceecf134361f91309e4b7cf20c9031\""
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
      "54"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1770980137"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "6"
    ],
    "http.response.header.x-github-request-id": [
      "9038:501B8:9A2644:2A6FBEB:698EFDDB"
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 6824,
    "process.parent_pid": 3996,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "7e826a2906cbcd00",
  "parent_span_id": "133d61d8a1f836ff",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1770978780738936064,
  "time_end": 1770978781423014656,
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
      "00-14afb1c6d015bd8cd56074e7e2864a4a-133d61d8a1f836ff-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 13 Feb 2026 10:33:01 GMT"
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
      "W/\"5676fe75df6fcb6a0a75dc1da422115d6450d3b6c9ce76d6c328f5fb8dc9871e\""
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
      "53"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1770980137"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "7"
    ],
    "http.response.header.x-github-request-id": [
      "903A:E8555:9A9337:2A59748:698EFDDC"
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 7690,
    "process.parent_pid": 3996,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "cff2dceedb29edb5",
  "parent_span_id": "ec0d0b64e489c249",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1770978781832124160,
  "time_end": 1770978782384805888,
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
      "00-14afb1c6d015bd8cd56074e7e2864a4a-ec0d0b64e489c249-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Fri, 13 Feb 2026 10:33:02 GMT"
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
      "W/\"7a57f76df155bbfcb16b0f992208a994e2250026d14254ecbd254fbb8fd9b9c6\""
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
      "52"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1770980137"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "8"
    ],
    "http.response.header.x-github-request-id": [
      "903D:14179C:964BBD:292D704:698EFDDD"
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 8556,
    "process.parent_pid": 3996,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "7df20efb97d216fc",
  "parent_span_id": "2766a656d773bbfd",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1770978783162875136,
  "time_end": 1770978784134959872,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 9425,
    "process.parent_pid": 3994,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "79847e7a8d174de5",
  "parent_span_id": "2766a656d773bbfd",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1770978783401983488,
  "time_end": 1770978784256790016,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-13T11%3A08%3A05Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-13T10%3A07%3A50Z&ske=2026-02-13T11%3A08%3A05Z&sks=b&skv=2018-11-09&sig=Y04pn1EwEHZ%2BrFY%2BtYcON22XClX3VWEFsWvjswkAxKI%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MDk3OTA4MywibmJmIjoxNzcwOTc4NzgzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.YZ6CetIvQTViOpUyEluOt42r4p75XOtzBNtLtqyCK3A&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-13T11%3A08%3A05Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-13T10%3A07%3A50Z&ske=2026-02-13T11%3A08%3A05Z&sks=b&skv=2018-11-09&sig=Y04pn1EwEHZ%2BrFY%2BtYcON22XClX3VWEFsWvjswkAxKI%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MDk3OTA4MywibmJmIjoxNzcwOTc4NzgzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.YZ6CetIvQTViOpUyEluOt42r4p75XOtzBNtLtqyCK3A&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 9425,
    "process.parent_pid": 3994,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "d8f0fa79c6d551aa",
  "parent_span_id": "2766a656d773bbfd",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1770978784314504704,
  "time_end": 1770978785281222144,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 9425,
    "process.parent_pid": 3994,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "c134ff6b7baa1257",
  "parent_span_id": "2766a656d773bbfd",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1770978784558454272,
  "time_end": 1770978785401924864,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-13T11%3A09%3A12Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-13T10%3A08%3A29Z&ske=2026-02-13T11%3A09%3A12Z&sks=b&skv=2018-11-09&sig=kqp7E8OIk3%2BIYSQ%2F7%2Fl8KROeCb6ummNrF%2BwiP0UwXC8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MDk3OTA4NCwibmJmIjoxNzcwOTc4Nzg0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.5TDyh2cYZLEEksdf-G6ilwHqUByIdtHE5eI_3LxRqaE&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-13T11%3A09%3A12Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-13T10%3A08%3A29Z&ske=2026-02-13T11%3A09%3A12Z&sks=b&skv=2018-11-09&sig=kqp7E8OIk3%2BIYSQ%2F7%2Fl8KROeCb6ummNrF%2BwiP0UwXC8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MDk3OTA4NCwibmJmIjoxNzcwOTc4Nzg0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.5TDyh2cYZLEEksdf-G6ilwHqUByIdtHE5eI_3LxRqaE&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 9425,
    "process.parent_pid": 3994,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "a1460d5ea38c9114",
  "parent_span_id": "2766a656d773bbfd",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1770978785458203904,
  "time_end": 1770978786427703040,
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
    "telemetry.sdk.version": "5.43.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 9425,
    "process.parent_pid": 3994,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "0d23b6f15dc37226",
  "parent_span_id": "2766a656d773bbfd",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1770978785728196096,
  "time_end": 1770978786498290944,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-13T11%3A06%3A50Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-13T10%3A06%3A21Z&ske=2026-02-13T11%3A06%3A50Z&sks=b&skv=2018-11-09&sig=WmSSAiN3T6ZIsLE3PB8yOVpL7w9ssEYnJQydaUOULwg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MDk3OTA4NSwibmJmIjoxNzcwOTc4Nzg1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.De7bE7HVG67rNpSIEmEIRa4kWxpbL8FNCLc5hPaIKG4&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-13T11%3A06%3A50Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-13T10%3A06%3A21Z&ske=2026-02-13T11%3A06%3A50Z&sks=b&skv=2018-11-09&sig=WmSSAiN3T6ZIsLE3PB8yOVpL7w9ssEYnJQydaUOULwg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MDk3OTA4NSwibmJmIjoxNzcwOTc4Nzg1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.De7bE7HVG67rNpSIEmEIRa4kWxpbL8FNCLc5hPaIKG4&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 9425,
    "process.parent_pid": 3994,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "427209f65dd9d7f8",
  "parent_span_id": "ee357342b9b95dd1",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1770978773508477184,
  "time_end": 1770978777125768192,
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
      "Fri, 13 Feb 2026 10:32:54 GMT"
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
      "W/\"a284ee326ae072aa0e61e8ed65fa93af969185426c0ba250cec3270304a60f62\""
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
      "1770980137"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "4"
    ],
    "http.response.header.x-github-request-id": [
      "9038:501B8:9A007B:2A65666:698EFDD5"
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "a8535bb3b9a37530",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1770978773160639488,
  "time_end": 1770978786506881536,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "f320e00226af2818",
  "parent_span_id": "8df860d72167c199",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978778344341248,
  "time_end": 1770978779229521920,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 5374,
    "process.parent_pid": 3996,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "e2ea6aaa54baca3f",
  "parent_span_id": "8df860d72167c199",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978779486088192,
  "time_end": 1770978780327148800,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 6824,
    "process.parent_pid": 3996,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "133d61d8a1f836ff",
  "parent_span_id": "8df860d72167c199",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978780578277376,
  "time_end": 1770978781427720704,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 7690,
    "process.parent_pid": 3996,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "ec0d0b64e489c249",
  "parent_span_id": "8df860d72167c199",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978781681313024,
  "time_end": 1770978782388150528,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 8556,
    "process.parent_pid": 3996,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "aa5cc87d631e8db0",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773208092672,
  "time_end": 1770978777130893824,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "b4fa8d94ce8be26d",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773196772096,
  "time_end": 1770978777138496512,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "7751229972dbee3d",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773211428608,
  "time_end": 1770978777145996032,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "6c6e1c710c5a01ef",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773201814528,
  "time_end": 1770978777140360960,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "6c68c210897bfc8a",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773183060992,
  "time_end": 1770978782397273600,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "c286b1bcba2f1de6",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773185172480,
  "time_end": 1770978777129039360,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "48a48482bf4be038",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773196472832,
  "time_end": 1770978777144162304,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "f9aa6c7f2d9b4a15",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1770978773201630464,
  "time_end": 1770978782399951360,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "04bc04feb323b886",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773189719552,
  "time_end": 1770978777136555008,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "e5fb1b4fa90554ca",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773207827968,
  "time_end": 1770978782393800192,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "42e22d1b3ff74bbc",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773216216576,
  "time_end": 1770978782394624256,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "d80ee83c121a4863",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1770978773189859584,
  "time_end": 1770978777125853184,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "a18229e43d4c17bb",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773182628608,
  "time_end": 1770978773262867968,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "ee357342b9b95dd1",
  "parent_span_id": "d80ee83c121a4863",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1770978773274982400,
  "time_end": 1770978777125800448,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "cffc49dec4f535b4",
  "parent_span_id": "39cc4225d382340e",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978777733717504,
  "time_end": 1770978777746866432,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 4706,
    "process.parent_pid": 3966,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "bb2cfde0efaa2354",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773196656896,
  "time_end": 1770978777142219264,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "f9fb0b79d1ff6d1b",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773185029376,
  "time_end": 1770978777134644480,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "c5b9e3f2272d6b7c",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773192523520,
  "time_end": 1770978777132793600,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "73224f7bbbf1b01b",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773182903296,
  "time_end": 1770978777127057920,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "2766a656d773bbfd",
  "parent_span_id": "60d8bb8fa7114b7a",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978782987511040,
  "time_end": 1770978786502516480,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 9425,
    "process.parent_pid": 3994,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "8df860d72167c199",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773201940992,
  "time_end": 1770978782391352064,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "39cc4225d382340e",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773203477760,
  "time_end": 1770978777750767872,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
  "trace_id": "14afb1c6d015bd8cd56074e7e2864a4a",
  "span_id": "60d8bb8fa7114b7a",
  "parent_span_id": "a8535bb3b9a37530",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1770978773211634176,
  "time_end": 1770978786506000128,
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
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/a265f88d-e0f6-44af-9bd5-f86522ac54b8/resourceGroups/azure-westus3-general-a265f88d-e0f6-44af-9bd5-f86522ac54b8/providers/Microsoft.Compute/virtualMachines/vk7avUmU3yL2zP",
    "host.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "host.name": "vk7avUmU3yL2zP",
    "host.type": "Standard_D4ds_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "d14f6e76-245a-4536-94b8-2100ccb1678c",
    "process.pid": 2688,
    "process.parent_pid": 2488,
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
