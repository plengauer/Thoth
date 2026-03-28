#!/bin/sh -e
export GITHUB_ACTION_REPOSITORY="${GITHUB_ACTION_REPOSITORY:-"$GITHUB_REPOSITORY"}"

if ! type sudo 1> /dev/null 2> /dev/null; then
  function sudo() {
    while [ "$1" != "${1#-}" ]; do shift; done
    "$@"
  }
  export -f sudo
fi
if type dpkg 1> /dev/null 2> /dev/null; then
  pkg_ext=deb
  install_package() { sudo -E -H apt-get install -y "$@"; }
elif type rpm 1> /dev/null 2> /dev/null; then
  pkg_ext=rpm
  if type dnf 1> /dev/null 2> /dev/null; then
    install_package() { sudo -E -H dnf -y install "$@"; }
  elif type yum 1> /dev/null 2> /dev/null; then
    install_package() { sudo -E -H yum -y install "$@"; }
  elif type zypper 1> /dev/null 2> /dev/null; then
    install_package() { sudo -E -H zypper --non-interactive install --allow-unsigned-rpm "$@"; }
  else
    install_package() { sudo rpm --install "$@"; }
  fi
elif type apk 1> /dev/null 2> /dev/null; then
  pkg_ext=apk
  install_package() { sudo apk add --allow-untrusted "$@"; }
fi
export -f install_package
ensure_installed() { for item in "$@"; do type "${item%%;*}" 1> /dev/null 2> /dev/null || echo "${item#*;}"; done | sort -u | xargs -r bash -c 'install_package "$@"' bash; }
ensure_installed jq curl wget "$@" || (type apt-get 1> /dev/null 2> /dev/null && sudo apt-get update && ensure_installed jq curl wget "$@")

if ! type otel.sh 2> /dev/null; then
  echo "::debug::Installing ..."
  action_tag_name="${GITHUB_ACTION_REF#*@}"
  if [ "$GITHUB_REPOSITORY" = "$GITHUB_ACTION_REPOSITORY" ] && [ -f "$GITHUB_WORKSPACE"/package."$pkg_ext" ]; then
    echo "::debug::Installing local package ..."
    install_package "$GITHUB_WORKSPACE"/package."$pkg_ext"
  elif [ "$pkg_ext" = deb ]; then
    echo "::debug::Downloading debian and installing ..."
    debian_file=/var/cache/apt/archives/opentelemetry-shell_"$(cat ../../../VERSION)"_all.deb
    [ "$action_tag_name" = main ] || action_tag_name=v"$(cat ../../../VERSION)"
    GITHUB_REPOSITORY="$GITHUB_ACTION_REPOSITORY" gh_release "$action_tag_name" | jq '.assets[] | select(.name | endswith(".deb")) | .url' -r | xargs -0 -I '{}' wget --header "Authorization: Bearer $INPUT_GITHUB_TOKEN" --header 'Accept: application/octet-stream' -O - '{}' | sudo tee "$debian_file" > /dev/null
    sudo -E -H apt-get -o Binary::apt::APT::Keep-Downloaded-Packages=true install -y "$debian_file"
  else
    echo "::debug::Downloading package and installing ..."
    [ "$action_tag_name" = main ] || action_tag_name=v"$(cat ../../../VERSION)"
    package_file="$(mktemp -u)"."$pkg_ext"
    GITHUB_REPOSITORY="$GITHUB_ACTION_REPOSITORY" gh_release "$action_tag_name" | jq '.assets[] | select(.name | endswith(".'"$pkg_ext"'")) | .url' -r | xargs -0 -I '{}' wget --header "Authorization: Bearer $INPUT_GITHUB_TOKEN" --header 'Accept: application/octet-stream' -O "$package_file" '{}'
    install_package "$package_file"
    rm "$package_file"
  fi || (
      echo ::warning::'Cannot find release for specified tag, falling back to latest. This may be due to tags that haven'\''t finished building yet (like in a fresh fork), in which case this will resolve automatically.' >&2
      package_file="$(mktemp -u)"."$pkg_ext"
      curl --fail -L -s -H "Authorization: Bearer $INPUT_GITHUB_TOKEN" "${GITHUB_API_URL:-https://api.github.com}"/repos/"$GITHUB_ACTION_REPOSITORY"/releases/latest | jq '.assets[] | select(.name | endswith(".'"$pkg_ext"'")) | .url' -r | xargs -0 -I '{}' wget --header "Authorization: Bearer $INPUT_GITHUB_TOKEN" --header 'Accept: application/octet-stream' -O "$package_file" '{}'
      install_package "$package_file"
      rm "$package_file"
    ) || ( echo ::warning::'Cannot find any release in repository, falling back to root repository' >&2 && wget -O - https://raw.githubusercontent.com/plengauer/Thoth/main/INSTALL.sh | sh -e )
fi
