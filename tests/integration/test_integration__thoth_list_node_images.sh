[ -d ../src/usr/share/opentelemetry_shell/agent.instrumentation.node ] || exit 0
set +f
export OTEL_SHELL_CONFIG_OBSERVE_PIPES=TRUE
export OTEL_SHELL_CONFIG_MUTE_INTERNALS=TRUE
export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE
export OTEL_SHELL_CONFIG_OBSERVE_SUBPROCESSES=TRUE
. otel.sh
( cd ../src/usr/share/opentelemetry_shell/agent.instrumentation.node && rm -rf node_modules && npm install --force )
seq 0 99 | while read -r line; do
  version_min="$(cat ../src/usr/share/opentelemetry_shell/agent.instrumentation.node/node_modules/@opentelemetry/*/package.json | jq -r .engines.node | grep -v null | cut -d ' ' -f 1 | tr -d ^ | cut -d = -f 2 | cut -d . -f 1 | sort -n -u | tail -n 1)"
  version_max="$(cat ../src/usr/share/opentelemetry_shell/agent.instrumentation.node/Dockerfile | grep '^FROM ' | cut -d ' ' -f 2 | cut -d : -f 2)"
  seq "$version_min" "$version_max" | jq -s -c | xargs -0 -I {} echo 'versions={}'
done
