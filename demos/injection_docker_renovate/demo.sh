export RENOVATE_TOKEN="$GITHUB_TOKEN"
. otel.sh
sudo -E docker run --rm --network host --env RENOVATE_TOKEN renovate/renovate --dry-run plengauer/Thoth
