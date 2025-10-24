\set -x
. /usr/bin/opentelemetry_shell.sh
\set +x
alias curl >&2
curl "$@"
