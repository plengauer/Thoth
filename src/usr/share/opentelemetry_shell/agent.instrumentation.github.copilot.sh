#!/bin/false

if \[ "${GITHUB_ACTIONS:-false}" = true ] && \[ "${GITHUB_EVENT_NAME:-}" = dynamic ] && (\[ "${GITHUB_JOB:-}" = copilot ] || \[ "${GITHUB_JOB:-}" = claude ] || \[ "${GITHUB_JOB:-}" = codex ]) && ! [ -f /tmp/thoth.copilot.instrumented ]; then
  for script_file in /opt/copilot-runtime/*-action-main/*/*.sh; do
    [ -f "$script_file" ] || continue
    if ! \grep -qF 'otel.sh' "$script_file"; then
      \sed -i 's~#!/bin/sh~#!/bin/sh\n. otel.sh~g' "$script_file"
      \sed -i 's~#!/bin/bash~#!/bin/bash\n. otel.sh~g' "$script_file"
      \sed -i 's~#!/usr/bin/env sh~#!/usr/bin/env sh\n. otel.sh~g' "$script_file"
      \sed -i 's~#!/usr/bin/env bash~#!/usr/bin/env bash\n. otel.sh~g' "$script_file"
    fi
    if ! \grep -qF '_otel_inject' "$script_file"; then    
      \sed -i 's~"$RUNNER_PATH/ghcca-node/node/bin/node"~_otel_inject "$RUNNER_PATH/ghcca-node/node/bin/node"~g' "$script_file"
      \sed -i 's~"${RUNNER_PATH}/ghcca-node/node/bin/node"~_otel_inject "${RUNNER_PATH}/ghcca-node/node/bin/node"~g' "$script_file"
      \sed -i 's~"${target_location}/node/bin/node"~_otel_inject "${target_location}/node/bin/node"~g' "$script_file"
      \sed -i 's~^${command_to_execute}$~_otel_inject ${command_to_execute}~g' "$script_file"
      \sed -i 's~^"${command_to_execute}"$~_otel_inject "${command_to_execute}"~g' "$script_file"
      \sed -i 's~eval exec \$command_to_execute~eval _otel_inject $command_to_execute~g' "$script_file"
    fi
    touch /tmp/thoth.copilot.instrumented
  done || \true
fi
