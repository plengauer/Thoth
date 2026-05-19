. ./assert.sh

line="$(grep -E 'grep "\$\(arch .*sed s/x86_64/amd64/g.*sed s/aarch64/arm64/g.*sed .*le\$/el/g' ../actions/instrument/job/inject_and_init.sh)"
assert_not_equals "" "$line"
