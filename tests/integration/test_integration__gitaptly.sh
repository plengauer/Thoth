set +f
if ! type sudo || ! type systemctl || ! type apt-get || [ -n "${WSL_DISTRO_NAME:-}" ]; then
  exit 0
fi

if [ -n "${GITHUB_TOKEN:-}" ] && type debconf-set-selections; then
  echo gitaptly gitaptly/GITHUB_API_TOKEN string "$GITHUB_TOKEN" | sudo debconf-set-selections
fi
curl --fail --retry 16 --retry-all-errors https://api.github.com/repos/plengauer/abom-http/releases/latest https://api.github.com/repos/plengauer/gitaptly/releases/latest | jq -r '.assets[].browser_download_url' | grep '.deb$' | xargs wget
DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -y ./*.deb || exit 0
sleep 5
curl http://127.0.0.1:8000/dists/stable/main/binary-all/Packages | grep '^Filename: ' | cut -d ' ' -f 2- | head -n1 | xargs -I {} wget http://127.0.0.1:8000/{}
