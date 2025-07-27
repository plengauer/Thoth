set -e
. /usr/bin/opentelemetry_shell.sh
if [ "$OPEN_FD" = TRUE ]; then exec 3>&2; fi
if [ "$SOURCE" = TRUE ]; then
  echo 'exec echo' "$@" > source_exec.sh
  . ./source_exec.sh
else
  exec echo "$@"
fi
