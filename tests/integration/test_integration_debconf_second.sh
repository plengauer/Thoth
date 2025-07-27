. ./assert.sh
if ! [ -f /usr/share/debconf/confmodule ]; then exit 0; fi
. /usr/bin/opentelemetry_shell.sh
set +u
. /usr/share/debconf/confmodule
db_get $(debconf-show $(debconf-show --listowners | head -n1) | sed 's/^\* //' | sed 's/  //' | cut -d: -f1 | head -n1)
assert_equals 0 "$?"
