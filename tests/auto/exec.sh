set -e
. /usr/bin/opentelemetry_shell.sh
if [ "$OPEN_FD" = TRUE ]; then exec 3>&2; fi
if [ "$SOURCE" = TRUE ]; then
  file="$(\mktemp)"
  echo 'exec echo' "$@" > "$file"
  . "$file"
else
  exec echo "$@"
fi
