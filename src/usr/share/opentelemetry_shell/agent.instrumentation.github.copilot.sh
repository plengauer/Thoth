#!/bin/false

if \[ "${GITHUB_ACTIONS:-false}" = true ] && \[ "$GITHUB_WORKFLOW" = 'Copilot coding agent' ] && \[ "$GITHUB_JOB" = copilot ] && \[ -n "${COPILOT_AGENT_RUNTIME_VERSION:-}" ] && \[ -n "${GITHUB_COPILOT_ACTION_DOWNLOAD_URL:-}" ]; then
  _otel_inject_copilot() {
    local exit_code=0
    _otel_call "$@" || local exit_code=$?
    if \[ "$exit_code" = 0 ] && \[ "$*" = 'tar -zxvf ./action.tar.gz' ]; then
      for script_file in "${RUNNER_TEMP}"/*-action-*/*/*.sh; do
        \sed -i 's~#!/bin/sh~#!/bin/sh\n. otel.sh~g' "$script_file"
        \sed -i 's~#!/bin/bash~#!/bin/bash\n. otel.sh~g' "$script_file"
        \sed -i 's~"$RUNNER_PATH/ghcca-node/node/bin/node"~_otel_inject "$RUNNER_PATH/ghcca-node/node/bin/node"~g' "$script_file"
        \sed -i 's~"${target_location}/node/bin/node"~_otel_inject "${target_location}/node/bin/node"~g' "$script_file"
        \sed -i 's~^${command_to_execute}$~_otel_inject ${command_to_execute}~g' "$script_file"
      done || \true
    fi
    return "$exit_code"
  }
  _otel_alias_prepend tar _otel_inject_copilot
fi
