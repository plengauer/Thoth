#!/bin/sh
set -e

if type dpkg 1>/dev/null 2>/dev/null; then
  extension=deb
elif type rpm 1>/dev/null 2>/dev/null; then
  extension=rpm
elif type apk 1>/dev/null 2>/dev/null; then
  extension=apk
else
  echo "Unsupported operating system (no apt-get, no rpm, and no apk available)" >&2
  exit 1
fi

package="$(mktemp -u)"."$extension"
extract_release_version() {
  while IFS= read -r location_header; do
    case "$location_header" in
      *"location: "*"/releases/tag/v"*)
        location_header="${location_header##*location: }"
        location_header="${location_header##*/releases/tag/v}"
        case "$location_header" in
          */* | '') ;;
          *) echo "$location_header" ;;
        esac
        ;;
    esac
  done
}
api_response="$(mktemp)"
if curl -L --no-progress-meter https://api.github.com/repos/plengauer/Thoth/releases/latest > "$api_response"; then
  if ! jq '.assets // [] | .[] | select(.name | endswith("'"$extension"'"))' < "$api_response" | jq -s | case "$extension" in
    deb) jq 'if . | any(.name | endswith("_all.deb")) then .[] | select(.name | endswith("_'"$(arch | sed s/x86_64/amd64/g | sed s/aarch64/arm64/g | sed 's/le$/el/g')"'.deb")) else .[0] end' ;;
    rpm) jq 'if . | any(.name | endswith(".noarch.rpm")) then .[] | select(.name | endswith("_'"$(arch)"'.rpm")) else .[0] end' ;;
    apk) jq '.[0]' ;;
    *) echo "Here be dragons" >&2; exit 1 ;;
  esac | jq -r 'select((.browser_download_url? // "") | (type == "string" and length > 0)) | .browser_download_url' | xargs -r wget -O "$package"; then
    rm -f "$package"
  fi
else
  rm -f "$package"
fi
rm -f "$api_response"
if ! [ -r "$package" ]; then
  echo "Warning: failed to use API, falling back to downloading directly." >&2
  curl -v --no-progress-meter https://github.com/plengauer/Thoth/releases/latest 2>&1 | grep location | tr -d '\r' | extract_release_version | case "$extension" in
    deb) xargs -I '{}' echo -n opentelemetry-shell_'{}'_"$(arch | sed s/x86_64/amd64/g | sed s/aarch64/arm64/g | sed 's/le$/el/g')".deb ;;
    rpm) xargs -I '{}' echo -n opentelemetry-shell-'{}'-1."$(arch)".rpm ;;
    apk) xargs -I '{}' echo -n opentelemetry-shell-'{}'-r0.apk ;;
    *) echo "Here be dragons" >&2 ;;
  esac | xargs -r -I '{}' wget -O "$package" https://github.com/plengauer/Thoth/releases/latest/download/'{}'
fi
if ! [ -r "$package" ]; then
  echo "Warning: failed to use API and failed to directly download architecture-dependent package, falling back to downloading architecture-independent package directly." >&2
  curl -v --no-progress-meter https://github.com/plengauer/Thoth/releases/latest 2>&1 | grep location | tr -d '\r' | extract_release_version | case "$extension" in
    deb) xargs -I '{}' echo -n opentelemetry-shell_'{}'_all.deb ;;
    rpm) xargs -I '{}' echo -n opentelemetry-shell-'{}'-1.noarch.rpm ;;
    apk) xargs -I '{}' echo -n opentelemetry-shell-'{}'-r0.apk ;;
    *) echo "Here be dragons" >&2 ;;
  esac | xargs -r -I '{}' wget -O "$package" https://github.com/plengauer/Thoth/releases/latest/download/'{}'
fi
if ! [ -r "$package" ]; then
  echo "Warning: failed to use API and failed to directly download any package, falling back to old releases format." >&2
  curl -v --no-progress-meter https://github.com/plengauer/Thoth/releases/latest 2>&1 | grep location | tr -d '\r' | extract_release_version | xargs -I '{}' echo -n opentelemetry-shell_'{}'."$extension" | xargs -r -I '{}' wget -O "$package" https://github.com/plengauer/Thoth/releases/latest/download/'{}'
fi
if ! [ -r "$package" ]; then
  echo "Error: failed download package." >&2
  exit 1
fi

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
