. ./assert.sh

line="$(printf '*   Trying 140.82.121.4:443...< location: https://github.com/plengauer/Thoth/releases/tag/v1.2.3\r')"
version="$(printf '%s\n' "$line" | grep location | tr -d '\r' | while IFS= read -r line; do echo "${line##*/v}"; done)"

assert_equals "1.2.3" "$version"
