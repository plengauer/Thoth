if ! type docker; then exit 0; fi

. ./assert.sh
. /usr/bin/opentelemetry_shell.sh

assert_equals "hello world 0" "$(sudo docker run debian:latest echo hello world 0)"
span="$(resolve_span '.name == "echo hello world 0"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | \jq -r '.kind')"

assert_equals "hello world 1" "$(sudo docker run ubuntu:latest echo hello world 1)"
span="$(resolve_span '.name == "echo hello world 1"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | \jq -r '.kind')"

assert_equals "hello world 2" "$(sudo docker run python:latest python3 -c 'print("hello world 2")')"
span="$(resolve_span '.name | startswith("python3 -c ")')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | \jq -r '.kind')"

assert_equals "hello world 3" "$(sudo docker run node:latest node -e 'console.log("hello world 3")')"
span="$(resolve_span '.name | startswith("node -e ")')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | \jq -r '.kind')"

assert_equals "hello world 4" "$(sudo docker run --entrypoint echo debian:latest hello world 4)"
span="$(resolve_span '.name == "echo hello world 4"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | \jq -r '.kind')"

assert_equals "hello world 5" "$(sudo docker run --volume /tmp:/tmp debian:latest echo hello world 5)"
span="$(resolve_span '.name == "echo hello world 5"')"
assert_equals "SpanKind.INTERNAL" "$(\echo "$span" | \jq -r '.kind')"

sudo docker image ls
assert_equals 0 "$?"

sudo docker container ls
assert_equals 0 "$?"

sudo docker ps --format '{{.Names}}'
assert_equals 0 "$?"

sudo docker image inspect --format='{{json .Id}}' ubuntu:latest
assert_equals 0 "$?"

# from https://github.com/actions/first-interaction/blob/main/Dockerfile (added because it was hanging forever)
dockerfile="$(mktemp)"
echo 'FROM node:20.10-buster-slim' >> "$dockerfile"
echo 'ENTRYPOINT ["node", "-e", "console.log(\"hello world 6\")"]' >> "$dockerfile"
sudo docker build -t docker_test_0 -f "$dockerfile" .
assert_equals 0 "$?"
assert_equals "hello world 6" "$(sudo docker run --rm=true docker_test_0)"
assert_equals 0 "$?"
