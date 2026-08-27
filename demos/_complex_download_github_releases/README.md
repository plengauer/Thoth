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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "485400ddca1ccbf0",
  "parent_span_id": "81e791b57ec8f248",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787583774709060352,
  "time_end": 1787583775631428096,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.116.6",
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
      "00-469368685b4fb3e5e7387552601a7d34-81e791b57ec8f248-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 24 Aug 2026 15:02:55 GMT"
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
      "W/\"f03827b0d283549a31d939cc74dec8c4b94466dd0a24713cac2edeb99bca3fd7\""
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
      "57"
    ],
    "http.response.header.x-ratelimit-used": [
      "3"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1787584643"
    ],
    "http.response.header.x-github-request-id": [
      "C421:13E63F:B99682D:C0F7E0B:6A8C5D1E"
    ],
    "http.response.header.x-github-edge-region": [
      "sea"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "060bd625-5fc9-4218-99f3-32380b002b61",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5461,
    "process.parent_pid": 4166,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "262563858af504d0",
  "parent_span_id": "87f6e081f0644ce8",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787583775975218944,
  "time_end": 1787583776799729408,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.116.6",
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
      "00-469368685b4fb3e5e7387552601a7d34-87f6e081f0644ce8-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 24 Aug 2026 15:02:56 GMT"
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
      "W/\"e17a45296749ae5647f855d446f39391a9d65dc55e60c03d20f533465eda142f\""
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
      "56"
    ],
    "http.response.header.x-ratelimit-used": [
      "4"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1787584643"
    ],
    "http.response.header.x-github-request-id": [
      "C422:D0BB5:BC4C0C5:C3ACD69:6A8C5D1F"
    ],
    "http.response.header.x-github-edge-region": [
      "sea"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "0350f82a-d242-4a58-9574-c2d7c5b5afd6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7005,
    "process.parent_pid": 4166,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "d60de6490b7b7641",
  "parent_span_id": "3ce4064a573c29d3",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787583777144678144,
  "time_end": 1787583777986318592,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.116.6",
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
      "00-469368685b4fb3e5e7387552601a7d34-3ce4064a573c29d3-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 24 Aug 2026 15:02:57 GMT"
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
      "W/\"e5aa7ead0c9b5d77645f11b2868d1bfdf11eed86370855b9b2366c63e5c14a82\""
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
      "55"
    ],
    "http.response.header.x-ratelimit-used": [
      "5"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1787584643"
    ],
    "http.response.header.x-github-request-id": [
      "C423:245286:BC364EE:C396F7C:6A8C5D21"
    ],
    "http.response.header.x-github-edge-region": [
      "sea"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "3ac2c9ea-60b6-4396-a030-71586a83e971",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7976,
    "process.parent_pid": 4166,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "075596283b7245ff",
  "parent_span_id": "9fd2d5b5dae10980",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787583778332299008,
  "time_end": 1787583779144721152,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.116.6",
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
      "00-469368685b4fb3e5e7387552601a7d34-9fd2d5b5dae10980-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 24 Aug 2026 15:02:58 GMT"
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
      "W/\"8059bc830212fe5f8372f929e8b3acf525679c6c881b3c637e8cedc1d850453b\""
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
      "54"
    ],
    "http.response.header.x-ratelimit-used": [
      "6"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1787584643"
    ],
    "http.response.header.x-github-request-id": [
      "C424:79ED:B4C7B82:BC2B497:6A8C5D22"
    ],
    "http.response.header.x-github-edge-region": [
      "sea"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "9a293de1-5920-4e76-9070-5edca12db6e5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8946,
    "process.parent_pid": 4166,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "679919238d0debba",
  "parent_span_id": "fe1e94d7adf44154",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787583780008656640,
  "time_end": 1787583780268036352,
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
    "service.instance.id": "2039c08d-92e7-40d6-b488-a46bfd4cc087",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9917,
    "process.parent_pid": 4157,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "f16e2cd56ed52cf8",
  "parent_span_id": "fe1e94d7adf44154",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787583780205675264,
  "time_end": 1787583780364239872,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-24T15%3A49%3A49Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-24T14%3A49%3A35Z&ske=2026-08-24T15%3A49%3A49Z&sks=b&skv=2018-11-09&sig=jx9tNvThQ0zxqQY2Cilklvj%2B%2FDpmsMetUq8Nj5Wx0ac%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NzU4NDA4MCwibmJmIjoxNzg3NTgzNzgwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.E7i6O_yjCUUXI0jkD2gJNhJsW8Le_6Fiqlmta2kSxgk&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-24T15%3A49%3A49Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-24T14%3A49%3A35Z&ske=2026-08-24T15%3A49%3A49Z&sks=b&skv=2018-11-09&sig=jx9tNvThQ0zxqQY2Cilklvj%2B%2FDpmsMetUq8Nj5Wx0ac%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NzU4NDA4MCwibmJmIjoxNzg3NTgzNzgwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.E7i6O_yjCUUXI0jkD2gJNhJsW8Le_6Fiqlmta2kSxgk&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "service.instance.id": "2039c08d-92e7-40d6-b488-a46bfd4cc087",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9917,
    "process.parent_pid": 4157,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "16a15c2429ecf8cb",
  "parent_span_id": "fe1e94d7adf44154",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787583780316722944,
  "time_end": 1787583780575986944,
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
    "service.instance.id": "2039c08d-92e7-40d6-b488-a46bfd4cc087",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9917,
    "process.parent_pid": 4157,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "c5cf4c4be32db363",
  "parent_span_id": "fe1e94d7adf44154",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787583780511346176,
  "time_end": 1787583780678306048,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-24T15%3A48%3A09Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-24T14%3A47%3A56Z&ske=2026-08-24T15%3A48%3A09Z&sks=b&skv=2018-11-09&sig=YoruKKoZKiUc%2BDNT%2BeDYm914ji%2FgsIkp8giD9g%2BVcRM%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NzU4NDA4MCwibmJmIjoxNzg3NTgzNzgwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.E7i6O_yjCUUXI0jkD2gJNhJsW8Le_6Fiqlmta2kSxgk&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-24T15%3A48%3A09Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-24T14%3A47%3A56Z&ske=2026-08-24T15%3A48%3A09Z&sks=b&skv=2018-11-09&sig=YoruKKoZKiUc%2BDNT%2BeDYm914ji%2FgsIkp8giD9g%2BVcRM%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NzU4NDA4MCwibmJmIjoxNzg3NTgzNzgwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.E7i6O_yjCUUXI0jkD2gJNhJsW8Le_6Fiqlmta2kSxgk&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "service.instance.id": "2039c08d-92e7-40d6-b488-a46bfd4cc087",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9917,
    "process.parent_pid": 4157,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "5b32d7e8a698b9b1",
  "parent_span_id": "fe1e94d7adf44154",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787583780630818304,
  "time_end": 1787583780882237952,
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
    "service.instance.id": "2039c08d-92e7-40d6-b488-a46bfd4cc087",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9917,
    "process.parent_pid": 4157,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "f15e295f2279a4ff",
  "parent_span_id": "fe1e94d7adf44154",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787583780817924352,
  "time_end": 1787583780913143040,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-24T15%3A37%3A07Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-24T14%3A36%3A56Z&ske=2026-08-24T15%3A37%3A07Z&sks=b&skv=2018-11-09&sig=PyST%2BkT0CShMm2gYk4BndEdUOUyhuowHRaIBFg6ilXc%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NzU4NDA4MCwibmJmIjoxNzg3NTgzNzgwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.E7i6O_yjCUUXI0jkD2gJNhJsW8Le_6Fiqlmta2kSxgk&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-08-24T15%3A37%3A07Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-08-24T14%3A36%3A56Z&ske=2026-08-24T15%3A37%3A07Z&sks=b&skv=2018-11-09&sig=PyST%2BkT0CShMm2gYk4BndEdUOUyhuowHRaIBFg6ilXc%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4NzU4NDA4MCwibmJmIjoxNzg3NTgzNzgwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.E7i6O_yjCUUXI0jkD2gJNhJsW8Le_6Fiqlmta2kSxgk&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "service.instance.id": "2039c08d-92e7-40d6-b488-a46bfd4cc087",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9917,
    "process.parent_pid": 4157,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "1140ebbedb47fc57",
  "parent_span_id": "f22038ccf16c9954",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1787583769599891968,
  "time_end": 1787583773190727680,
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
      "Mon, 24 Aug 2026 15:02:50 GMT"
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
      "W/\"4dbcc5943ac86efcb1d453ee883fb61b48aa8b9f1848f92ead8b74f685152e31\""
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
      "1787584643"
    ],
    "http.response.header.x-github-request-id": [
      "C420:ED860:B9A9E17:C10C57F:6A8C5D19"
    ],
    "http.response.header.x-github-edge-region": [
      "sea"
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "b687c90d55ba38d0",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1787583769305750528,
  "time_end": 1787583780917747712,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.2",
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "81e791b57ec8f248",
  "parent_span_id": "7b16e0509efd377d",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583774635978752,
  "time_end": 1787583775679185920,
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
    "service.instance.id": "060bd625-5fc9-4218-99f3-32380b002b61",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5461,
    "process.parent_pid": 4166,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "87f6e081f0644ce8",
  "parent_span_id": "7b16e0509efd377d",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583775903329792,
  "time_end": 1787583776847723520,
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
    "service.instance.id": "0350f82a-d242-4a58-9574-c2d7c5b5afd6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7005,
    "process.parent_pid": 4166,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "3ce4064a573c29d3",
  "parent_span_id": "7b16e0509efd377d",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583777074842880,
  "time_end": 1787583778034289152,
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
    "service.instance.id": "3ac2c9ea-60b6-4396-a030-71586a83e971",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7976,
    "process.parent_pid": 4166,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "9fd2d5b5dae10980",
  "parent_span_id": "7b16e0509efd377d",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583778260768000,
  "time_end": 1787583779193004544,
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
    "service.instance.id": "9a293de1-5920-4e76-9070-5edca12db6e5",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8946,
    "process.parent_pid": 4166,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "a1d853c4e6d9526d",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769325816576,
  "time_end": 1787583773191909120,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "dab3bb1572e88056",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769331676416,
  "time_end": 1787583773197106944,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "ad532701fd6eab8c",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769337715968,
  "time_end": 1787583773202109696,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "edd39dd192a88fdf",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769325592832,
  "time_end": 1787583773198360832,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "315ac0a97c1b1aad",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769352004096,
  "time_end": 1787583779198454784,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "2213f9523763c032",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769337939200,
  "time_end": 1787583773190865920,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "ec7e95df3eb991c8",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769335744256,
  "time_end": 1787583773200969728,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "cd453c8a74ccd8b2",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1787583769345744128,
  "time_end": 1787583779200884992,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "ac06076ffd40679b",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769352151552,
  "time_end": 1787583773195823872,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "812180ee3018f0a9",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769348219904,
  "time_end": 1787583779196631040,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "1a7bf7c22a6fde8c",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769360243712,
  "time_end": 1787583779196797696,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "853ce8200c7012fe",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1787583769321364224,
  "time_end": 1787583773190810368,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "11df4135c2e31800",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769317654272,
  "time_end": 1787583769351900160,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "f22038ccf16c9954",
  "parent_span_id": "853ce8200c7012fe",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1787583769395587328,
  "time_end": 1787583773190752512,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "7ea079b150cbd507",
  "parent_span_id": "174de5b4bdf0f7c4",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583773897135872,
  "time_end": 1787583773906404352,
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
    "service.instance.id": "8e66863d-0545-4976-a4b1-c1d995ec8fb2",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4863,
    "process.parent_pid": 4168,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "be7f2a32eec56cf0",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769335897600,
  "time_end": 1787583773199653120,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "2ce6f0c21c6b4473",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769335577600,
  "time_end": 1787583773194458112,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "ce45da9d3753fdc8",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769329533696,
  "time_end": 1787583773193176832,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "0d1809165a4ea8ec",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769322771712,
  "time_end": 1787583773190839040,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "fe1e94d7adf44154",
  "parent_span_id": "8ca9189fc675d7ff",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583779928313856,
  "time_end": 1787583780914749696,
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
    "service.instance.id": "2039c08d-92e7-40d6-b488-a46bfd4cc087",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9917,
    "process.parent_pid": 4157,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "7b16e0509efd377d",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769349619968,
  "time_end": 1787583779194834944,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "174de5b4bdf0f7c4",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769338917888,
  "time_end": 1787583773908541184,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
  "trace_id": "469368685b4fb3e5e7387552601a7d34",
  "span_id": "8ca9189fc675d7ff",
  "parent_span_id": "b687c90d55ba38d0",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1787583769360569344,
  "time_end": 1787583780917221632,
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
    "service.instance.id": "34842182-af50-4d11-8bc7-658553634578",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/b57e0536-49d1-49a1-b3fb-048088d600d7/resourceGroups/azure-westus-general-b57e0536-49d1-49a1-b3fb-048088d600d7/providers/Microsoft.Compute/virtualMachines/2L6rFtcDOvI1ad",
    "host.id": "009ef4bb-edf9-4f6a-b9ec-b85207d80b75",
    "host.name": "2L6rFtcDOvI1ad",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 3020,
    "process.parent_pid": 2819,
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
