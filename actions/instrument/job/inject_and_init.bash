set -e

curl() {
  command curl --no-progress-meter --fail --retry 12 --retry-all-errors "$GITHUB_API_URL"/repos/"$GITHUB_REPOSITORY"/actions/runs/"$GITHUB_RUN_ID"/"$1"
}
export -f curl

if [ -z "$GITHUB_ACTION_REPOSITORY" ]; then export GITHUB_ACTION_REPOSITORY="$GITHUB_REPOSITORY"; fi
action_tag_name="$(echo "$GITHUB_ACTION_REF" | cut -sd @ -f 2-)"
if [ -n "$action_tag_name" ]; then
  debian_file="$(mktemp)"
  command curl --no-progress-meter --fail --retry 12 --retry-all-errors "$GITHUB_API_URL"/repos/"$GITHUB_ACTION_REPOSITORY"/releases | { if [ "$action_tag_name" = main ]; then jq '.[0]'; else jq '.[] | select(.tag_name=="'"$action_tag_name"'")'; fi } | jq -r '.assets[] | .browser_download_url' | xargs wget -O "$debian_file"
  sudo apt-get install -y "$debian_file"
  rm "$debian_file"
else
  wget -O - https://raw.githubusercontent.com/"$GITHUB_ACTION_REPOSITORY"/main/INSTALL.sh | sh
fi
npm install '@actions/artifact'

my_dir="$(echo "$0" | rev | cut -d / -f 2- | rev)"
new_path_dir="$(mktemp -d)"
gcc -o "$new_path_dir"/sh "$my_dir"/forward.c -DEXECUTABLE="$(which sh)" -DARG1="$my_dir"/forward.sh -DARG2="$(which sh)"
gcc -o "$new_path_dir"/dash "$my_dir"/forward.c -DEXECUTABLE="$(which dash)" -DARG1="$my_dir"/forward.sh -DARG2="$(which dash)"
gcc -o "$new_path_dir"/bash "$my_dir"/forward.c -DEXECUTABLE="$(which bash)" -DARG1="$my_dir"/forward.sh -DARG2="$(which bash)"
echo "$new_path_dir" >> "$GITHUB_PATH"

if curl jobs | jq -r '.jobs[] | select(.status != "completed") | .name' | grep -q '^observe$'; then
  while ! curl artifacts | jq -r '.artifacts[].name' | grep -q '^opentelemetry$'; do sleep 3; done
fi
env_dir="$(mktemp -d)"
node download_artifact.js opentelemetry "$env_dir" || true
if [ -f "$env_dir"/.env ]; then
  while read -r line; do
    export "$line"
  done < "$env_dir"/.env
fi
rm -r "$env_dir"

if [ -z "$OTEL_SERVICE_NAME" ]; then
  export OTEL_SERVICE_NAME="$(echo "$GITHUB_REPOSITORY" | cut -d / -f 2-) CI"
fi

root4job_end() {
  if [ "$(curl jobs | jq -r ".jobs[] | select(.name == \"$GITHUB_JOB\") | select(.run_attempt == $GITHUB_RUN_ATTEMPT) | .steps[] | select(.status == \"completed\") | select(.conclusion == \"failure\") | .name" | wc -l)" -gt 0 ]; then
    otel_span_error "$span_handle"
  fi
  otel_span_end "$span_handle"
  otel_shutdown
  exit 0
}
export -f root4job_end

root4job() {
  traceparent_file="$1"
  . otelapi.sh
  otel_init
  span_handle="$(otel_span_start CONSUMER "$GITHUB_WORKFLOW / $GITHUB_JOB")"
  otel_span_activate "$span_handle"
  echo "$OTEL_TRACEPARENT" > "$traceparent_file"
  otel_span_deactivate "$span_handle"
  trap root4job_end SIGUSR1
  while true; do sleep 1; done
}
export -f root4job

root_pid_file="$(mktemp -u | rev | cut -d / -f 2- | rev)/opentelemetry_shell_$GITHUB_RUN_ID.pid"
traceparent_file="$(mktemp -u)"
nohup bash -c 'root4job "$@"' bash "$traceparent_file" &> /dev/null &
echo "$!" > "$root_pid_file"

while ! [ -f "$traceparent_file" ]; do sleep 1; done
export OTEL_TRACEPARENT="$(cat "$traceparent_file")"
rm "$traceparent_file"

printenv | grep '^OTEL_' >> "$GITHUB_ENV"
