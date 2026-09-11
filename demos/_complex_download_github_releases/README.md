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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "f1ec2ec06d322597",
  "parent_span_id": "0b0788cf870a9b36",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274391053922304,
  "time_end": 1788274391902966528,
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
      "00-d3fb8afaa4b6d067f56c7df2c87b9a61-0b0788cf870a9b36-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Tue, 01 Sep 2026 14:53:11 GMT"
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
      "W/\"af3ff390f00280a2e93cab0e0d06724358cbf7781af557f8dc5d7453c24b61d5\""
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
      "49"
    ],
    "http.response.header.x-ratelimit-used": [
      "11"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1788275631"
    ],
    "http.response.header.x-github-request-id": [
      "A02A:A7759:AAB6D1:234E846:6A96E6D7"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "2180b6dc-4669-4839-8039-4213f344b93d",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5319,
    "process.parent_pid": 4020,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "74551254482f9ed2",
  "parent_span_id": "0f7aad7b5b83164b",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274392194716160,
  "time_end": 1788274392837465600,
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
      "00-d3fb8afaa4b6d067f56c7df2c87b9a61-0f7aad7b5b83164b-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Tue, 01 Sep 2026 14:53:12 GMT"
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
      "W/\"8312adcb250a3cc53b3840021f0dce16b1d0394386b6aa27673bdc4f49444b5f\""
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
      "48"
    ],
    "http.response.header.x-ratelimit-used": [
      "12"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1788275631"
    ],
    "http.response.header.x-github-request-id": [
      "A02B:309FA0:1B7320:5A3A20:6A96E6D8"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "cbc61827-dabe-4b9e-8ca3-f043401ab337",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 6862,
    "process.parent_pid": 4020,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "02974c5b20e24ccb",
  "parent_span_id": "3a8f861218ccb906",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274393123250432,
  "time_end": 1788274393847495424,
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
      "00-d3fb8afaa4b6d067f56c7df2c87b9a61-3a8f861218ccb906-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Tue, 01 Sep 2026 14:53:13 GMT"
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
      "W/\"3dc4a1b13b170de09f986a2ea6123645717fc1fd0b70787e3b06ed4ab61ecb5b\""
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
      "47"
    ],
    "http.response.header.x-ratelimit-used": [
      "13"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1788275631"
    ],
    "http.response.header.x-github-request-id": [
      "A02F:23CA58:AA3E83:23159C3:6A96E6D9"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "e2223cda-60df-4954-8177-906c6d1d9c08",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7833,
    "process.parent_pid": 4020,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "78909b812530e77f",
  "parent_span_id": "d4b72212d5ce2fe5",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274394120342528,
  "time_end": 1788274394745223424,
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
      "00-d3fb8afaa4b6d067f56c7df2c87b9a61-d4b72212d5ce2fe5-03"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Tue, 01 Sep 2026 14:53:14 GMT"
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
      "W/\"7cce469005a0e744816b73d454845e2992f09795c35dad1aad1089c78c2527a3\""
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
      "46"
    ],
    "http.response.header.x-ratelimit-used": [
      "14"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1788275631"
    ],
    "http.response.header.x-github-request-id": [
      "A032:BAD68:A874F0:22B4EEF:6A96E6DA"
    ],
    "http.response.header.x-github-edge-region": [
      "iad"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "f6dd00cb-9542-4de7-9a91-1589f6d26604",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8804,
    "process.parent_pid": 4020,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "897d407cd02f5de6",
  "parent_span_id": "4021f4f2d6fd1791",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274395405280000,
  "time_end": 1788274396440382720,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.112.4",
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "1042d594-38f9-4687-a7c1-75a03afe670b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9774,
    "process.parent_pid": 4019,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "5b72cbcc3434a98e",
  "parent_span_id": "4021f4f2d6fd1791",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274395597576704,
  "time_end": 1788274396510554624,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.109.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-01T15%3A51%3A04Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-01T14%3A51%3A00Z&ske=2026-09-01T15%3A51%3A04Z&sks=b&skv=2018-11-09&sig=c%2FINcd2LKAqpaeddDuwTuvcpvBlBFXEXHPVzkGJwAw0%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4ODI3NDY5NSwibmJmIjoxNzg4Mjc0Mzk1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.TZtRNhE59z3peMD6clTU0bQq3cjYXrJfiKJqNHi1VV0&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-01T15%3A51%3A04Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.7.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-01T14%3A51%3A00Z&ske=2026-09-01T15%3A51%3A04Z&sks=b&skv=2018-11-09&sig=c%2FINcd2LKAqpaeddDuwTuvcpvBlBFXEXHPVzkGJwAw0%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4ODI3NDY5NSwibmJmIjoxNzg4Mjc0Mzk1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.TZtRNhE59z3peMD6clTU0bQq3cjYXrJfiKJqNHi1VV0&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "1042d594-38f9-4687-a7c1-75a03afe670b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9774,
    "process.parent_pid": 4019,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "0320dd40d511eefd",
  "parent_span_id": "4021f4f2d6fd1791",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274396496436736,
  "time_end": 1788274396753558272,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.112.4",
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "1042d594-38f9-4687-a7c1-75a03afe670b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9774,
    "process.parent_pid": 4019,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "14132f5a42385476",
  "parent_span_id": "4021f4f2d6fd1791",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274396724601344,
  "time_end": 1788274396847115776,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.109.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-01T15%3A50%3A58Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-01T14%3A50%3A06Z&ske=2026-09-01T15%3A50%3A58Z&sks=b&skv=2018-11-09&sig=tDOd7hn7MDjRrgtB0cmHjgrTGR08D4aJXjY3V12jdYs%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4ODI3NDY5NiwibmJmIjoxNzg4Mjc0Mzk2LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.vcNsNQAubKvaZlqQ3EQ9V87XkH_dsE82EuA4B-4RLAU&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-01T15%3A50%3A58Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.6.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-01T14%3A50%3A06Z&ske=2026-09-01T15%3A50%3A58Z&sks=b&skv=2018-11-09&sig=tDOd7hn7MDjRrgtB0cmHjgrTGR08D4aJXjY3V12jdYs%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4ODI3NDY5NiwibmJmIjoxNzg4Mjc0Mzk2LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.vcNsNQAubKvaZlqQ3EQ9V87XkH_dsE82EuA4B-4RLAU&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "1042d594-38f9-4687-a7c1-75a03afe670b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9774,
    "process.parent_pid": 4019,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "73590a77a49b09f9",
  "parent_span_id": "4021f4f2d6fd1791",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274396839490560,
  "time_end": 1788274397051328512,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "140.82.112.4",
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "1042d594-38f9-4687-a7c1-75a03afe670b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9774,
    "process.parent_pid": 4019,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "ef687d90f9185619",
  "parent_span_id": "4021f4f2d6fd1791",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274397027254272,
  "time_end": 1788274397107176704,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.109.133",
    "network.peer.port": 443,
    "server.address": "release-assets.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://release-assets.githubusercontent.com/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-01T15%3A51%3A24Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-01T14%3A50%3A47Z&ske=2026-09-01T15%3A51%3A24Z&sks=b&skv=2018-11-09&sig=INeDfwr1MFMoXYFWLwviRmUQiZ75mIv%2BB88Eci4AQJk%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4ODI3NDY5NiwibmJmIjoxNzg4Mjc0Mzk2LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.vcNsNQAubKvaZlqQ3EQ9V87XkH_dsE82EuA4B-4RLAU&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-01T15%3A51%3A24Z&rscd=attachment%3B+filename%3Dopentelemetry-shell_1.13.5.deb&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-01T14%3A50%3A47Z&ske=2026-09-01T15%3A51%3A24Z&sks=b&skv=2018-11-09&sig=INeDfwr1MFMoXYFWLwviRmUQiZ75mIv%2BB88Eci4AQJk%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4ODI3NDY5NiwibmJmIjoxNzg4Mjc0Mzk2LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.vcNsNQAubKvaZlqQ3EQ9V87XkH_dsE82EuA4B-4RLAU&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "1042d594-38f9-4687-a7c1-75a03afe670b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9774,
    "process.parent_pid": 4019,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "3e35b826c9ecaca9",
  "parent_span_id": "374cc5af89683a64",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1788274386281193216,
  "time_end": 1788274389889737472,
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
      "Tue, 01 Sep 2026 14:53:06 GMT"
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
      "W/\"b4312b6e5cb33c82cce1a814e95c12aa643aead390b5080dac3f299bb38fa544\""
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
      "50"
    ],
    "http.response.header.x-ratelimit-used": [
      "10"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1788275631"
    ],
    "http.response.header.x-github-request-id": [
      "A029:2DF075:A6BEAE:224AD3F:6A96E6D2"
    ],
    "http.response.header.x-github-edge-region": [
      "sea"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "09798cdda5356e31",
  "parent_span_id": null,
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1788274386013076224,
  "time_end": 1788274397110696960,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "0b0788cf870a9b36",
  "parent_span_id": "8c0613065bd0fefb",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274390877674496,
  "time_end": 1788274391937757696,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "2180b6dc-4669-4839-8039-4213f344b93d",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 5319,
    "process.parent_pid": 4020,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "0f7aad7b5b83164b",
  "parent_span_id": "8c0613065bd0fefb",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274392084799744,
  "time_end": 1788274392872288256,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "cbc61827-dabe-4b9e-8ca3-f043401ab337",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 6862,
    "process.parent_pid": 4020,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "3a8f861218ccb906",
  "parent_span_id": "8c0613065bd0fefb",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274393028454400,
  "time_end": 1788274393881801216,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "e2223cda-60df-4954-8177-906c6d1d9c08",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 7833,
    "process.parent_pid": 4020,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "d4b72212d5ce2fe5",
  "parent_span_id": "8c0613065bd0fefb",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274394033214464,
  "time_end": 1788274394782238720,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "f6dd00cb-9542-4de7-9a91-1589f6d26604",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 8804,
    "process.parent_pid": 4020,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "180995cc81487fae",
  "parent_span_id": "09798cdda5356e31",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386035028480,
  "time_end": 1788274389890171904,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "e725a85a3cc154bd",
  "parent_span_id": "09798cdda5356e31",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386030199040,
  "time_end": 1788274389894237184,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "917385ea6f1dcd0b",
  "parent_span_id": "09798cdda5356e31",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386048228864,
  "time_end": 1788274389898439424,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "814e1a01b56db396",
  "parent_span_id": "09798cdda5356e31",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386030312704,
  "time_end": 1788274389895383808,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "0ad4c4d448c944f4",
  "parent_span_id": "09798cdda5356e31",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386036487680,
  "time_end": 1788274394786613248,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "e0d10e7cf46a54c4",
  "parent_span_id": "09798cdda5356e31",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386035204864,
  "time_end": 1788274389889833216,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "dc9a7684f413d961",
  "parent_span_id": "09798cdda5356e31",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386039751424,
  "time_end": 1788274389897305088,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "486b7fa07161177d",
  "parent_span_id": "09798cdda5356e31",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1788274386039879680,
  "time_end": 1788274394787863296,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "928643cfd2af5c16",
  "parent_span_id": "09798cdda5356e31",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386034897920,
  "time_end": 1788274389893176576,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "048d27f68f801dc7",
  "parent_span_id": "09798cdda5356e31",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386043159296,
  "time_end": 1788274394786585856,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "9702c1d2de4341ca",
  "parent_span_id": "09798cdda5356e31",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386036355840,
  "time_end": 1788274394785005056,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "0478a285697b1818",
  "parent_span_id": "09798cdda5356e31",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1788274386023745792,
  "time_end": 1788274389889796608,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "011f0ffe0a01eb3e",
  "parent_span_id": "09798cdda5356e31",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386020974848,
  "time_end": 1788274386052449792,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "374cc5af89683a64",
  "parent_span_id": "0478a285697b1818",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1788274386065424896,
  "time_end": 1788274389889758208,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "ac04a4ccb083f6e8",
  "parent_span_id": "f8ae9210d46a27cf",
  "name": "seq 1 4",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274390394159104,
  "time_end": 1788274390400819712,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "1898f2cd-1b9e-4ff2-a5cd-0cabdbca21f3",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 4721,
    "process.parent_pid": 4018,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "7cc93cd089f4c89a",
  "parent_span_id": "09798cdda5356e31",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386035101696,
  "time_end": 1788274389896243200,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "def72f0649402b27",
  "parent_span_id": "09798cdda5356e31",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386025129984,
  "time_end": 1788274389892381184,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "4d1c418ab818ae45",
  "parent_span_id": "09798cdda5356e31",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386025296896,
  "time_end": 1788274389891313664,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "714a7c66b15efb5b",
  "parent_span_id": "09798cdda5356e31",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386022454528,
  "time_end": 1788274389889815552,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "4021f4f2d6fd1791",
  "parent_span_id": "d36ffb2b6052bc40",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274395300527360,
  "time_end": 1788274397108121344,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "1042d594-38f9-4687-a7c1-75a03afe670b",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 9774,
    "process.parent_pid": 4019,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "8c0613065bd0fefb",
  "parent_span_id": "09798cdda5356e31",
  "name": "xargs -I {} curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={}",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386043059456,
  "time_end": 1788274394783312384,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "f8ae9210d46a27cf",
  "parent_span_id": "09798cdda5356e31",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386050513152,
  "time_end": 1788274390402342656,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
  "trace_id": "d3fb8afaa4b6d067f56c7df2c87b9a61",
  "span_id": "d36ffb2b6052bc40",
  "parent_span_id": "09798cdda5356e31",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1788274386050390016,
  "time_end": 1788274397110106112,
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
    "telemetry.sdk.version": "5.61.5",
    "service.instance.id": "51d14cfa-0c77-4068-bd66-8596acf5f72e",
    "service.name": "unknown_service",
    "azure.vm.scaleset.name": "",
    "azure.vm.sku": "",
    "cloud.platform": "azure_vm",
    "cloud.provider": "azure",
    "cloud.region": "centralus",
    "cloud.resource_id": "/subscriptions/9b783200-eb9c-4123-a29c-c14fdc4e6af5/resourceGroups/azure-centralus-general-9b783200-eb9c-4123-a29c-c14fdc4e6af5/providers/Microsoft.Compute/virtualMachines/yTfsGSi4t1jyj6",
    "host.id": "40dd71ff-c43d-4cab-99b6-61c0152a07fd",
    "host.name": "yTfsGSi4t1jyj6",
    "host.type": "Standard_D4ds_v7",
    "os.type": "linux",
    "os.version": "6.17.0-1022-azure",
    "process.pid": 2877,
    "process.parent_pid": 2669,
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
