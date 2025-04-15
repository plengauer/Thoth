#!/bin/sh -e
export GITHUB_ACTION_REPOSITORY="${GITHUB_ACTION_REPOSITORY:-"$GITHUB_REPOSITORY"}"

ensure_installed() { type "$1" 2> /dev/null || sudo apt-get install "${2:-$1}"; }
ensure_installed curl
ensure_installed wget
ensure_installed jq
ensure_installed sed
ensure_installed unzip
ensure_installed node nodejs
ensure_installed npm
ensure_installed docker docker.io

cp ../shared/package.json . && npm install && rm package.json

if ! type otel.sh 2> /dev/null; then
  action_tag_name="$(echo "$GITHUB_ACTION_REF" | cut -sd @ -f 2-)"
  if [ -z "$action_tag_name" ]; then action_tag_name="v$(cat ../../../VERSION)"; fi
  if [ -n "$action_tag_name" ]; then
    if [ "$INPUT_CACHE" = "true" ]; then
      cache_key="${GITHUB_ACTION_REPOSITORY} ${action_tag_name} $({ cat /etc/os-release; python3 --version; node --version; printenv | grep -E '^OTEL_SHELL_CONFIG_INSTALL_'; } | md5sum | cut -d ' ' -f 1)"
      sudo -E -H node -e "require('@actions/cache').restoreCache(['/var/cache/apt/archives/*.deb', '/opt/opentelemetry_shell/sdk/venv', '/opt/opentelemetry_shell/venv', '/opt/opentelemetry_shell/node_modules', '/opt/opentelemetry_shell/opentelemetry-javaagent.jar', '/opt/opentelemetry_shell/rootcontextagent.jar', '/opt/opentelemetry_shell/collector.image'], '$cache_key');"
    fi
    debian_file=/var/cache/apt/archives/opentelemetry-shell_$(cat ../../../VERSION)_all.deb
    if ! [ -f "$debian_file" ]; then
      if [ "$GITHUB_REPOSITORY" = "$GITHUB_ACTION_REPOSITORY" ] && [ -f "$GITHUB_WORKSPACE"/package.deb ]; then
        echo "Using local debian." >&2
        sudo mv "$GITHUB_WORKSPACE"/package.deb "$debian_file"
      else
        gh_releases | ( [ "$action_tag_name" = main ] && jq '.[0]' || jq '.[] | select(.tag_name=="'"$action_tag_name"'")' ) | jq -r '.assets[].browser_download_url' | grep '.deb$' | xargs wget -O - | sudo tee "$debian_file" > /dev/null
      fi
      write_back_cache=TRUE
    fi
    OTEL_SHELL_CONFIG_INSTALL_ASSUME=TRUE sudo -E -H apt-get -o Binary::apt::APT::Keep-Downloaded-Packages=true install -y "$debian_file"
    if ! [ "${OTEL_SHELL_CONFIG_INSTALL_DEEP:-FALSE}" = TRUE ] && type docker 1> /dev/null 2> /dev/null && [ -r Dockerfile ]; then
      export OTEL_SHELL_COLLECTOR_IMAGE="$(cat Dockerfile | grep '^FROM ' | cut -d ' ' -f 2-)"
      if [ -r /opt/opentelemetry_shell/collector.image ]; then
        sudo docker load < /opt/opentelemetry_shell/collector.image
      else
        sudo docker pull "$OTEL_SHELL_COLLECTOR_IMAGE"
        sudo docker save "$OTEL_SHELL_COLLECTOR_IMAGE" | sudo tee /opt/opentelemetry_shell/collector.image > /dev/null
        write_back_cache=TRUE
      fi
    fi
    if [ "${write_back_cache:-FALSE}" = TRUE ] && [ -n "${cache_key:-}" ]; then
      sudo -E -H node -e "require('@actions/cache').saveCache(['/var/cache/apt/archives/*.deb', '/opt/opentelemetry_shell/sdk/venv', '/opt/opentelemetry_shell/venv', '/opt/opentelemetry_shell/node_modules', '/opt/opentelemetry_shell/opentelemetry-javaagent.jar', '/opt/opentelemetry_shell/rootcontextagent.jar', '/opt/opentelemetry_shell/collector.image'], '$cache_key');"
    fi
    sudo rm "$debian_file"
  else
    false
  fi || wget -O - https://raw.githubusercontent.com/"$GITHUB_ACTION_REPOSITORY"/main/INSTALL.sh | sh
fi
