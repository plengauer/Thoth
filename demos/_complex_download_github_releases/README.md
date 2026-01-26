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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "0dac5dbf21155c96",
  "parent_span_id": "c8c4abe3a14511b2",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1769458658105757952,
  "time_end": 1769458658871557120,
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
      "00-98c4f51ac4dc6027d649936561e55212-c8c4abe3a14511b2-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 26 Jan 2026 20:17:38 GMT"
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
      "W/\"e8d13ecfda31e257f7b2e78dc6507a38581f321876da4b5b01f4ddeac288009a\""
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
      "45"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1769460007"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "15"
    ],
    "http.response.header.x-github-request-id": [
      "6441:255894:2F731F3:D2F90FC:6977CBE2"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 5405,
    "process.parent_pid": 4034,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "d3b8fa0b3e7c18fd",
  "parent_span_id": "6ce1a9b1ad8c5a94",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1769458659296519936,
  "time_end": 1769458659964465408,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.113.5",
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
      "00-98c4f51ac4dc6027d649936561e55212-6ce1a9b1ad8c5a94-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 26 Jan 2026 20:17:39 GMT"
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
      "W/\"92d9376baead7ff655da9b81eed2eec38429abf0148c04ec833f4ab50936022a\""
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
      "44"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1769460007"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "16"
    ],
    "http.response.header.x-github-request-id": [
      "6442:2C204F:2E1BC44:CE4B9CD:6977CBE3"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 6854,
    "process.parent_pid": 4034,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "e65fd8613df1ff5a",
  "parent_span_id": "7a2e1c2adf3e3def",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1769458660398200832,
  "time_end": 1769458661165852160,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.113.5",
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
      "00-98c4f51ac4dc6027d649936561e55212-7a2e1c2adf3e3def-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 26 Jan 2026 20:17:40 GMT"
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
      "W/\"d9500f4effffe711f969a75ee5bd63dbdb578b583aff23ca2a850b031610f9e0\""
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
      "43"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1769460007"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "17"
    ],
    "http.response.header.x-github-request-id": [
      "6443:BA5DC:2F3E292:D3BF78C:6977CBE4"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 7718,
    "process.parent_pid": 4034,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "007d5a397318f928",
  "parent_span_id": "0a06d3e8cac013cb",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1769458661594475264,
  "time_end": 1769458662154580224,
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
      "00-98c4f51ac4dc6027d649936561e55212-0a06d3e8cac013cb-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 26 Jan 2026 20:17:41 GMT"
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
      "W/\"26be1ef72288f65ccc30464e1b021234a63fc6c2829190b7cfa152cc876a1a23\""
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
      "42"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1769460007"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "18"
    ],
    "http.response.header.x-github-request-id": [
      "6444:24CB0F:300516E:D6DD997:6977CBE5"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 8582,
    "process.parent_pid": 4034,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "483f35949e052dfd",
  "parent_span_id": "358a6795b8889d13",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1769458662905022464,
  "time_end": 1769458663889893376,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 9260,
    "process.parent_pid": 4004,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "39eb131e48f91c04",
  "parent_span_id": "358a6795b8889d13",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1769458663104900864,
  "time_end": 1769458664002060544,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-01-26T20%3A51%3A47Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-01-26T19%3A51%3A27Z&ske=2026-01-26T20%3A51%3A47Z&sks=b&skv=2018-11-09&sig=eAdqNmv7rvKql%2BnPrloCv1zTScx1M%2BfRuVuigIu1u%2B0%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2OTQ1ODk2MywibmJmIjoxNzY5NDU4NjYzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.jk9RM6ybb4EI6v_Ak8xojH3jFmP3pxOFaG4xMfTpupU&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-01-26T20%3A51%3A47Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-01-26T19%3A51%3A27Z&ske=2026-01-26T20%3A51%3A47Z&sks=b&skv=2018-11-09&sig=eAdqNmv7rvKql%2BnPrloCv1zTScx1M%2BfRuVuigIu1u%2B0%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2OTQ1ODk2MywibmJmIjoxNzY5NDU4NjYzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.jk9RM6ybb4EI6v_Ak8xojH3jFmP3pxOFaG4xMfTpupU&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 9260,
    "process.parent_pid": 4004,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "ce1de9bcc0e1ae56",
  "parent_span_id": "358a6795b8889d13",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1769458664048289280,
  "time_end": 1769458665031584512,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 9260,
    "process.parent_pid": 4004,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "b73e3826237343ee",
  "parent_span_id": "358a6795b8889d13",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1769458664232107520,
  "time_end": 1769458665136533504,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-01-26T20%3A53%3A30Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-01-26T19%3A53%3A04Z&ske=2026-01-26T20%3A53%3A30Z&sks=b&skv=2018-11-09&sig=Qr7%2BbmJYbYa6A7BK%2B2FuHj8k7%2FnnmSHi3BT5ajs93ow%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2OTQ1ODk2NCwibmJmIjoxNzY5NDU4NjY0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.2CV-nVD3ttfw8d5vnqPsivzINAJqwGUM7cGPORx3zXA&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-01-26T20%3A53%3A30Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-01-26T19%3A53%3A04Z&ske=2026-01-26T20%3A53%3A30Z&sks=b&skv=2018-11-09&sig=Qr7%2BbmJYbYa6A7BK%2B2FuHj8k7%2FnnmSHi3BT5ajs93ow%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2OTQ1ODk2NCwibmJmIjoxNzY5NDU4NjY0LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.2CV-nVD3ttfw8d5vnqPsivzINAJqwGUM7cGPORx3zXA&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 9260,
    "process.parent_pid": 4004,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "f524d0e448756451",
  "parent_span_id": "358a6795b8889d13",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1769458665183973120,
  "time_end": 1769458666167109120,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 9260,
    "process.parent_pid": 4004,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "f9bffb6b31c44091",
  "parent_span_id": "358a6795b8889d13",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1769458665392636928,
  "time_end": 1769458666231645184,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-01-26T20%3A51%3A50Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-01-26T19%3A51%3A37Z&ske=2026-01-26T20%3A51%3A50Z&sks=b&skv=2018-11-09&sig=lNyvTG2eZsK7tS%2BpUB2WfVoCwFm8SUllUuyYTxuF3H8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2OTQ1ODk2NSwibmJmIjoxNzY5NDU4NjY1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.BfkMLKhIEy9rJQfPjLPqSQlRtjTaD45ruN2reS5kzDU&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-01-26T20%3A51%3A50Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-01-26T19%3A51%3A37Z&ske=2026-01-26T20%3A51%3A50Z&sks=b&skv=2018-11-09&sig=lNyvTG2eZsK7tS%2BpUB2WfVoCwFm8SUllUuyYTxuF3H8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2OTQ1ODk2NSwibmJmIjoxNzY5NDU4NjY1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.BfkMLKhIEy9rJQfPjLPqSQlRtjTaD45ruN2reS5kzDU&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 9260,
    "process.parent_pid": 4004,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "2a044c91acbae5e3",
  "parent_span_id": "c65cb12b249ffb99",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1769458653097985536,
  "time_end": 1769458656563894016,
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
      "Mon, 26 Jan 2026 20:17:33 GMT"
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
      "W/\"dfd0508912b718e5fced014ba9279f79ff3933bd2d2ace891a6eb67ec8778146\""
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
      "46"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1769460007"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "14"
    ],
    "http.response.header.x-github-request-id": [
      "6440:25A064:2F17490:D2FBB1E:6977CBDD"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "73dc6bee5686a5d7",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1769458652780635392,
  "time_end": 1769458666240874752,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "c8c4abe3a14511b2",
  "parent_span_id": "a32e9ee903d444b3",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458657954131712,
  "time_end": 1769458658877807872,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 5405,
    "process.parent_pid": 4034,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "6ce1a9b1ad8c5a94",
  "parent_span_id": "a32e9ee903d444b3",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458659152649216,
  "time_end": 1769458659968411392,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 6854,
    "process.parent_pid": 4034,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "7a2e1c2adf3e3def",
  "parent_span_id": "a32e9ee903d444b3",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458660250431232,
  "time_end": 1769458661169923584,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 7718,
    "process.parent_pid": 4034,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "0a06d3e8cac013cb",
  "parent_span_id": "a32e9ee903d444b3",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458661451315200,
  "time_end": 1769458662158785280,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 8582,
    "process.parent_pid": 4034,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "ce528351600fe43f",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652820109824,
  "time_end": 1769458656572184064,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "25d8868b8babca3b",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652819938560,
  "time_end": 1769458656581266944,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "aa315df001fa4fc5",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652814309888,
  "time_end": 1769458656590061824,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "ef45aeb957f54afe",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652814032384,
  "time_end": 1769458656583431936,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "8b985bce3c731c5e",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652818340608,
  "time_end": 1769458662169232640,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "f2915fc58084856e",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652819799552,
  "time_end": 1769458656569775104,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "afa4c3bbfc047592",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652830160640,
  "time_end": 1769458656587762176,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "41a54d51225a3206",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1769458652830452992,
  "time_end": 1769458662172730112,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "c1424613ab5ef291",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652813823744,
  "time_end": 1769458656579136256,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "8347731aa75547c2",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652830822400,
  "time_end": 1769458662023892480,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "f6613fdb9c15b349",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652810915584,
  "time_end": 1769458662166321664,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "4b023994941202e2",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1769458652807088640,
  "time_end": 1769458656565109760,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "2d2e39de6b5d687b",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652801694464,
  "time_end": 1769458652893423872,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "c65cb12b249ffb99",
  "parent_span_id": "4b023994941202e2",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1769458652897334272,
  "time_end": 1769458656563915520,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "4e75125f6d438bca",
  "parent_span_id": "44dc04f3a3e6c7a5",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458657253764352,
  "time_end": 1769458657268545792,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 4737,
    "process.parent_pid": 3991,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "b12a40911af30782",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652830606080,
  "time_end": 1769458656585569536,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "5582420cdd494cd3",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652814604032,
  "time_end": 1769458656576798720,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "ba30531a50618d47",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652820425216,
  "time_end": 1769458656574528256,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "90383167dde876b3",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652810777600,
  "time_end": 1769458656567459840,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "358a6795b8889d13",
  "parent_span_id": "0d5acb8fafbe8b4b",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458662737504000,
  "time_end": 1769458666235860480,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 9260,
    "process.parent_pid": 4004,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "a32e9ee903d444b3",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652842880512,
  "time_end": 1769458662163218944,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "44dc04f3a3e6c7a5",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652814181632,
  "time_end": 1769458657272767744,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
  "trace_id": "98c4f51ac4dc6027d649936561e55212",
  "span_id": "0d5acb8fafbe8b4b",
  "parent_span_id": "73dc6bee5686a5d7",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1769458652820277504,
  "time_end": 1769458666240070144,
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
    "telemetry.sdk.version": "5.42.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "WestUS3",
    "cloud.resource_id": "/subscriptions/e2510ac9-ec8e-4248-bcbc-d67d4a148df7/resourceGroups/azure-westus3-general-e2510ac9-ec8e-4248-bcbc-d67d4a148df7/providers/Microsoft.Compute/virtualMachines/oetaWJo8EKU2xp",
    "host.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "host.name": "oetaWJo8EKU2xp",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "3e0a006a-0f8d-4f8b-8da4-0594186fc017",
    "process.pid": 2718,
    "process.parent_pid": 2518,
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
