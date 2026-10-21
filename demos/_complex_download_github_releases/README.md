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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "5d5f100db7c5065e",
  "parent_span_id": "e72aaeb6d1d43cce",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1792566633808749568,
  "time_end": 1792566634780007936,
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
      "00-17ae5843cc959d8efb1e4b4ca4e56a8f-e72aaeb6d1d43cce-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Wed, 21 Oct 2026 07:10:34 GMT"
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
      "W/\"c54c6bb17d52066a8d19243b41d82b49a1896d233deb6193ebb53a71bb7e62c0\""
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
      "1792568254"
    ],
    "http.response.header.x-github-request-id": [
      "E041:2B15DF:4D4595:FA40B8:6AD86569"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "d35c6636-51bf-431f-bd7a-d75088cf7d8f",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 5461,
    "process.parent_pid": 4182,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "5799eff1051771c0",
  "parent_span_id": "8943d1ba28d6c2e6",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1792566635151166464,
  "time_end": 1792566636021366784,
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
      "00-17ae5843cc959d8efb1e4b4ca4e56a8f-8943d1ba28d6c2e6-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Wed, 21 Oct 2026 07:10:35 GMT"
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
      "W/\"b965ebc64e77d986ab3878d0550679b84616ad99853b0b84051d89fc49909df8\""
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
      "1792568254"
    ],
    "http.response.header.x-github-request-id": [
      "E042:2BF1B5:4E7D9F:FE42FF:6AD8656B"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "c7b4c250-a90e-4892-b0af-2f10796f19fa",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 7004,
    "process.parent_pid": 4182,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "43a0f08e8b48a8b3",
  "parent_span_id": "96e8d07cb5490e06",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1792566636390820864,
  "time_end": 1792566637168989184,
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
      "00-17ae5843cc959d8efb1e4b4ca4e56a8f-96e8d07cb5490e06-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Wed, 21 Oct 2026 07:10:36 GMT"
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
      "W/\"a1ec710c3efeab75944ad9f0ca4c327c8d699b059948a9dd350a561fd1030c16\""
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
      "1792568254"
    ],
    "http.response.header.x-github-request-id": [
      "E043:2147FB:4AE151:F2E1E0:6AD8656C"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "0477fba2-64c2-45b4-8994-0200f10d76cd",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 7974,
    "process.parent_pid": 4182,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "10b468e13e0e5bde",
  "parent_span_id": "750b9eaa55880c30",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1792566637559269632,
  "time_end": 1792566638381307392,
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
      "00-17ae5843cc959d8efb1e4b4ca4e56a8f-750b9eaa55880c30-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Wed, 21 Oct 2026 07:10:37 GMT"
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
      "W/\"7652ca4e2bdc63223e7a848af40dc5b0ce906d097386a541da05a77b2a1bf892\""
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
      "1792568254"
    ],
    "http.response.header.x-github-request-id": [
      "E044:22F108:49B559:EEDE58:6AD8656D"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "28606736-e011-4db9-a019-5cb4f47965b6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 8945,
    "process.parent_pid": 4182,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "6bbd3bd23e42de09",
  "parent_span_id": "4fad491edd21b7d1",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1792566639257599744,
  "time_end": 1792566640292130048,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.114.4",
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "b8374e6f-4dd5-4406-bff9-bc79afcfb02c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 9916,
    "process.parent_pid": 4163,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "40080699e2f1ad46",
  "parent_span_id": "4fad491edd21b7d1",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1792566639482437376,
  "time_end": 1792566640411744256,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-10-21T07%3A57%3A15Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-10-21T06%3A56%3A33Z&ske=2026-10-21T07%3A57%3A15Z&sks=b&skv=2018-11-09&sig=DrLKXXaM%2BrCi6rRrMTtmPIjN%2Bv6trfaXvzkSLjMrYs8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MjU2NjkzOSwibmJmIjoxNzkyNTY2NjM5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.R9lFF138ng41aHO2CgyEM5DO-iUoo7Wec05yPiTcBjY&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-10-21T07%3A57%3A15Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-10-21T06%3A56%3A33Z&ske=2026-10-21T07%3A57%3A15Z&sks=b&skv=2018-11-09&sig=DrLKXXaM%2BrCi6rRrMTtmPIjN%2Bv6trfaXvzkSLjMrYs8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MjU2NjkzOSwibmJmIjoxNzkyNTY2NjM5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.R9lFF138ng41aHO2CgyEM5DO-iUoo7Wec05yPiTcBjY&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "b8374e6f-4dd5-4406-bff9-bc79afcfb02c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 9916,
    "process.parent_pid": 4163,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "bde9579ec828bb12",
  "parent_span_id": "4fad491edd21b7d1",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1792566640412431104,
  "time_end": 1792566640654646272,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.114.4",
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "b8374e6f-4dd5-4406-bff9-bc79afcfb02c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 9916,
    "process.parent_pid": 4163,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "76522826907290b0",
  "parent_span_id": "4fad491edd21b7d1",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1792566640611322880,
  "time_end": 1792566640790455040,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-10-21T08%3A09%3A34Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-10-21T07%3A09%3A33Z&ske=2026-10-21T08%3A09%3A34Z&sks=b&skv=2018-11-09&sig=jzUaKzqJ39jMwlEOzwVKcuTebhfi%2FhkwkhxTvpYwZyM%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MjU2Njk0MCwibmJmIjoxNzkyNTY2NjQwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.zufDG5kLZ_F4cmz3VEypPNCDFm7FOQvCSQmj46-8bFw&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-10-21T08%3A09%3A34Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-10-21T07%3A09%3A33Z&ske=2026-10-21T08%3A09%3A34Z&sks=b&skv=2018-11-09&sig=jzUaKzqJ39jMwlEOzwVKcuTebhfi%2FhkwkhxTvpYwZyM%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MjU2Njk0MCwibmJmIjoxNzkyNTY2NjQwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.zufDG5kLZ_F4cmz3VEypPNCDFm7FOQvCSQmj46-8bFw&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "b8374e6f-4dd5-4406-bff9-bc79afcfb02c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 9916,
    "process.parent_pid": 4163,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "29a5ab48a358fd51",
  "parent_span_id": "4fad491edd21b7d1",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1792566640788815104,
  "time_end": 1792566641067070464,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.114.4",
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "b8374e6f-4dd5-4406-bff9-bc79afcfb02c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 9916,
    "process.parent_pid": 4163,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "d17f0121ca0d9e71",
  "parent_span_id": "4fad491edd21b7d1",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1792566641023164928,
  "time_end": 1792566641124867584,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-10-21T07%3A53%3A58Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-10-21T06%3A53%3A51Z&ske=2026-10-21T07%3A53%3A58Z&sks=b&skv=2018-11-09&sig=N%2BF6nrXhOXXYnm8teUa7iVGTwyu%2B%2FC9AXVtNuy%2B5ktg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MjU2Njk0MCwibmJmIjoxNzkyNTY2NjQwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.zufDG5kLZ_F4cmz3VEypPNCDFm7FOQvCSQmj46-8bFw&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-10-21T07%3A53%3A58Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-10-21T06%3A53%3A51Z&ske=2026-10-21T07%3A53%3A58Z&sks=b&skv=2018-11-09&sig=N%2BF6nrXhOXXYnm8teUa7iVGTwyu%2B%2FC9AXVtNuy%2B5ktg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MjU2Njk0MCwibmJmIjoxNzkyNTY2NjQwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.zufDG5kLZ_F4cmz3VEypPNCDFm7FOQvCSQmj46-8bFw&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "b8374e6f-4dd5-4406-bff9-bc79afcfb02c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 9916,
    "process.parent_pid": 4163,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "458c88f58eb51e96",
  "parent_span_id": "3b6964f63c6405c3",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1792566628559141376,
  "time_end": 1792566632313667840,
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
      "Wed, 21 Oct 2026 07:10:29 GMT"
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
      "W/\"0c84f378ac0e0861ae03ad03accc0e843b5db89e005bba605e0821642a8f2cf7\""
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
      "1792568254"
    ],
    "http.response.header.x-github-request-id": [
      "E040:2BC06D:4BBF59:F54CDA:6AD86564"
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "3767435aa57dd504",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1792566628289580032,
  "time_end": 1792566641128849664,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "e72aaeb6d1d43cce",
  "parent_span_id": "c4a6171fed981c7f",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566633675276544,
  "time_end": 1792566634824994560,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 507,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "d35c6636-51bf-431f-bd7a-d75088cf7d8f",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 5461,
    "process.parent_pid": 4182,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "8943d1ba28d6c2e6",
  "parent_span_id": "c4a6171fed981c7f",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566635020263936,
  "time_end": 1792566636063376640,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 507,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "c7b4c250-a90e-4892-b0af-2f10796f19fa",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 7004,
    "process.parent_pid": 4182,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "96e8d07cb5490e06",
  "parent_span_id": "c4a6171fed981c7f",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566636259254016,
  "time_end": 1792566637213410048,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 507,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "0477fba2-64c2-45b4-8994-0200f10d76cd",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 7974,
    "process.parent_pid": 4182,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "750b9eaa55880c30",
  "parent_span_id": "c4a6171fed981c7f",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566637417523456,
  "time_end": 1792566638424739072,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 507,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "28606736-e011-4db9-a019-5cb4f47965b6",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 8945,
    "process.parent_pid": 4182,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "18f48814963c9523",
  "parent_span_id": "3767435aa57dd504",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628314153216,
  "time_end": 1792566632316278784,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "d7277f0cf053a009",
  "parent_span_id": "3767435aa57dd504",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628321555712,
  "time_end": 1792566632320502784,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "e123bd58a4c7703c",
  "parent_span_id": "3767435aa57dd504",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628321683968,
  "time_end": 1792566632324885504,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "7f96ba6fabcaacd8",
  "parent_span_id": "3767435aa57dd504",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628322202880,
  "time_end": 1792566632321539584,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "e171336b4c011c0d",
  "parent_span_id": "3767435aa57dd504",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628322044672,
  "time_end": 1792566638430149376,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "71469402fa0a1340",
  "parent_span_id": "3767435aa57dd504",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628321948672,
  "time_end": 1792566632315267584,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "020ff4cf242e5ffb",
  "parent_span_id": "3767435aa57dd504",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628317102080,
  "time_end": 1792566632323703040,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "665fe98293867e24",
  "parent_span_id": "3767435aa57dd504",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1792566628315216128,
  "time_end": 1792566638433331456,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "f4f52b1c788375d3",
  "parent_span_id": "3767435aa57dd504",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628315099648,
  "time_end": 1792566632319453696,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "7705c8a68ea26da0",
  "parent_span_id": "3767435aa57dd504",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628333640704,
  "time_end": 1792566638430120192,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "10c5572b15633084",
  "parent_span_id": "3767435aa57dd504",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628324365824,
  "time_end": 1792566638428728576,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "567a5fa2946e1aab",
  "parent_span_id": "3767435aa57dd504",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1792566628305712384,
  "time_end": 1792566632313751808,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "e0ebaeb9191ed4ef",
  "parent_span_id": "3767435aa57dd504",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628299730432,
  "time_end": 1792566628333789440,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "3b6964f63c6405c3",
  "parent_span_id": "567a5fa2946e1aab",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1792566628358938112,
  "time_end": 1792566632313698816,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "499975d43ff92bab",
  "parent_span_id": "ffae67d8f44d95e3",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566632984218880,
  "time_end": 1792566632993713152,
  "attributes": {
    "shell.command_line": "seq 1 4",
    "shell.command": "seq",
    "shell.command.type": "file",
    "shell.command.name": "seq",
    "subprocess.executable.path": "/usr/bin/seq",
    "subprocess.executable.name": "seq",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 507,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "16e832f2-cf53-49c4-a0e6-817c8174313c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 4863,
    "process.parent_pid": 4156,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "28fd32d7d01ee428",
  "parent_span_id": "3767435aa57dd504",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628323977984,
  "time_end": 1792566632322611968,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "328a37582940fd4c",
  "parent_span_id": "3767435aa57dd504",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628314441728,
  "time_end": 1792566632318403840,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "88e3dde04067f204",
  "parent_span_id": "3767435aa57dd504",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628314337024,
  "time_end": 1792566632317311744,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "81c71c3423bd5e78",
  "parent_span_id": "3767435aa57dd504",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628322130176,
  "time_end": 1792566632314208000,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "4fad491edd21b7d1",
  "parent_span_id": "35ddd4733d27e2a3",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566639111693312,
  "time_end": 1792566641126039296,
  "attributes": {
    "shell.command_line": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
    "shell.command": "wget",
    "shell.command.type": "file",
    "shell.command.name": "wget",
    "subprocess.executable.path": "/usr/bin/wget",
    "subprocess.executable.name": "wget",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 507,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "b8374e6f-4dd5-4406-bff9-bc79afcfb02c",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 9916,
    "process.parent_pid": 4163,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "c4a6171fed981c7f",
  "parent_span_id": "3767435aa57dd504",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628324243456,
  "time_end": 1792566638426458112,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "ffae67d8f44d95e3",
  "parent_span_id": "3767435aa57dd504",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628322575104,
  "time_end": 1792566632994757120,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
  "trace_id": "17ae5843cc959d8efb1e4b4ca4e56a8f",
  "span_id": "35ddd4733d27e2a3",
  "parent_span_id": "3767435aa57dd504",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1792566628321780736,
  "time_end": 1792566641127775744,
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
    "telemetry.sdk.version": "5.64.0",
    "service.instance.id": "5fb113b0-dedd-422f-a6cd-c82fc2164b73",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/6de7c00d-4568-4346-bbc6-9426fdd5533e/resourceGroups/azure-westus3-general-6de7c00d-4568-4346-bbc6-9426fdd5533e/providers/Microsoft.Compute/virtualMachines/mQLLbBiCOD8EBf",
    "host.id": "81c2f345-22d4-470f-9e56-257e8cfb3b58",
    "host.name": "mQLLbBiCOD8EBf",
    "host.type": "Standard_D4ads_v6",
    "os.type": "linux",
    "os.version": "7.0.0-1017-azure",
    "process.pid": 3020,
    "process.parent_pid": 2820,
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
