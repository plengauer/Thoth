#!/bin/bash
set -e

github() {
  url="$GITHUB_API_URL"/"$1"?per_page=100
  curl --no-progress-meter --fail --retry 16 --retry-all-errors --head "$url" \
    | grep '^link: ' | cut -d ' '  -f 2- | tr -d ' <>' | tr ',' '\n' \
    | grep 'rel="last"' | cut -d ';' -f1 | cut -d '?' -f 2- | tr '&' '\n' \
    | grep '^page=' | cut -d = -f 2 \
    | xargs seq 1 | while IFS= read -r page; do
      curl --no-progress-meter --fail --retry 16 --retry-all-errors "$url"\&page="$page"
    done
}
export -f github

github_workflow() {
  github repos/"$GITHUB_REPOSITORY"/actions/runs/"$GITHUB_RUN_ID"/"$1"
}
export -f github_workflow

echo "$GITHUB_ACTION" > /tmp/opentelemetry_shell_action_name

if [ -z "$GITHUB_ACTION_REPOSITORY" ]; then export GITHUB_ACTION_REPOSITORY="$GITHUB_REPOSITORY"; fi
action_tag_name="$(echo "$GITHUB_ACTION_REF" | cut -sd @ -f 2-)"
if [ -n "$action_tag_name" ]; then
  debian_file="$(mktemp)"
  github repos/"$GITHUB_ACTION_REPOSITORY"/releases | { if [ "$action_tag_name" = main ]; then jq '.[0]'; else jq '.[] | select(.tag_name=="'"$action_tag_name"'")'; fi } | jq -r '.assets[] | .browser_download_url' | xargs wget -O "$debian_file"
  sudo -E apt-get install -y "$debian_file"
  rm "$debian_file"
elif [ "$GITHUB_REPOSITORY" = "$GITHUB_ACTION_REPOSITORY" ]; then
  dpkg -l | grep -q opentelemetry-shell
else
  wget -O - https://raw.githubusercontent.com/"$GITHUB_ACTION_REPOSITORY"/main/INSTALL.sh | sh
fi
npm install '@actions/artifact'

my_dir="$(echo "$0" | rev | cut -d / -f 2- | rev)"
new_path_dir="/tmp/otel/bin"
mkdir -p "$new_path_dir"
gcc -o "$new_path_dir"/sh "$my_dir"/forward.c -DEXECUTABLE="$(which sh)" -DARG1="$my_dir"/decorate_action_run.sh -DARG2="$(which sh)"
gcc -o "$new_path_dir"/dash "$my_dir"/forward.c -DEXECUTABLE="$(which dash)" -DARG1="$my_dir"/decorate_action_run.sh -DARG2="$(which dash)"
gcc -o "$new_path_dir"/bash "$my_dir"/forward.c -DEXECUTABLE="$(which bash)" -DARG1="$my_dir"/decorate_action_run.sh -DARG2="$(which bash)"
echo "$new_path_dir" >> "$GITHUB_PATH"

for node_path in /home/runner/runners/*/externals/node*/bin/node; do
  dir_path_new="$(echo "$node_path" | rev | cut -d / -f 2- | rev).original"
  mkdir "$dir_path_new"
  node_path_new="$dir_path_new"/node
  mv "$node_path" "$node_path_new"
  gcc -o "$node_path" "$my_dir"/forward.c -DEXECUTABLE=/bin/bash -DARG1="$my_dir"/decorate_action_node.sh -DARG2="$node_path_new"
done

# cant use the same path trick as for the shells, because path is resolved at the very start, so paths must not change
docker_path="$(which docker)"
sudo mv "$docker_path" "$my_dir"
sudo gcc -o "$docker_path" "$my_dir"/forward.c -DEXECUTABLE=/bin/bash -DARG1="$my_dir"/decorate_action_docker.sh -DARG2="$my_dir"/docker

if github_workflow jobs | jq -r '.jobs[] | select(.status != "completed") | .name' | grep -q '^observe$'; then
  while ! github_workflow artifacts | jq -r '.artifacts[].name' | grep -q '^opentelemetry$'; do sleep 3; done
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
  if [ -f /tmp/opentelemetry_shell.github.error ]; then
    otel_span_error "$span_handle"
  fi
  otel_span_end "$span_handle"
  otel_shutdown
  exit 0
}
export -f root4job_end

root4job() {
  rm /tmp/opentelemetry_shell.github.error 2> /dev/null
  ( while true; do cat "$OTEL_SHELL_SDK_OUTPUT_REDIRECT"; done >> "$OTEL_SHELL_SDK_LOG_FILE" ) 1> /dev/null 2> /dev/null &
  traceparent_file="$1"
  . otelapi.sh
  otel_init
  span_handle="$(otel_span_start CONSUMER "$GITHUB_WORKFLOW / $GITHUB_JOB")"
  otel_span_activate "$span_handle"
  echo "$TRACEPARENT" > "$traceparent_file"
  otel_span_deactivate "$span_handle"
  trap root4job_end SIGUSR1
  while true; do sleep 1; done
}
export -f root4job

tmp_dir="$(mktemp -d)"
chmod 777 "$tmp_dir"
export OTEL_SHELL_SDK_OUTPUT_REDIRECT="$(mktemp -u -p "$tmp_dir")"
mkfifo "$OTEL_SHELL_SDK_OUTPUT_REDIRECT"
chmod 777 "$OTEL_SHELL_SDK_OUTPUT_REDIRECT"
export OTEL_SHELL_SDK_LOG_FILE="$(mktemp -u -p "$tmp_dir")"
echo "log_file=$OTEL_SHELL_SDK_LOG_FILE" >> "$GITHUB_STATE"
traceparent_file="$(mktemp -u)"
nohup bash -c 'root4job "$@"' bash "$traceparent_file" &> /dev/null &
echo "pid=$!" >> "$GITHUB_STATE"

while ! [ -f "$traceparent_file" ]; do sleep 1; done
export TRACEPARENT="$(cat "$traceparent_file")"
rm "$traceparent_file"

export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE
export OTEL_SHELL_CONFIG_OBSERVE_PIPES=TRUE

printenv | grep -E '^OTEL_|^TRACEPARENT=|^TRACESTATE=' >> "$GITHUB_ENV"
