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
      curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2
        GET
      curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3
        GET
      curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "625861e084124197",
  "parent_span_id": "c25f9822aafc4147",
  "name": "/usr/bin/perl /usr/bin/parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} ::: 1 2 3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340133894164992,
  "time_end": 1751340136096743680,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 5770,
    "process.parent_pid": 4479,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "305f0003b0b3ed9f",
  "parent_span_id": "7eecb9eb5de02541",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1751340135237676800,
  "time_end": 1751340135954564096,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.112.5",
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
      "00-5a1c08180f70c288b8664d72e25d807b-7eecb9eb5de02541-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Tue, 01 Jul 2025 03:22:15 GMT"
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
      "W/\"19efc46ba42f4924b2a4cff003c57b37e613c45972abb47e24e50d40f3b9b8d2\""
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
      "58"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1751343729"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "2"
    ],
    "http.response.header.x-github-request-id": [
      "07C1:BB900:AD6FCF:1603BF8:68635467"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 6570,
    "process.parent_pid": 6528,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "29f47d55a666ea96",
  "parent_span_id": "6ee145a1e873a494",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1751340135313050880,
  "time_end": 1751340136075351040,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.112.5",
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
      "00-5a1c08180f70c288b8664d72e25d807b-6ee145a1e873a494-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Tue, 01 Jul 2025 03:22:15 GMT"
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
      "W/\"42310049d6a55d079891e6b7dbf7f89b449ad9c3ffe8675a02ba0a40aaf1017a\""
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
      "57"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1751343729"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "3"
    ],
    "http.response.header.x-github-request-id": [
      "07C2:648A1:AFCB5C:1651163:68635467"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 6569,
    "process.parent_pid": 6528,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "6cd546ca025a616d",
  "parent_span_id": "434649ce5207e035",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1751340135316124672,
  "time_end": 1751340136055306496,
  "attributes": {
    "network.transport": "tcp",
    "network.protocol.name": "https",
    "network.protocol.version": "2",
    "network.peer.address": "140.82.112.5",
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
      "00-5a1c08180f70c288b8664d72e25d807b-434649ce5207e035-01"
    ],
    "http.response.status_code": 200,
    "http.response.header.date": [
      "Tue, 01 Jul 2025 03:22:15 GMT"
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
      "W/\"73beae9eef6928a106592d5deea03d97bb2ba8e674b2a8b0c9eedd4d96bb8261\""
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
      "56"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1751343729"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "4"
    ],
    "http.response.header.x-github-request-id": [
      "07C3:DE140:A8F01F:1573519:68635467"
    ]
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 6572,
    "process.parent_pid": 6528,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "911de674d953fbcb",
  "parent_span_id": "06f5e2be4f41444c",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1751340136832160000,
  "time_end": 1751340137853079808,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11162,
    "process.parent_pid": 4410,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "760b12de013c3a1f",
  "parent_span_id": "06f5e2be4f41444c",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1751340136963109376,
  "time_end": 1751340137991578624,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.109.133",
    "network.peer.port": 443,
    "server.address": "objects.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://objects.githubusercontent.com/github-production-release-asset-2e65be/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250701%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250701T032216Z&X-Amz-Expires=1800&X-Amz-Signature=df6019a8cddae3d45f29304f8a9f50c4d7311bdc151560bb54a4cbd8db9dd9b6&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset-2e65be/692042935/5544a935-3cf9-4f9b-b6ed-d668fd012e99",
    "url.query": "X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250701%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250701T032216Z&X-Amz-Expires=1800&X-Amz-Signature=df6019a8cddae3d45f29304f8a9f50c4d7311bdc151560bb54a4cbd8db9dd9b6&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.7.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11162,
    "process.parent_pid": 4410,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "6a9bf132450d881a",
  "parent_span_id": "06f5e2be4f41444c",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1751340137998352384,
  "time_end": 1751340139021670912,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11162,
    "process.parent_pid": 4410,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "2c091141cdd0c066",
  "parent_span_id": "06f5e2be4f41444c",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1751340138108601088,
  "time_end": 1751340139144922624,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.109.133",
    "network.peer.port": 443,
    "server.address": "objects.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://objects.githubusercontent.com/github-production-release-asset-2e65be/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250701%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250701T032218Z&X-Amz-Expires=1800&X-Amz-Signature=b0cc132cc402f1fb12aa66439fb3e782cdae1fb82188105fc4dceb98c2598221&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset-2e65be/692042935/e8091cbc-915a-4ba7-bca7-308817fe26c4",
    "url.query": "X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250701%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250701T032218Z&X-Amz-Expires=1800&X-Amz-Signature=b0cc132cc402f1fb12aa66439fb3e782cdae1fb82188105fc4dceb98c2598221&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.6.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11162,
    "process.parent_pid": 4410,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "5fc9ed10056b4bd6",
  "parent_span_id": "06f5e2be4f41444c",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1751340139151696128,
  "time_end": 1751340140174682112,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11162,
    "process.parent_pid": 4410,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "ae36933302b843a2",
  "parent_span_id": "06f5e2be4f41444c",
  "name": "GET",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1751340139268698880,
  "time_end": 1751340140292803072,
  "attributes": {
    "network.protocol.name": "https",
    "network.transport": "tcp",
    "network.peer.address": "185.199.109.133",
    "network.peer.port": 443,
    "server.address": "objects.githubusercontent.com",
    "server.port": 443,
    "url.full": "https://objects.githubusercontent.com/github-production-release-asset-2e65be/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250701%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250701T032219Z&X-Amz-Expires=1800&X-Amz-Signature=ec08cd68fe4909e4d576b8f6c1af9d27c64b9f767379e48824fbf19fd83e6478&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
    "url.path": "/github-production-release-asset-2e65be/692042935/25d95ab9-56aa-4a77-8e84-d4947ecef0fc",
    "url.query": "X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250701%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250701T032219Z&X-Amz-Expires=1800&X-Amz-Signature=ec08cd68fe4909e4d576b8f6c1af9d27c64b9f767379e48824fbf19fd83e6478&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dopentelemetry-shell_1.13.5.deb&response-content-type=application%2Foctet-stream",
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11162,
    "process.parent_pid": 4410,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "cc71a39a1099f5e3",
  "parent_span_id": "ed57bfa6a864cd04",
  "name": "HEAD",
  "kind": "CLIENT",
  "status": "UNSET",
  "time_start": 1751340129116318464,
  "time_end": 1751340132529778944,
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
      "Tue, 01 Jul 2025 03:22:09 GMT"
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
      "W/\"e33952ac9433c4961b5dc333dfb107da8defa93e27cde216124be65aa11646ae\""
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
      "59"
    ],
    "http.response.header.x-ratelimit-reset": [
      "1751343729"
    ],
    "http.response.header.x-ratelimit-resource": [
      "core"
    ],
    "http.response.header.x-ratelimit-used": [
      "1"
    ],
    "http.response.header.x-github-request-id": [
      "07C0:140E1C:ADDED6:1618546:68635461"
    ],
    "http.response.header.connection": [
      "close"
    ],
    "http.response.body.size": 0
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "cc87e365a86aa762",
  "parent_span_id": "",
  "name": "bash -e demo.sh",
  "kind": "SERVER",
  "status": "UNSET",
  "time_start": 1751340128758637568,
  "time_end": 1751340140336256768,
  "attributes": {},
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "6ee145a1e873a494",
  "parent_span_id": "625861e084124197",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340135192198912,
  "time_end": 1751340136079565312,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 6569,
    "process.parent_pid": 6528,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "7eecb9eb5de02541",
  "parent_span_id": "625861e084124197",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340135122695936,
  "time_end": 1751340135959489280,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 6570,
    "process.parent_pid": 6528,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "434649ce5207e035",
  "parent_span_id": "625861e084124197",
  "name": "curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340135197674752,
  "time_end": 1751340136059683328,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 6572,
    "process.parent_pid": 6528,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "324cf9860cb5d81c",
  "parent_span_id": "cc87e365a86aa762",
  "name": "cut -d   -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128818970880,
  "time_end": 1751340132542116352,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "90960fe7c17f368f",
  "parent_span_id": "cc87e365a86aa762",
  "name": "cut -d ; -f1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128803742208,
  "time_end": 1751340132551922688,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "d5a6c3cf25d83db3",
  "parent_span_id": "cc87e365a86aa762",
  "name": "cut -d = -f 2",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128806695936,
  "time_end": 1751340132561761280,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "d7a11e4961d61f55",
  "parent_span_id": "cc87e365a86aa762",
  "name": "cut -d ? -f 2-",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128804032512,
  "time_end": 1751340132554387968,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "cd6ace16bec5d7d5",
  "parent_span_id": "cc87e365a86aa762",
  "name": "grep .deb$",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128804567808,
  "time_end": 1751340136166770944,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "4395f3b15a810fd8",
  "parent_span_id": "cc87e365a86aa762",
  "name": "grep ^link:",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128799362816,
  "time_end": 1751340132539680000,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "d2ef54cb023b7c0d",
  "parent_span_id": "cc87e365a86aa762",
  "name": "grep ^page=",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128818828032,
  "time_end": 1751340132559330304,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "12b0f4e1f67732e9",
  "parent_span_id": "cc87e365a86aa762",
  "name": "grep _1.",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1751340128818353920,
  "time_end": 1751340136170692096,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "d7510c8b5ff0a4d2",
  "parent_span_id": "cc87e365a86aa762",
  "name": "grep rel=\"last\"",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128803864320,
  "time_end": 1751340132549471744,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "f3047dae6b03f118",
  "parent_span_id": "cc87e365a86aa762",
  "name": "head --lines=3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128804292608,
  "time_end": 1751340136095539712,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "3ce05bb8b654fa51",
  "parent_span_id": "cc87e365a86aa762",
  "name": "jq .[].assets[].browser_download_url -r",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128818695680,
  "time_end": 1751340136160477696,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "e1711fee469ce140",
  "parent_span_id": "cc87e365a86aa762",
  "name": "ncat --ssl -i 3 --no-shutdown api.github.com 443",
  "kind": "INTERNAL",
  "status": "ERROR",
  "time_start": 1751340128775307520,
  "time_end": 1751340132534706176,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "1b3eaa54d384d157",
  "parent_span_id": "cc87e365a86aa762",
  "name": "printf HEAD /repos/plengauer/Thoth/releases?per_page=100 HTTP/1.1\\r\\nConnection: close\\r\\nUser-Agent: ncat\\r\\nHost: api.github.com\\r\\n\\r\\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128785126656,
  "time_end": 1751340128900237568,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "ed57bfa6a864cd04",
  "parent_span_id": "e1711fee469ce140",
  "name": "send/receive",
  "kind": "PRODUCER",
  "status": "UNSET",
  "time_start": 1751340128894641920,
  "time_end": 1751340132530265088,
  "attributes": {
    "network.transport": "tcp",
    "network.peer.port": 443,
    "server.address": "api.github.com",
    "server.port": 443
  },
  "resource_attributes": {
    "telemetry.sdk.language": "shell",
    "telemetry.sdk.name": "opentelemetry",
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "3ac1b0c8c92bfc35",
  "parent_span_id": "c8ac63ffada0bef9",
  "name": "seq 1 3",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340133174800896,
  "time_end": 1751340133193157632,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 5146,
    "process.parent_pid": 4419,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "c8385383ac904c47",
  "parent_span_id": "cc87e365a86aa762",
  "name": "tr & \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128804166656,
  "time_end": 1751340132556866816,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "20c7173750f5425a",
  "parent_span_id": "cc87e365a86aa762",
  "name": "tr , \\n",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128804432384,
  "time_end": 1751340132547042304,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "c8e50a38faec76b2",
  "parent_span_id": "cc87e365a86aa762",
  "name": "tr -d  <>",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128799687168,
  "time_end": 1751340132544613376,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "cd614725b4ea3177",
  "parent_span_id": "cc87e365a86aa762",
  "name": "tr [:upper:] [:lower:]",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128784953088,
  "time_end": 1751340132537183744,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "06f5e2be4f41444c",
  "parent_span_id": "71a656fe1c52e012",
  "name": "wget https://github.com/plengauer/Thoth/releases/download/v1.13.7/opentelemetry-shell_1.13.7.deb https://github.com/plengauer/Thoth/releases/download/v1.13.6/opentelemetry-shell_1.13.6.deb https://github.com/plengauer/Thoth/releases/download/v1.13.5/opentelemetry-shell_1.13.5.deb",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340136736368640,
  "time_end": 1751340140298098688,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 11162,
    "process.parent_pid": 4410,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "c25f9822aafc4147",
  "parent_span_id": "cc87e365a86aa762",
  "name": "xargs parallel -q curl --no-progress-meter --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/Thoth/releases?per_page=100&page={} :::",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128810614016,
  "time_end": 1751340136157454336,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "c8ac63ffada0bef9",
  "parent_span_id": "cc87e365a86aa762",
  "name": "xargs seq 1",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128806571008,
  "time_end": 1751340133231021824,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
  "trace_id": "5a1c08180f70c288b8664d72e25d807b",
  "span_id": "71a656fe1c52e012",
  "parent_span_id": "cc87e365a86aa762",
  "name": "xargs wget",
  "kind": "INTERNAL",
  "status": "UNSET",
  "time_start": 1751340128806425600,
  "time_end": 1751340140335601920,
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
    "telemetry.sdk.version": "5.21.0",
    "service.name": "unknown_service",
    "github.repository.id": "692042935",
    "github.repository.name": "Thoth",
    "github.repository.owner.id": "100447901",
    "github.repository.owner.name": "plengauer",
    "github.actions.workflow.ref": "plengauer/Thoth/.github/workflows/refresh_demos.yaml@refs/tags/v5.21.0",
    "github.actions.workflow.sha": "e101f92ed22a6dd0217674b9fbedd6c23633d6a8",
    "github.actions.workflow.name": "Refresh Demos",
    "os.type": "linux",
    "os.version": "6.11.0-1015-azure",
    "process.pid": 2945,
    "process.parent_pid": 2202,
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
