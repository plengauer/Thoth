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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "87aa8de05c82fd41",
  "parent_span_id": "e4fc3b1ef1dd880a",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772722301664141568,
  "time_end": 1772722302540201728,
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
      "00-fdb7856a5fef2f4372d86b9152ee401d-e4fc3b1ef1dd880a-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Thu, 05 Mar 2026 14:51:42 GMT"
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
      "W/\"0c7cb93b6b1b20341d24b5b9ec39313ef746c8ef7c316f725a894dfef5ed53b8\""
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
      "25"
    ],
    "http.response.header.x-ratelimit-used": [
      "35"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1772723819"
    ],
    "http.response.header.x-github-request-id": [
      "67C1:AF090:C4E7DE:C7E626:69A9987D"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 5331,
    "process.parent_pid": 3992,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "d32d7301264b4807",
  "parent_span_id": "9c3fc2ff2ca634a4",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772722302909817088,
  "time_end": 1772722303831113728,
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
      "00-fdb7856a5fef2f4372d86b9152ee401d-9c3fc2ff2ca634a4-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Thu, 05 Mar 2026 14:51:43 GMT"
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
      "W/\"ad178d6f9656bfb338f4d346bdf37d5fde988c7d863c8eaa4bc258765cad36a5\""
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
      "24"
    ],
    "http.response.header.x-ratelimit-used": [
      "36"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1772723819"
    ],
    "http.response.header.x-github-request-id": [
      "67C2:2948C9:C0E97D:C3EED0:69A9987E"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 6921,
    "process.parent_pid": 3992,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "fee45bf21903ea4a",
  "parent_span_id": "f7213fba46e75a35",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772722304203755520,
  "time_end": 1772722304974013440,
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
      "00-fdb7856a5fef2f4372d86b9152ee401d-f7213fba46e75a35-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Thu, 05 Mar 2026 14:51:44 GMT"
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
      "W/\"38cbdc4550e497cb67e140cbfb43d9d1fe68d665b9f8a9572d781fa573610f37\""
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
      "23"
    ],
    "http.response.header.x-ratelimit-used": [
      "37"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1772723819"
    ],
    "http.response.header.x-github-request-id": [
      "67C3:3BBD9F:C3612E:C6648A:69A99880"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 7930,
    "process.parent_pid": 3992,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "87233dc8575ea593",
  "parent_span_id": "33e7daa4cb4bec21",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772722305344730112,
  "time_end": 1772722306097549824,
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
      "00-fdb7856a5fef2f4372d86b9152ee401d-33e7daa4cb4bec21-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Thu, 05 Mar 2026 14:51:45 GMT"
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
      "W/\"c5c75072e517889c08be6a4be5b389e6e9a004c095644e8557f957ada069b57c\""
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
      "22"
    ],
    "http.response.header.x-ratelimit-used": [
      "38"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1772723819"
    ],
    "http.response.header.x-github-request-id": [
      "67C4:1B006E:C16503:C46985:69A99881"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 8938,
    "process.parent_pid": 3992,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "2b79f43252196987",
  "parent_span_id": "f90caa16bfa40735",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772722306612830976,
  "time_end": 1772722306873654528,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 9489,
    "process.parent_pid": 4009,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "7e577d60fd8f6fe6",
  "parent_span_id": "f90caa16bfa40735",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772722306799742976,
  "time_end": 1772722306988681728,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-05T15%3A35%3A53Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-05T14%3A34%3A59Z&ske=2026-03-05T15%3A35%3A53Z&sks=b&skv=2018-11-09&sig=DCHsnUoJTeOOi%2FQLZYsHHsvCX6rukNYEWK5A%2FQTwgWk%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MjcyMjYwNiwibmJmIjoxNzcyNzIyMzA2LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.Lq16QNr1c2NNeLflc_rlY2T-zM2Mzh8jU81WJz6oab0&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-05T15%3A35%3A53Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-05T14%3A34%3A59Z&ske=2026-03-05T15%3A35%3A53Z&sks=b&skv=2018-11-09&sig=DCHsnUoJTeOOi%2FQLZYsHHsvCX6rukNYEWK5A%2FQTwgWk%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MjcyMjYwNiwibmJmIjoxNzcyNzIyMzA2LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.Lq16QNr1c2NNeLflc_rlY2T-zM2Mzh8jU81WJz6oab0&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 9489,
    "process.parent_pid": 4009,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "0d70fa4bdf9b0397",
  "parent_span_id": "f90caa16bfa40735",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772722306913596416,
  "time_end": 1772722307200849664,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 9489,
    "process.parent_pid": 4009,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "fa7acc5fcefcf81e",
  "parent_span_id": "f90caa16bfa40735",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772722307127578368,
  "time_end": 1772722307317287424,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-05T15%3A47%3A06Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-05T14%3A46%3A57Z&ske=2026-03-05T15%3A47%3A06Z&sks=b&skv=2018-11-09&sig=hR%2FLasnUdbJ4LhT2Ue9RnCwWhts3NY%2B%2FTL%2Bn%2FnXI6g8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MjcyMjYwNywibmJmIjoxNzcyNzIyMzA3LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.f0lftP11_5MaESXHOZfiex3YfJ8f6T7S7YE___yI2UY&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-05T15%3A47%3A06Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-05T14%3A46%3A57Z&ske=2026-03-05T15%3A47%3A06Z&sks=b&skv=2018-11-09&sig=hR%2FLasnUdbJ4LhT2Ue9RnCwWhts3NY%2B%2FTL%2Bn%2FnXI6g8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MjcyMjYwNywibmJmIjoxNzcyNzIyMzA3LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.f0lftP11_5MaESXHOZfiex3YfJ8f6T7S7YE___yI2UY&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 9489,
    "process.parent_pid": 4009,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "bc149aef0d0b66c2",
  "parent_span_id": "f90caa16bfa40735",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772722307248971520,
  "time_end": 1772722307572025600,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 9489,
    "process.parent_pid": 4009,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "0ba0747e8b8a66a7",
  "parent_span_id": "f90caa16bfa40735",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772722307496493824,
  "time_end": 1772722307723048192,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.111.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-05T15%3A35%3A06Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-05T14%3A34%3A50Z&ske=2026-03-05T15%3A35%3A06Z&sks=b&skv=2018-11-09&sig=i4HUjL%2B0%2F2WTorQPA1TJAqtrN8G2XnBA%2BdiqSz7Yfsw%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MjcyMjYwNywibmJmIjoxNzcyNzIyMzA3LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.f0lftP11_5MaESXHOZfiex3YfJ8f6T7S7YE___yI2UY&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-05T15%3A35%3A06Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-03-05T14%3A34%3A50Z&ske=2026-03-05T15%3A35%3A06Z&sks=b&skv=2018-11-09&sig=i4HUjL%2B0%2F2WTorQPA1TJAqtrN8G2XnBA%2BdiqSz7Yfsw%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MjcyMjYwNywibmJmIjoxNzcyNzIyMzA3LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.f0lftP11_5MaESXHOZfiex3YfJ8f6T7S7YE___yI2UY&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 9489,
    "process.parent_pid": 4009,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "506b29549770494a",
  "parent_span_id": "26e5e2556dde6903",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1772722296513895936,
  "time_end": 1772722300196348928,
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
      "Thu, 05 Mar 2026 14:51:37 GMT"
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
      "W/\"0a26ebb245e3d269268bbddafa15a0ba0554445f07f94b7879a12b9adaa3dbb4\""
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
      "26"
    ],
    "http.response.header.x-ratelimit-used": [
      "34"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1772723819"
    ],
    "http.response.header.x-github-request-id": [
      "67C0:298541:C6DFF4:C9DA0D:69A99878"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "aae25cdf3548ed43",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1772722296150822912,
  "time_end": 1772722307733556480,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "e4fc3b1ef1dd880a",
  "parent_span_id": "b05820dbcf425923",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722301579378688,
  "time_end": 1772722302601098496,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 464,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 5331,
    "process.parent_pid": 3992,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "9c3fc2ff2ca634a4",
  "parent_span_id": "b05820dbcf425923",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722302830652672,
  "time_end": 1772722303892278528,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 464,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 6921,
    "process.parent_pid": 3992,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "f7213fba46e75a35",
  "parent_span_id": "b05820dbcf425923",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722304121425920,
  "time_end": 1772722305035363328,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 464,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 7930,
    "process.parent_pid": 3992,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "33e7daa4cb4bec21",
  "parent_span_id": "b05820dbcf425923",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722305264085248,
  "time_end": 1772722306173254400,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 464,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 8938,
    "process.parent_pid": 3992,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "a335891331862eee",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296177720576,
  "time_end": 1772722300204760832,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "61bd1f0c0301d1f2",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296177211904,
  "time_end": 1772722300214399232,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "301b8e0ec96d5d72",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296200294656,
  "time_end": 1772722300224186368,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "f84bd43069c787ca",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296198130176,
  "time_end": 1772722300216759808,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "c20fc4d6a366ef9f",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296195287808,
  "time_end": 1772722306185815296,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "14d95df3aa2f5a85",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296176880128,
  "time_end": 1772722300202423040,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "467d7659e178b510",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296224829184,
  "time_end": 1772722300221652736,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "204abb3ea1b0e8a5",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1772722296209938432,
  "time_end": 1772722306189213952,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "a10c004525ea9ac5",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296200983552,
  "time_end": 1772722300211996160,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "f14f1420faa96bde",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296198308608,
  "time_end": 1772722305778051072,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "e3d0eec8747de989",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296220398848,
  "time_end": 1772722306182507776,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "a961a8e40d3c36c7",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1772722296176729088,
  "time_end": 1772722300197567232,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "04c2e4df02d32670",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296169090816,
  "time_end": 1772722296256652032,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "26e5e2556dde6903",
  "parent_span_id": "a961a8e40d3c36c7",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1772722296299383040,
  "time_end": 1772722300196377600,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "601e820f40c28044",
  "parent_span_id": "c153d63c53f1bdc4",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722300887285504,
  "time_end": 1772722300903422208,
  "attributes": {
    "shell.command_line": "seq 1 4",
    "shell.command": "seq",
    "shell.command.type": "file",
    "shell.command.name": "seq",
    "subprocess.executable.path": "/usr/bin/seq",
    "subprocess.executable.name": "seq",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 464,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 4721,
    "process.parent_pid": 3981,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "15ac93558bef3b98",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296210393088,
  "time_end": 1772722300219154432,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "2d47f8e163804150",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296177011712,
  "time_end": 1772722300209574400,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "456f602cd553cc23",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296216653568,
  "time_end": 1772722300207196928,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "d4cc15b31eb33e86",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296184958720,
  "time_end": 1772722300200019456,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "f90caa16bfa40735",
  "parent_span_id": "6495acdf2940310e",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722306518130432,
  "time_end": 1772722307727745024,
  "attributes": {
    "shell.command_line": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
    "shell.command": "wget",
    "shell.command.type": "file",
    "shell.command.name": "wget",
    "subprocess.executable.path": "/usr/bin/wget",
    "subprocess.executable.name": "wget",
    "shell.command.exit_code": 0,
    "code.filepath": "/usr/bin/otel.sh",
    "code.lineno": 464,
    "code.function": "_otel_inject"
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 9489,
    "process.parent_pid": 4009,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "b05820dbcf425923",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296205903872,
  "time_end": 1772722306178512128,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "c153d63c53f1bdc4",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296205721344,
  "time_end": 1772722300908414464,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
  "trace_id": "fdb7856a5fef2f4372d86b9152ee401d",
  "span_id": "6495acdf2940310e",
  "parent_span_id": "aae25cdf3548ed43",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1772722296210260480,
  "time_end": 1772722307732648192,
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
    "telemetry.sdk.version": "5.47.1",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "westus",
    "cloud.resource_id": "/subscriptions/8b750a8a-d62c-4b61-9624-363a23f2bb24/resourceGroups/azure-westus-general-8b750a8a-d62c-4b61-9624-363a23f2bb24/providers/Microsoft.Compute/virtualMachines/aK5c0NBbLmH72G",
    "host.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "host.name": "aK5c0NBbLmH72G",
    "host.type": "Standard_D4ads_v5",
    "os.type": "linux",
    "os.version": "6.14.0-1017-azure",
    "service.instance.id": "43c9f4b1-465e-40c7-99cf-8c48f77f1b1d",
    "process.pid": 2748,
    "process.parent_pid": 2550,
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
