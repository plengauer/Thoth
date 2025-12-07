if ! \[ -f /usr/share/debconf/confmodule ]; then exit 0; fi
\export DEBIAN_FRONTEND=noninteractive

if \[ -x populate.sh ]; then
  . otel.sh
else
  \echo '. /usr/share/debconf/confmodule
echo hello world
value() {
  db_get philbot/"$*"
  \echo "$RET"
}
config() {
    value "$*" | xargs -I {} /bin/echo "$*={}"
}
config DISCORD_API_TOKEN
' > populate.sh
  chmod +x populate.sh
fi

sh -e ./populate.sh
. otel.sh
. /usr/share/debconf/confmodule
config() { db_get philbot-containerized/"$*"; echo "$*=$RET"; }
config SHARD_COUNT_MIN  
db_stop
