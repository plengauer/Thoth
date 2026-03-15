#!/bin/sh -e
export GITHUB_ACTION_REPOSITORY="${GITHUB_ACTION_REPOSITORY:-"$GITHUB_REPOSITORY"}"

if [ "$(uname -s)" = "Darwin" ]; then
  ensure_installed() { for item in "$@"; do type "${item%%;*}" 1> /dev/null 2> /dev/null || echo "${item#*;}"; done | sort -u | xargs -n 1 -I '{}' brew install '{}'; }
  ensure_installed jq curl wget "$@"
else
  ensure_installed() { for item in "$@"; do type "${item%%;*}" 1> /dev/null 2> /dev/null || echo "${item#*;}"; done | sort -u | xargs -r sudo apt-get -y install; }
  ensure_installed jq curl wget "$@" || (sudo apt-get update && ensure_installed jq curl wget "$@")
fi

if ! type otel.sh 2> /dev/null; then
  echo "::debug::Installing ..."
  action_tag_name="${GITHUB_ACTION_REF#*@}"
  if [ "$(uname -s)" = "Darwin" ]; then
    echo "::debug::Installing via Homebrew ..."
    brew tap plengauer/opentelemetry-shell https://github.com/"$GITHUB_ACTION_REPOSITORY" || true
    brew install opentelemetry-shell || (
      echo ::warning::'Cannot install via Homebrew tap, falling back to tarball installation' >&2
      [ "$action_tag_name" = main ] || action_tag_name=v"$(cat ../../../VERSION)"
      tarball_file=/tmp/opentelemetry-shell.tar.gz
      GITHUB_REPOSITORY="$GITHUB_ACTION_REPOSITORY" gh_release "$action_tag_name" | jq '.assets[] | select(.name | endswith(".tar.gz")) | .url' -r | xargs -0 -I '{}' wget --header "Authorization: Bearer $INPUT_GITHUB_TOKEN" --header 'Accept: application/octet-stream' -O "$tarball_file" '{}'
      sudo mkdir -p /usr/local/share /usr/local/bin /usr/local/opt
      sudo tar xzf "$tarball_file" -C /usr/local
      sudo ln -sf /usr/local/usr/bin/otel.sh /usr/local/bin/otel.sh
      sudo ln -sf /usr/local/usr/bin/otelapi.sh /usr/local/bin/otelapi.sh
      rm "$tarball_file"
    )
  elif [ "$GITHUB_REPOSITORY" = "$GITHUB_ACTION_REPOSITORY" ] && [ -f "$GITHUB_WORKSPACE"/package.deb ]; then
    echo "::debug::Installing local debian ..."
    sudo -E -H apt-get install -y "$GITHUB_WORKSPACE"/package.deb
  else
    echo "::debug::Downloading debian and installing ..."
    debian_file=/var/cache/apt/archives/opentelemetry-shell_"$(cat ../../../VERSION)"_all.deb
    [ "$action_tag_name" = main ] || action_tag_name=v"$(cat ../../../VERSION)"
    GITHUB_REPOSITORY="$GITHUB_ACTION_REPOSITORY" gh_release "$action_tag_name" | jq '.assets[] | select(.name | endswith(".deb")) | .url' -r | xargs -0 -I '{}' wget --header "Authorization: Bearer $INPUT_GITHUB_TOKEN" --header 'Accept: application/octet-stream' -O - '{}' | sudo tee "$debian_file" > /dev/null
    sudo -E -H apt-get -o Binary::apt::APT::Keep-Downloaded-Packages=true install -y "$debian_file"
  fi || (
      echo ::warning::'Cannot find release for specified tag, falling back to latest. This may be due to tags that haven'\''t finished building yet (like in a fresh fork), in which case this will resolve automatically.' >&2
      if [ "$(uname -s)" = "Darwin" ]; then
        curl --fail -L -s -H "Authorization: Bearer $INPUT_GITHUB_TOKEN" "${GITHUB_API_URL:-https://api.github.com}"/repos/"$GITHUB_ACTION_REPOSITORY"/releases/latest | jq '.assets[] | select(.name | endswith(".tar.gz")) | .url' -r | xargs -0 -I '{}' wget --header "Authorization: Bearer $INPUT_GITHUB_TOKEN" --header 'Accept: application/octet-stream' -O /tmp/package.tar.gz '{}'
        sudo tar xzf /tmp/package.tar.gz -C /usr/local
        sudo ln -sf /usr/local/usr/bin/otel.sh /usr/local/bin/otel.sh
        sudo ln -sf /usr/local/usr/bin/otelapi.sh /usr/local/bin/otelapi.sh
        rm /tmp/package.tar.gz
      else
        curl --fail -L -s -H "Authorization: Bearer $INPUT_GITHUB_TOKEN" "${GITHUB_API_URL:-https://api.github.com}"/repos/"$GITHUB_ACTION_REPOSITORY"/releases/latest | jq '.assets[] | select(.name | endswith(".deb")) | .url' -r | xargs -0 -I '{}' wget --header "Authorization: Bearer $INPUT_GITHUB_TOKEN" --header 'Accept: application/octet-stream' -O /tmp/package.deb '{}'
        sudo -E -H apt-get install -y /tmp/package.deb
        rm /tmp/package.deb
      fi
    ) || ( echo ::warning::'Cannot find any release in repository, falling back to root repository' >&2 && wget -O - https://raw.githubusercontent.com/plengauer/Thoth/main/INSTALL.sh | sh -e )
fi
