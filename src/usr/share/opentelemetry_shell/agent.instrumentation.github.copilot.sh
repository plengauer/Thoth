#!/bin/false

if \[ "${GITHUB_ACTIONS:-false}" = true ] && \[ "${GITHUB_EVENT_NAME:-}" = dynamic ] && \[ -n "${COPILOT_AGENT_RUNTIME_VERSION:-}" ] && \[ -n "${GITHUB_COPILOT_ACTION_DOWNLOAD_URL:-}" ] && (\[ "${GITHUB_JOB:-}" = copilot ] || \[ "${GITHUB_JOB:-}" = claude ] || \[ "${GITHUB_JOB:-}" = codex ]); then
  _otel_instrument_copilot() {
    for script_file in "$1"/*/*.sh; do
      [ -f "$script_file" ] || continue
      \sed -i 's~#!/bin/sh~#!/bin/sh\n. otel.sh~g' "$script_file"
      \sed -i 's~#!/bin/bash~#!/bin/bash\n. otel.sh~g' "$script_file"
      \sed -i 's~#!/usr/bin/env sh~#!/usr/bin/env sh\n. otel.sh~g' "$script_file"
      \sed -i 's~#!/usr/bin/env bash~#!/usr/bin/env bash\n. otel.sh~g' "$script_file"
      \sed -i 's~"$RUNNER_PATH/ghcca-node/node/bin/node"~_otel_inject "$RUNNER_PATH/ghcca-node/node/bin/node"~g' "$script_file"
      \sed -i 's~"${RUNNER_PATH}/ghcca-node/node/bin/node"~_otel_inject "${RUNNER_PATH}/ghcca-node/node/bin/node"~g' "$script_file"
      \sed -i 's~"${target_location}/node/bin/node"~_otel_inject "${target_location}/node/bin/node"~g' "$script_file"
      \sed -i 's~^${command_to_execute}$~_otel_inject ${command_to_execute}~g' "$script_file"
      \sed -i 's~^"${command_to_execute}"$~_otel_inject "${command_to_execute}"~g' "$script_file"
      \sed -i 's~eval exec \$command_to_execute~eval _otel_inject $command_to_execute~g' "$script_file"
    done
  }
  if \[ -n "${COPILOT_AGENT_RUNTIME_VERSION:-}" ] && \[ -n "${GITHUB_COPILOT_ACTION_DOWNLOAD_URL:-}" ] && \[ "${COPILOT_PREINSTALLED_RUNTIME:-}" = false ]; then
    _otel_inject_copilot() {
      local exit_code=0
      _otel_call "$@" || local exit_code=$?
      local cmdline="$*"
      cmdline="${cmdline#\\}"
      if \[ "$exit_code" = 0 ] && (\[ "$cmdline" = 'tar -zxvf ./action.tar.gz' ] || \[ "$cmdline" = 'tar -xzf ./action.tar.gz' ] || \[ "$cmdline" = 'tar -zxf ./action.tar.gz' ] || \[ "$cmdline" = 'tar -zxv' ] || \[ "$cmdline" = 'tar -xzv' ]); then
        _otel_instrument_copilot ./*-action-* || \true
        _otel_instrument_copilot "${RUNNER_TEMP}"/*-action-* || \true
      fi
      return "$exit_code"
    }
    _otel_alias_prepend_function=_otel_alias_prepend
    $_otel_alias_prepend_function tar _otel_inject_copilot
  elif \[ "${COPILOT_PREINSTALLED_RUNTIME:-}" = true ] && ! \[ -f /tmp/thoth.copilot.instrumented ] ; then
    ( \sudo bash -c "$(\declare -f _otel_instrument_copilot); _otel_instrument_copilot /opt/copilot-runtime/*-action-*" ) || \true
    \touch /tmp/thoth.copilot.instrumented
  fi
fi
