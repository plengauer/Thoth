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
```json
{
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "853e5cc8b2ff6f39",
  "parent_span_id": "d59e7327bd2654ed",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787429257347554304,
  "time_end": 1787429258182776064,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "172.182.252.137",
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
      "00-aaa89fa53a5ed64a455e1f1de2fd01c7-d59e7327bd2654ed-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 22 Aug 2026 20:07:37 GMT"
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
      "W/\"42dbd4b0df402cbfd2885bbafb6aedb0682df978e0efa1f5bdabb06a56655250\""
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
      "58"
    ],
    "http.response.header.x-ratelimit-used": [
      "2"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1787432852"
    ],
    "http.response.header.x-github-request-id": [
      "FC21:1EE8F7:108ABCE:1338E84:6A8A0189"
    ],
    "http.response.header.x-github-edge-region": [
      "westus3"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "839cf5a2-ec24-47e4-93a5-0654405227d0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5453,
    "process.parent_pid": 4156,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "d2434754b24e581b",
  "parent_span_id": "636008cf35d00403",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787429258508646144,
  "time_end": 1787429259230473984,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "172.182.252.137",
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
      "00-aaa89fa53a5ed64a455e1f1de2fd01c7-636008cf35d00403-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 22 Aug 2026 20:07:38 GMT"
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
      "W/\"6574c282322da85c877a076c57f4839a4d58b9b94ed0e443002aae00b1fa0a5e\""
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
      "57"
    ],
    "http.response.header.x-ratelimit-used": [
      "3"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1787432852"
    ],
    "http.response.header.x-github-request-id": [
      "FC22:1D8BA7:109FF04:134DB2E:6A8A018A"
    ],
    "http.response.header.x-github-edge-region": [
      "westus3"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "1a6e6db5-6078-4351-aa63-68a9336498a6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 6996,
    "process.parent_pid": 4156,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "019514157007d218",
  "parent_span_id": "2e94908dac0e41b1",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787429259558708480,
  "time_end": 1787429260248773632,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "172.182.252.137",
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
      "00-aaa89fa53a5ed64a455e1f1de2fd01c7-2e94908dac0e41b1-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 22 Aug 2026 20:07:39 GMT"
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
      "W/\"f3c2584830a9fb6da25076b1f2fe1561424c9ab1d9311e27e1d8b749ce1da888\""
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
      "56"
    ],
    "http.response.header.x-ratelimit-used": [
      "4"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1787432852"
    ],
    "http.response.header.x-github-request-id": [
      "FC23:7B465:FE9B02:1296832:6A8A018B"
    ],
    "http.response.header.x-github-edge-region": [
      "westus3"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "0a53b3c3-cf37-47b2-9f47-85971150d53d",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7967,
    "process.parent_pid": 4156,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "296c31ae026e452a",
  "parent_span_id": "16d780d0255d94ab",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787429260575440384,
  "time_end": 1787429261285546496,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "172.182.252.137",
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
      "00-aaa89fa53a5ed64a455e1f1de2fd01c7-16d780d0255d94ab-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Sat, 22 Aug 2026 20:07:40 GMT"
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
      "W/\"b0b12f11a4a5af33145518cef09f9d348bb5c34e0daf75d319eac5fc6d746746\""
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
      "55"
    ],
    "http.response.header.x-ratelimit-used": [
      "5"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1787432852"
    ],
    "http.response.header.x-github-request-id": [
      "FC24:1CC1F9:1040AFD:12EF0C4:6A8A018C"
    ],
    "http.response.header.x-github-edge-region": [
      "westus3"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "dd7fc32d-01a5-44dd-9f2b-dc87d3b00650",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8937,
    "process.parent_pid": 4156,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "6e9ecefd1d97dec5",
  "parent_span_id": "c4e401f6e024b4af",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787429262148705024,
  "time_end": 1787429263224956416,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "172.182.252.133",
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "e6d71cbd-3db6-472d-ac8f-26787df1bd30",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9907,
    "process.parent_pid": 4154,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "f2ecbf006e8e6191",
  "parent_span_id": "c4e401f6e024b4af",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787429262325118720,
  "time_end": 1787429263317446912,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-22T20%3A52%3A38Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-22T19%3A52%3A21Z&ske=2026-08-22T20%3A52%3A38Z&sks=b&skv=2018-11-09&sig=7J1Qo%2FrE%2B37UGQrdH9xhKZWdTZuUmEQk0bfjeuvnMG8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NzQyOTU2MiwibmJmIjoxNzg3NDI5MjYyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.E7wcd8p8IMZfphpbAqBB-eGoXypzmAhtky5FwmVxuAE&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-22T20%3A52%3A38Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-22T19%3A52%3A21Z&ske=2026-08-22T20%3A52%3A38Z&sks=b&skv=2018-11-09&sig=7J1Qo%2FrE%2B37UGQrdH9xhKZWdTZuUmEQk0bfjeuvnMG8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NzQyOTU2MiwibmJmIjoxNzg3NDI5MjYyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.E7wcd8p8IMZfphpbAqBB-eGoXypzmAhtky5FwmVxuAE&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "e6d71cbd-3db6-472d-ac8f-26787df1bd30",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9907,
    "process.parent_pid": 4154,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "890d1ed965002a66",
  "parent_span_id": "c4e401f6e024b4af",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787429263275378432,
  "time_end": 1787429263517143040,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "172.182.252.133",
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "e6d71cbd-3db6-472d-ac8f-26787df1bd30",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9907,
    "process.parent_pid": 4154,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "2142044385bac808",
  "parent_span_id": "c4e401f6e024b4af",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787429263455358464,
  "time_end": 1787429263611934720,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-22T20%3A54%3A05Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-22T19%3A53%3A06Z&ske=2026-08-22T20%3A54%3A05Z&sks=b&skv=2018-11-09&sig=LnllsSNJEMYfvpTIESJJQe4spT9bdA7RZrH2%2FSyLX6E%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NzQyOTU2MywibmJmIjoxNzg3NDI5MjYzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.lLfR_-mkxALhcRxtoSYYgCE_PntixsyAOmjFvHHhR1I&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-22T20%3A54%3A05Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-22T19%3A53%3A06Z&ske=2026-08-22T20%3A54%3A05Z&sks=b&skv=2018-11-09&sig=LnllsSNJEMYfvpTIESJJQe4spT9bdA7RZrH2%2FSyLX6E%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NzQyOTU2MywibmJmIjoxNzg3NDI5MjYzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.lLfR_-mkxALhcRxtoSYYgCE_PntixsyAOmjFvHHhR1I&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "e6d71cbd-3db6-472d-ac8f-26787df1bd30",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9907,
    "process.parent_pid": 4154,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "642c501b2a1dafd4",
  "parent_span_id": "c4e401f6e024b4af",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787429263566439424,
  "time_end": 1787429263800949504,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "172.182.252.133",
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "e6d71cbd-3db6-472d-ac8f-26787df1bd30",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9907,
    "process.parent_pid": 4154,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "18258e69391fe8ac",
  "parent_span_id": "c4e401f6e024b4af",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787429263744209920,
  "time_end": 1787429263852775936,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.110.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-22T20%3A50%3A53Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-22T19%3A50%3A04Z&ske=2026-08-22T20%3A50%3A53Z&sks=b&skv=2018-11-09&sig=mjG7oSD2adUw1GQguLUJkxr%2Be85b5%2B%2FsWI8wXbUhY9M%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NzQyOTU2MywibmJmIjoxNzg3NDI5MjYzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.lLfR_-mkxALhcRxtoSYYgCE_PntixsyAOmjFvHHhR1I&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-22T20%3A50%3A53Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-22T19%3A50%3A04Z&ske=2026-08-22T20%3A50%3A53Z&sks=b&skv=2018-11-09&sig=mjG7oSD2adUw1GQguLUJkxr%2Be85b5%2B%2FsWI8wXbUhY9M%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NzQyOTU2MywibmJmIjoxNzg3NDI5MjYzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.lLfR_-mkxALhcRxtoSYYgCE_PntixsyAOmjFvHHhR1I&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "e6d71cbd-3db6-472d-ac8f-26787df1bd30",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9907,
    "process.parent_pid": 4154,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "174db07f416b391c",
  "parent_span_id": "5b0cc1f2a794c745",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787429252276781312,
  "time_end": 1787429255817487616,
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
      "Sat, 22 Aug 2026 20:07:32 GMT"
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
      "W/\"9919168581455dd66096d2899b8044e2a1a6fcfe61a7797a952ea317e405bdf8\""
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
      "59"
    ],
    "http.response.header.x-ratelimit-used": [
      "1"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1787432852"
    ],
    "http.response.header.x-github-request-id": [
      "FC20:1F1FF2:FCECE9:127BC94:6A8A0184"
    ],
    "http.response.header.x-github-edge-region": [
      "westus3"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "59f08d8ab38defc4",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1787429251988942336,
  "time_end": 1787429263857726464,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "d59e7327bd2654ed",
  "parent_span_id": "3b496c65432a15f0",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429257276791296,
  "time_end": 1787429258229139456,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "839cf5a2-ec24-47e4-93a5-0654405227d0",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5453,
    "process.parent_pid": 4156,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "636008cf35d00403",
  "parent_span_id": "3b496c65432a15f0",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429258443427328,
  "time_end": 1787429259276567552,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "1a6e6db5-6078-4351-aa63-68a9336498a6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 6996,
    "process.parent_pid": 4156,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "2e94908dac0e41b1",
  "parent_span_id": "3b496c65432a15f0",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429259492465408,
  "time_end": 1787429260294887168,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "0a53b3c3-cf37-47b2-9f47-85971150d53d",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7967,
    "process.parent_pid": 4156,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "16d780d0255d94ab",
  "parent_span_id": "3b496c65432a15f0",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429260507493632,
  "time_end": 1787429261332035840,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "dd7fc32d-01a5-44dd-9f2b-dc87d3b00650",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8937,
    "process.parent_pid": 4156,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "b5c0a581fa8d0271",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252026115840,
  "time_end": 1787429255818982144,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "dbd38f3c09ba6493",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252016180736,
  "time_end": 1787429255824020736,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "6d63e45c1ccab298",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252032098816,
  "time_end": 1787429255829145856,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "c07d18b9e985d0d7",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252028185600,
  "time_end": 1787429255825338112,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "a0a3399a57234a97",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252024561664,
  "time_end": 1787429261337502208,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "f8540e877985e531",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252015684096,
  "time_end": 1787429255817810432,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "25d4ade8519773c0",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252022473216,
  "time_end": 1787429255827946752,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "e793ad9230f47254",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1787429252024373504,
  "time_end": 1787429261340479744,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "0b03327f33dfba20",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252007551744,
  "time_end": 1787429255822885632,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "33c8100506906468",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252022602752,
  "time_end": 1787429261336088832,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "8dd4dca636dc2d91",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252022065920,
  "time_end": 1787429261336118528,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "083389da5f3da0aa",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1787429252007204608,
  "time_end": 1787429255817593344,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "260e67f7f66d1798",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252007060992,
  "time_end": 1787429252057391872,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "5b0cc1f2a794c745",
  "parent_span_id": "083389da5f3da0aa",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1787429252076205824,
  "time_end": 1787429255817520896,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "865e59fbf2bdd8ca",
  "parent_span_id": "100cc99e0aff4768",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429256546574592,
  "time_end": 1787429256555447808,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "bc223a86-18ec-4ee2-8bb3-277c08842bd6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4855,
    "process.parent_pid": 4147,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "a54de25473019804",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252015844352,
  "time_end": 1787429255826635776,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "ac8c8d63059b76de",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252007403008,
  "time_end": 1787429255821711360,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "7ed5ab13fd642a3e",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252016014848,
  "time_end": 1787429255820390400,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "9a4b4837f8234ee6",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252006850560,
  "time_end": 1787429255817629440,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "c4e401f6e024b4af",
  "parent_span_id": "6e4f1a52d3758890",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429262063847168,
  "time_end": 1787429263854304256,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "e6d71cbd-3db6-472d-ac8f-26787df1bd30",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9907,
    "process.parent_pid": 4154,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "3b496c65432a15f0",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252007690240,
  "time_end": 1787429261333715968,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "100cc99e0aff4768",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252022254592,
  "time_end": 1787429256557632256,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
  "trace_id": "aaa89fa53a5ed64a455e1f1de2fd01c7",
  "span_id": "6e4f1a52d3758890",
  "parent_span_id": "59f08d8ab38defc4",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787429252019388160,
  "time_end": 1787429263856298752,
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
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "63cc3022-9253-4ec9-9f6f-76998b6365e6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/00dff12c-aa37-49c2-9803-a5cc1ebb9758/resourceGroups/azure-westus-general-00dff12c-aa37-49c2-9803-a5cc1ebb9758/providers/Microsoft.Compute/virtualMachines/tomuFkOfdJhT2p",
    "host.id": "d3f4bd8a-5961-4570-b9f3-b2cb978dfb0e",
    "host.name": "tomuFkOfdJhT2p",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3012,
    "process.parent_pid": 2811,
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
