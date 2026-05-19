. ./assert.sh

resolve_arch() {
  echo "$1" | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g' | sed 's/le$/el/g'
}

assert_equals amd64 "$(resolve_arch x86_64)"
assert_equals arm64 "$(resolve_arch aarch64)"
assert_equals ppc64el "$(resolve_arch ppc64le)"

assert_not_equals "" "$(grep -F "sed 's/x86_64/amd64/g'" ../actions/instrument/job/inject_and_init.sh)"
assert_not_equals "" "$(grep -F "sed 's/aarch64/arm64/g'" ../actions/instrument/job/inject_and_init.sh)"
assert_not_equals "" "$(grep -F "sed 's/le$/el/g'" ../actions/instrument/job/inject_and_init.sh)"
