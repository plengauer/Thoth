. ./assert.sh

tmp_dir="$(mktemp -d)"

cat > "$tmp_dir"/dpkg << 'EOF'
#!/bin/sh
exit 1
EOF
chmod +x "$tmp_dir"/dpkg

cat > "$tmp_dir"/rpm << 'EOF'
#!/bin/sh
exit 1
EOF
chmod +x "$tmp_dir"/rpm

cat > "$tmp_dir"/apk << 'EOF'
#!/bin/sh
if [ "$1" = info ] && [ "$2" = -e ] && [ "$3" = -v ] && [ "$4" = opentelemetry-shell ]; then
  echo opentelemetry-shell-1.2.3-r0
  exit 0
fi
exit 1
EOF
chmod +x "$tmp_dir"/apk

PATH="$tmp_dir:$PATH"
. ../src/usr/share/opentelemetry_shell/api.sh

assert_equals 1.2.3 "$(_otel_resolve_package_version opentelemetry-shell)"
