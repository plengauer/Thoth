. ./assert.sh

line="$(printf '*   Trying 140.82.121.4:443...< location: https://github.com/plengauer/Thoth/releases/tag/v1.2.3\r')"
version="$(printf '%s\n' "$line" | grep location | tr -d '\r' | while IFS= read -r read_line; do case "$read_line" in *"location: "*"/releases/tag/v"*) read_line="${read_line##*location: }"; read_line="${read_line##*/releases/tag/v}"; case "$read_line" in */*|'') ;; *) echo "$read_line";; esac;; esac; done)"
invalid_line="$(printf '*   Trying 140.82.121.4:443...< location: https://github.com/plengauer/Thoth/releases/tag/v1.2.3/path\r')"
invalid_version="$(printf '%s\n' "$invalid_line" | grep location | tr -d '\r' | while IFS= read -r read_line; do case "$read_line" in *"location: "*"/releases/tag/v"*) read_line="${read_line##*location: }"; read_line="${read_line##*/releases/tag/v}"; case "$read_line" in */*|'') ;; *) echo "$read_line";; esac;; esac; done)"

assert_equals "1.2.3" "$version"
assert_equals "" "$invalid_version"
