# renovate is really a docker running an npm package, that is pre-isntrumented with otel running in a docker container that during startup runs through an exec and a shebang first!
if ! type docker; then exit 0; fi
. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

log_file="$(\mktemp)"
docker run --rm --env RENOVATE_DRY_RUN=full --env RENOVATE_TOKEN=abc --env RENOVATE_REPOSITORIES="plengauer/opentelemetry-bash" ghcr.io/renovatebot/renovate:latest > "$log_file"
assert_not_equals 0 "$?" # because no github token available
\cat "$log_file"
span="$(resolve_span '. | select(.name == "/usr/local/renovate/node --use-openssl-ca /usr/local/renovate/dist/renovate.js")')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | \jq -r '.kind')
span_id="$(\echo "$span" | \jq -r '.context.span_id')"

\cat "$log_file" | \grep "${span_id:2}" || exit 1
