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
  | xargs seq 1 | xargs parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors "$url"\&page={} ::: \
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
    seq 1 3
  head --lines=3
  xargs parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} :::
    /usr/bin/perl /usr/bin/parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} ::: 1 2 3
      curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1
        GET
      curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3
        GET
      curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2
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
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "7848d2ae7d4b56b2",
  "parent_span_id": "88df2a46721c057e",
  "name": "/usr/bin/perl /usr/bin/parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} ::: 1 2 3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166181819476736,
  "time_end": 1749166184077546240,
  "attributes": {
    "shell.command_line": "/usr/bin/perl /usr/bin/parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} ::: 1 2 3",
    "shell.command": "/usr/bin/perl",
    "shell.command.type": "file",
    "shell.command.name": "perl",
    "subprocess.executable.path": "/usr/bin/perl",
    "subprocess.executable.name": "perl",
    "shell.command.exit_code": 0,
    "code.lineno": 2
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 5878,
    "process.parent_pid": 4563,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} :::",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "2486de69e34edc83",
  "parent_span_id": "bf230dabccc2eca8",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1749166183162057472,
  "time_end": 1749166183920219904,
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
      "00-8be966e7b6228bf9a02ef73b1dee2a36-bf230dabccc2eca8-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Thu, 05 Jun 2025 23:29:43 GMT"
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
      "W/\"2b4f0625656091b47954adf191af2abddd540d63568d68649c92fcc6d4e35c67\""
    ],
    "http.response.header.x-github-media-type": [
      "github.v3; format=json"
    ],
    "http.response.header.link": [
      "<https://api.github.com/repositories/692042935/releases?per_page=100&page=2>; rel=\"next\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=3>; rel=\"last\""
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
      "1749169579"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "8"
    ],
    "http.response.header.x-github-request-id": [
      "AC01:271A4A:3CE4CE2:7A68DD1:68422867"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 6679,
    "process.parent_pid": 6637,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "/usr/bin/perl /usr/bin/parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} ::: 1 2 3",
    "process.command": "/usr/bin/perl",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "74a76964cf19bb01",
  "parent_span_id": "96b7bed3745bc5fa",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1749166183246310656,
  "time_end": 1749166183988927488,
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
      "00-8be966e7b6228bf9a02ef73b1dee2a36-96b7bed3745bc5fa-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Thu, 05 Jun 2025 23:29:43 GMT"
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
      "W/\"8333211f28e1ea4c180b7d5af4fcd2e6c22ab0afcc1c64941da8fa1255ec1257\""
    ],
    "http.response.header.x-github-media-type": [
      "github.v3; format=json"
    ],
    "http.response.header.link": [
      "<https://api.github.com/repositories/692042935/releases?per_page=100&page=2>; rel=\"prev\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=1>; rel=\"first\""
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
      "51"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1749169579"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "9"
    ],
    "http.response.header.x-github-request-id": [
      "AC03:22401F:3EFB7D9:7E7DD92:68422867"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 6682,
    "process.parent_pid": 6637,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "/usr/bin/perl /usr/bin/parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} ::: 1 2 3",
    "process.command": "/usr/bin/perl",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "f300c3d24c07adb7",
  "parent_span_id": "33b40bfc5ba375ad",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1749166183255799808,
  "time_end": 1749166184058857984,
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
      "00-8be966e7b6228bf9a02ef73b1dee2a36-33b40bfc5ba375ad-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Thu, 05 Jun 2025 23:29:43 GMT"
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
      "W/\"9899c8e43695cdcf601f4cdc1bc9adb411e122d5fab83161524faa37b1adacd5\""
    ],
    "http.response.header.x-github-media-type": [
      "github.v3; format=json"
    ],
    "http.response.header.link": [
      "<https://api.github.com/repositories/692042935/releases?per_page=100&page=1>; rel=\"prev\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=3>; rel=\"next\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=3>; rel=\"last\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=1>; rel=\"first\""
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
      "50"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1749169579"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "10"
    ],
    "http.response.header.x-github-request-id": [
      "AC02:4440C:3CDE5FB:7A49CEA:68422867"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 6680,
    "process.parent_pid": 6637,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "/usr/bin/perl /usr/bin/parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} ::: 1 2 3",
    "process.command": "/usr/bin/perl",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "b0181f2896893aa4",
  "parent_span_id": "7c0858b5676eb908",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1749166184877276160,
  "time_end": 1749166185854760960,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11235,
    "process.parent_pid": 4493,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "a27d5b1ed3ca5e22",
  "parent_span_id": "7c0858b5676eb908",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1749166185075373568,
  "time_end": 1749166186234815232,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.109.133",
    "network.peer.port": 443,
    "server.address": "objects.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://objects.githubusercontent.com/github-production-release-asset-2e65be/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250605%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250605T232945Z&X-Amz-Expires=300&X-Amz-Signature=7695beba8928008a9a8db1abb3fd866e6e920a8f24e537bad6942ee7b997dfc1&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset-2e65be/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250605%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250605T232945Z&X-Amz-Expires=300&X-Amz-Signature=7695beba8928008a9a8db1abb3fd866e6e920a8f24e537bad6942ee7b997dfc1&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11235,
    "process.parent_pid": 4493,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "e4e29f6a9c10a904",
  "parent_span_id": "7c0858b5676eb908",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1749166186286069760,
  "time_end": 1749166187263318528,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11235,
    "process.parent_pid": 4493,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "1c5b254695fb64f7",
  "parent_span_id": "7c0858b5676eb908",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1749166186487352832,
  "time_end": 1749166187636843008,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.109.133",
    "network.peer.port": 443,
    "server.address": "objects.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://objects.githubusercontent.com/github-production-release-asset-2e65be/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250605%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250605T232946Z&X-Amz-Expires=300&X-Amz-Signature=4cf8dec7ae95728b765ffb4f6996c8196390fe2ba2cc81cd2695a225784703eb&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset-2e65be/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250605%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250605T232946Z&X-Amz-Expires=300&X-Amz-Signature=4cf8dec7ae95728b765ffb4f6996c8196390fe2ba2cc81cd2695a225784703eb&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11235,
    "process.parent_pid": 4493,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "e44d8ddf19a09127",
  "parent_span_id": "7c0858b5676eb908",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1749166187688490752,
  "time_end": 1749166188665823744,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11235,
    "process.parent_pid": 4493,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "b64bb922ac257764",
  "parent_span_id": "7c0858b5676eb908",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1749166187918256384,
  "time_end": 1749166188951073792,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.109.133",
    "network.peer.port": 443,
    "server.address": "objects.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://objects.githubusercontent.com/github-production-release-asset-2e65be/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250605%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250605T232947Z&X-Amz-Expires=300&X-Amz-Signature=48b29b8dfae9767382ee42ecdaf653771ab7e673a473a405adeda22bc80f2120&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset-2e65be/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250605%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250605T232947Z&X-Amz-Expires=300&X-Amz-Signature=48b29b8dfae9767382ee42ecdaf653771ab7e673a473a405adeda22bc80f2120&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11235,
    "process.parent_pid": 4493,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "4df8b65c257709a6",
  "parent_span_id": "8d24601c9d2b5aac",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1749166176964256000,
  "time_end": 1749166180481199872,
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
      "Thu, 05 Jun 2025 23:29:37 GMT"
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
      "W/\"e35a450a4d00b8b8b05e88c7177700c582d698102b2e02f54a22f6e1b4b6adb0\""
    ],
    "http.response.header.x-github-media-type": [
      "github.v3; format=json"
    ],
    "http.response.header.link": [
      "<https://api.github.com/repositories/692042935/releases?per_page=100&page=2>; rel=\"next\", <https://api.github.com/repositories/692042935/releases?per_page=100&page=3>; rel=\"last\""
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
      "1749169579"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "7"
    ],
    "http.response.header.x-github-request-id": [
      "AC00:2285A8:3DBAC03:7C0080F:68422860"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "3853234bfb7c42f1",
  "parent_span_id": "",
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1749166176613711360,
  "time_end": 1749166188991866624,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "bf230dabccc2eca8",
  "parent_span_id": "7848d2ae7d4b56b2",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166182996731392,
  "time_end": 1749166183925137408,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.lineno": 2
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 6679,
    "process.parent_pid": 6637,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "/usr/bin/perl /usr/bin/parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} ::: 1 2 3",
    "process.command": "/usr/bin/perl",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "33b40bfc5ba375ad",
  "parent_span_id": "7848d2ae7d4b56b2",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166183086110976,
  "time_end": 1749166184062614784,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.lineno": 2
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 6680,
    "process.parent_pid": 6637,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "/usr/bin/perl /usr/bin/parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} ::: 1 2 3",
    "process.command": "/usr/bin/perl",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "96b7bed3745bc5fa",
  "parent_span_id": "7848d2ae7d4b56b2",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166183083585792,
  "time_end": 1749166183993022464,
  "attributes": {
    "shell.command_line": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
    "shell.command": "curl",
    "shell.command.type": "file",
    "shell.command.name": "curl",
    "subprocess.executable.path": "/usr/bin/curl",
    "subprocess.executable.name": "curl",
    "shell.command.exit_code": 0,
    "code.lineno": 2
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 6682,
    "process.parent_pid": 6637,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "/usr/bin/perl /usr/bin/parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} ::: 1 2 3",
    "process.command": "/usr/bin/perl",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "23cc3586f6ee0f80",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176655591424,
  "time_end": 1749166180493332480,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "1e45c1304f487c99",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176657701888,
  "time_end": 1749166180502887168,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "f1d962b8cbb43ca2",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176658089472,
  "time_end": 1749166180512476416,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "d0dcdd78b795937d",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176657822208,
  "time_end": 1749166180505345280,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "ac55e263d2391ace",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176655171584,
  "time_end": 1749166184125763072,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "1170bc14fdfa0075",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176657568000,
  "time_end": 1749166180490923776,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "0eadf8e2778aa57d",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176676077824,
  "time_end": 1749166180510144768,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "5a6ce2757d367ac4",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1749166176658315008,
  "time_end": 1749166184129288192,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "0ee349124c096f47",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176647460096,
  "time_end": 1749166180500424960,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "8670b32b3491fc2e",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176683366400,
  "time_end": 1749166184076070912,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "1df0fe1f8a60e03f",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176655343360,
  "time_end": 1749166184122899200,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "d0b1244dd0661592",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1749166176634818304,
  "time_end": 1749166180486129664,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "8ac1368b330b1d7b",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176645032960,
  "time_end": 1749166176749063424,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "8d24601c9d2b5aac",
  "parent_span_id": "d0b1244dd0661592",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1749166176767627776,
  "time_end": 1749166180481686528,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "f65596d9005c60c6",
  "parent_span_id": "9505a44a19fe208a",
  "name": "seq 1 3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166181114289920,
  "time_end": 1749166181132459008,
  "attributes": {
    "shell.command_line": "seq 1 3",
    "shell.command": "seq",
    "shell.command.type": "file",
    "shell.command.name": "seq",
    "subprocess.executable.path": "/usr/bin/seq",
    "subprocess.executable.name": "seq",
    "shell.command.exit_code": 0,
    "code.lineno": 2
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 5255,
    "process.parent_pid": 4496,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs seq 1",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "dccc23888d500059",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176658579712,
  "time_end": 1749166180507718912,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "2bf529b9ff776575",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176658816256,
  "time_end": 1749166180498059264,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "be4dae255d884a68",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176655710976,
  "time_end": 1749166180495688960,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "677e1e6a9e1d2f18",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176658206464,
  "time_end": 1749166180488587264,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "7c0858b5676eb908",
  "parent_span_id": "476f37102b72ba7f",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166184704495616,
  "time_end": 1749166188956396544,
  "attributes": {
    "shell.command_line": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
    "shell.command": "wget",
    "shell.command.type": "file",
    "shell.command.name": "wget",
    "subprocess.executable.path": "/usr/bin/wget",
    "subprocess.executable.name": "wget",
    "shell.command.exit_code": 0,
    "code.lineno": 2
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11235,
    "process.parent_pid": 4493,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "xargs wget",
    "process.command": "xargs",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "hBc",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "88df2a46721c057e",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "xargs parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} :::",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176655470080,
  "time_end": 1749166184119379456,
  "attributes": {
    "shell.command_line": "xargs parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} :::",
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "9505a44a19fe208a",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176657947136,
  "time_end": 1749166181166239488,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
{
  "trace_id": "8be966e7b6228bf9a02ef73b1dee2a36",
  "span_id": "476f37102b72ba7f",
  "parent_span_id": "3853234bfb7c42f1",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1749166176658690560,
  "time_end": 1749166188991232000,
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
    "telemetry.sdk.version": "5.18.2",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.18.2",
    "github.actions.workflow.sha": "f106684528e2a8764b73725289fadb5587d57cb0",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 3053,
    "process.parent_pid": 2308,
    "process.executable.name": "bash",
    "process.executable.path": "/usr/bin/bash",
    "process.command_line": "bash -e demo.sh",
    "process.command": "bash",
    "process.owner": "runner",
    "process.runtime.name": "bash",
    "process.runtime.description": "Bourne Again Shell",
    "process.runtime.version": "5.2.21-2ubuntu4",
    "process.runtime.options": "ehB",
    "service.version": "",
    "service.namespace": "",
    "service.instance.id": ""
  },
  "links": [],
  "events": []
}
```
