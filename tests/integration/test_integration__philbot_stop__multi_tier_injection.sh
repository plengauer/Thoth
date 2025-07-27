if ! dpkg -s moreutils; then exit 0; fi
. ./assert.sh

# from a real world example

# lets simulate the caller
. /usr/bin/opentelemetry_shell.sh
seq -s " philbot-discordgateway2http_" 0 3 | xargs -I '{}' echo philbot-discordgateway2http_'{}' | xargs parallel.moreutils -j 3 sh -c 'echo docker rm --force $1' echo --
# in reality the parallel command stops a docker container, but echo should be enough for this

# lets assert
assert_equals 0 $?

span="$(resolve_span '.name == "xargs -I {} echo philbot-discordgateway2http_{}"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')

span="$(resolve_span '.name == "echo philbot-discordgateway2http_0 philbot-discordgateway2http_1 philbot-discordgateway2http_2 philbot-discordgateway2http_3"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_equals "xargs -I {} echo philbot-discordgateway2http_{}" "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

span="$(resolve_span '.name == "xargs parallel.moreutils -j 3 sh -c echo docker rm --force $1 echo --"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')

span="$(resolve_span '.name == "parallel.moreutils -j 3 sh -c echo docker rm --force $1 echo -- philbot-discordgateway2http_0 philbot-discordgateway2http_1 philbot-discordgateway2http_2 philbot-discordgateway2http_3"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_equals 'xargs parallel.moreutils -j 3 sh -c echo docker rm --force $1 echo --' "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

span="$(resolve_span '.name == "sh -c echo docker rm --force $1 echo philbot-discordgateway2http_0"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_equals 'parallel.moreutils -j 3 sh -c echo docker rm --force $1 echo -- philbot-discordgateway2http_0 philbot-discordgateway2http_1 philbot-discordgateway2http_2 philbot-discordgateway2http_3' "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

span="$(resolve_span '.name == "echo docker rm --force philbot-discordgateway2http_0"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_equals 'sh -c echo docker rm --force $1 echo philbot-discordgateway2http_0' "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

span="$(resolve_span '.name == "sh -c echo docker rm --force $1 echo philbot-discordgateway2http_1"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_equals 'parallel.moreutils -j 3 sh -c echo docker rm --force $1 echo -- philbot-discordgateway2http_0 philbot-discordgateway2http_1 philbot-discordgateway2http_2 philbot-discordgateway2http_3' "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

span="$(resolve_span '.name == "echo docker rm --force philbot-discordgateway2http_1"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_equals 'sh -c echo docker rm --force $1 echo philbot-discordgateway2http_1' "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

span="$(resolve_span '.name == "sh -c echo docker rm --force $1 echo philbot-discordgateway2http_2"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_equals 'parallel.moreutils -j 3 sh -c echo docker rm --force $1 echo -- philbot-discordgateway2http_0 philbot-discordgateway2http_1 philbot-discordgateway2http_2 philbot-discordgateway2http_3' "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

span="$(resolve_span '.name == "echo docker rm --force philbot-discordgateway2http_2"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_equals 'sh -c echo docker rm --force $1 echo philbot-discordgateway2http_2' "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

span="$(resolve_span '.name == "sh -c echo docker rm --force $1 echo philbot-discordgateway2http_3"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_equals 'parallel.moreutils -j 3 sh -c echo docker rm --force $1 echo -- philbot-discordgateway2http_0 philbot-discordgateway2http_1 philbot-discordgateway2http_2 philbot-discordgateway2http_3' "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

span="$(resolve_span '.name == "echo docker rm --force philbot-discordgateway2http_3"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_equals 'sh -c echo docker rm --force $1 echo philbot-discordgateway2http_3' "$(\echo "$span" | jq -r '.resource.attributes."process.command_line"')"

