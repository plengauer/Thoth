. ./assert.sh

tmp_cache="$(mktemp -d)"
arch_normalized="$(arch | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g' | sed 's/le$/el/g')"

# Deb-file resolution logic (mirrors inject_and_init.sh, using find to avoid noglob issue)
find_otelshell_deb() {
  local dir="$1"
  local arch="$2"
  local deb
  deb="$(find "$dir" -maxdepth 1 -name "opentelemetry-shell_*_${arch}.deb" 2>/dev/null | head -1 || true)"
  [ -r "$deb" ] || deb="$(find "$dir" -maxdepth 1 -name "opentelemetry-shell_*_all.deb" 2>/dev/null | head -1 || true)"
  echo "$deb"
}

# Case 1: only arch-specific deb present (the bug scenario - amd64 cache used on amd64)
touch "$tmp_cache/opentelemetry-shell_1.0.0_${arch_normalized}.deb"
result="$(find_otelshell_deb "$tmp_cache" "$arch_normalized")"
assert_equals "$tmp_cache/opentelemetry-shell_1.0.0_${arch_normalized}.deb" "$result"
rm "$tmp_cache/opentelemetry-shell_1.0.0_${arch_normalized}.deb"

# Case 2: only _all.deb present (backward-compatible fallback)
touch "$tmp_cache/opentelemetry-shell_1.0.0_all.deb"
result="$(find_otelshell_deb "$tmp_cache" "$arch_normalized")"
assert_equals "$tmp_cache/opentelemetry-shell_1.0.0_all.deb" "$result"
rm "$tmp_cache/opentelemetry-shell_1.0.0_all.deb"

# Case 3: both present — arch-specific should be preferred
touch "$tmp_cache/opentelemetry-shell_1.0.0_${arch_normalized}.deb"
touch "$tmp_cache/opentelemetry-shell_1.0.0_all.deb"
result="$(find_otelshell_deb "$tmp_cache" "$arch_normalized")"
assert_equals "$tmp_cache/opentelemetry-shell_1.0.0_${arch_normalized}.deb" "$result"
rm "$tmp_cache/opentelemetry-shell_1.0.0_${arch_normalized}.deb" "$tmp_cache/opentelemetry-shell_1.0.0_all.deb"

# Case 4: neither present — result should be empty
result="$(find_otelshell_deb "$tmp_cache" "$arch_normalized")"
assert_equals "" "$result"

# Arch canonicalization: x86_64 -> amd64, aarch64 -> arm64, ppc64le -> ppc64el
assert_equals "amd64" "$(echo x86_64 | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g' | sed 's/le$/el/g')"
assert_equals "arm64" "$(echo aarch64 | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g' | sed 's/le$/el/g')"
assert_equals "ppc64el" "$(echo ppc64le | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g' | sed 's/le$/el/g')"
assert_equals "s390x" "$(echo s390x | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g' | sed 's/le$/el/g')"

rmdir "$tmp_cache"
