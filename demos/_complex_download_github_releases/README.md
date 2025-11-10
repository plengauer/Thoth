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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "40b5f35ba1a875b1",
  "parent_span_id": "07efdda4950a5564",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1762786045203406848,
  "time_end": 1762786045780062720,
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
      "00-9c3beadeac7b0b35f136a0df8af1f8ba-07efdda4950a5564-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 10 Nov 2025 14:47:25 GMT"
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
      "W/\"e4ceb63d4a1e08512846eeaec6d6c9481820f5e31a25c2ab9ddd8a7b87a54eb1\""
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
      "29"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1762786683"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "31"
    ],
    "http.response.header.x-github-request-id": [
      "B411:91A4D:48BDD8D:147CFCCC:6911FAFD"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 6024,
    "process.parent_pid": 4659,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "365b47a2adee68b7",
  "parent_span_id": "b1801f4d7de99a51",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1762786046170778112,
  "time_end": 1762786046782372608,
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
      "00-9c3beadeac7b0b35f136a0df8af1f8ba-b1801f4d7de99a51-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 10 Nov 2025 14:47:26 GMT"
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
      "W/\"40c7f7aa8a942b59313eb5e626b3dafc607cbcae3b343a2d3f71477ce9c8b93f\""
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
      "28"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1762786683"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "32"
    ],
    "http.response.header.x-github-request-id": [
      "B412:2764FC:FDD3EC7:487E46D6:6911FAFE"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 7505,
    "process.parent_pid": 4659,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "2b6ab4a08263f4da",
  "parent_span_id": "66bfa840ffc5e3cf",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1762786047164399104,
  "time_end": 1762786047776674816,
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
      "00-9c3beadeac7b0b35f136a0df8af1f8ba-66bfa840ffc5e3cf-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 10 Nov 2025 14:47:27 GMT"
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
      "W/\"cd3cb2bd83298b9ca3836ac70e3e3f404b90017898e40e976583aeb7d8037a5a\""
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
      "27"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1762786683"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "33"
    ],
    "http.response.header.x-github-request-id": [
      "B413:11C965:4AB6E5F:1503F5B7:6911FAFF"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 8402,
    "process.parent_pid": 4659,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "5c793bd82a0197d5",
  "parent_span_id": "fabf38141bf3bc69",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1762786048171314176,
  "time_end": 1762786048638997504,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.114.6",
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
      "00-9c3beadeac7b0b35f136a0df8af1f8ba-fabf38141bf3bc69-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Mon, 10 Nov 2025 14:47:28 GMT"
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
      "W/\"b107a21c7f69342c9f5e981b3f3d0f2bc2c676907594d92e52a307c5a70c155e\""
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
      "26"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1762786683"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "34"
    ],
    "http.response.header.x-github-request-id": [
      "B414:42811:43ABAB6:13149520:6911FB00"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 9298,
    "process.parent_pid": 4659,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "d08dd8c709391afe",
  "parent_span_id": "e27b81f9f7beec2e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1762786049503408896,
  "time_end": 1762786050527160832,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 10198,
    "process.parent_pid": 4613,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "1ee72476bef6bee3",
  "parent_span_id": "e27b81f9f7beec2e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1762786049673881856,
  "time_end": 1762786050564107264,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.108.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-10T15%3A28%3A39Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-10T14%3A28%3A15Z&ske=2025-11-10T15%3A28%3A39Z&sks=b&skv=2018-11-09&sig=qTOyD0bHz3TI%2B2YZRzbkUJjsmRMeqFjHNizU%2BHGXHqE%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2Mjc4NjM0OSwibmJmIjoxNzYyNzg2MDQ5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.KJGdUMeHtRALxfs8uZewmZbtQ26VbOtvJW7ZqYZWtLY&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-10T15%3A28%3A39Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-10T14%3A28%3A15Z&ske=2025-11-10T15%3A28%3A39Z&sks=b&skv=2018-11-09&sig=qTOyD0bHz3TI%2B2YZRzbkUJjsmRMeqFjHNizU%2BHGXHqE%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2Mjc4NjM0OSwibmJmIjoxNzYyNzg2MDQ5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.KJGdUMeHtRALxfs8uZewmZbtQ26VbOtvJW7ZqYZWtLY&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 10198,
    "process.parent_pid": 4613,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "2cdb2d9c66df1020",
  "parent_span_id": "e27b81f9f7beec2e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1762786050570242816,
  "time_end": 1762786051595749632,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 10198,
    "process.parent_pid": 4613,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "a7362d1ff710f3c9",
  "parent_span_id": "e27b81f9f7beec2e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1762786050733447168,
  "time_end": 1762786051633856256,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.108.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-10T15%3A27%3A32Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-10T14%3A27%3A04Z&ske=2025-11-10T15%3A27%3A32Z&sks=b&skv=2018-11-09&sig=Ajq01rkFuJ7E%2FUgtjdBYtzUNsl9JsDZguCHUxo1PMeY%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2Mjc4NjM1MCwibmJmIjoxNzYyNzg2MDUwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.L-uk8-V6emydLarQ4TZiYYr8MwJWH_WH4gxPPs_e_6Q&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-10T15%3A27%3A32Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-10T14%3A27%3A04Z&ske=2025-11-10T15%3A27%3A32Z&sks=b&skv=2018-11-09&sig=Ajq01rkFuJ7E%2FUgtjdBYtzUNsl9JsDZguCHUxo1PMeY%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2Mjc4NjM1MCwibmJmIjoxNzYyNzg2MDUwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.L-uk8-V6emydLarQ4TZiYYr8MwJWH_WH4gxPPs_e_6Q&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 10198,
    "process.parent_pid": 4613,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "c23e22bc09f9e541",
  "parent_span_id": "e27b81f9f7beec2e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1762786051633699072,
  "time_end": 1762786052663919104,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 10198,
    "process.parent_pid": 4613,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "b8c7e291694cb320",
  "parent_span_id": "e27b81f9f7beec2e",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1762786051770098944,
  "time_end": 1762786052689249792,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.108.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-10T15%3A28%3A38Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-10T14%3A27%3A59Z&ske=2025-11-10T15%3A28%3A38Z&sks=b&skv=2018-11-09&sig=KfxZCWDcTy0cfrABYAC5Nc%2FXNDkihS2Hq77y%2Fnbxg7c%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2Mjc4NjM1MSwibmJmIjoxNzYyNzg2MDUxLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.Ca2qe5JkUuYvenHScPk_yAVWwepOZRqcaQ2LyUUwyTk&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-10T15%3A28%3A38Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-10T14%3A27%3A59Z&ske=2025-11-10T15%3A28%3A38Z&sks=b&skv=2018-11-09&sig=KfxZCWDcTy0cfrABYAC5Nc%2FXNDkihS2Hq77y%2Fnbxg7c%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2Mjc4NjM1MSwibmJmIjoxNzYyNzg2MDUxLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.Ca2qe5JkUuYvenHScPk_yAVWwepOZRqcaQ2LyUUwyTk&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 10198,
    "process.parent_pid": 4613,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "d4d7d14cee7dbaf1",
  "parent_span_id": "d2361e7c3b536048",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1762786040121657088,
  "time_end": 1762786043642285056,
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
      "Mon, 10 Nov 2025 14:47:20 GMT"
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
      "W/\"635a77d51fe74b38383016d51dca9dacb2652508a105a86bdd68292ed6305ebb\""
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
      "30"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1762786683"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "30"
    ],
    "http.response.header.x-github-request-id": [
      "B410:DD54E:461BE66:13C927BA:6911FAF8"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "e422609d335969b8",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1762786039746899712,
  "time_end": 1762786052741392896,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "07efdda4950a5564",
  "parent_span_id": "fe4a0d15ac7fd0c7",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786045079628544,
  "time_end": 1762786045784289280,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 6024,
    "process.parent_pid": 4659,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "b1801f4d7de99a51",
  "parent_span_id": "fe4a0d15ac7fd0c7",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786046072677632,
  "time_end": 1762786046786728192,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 7505,
    "process.parent_pid": 4659,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "66bfa840ffc5e3cf",
  "parent_span_id": "fe4a0d15ac7fd0c7",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786047070518272,
  "time_end": 1762786047781088000,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 8402,
    "process.parent_pid": 4659,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "fabf38141bf3bc69",
  "parent_span_id": "fe4a0d15ac7fd0c7",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786048071943424,
  "time_end": 1762786048643649536,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 9298,
    "process.parent_pid": 4659,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "b260c6c1a99709f2",
  "parent_span_id": "e422609d335969b8",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039773020416,
  "time_end": 1762786043653606912,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "de5de0c67208c1d2",
  "parent_span_id": "e422609d335969b8",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039808180480,
  "time_end": 1762786043663426560,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "d8059024afaf9196",
  "parent_span_id": "e422609d335969b8",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039795743232,
  "time_end": 1762786043673283840,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "21623c9e687c78bb",
  "parent_span_id": "e422609d335969b8",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039808660480,
  "time_end": 1762786043665833472,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "d84b868101379ab8",
  "parent_span_id": "e422609d335969b8",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039799949056,
  "time_end": 1762786048695020032,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "89d7274a82c9d715",
  "parent_span_id": "e422609d335969b8",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039792753152,
  "time_end": 1762786043650983680,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "656abd3d2d9d35c8",
  "parent_span_id": "e422609d335969b8",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039795954176,
  "time_end": 1762786043670838528,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "c02f2c3563be4f5d",
  "parent_span_id": "e422609d335969b8",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1762786039808400384,
  "time_end": 1762786048698846720,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "c81bef77a20969e4",
  "parent_span_id": "e422609d335969b8",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039799603200,
  "time_end": 1762786043661025280,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "74fa3731673ab9c8",
  "parent_span_id": "e422609d335969b8",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039799779328,
  "time_end": 1762786048691844352,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "01e8bc77368e2e58",
  "parent_span_id": "e422609d335969b8",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039795506176,
  "time_end": 1762786048692164608,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "cc3806b80396470e",
  "parent_span_id": "e422609d335969b8",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1762786039773245696,
  "time_end": 1762786043646036736,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "0100575836d3049f",
  "parent_span_id": "e422609d335969b8",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039769224960,
  "time_end": 1762786039881718784,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "d2361e7c3b536048",
  "parent_span_id": "cc3806b80396470e",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1762786039909381120,
  "time_end": 1762786043642307840,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "8d8c591d720a79bf",
  "parent_span_id": "ae2245f2934e49eb",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786044371357696,
  "time_end": 1762786044390110208,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 5348,
    "process.parent_pid": 4609,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "ebb061468ed2702e",
  "parent_span_id": "e422609d335969b8",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039776953856,
  "time_end": 1762786043668219392,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "4ceac5d57839afef",
  "parent_span_id": "e422609d335969b8",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039789720064,
  "time_end": 1762786043658479872,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "fae72be2bc86f578",
  "parent_span_id": "e422609d335969b8",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039781682176,
  "time_end": 1762786043656109056,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "5f4649fce9dfb393",
  "parent_span_id": "e422609d335969b8",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039777149952,
  "time_end": 1762786043648466432,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "e27b81f9f7beec2e",
  "parent_span_id": "00f9982d3757b2c8",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786049394076160,
  "time_end": 1762786052694422784,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 10198,
    "process.parent_pid": 4613,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "fe4a0d15ac7fd0c7",
  "parent_span_id": "e422609d335969b8",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039792295424,
  "time_end": 1762786048688851968,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "ae2245f2934e49eb",
  "parent_span_id": "e422609d335969b8",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039808808960,
  "time_end": 1762786044444508928,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
  "trace_id": "9c3beadeac7b0b35f136a0df8af1f8ba",
  "span_id": "00f9982d3757b2c8",
  "parent_span_id": "e422609d335969b8",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1762786039817241600,
  "time_end": 1762786052740699136,
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
    "telemetry.sdk.version": "5.33.3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "northcentralus",
    "cloud.resource_id": "/subscriptions/245e763f-a8e1-49d1-9f98-7c96dac48526/resourceGroups/azure-northcentralus-general-245e763f-a8e1-49d1-9f98-7c96dac48526/providers/Microsoft.Compute/virtualMachines/YvjKX9nFbKGhik",
    "host.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "host.name": "YvjKX9nFbKGhik",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.11.0-1018-azure",
    "service.instance.id": "b48926ac-5bdc-4a9c-a2c7-f500d75b1e89",
    "process.pid": 3146,
    "process.parent_pid": 2391,
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
