if ! \[ -f /usr/share/debconf/confmodule ]; then exit 0; fi
\export DEBIAN_FRONTEND=noninteractive

if \[ -x populate.sh ]; then
  . otel.sh
else
  \echo '. /usr/share/debconf/confmodule
  echo hello world
  ' > populate.sh
  chmod +x populate.sh
fi

sh -e populate.sh
. otel.sh
. /usr/share/debconf/confmodule
db_stop
