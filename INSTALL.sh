#!/bin/sh
set -e

if type dpkg 1> /dev/null 2> /dev/null; then
  extension=deb
elif type rpm 1> /dev/null 2> /dev/null; then
  extension=rpm
elif type apk 1> /dev/null 2> /dev/null; then
  extension=apk
else
  echo "Unsupported operating system (no apt-get, no rpm, and no apk available)" >&2
  exit 1
fi

package="$(mktemp -u)"."$extension"
curl -L --no-progress-meter https://api.github.com/repos/plengauer/opentelemetry-shell/releases/latest | jq -r '.assets[].browser_download_url' | grep '.'"$extension"'$' | xargs wget -O "$package" \
 || curl -v --no-progress-meter https://github.com/plengauer/Thoth/releases/latest 2>&1 | grep location | tr -d '\r' | rev | cut -d / -f 1 | rev | cut -d v -f 2 | xargs -I '{}' wget -O "$package" https://github.com/plengauer/Thoth/releases/latest/download/opentelemetry-shell_'{}'."$extension"

if [ "$(whoami)" = "root" ]; then
  wrapper=env
else
  wrapper=sudo
fi

case "$extension" in
  deb)
    if type apt-get; then
      $wrapper apt-get install -y "$package"  
    elif type apt; then
      $wrapper apt install -y "$package"  
    else
      $wrapper dpkg --install "$package"  
    fi
    ;;
  rpm)
    if type dnf; then
      $wrapper dnf -y install "$package"
    elif type yum; then
      $wrapper yum -y install "$package"
    elif type zypper; then
      $wrapper zypper --non-interactive install --allow-unsigned-rpm "$package"
    else
      $wrapper rpm --install "$package"
    fi
    ;;
  apk)
    $wrapper apk add --allow-untrusted "$package"
    ;;
  *)
    echo Here be dragons >&2
    exit 1
    ;;
esac

rm "$package"
