#!/bin/sh -e
export GITHUB_ACTION_REPOSITORY="${GITHUB_ACTION_REPOSITORY:-"$GITHUB_REPOSITORY"}"

ensure_installed() { for item in "$@"; do type "${item%%;*}" 1> /dev/null 2> /dev/null || echo "${item#*;}"; done | sort -u | (type eatmydata 1> /dev/null 2> /dev/null && xargs -r sudo eatmydata apt-get -y install || xargs -r sudo apt-get -y install); }
ensure_installed eatmydata jq curl wget "$@" || (sudo apt-get update && ensure_installed eatmydata jq curl wget "$@")

if ! type otel.sh 2> /dev/null; then
  action_tag_name="${GITHUB_ACTION_REF#*@}"
  if [ "$GITHUB_REPOSITORY" = "$GITHUB_ACTION_REPOSITORY" ] && [ -f "$GITHUB_WORKSPACE"/package.deb ]; then
    sudo -E -H eatmydata apt-get install -y "$GITHUB_WORKSPACE"/package.deb
  else
    debian_file=/var/cache/apt/archives/opentelemetry-shell_"$(cat ../../../VERSION)"_all.deb
    [ "$action_tag_name" = main ] || action_tag_name=v"$(cat ../../../VERSION)"
    gh_release "$action_tag_name" | jq '.assets[] | select(.name | endswith(".deb")) | .url' -r | xargs -0 -I '{}' wget --header "Authorization: Bearer $INPUT_GITHUB_TOKEN" --header 'Accept: application/octet-stream' -O - '{}' | sudo tee "$debian_file" > /dev/null
    sudo -E -H eatmydata apt-get -o Binary::apt::APT::Keep-Downloaded-Packages=true install -y "$debian_file"
  fi || (
      echo ::warning::'Cannot find release for specified tag, falling back to latest. This may be due to tags that haven'\''t finished building yet (like in a fresh fork), in which case this will resolve automatically.' >&2
      curl --fail -L -s -H "Authorization: Bearer $INPUT_GITHUB_TOKEN" "${GITHUB_API_URL:-https://api.github.com}"/repos/"$GITHUB_ACTION_REPOSITORY"/releases/latest | jq '.assets[] | select(.name | endswith(".deb")) | .url' -r | xargs -0 -I '{}' wget --header "Authorization: Bearer $INPUT_GITHUB_TOKEN" --header 'Accept: application/octet-stream' -O /tmp/package.deb '{}'
      sudo -E -H eatmydata apt-get install -y /tmp/package.deb
      rm /tmp/package.deb
    ) || ( echo ::warning::'Cannot find any release in repository, falling back to root repository' >&2 && wget -O - https://raw.githubusercontent.com/plengauer/Thoth/main/INSTALL.sh | sh -e )
fi
