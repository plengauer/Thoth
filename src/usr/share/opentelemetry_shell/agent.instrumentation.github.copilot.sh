#!/bin/false

_otel_enable_coding_agent_otlp_endpoint() {
  if \[ -z "${OTEL_EXPORTER_OTLP_ENDPOINT+x}" ] && \[ -n "${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-}" ]; then
    export OTEL_EXPORTER_OTLP_ENDPOINT="${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT%/v1/traces}"
    \[ -n "${GITHUB_ENV:-}" ] && \printf 'OTEL_EXPORTER_OTLP_ENDPOINT=%s\n' "$OTEL_EXPORTER_OTLP_ENDPOINT" >>"$GITHUB_ENV"
  fi
}

_otel_enable_coding_agent_otel_copilot() {
  if \[ -z "${COPILOT_OTEL_ENABLED+x}" ]; then
    export COPILOT_OTEL_ENABLED=true
    \[ -n "${GITHUB_ENV:-}" ] && \printf 'COPILOT_OTEL_ENABLED=%s\n' "$COPILOT_OTEL_ENABLED" >>"$GITHUB_ENV"
  fi
}

_otel_is_agentic_workflow() {
  \[ "${GITHUB_EVENT_NAME:-}" = dynamic ] && return 0
  \[ -n "${GH_AW_WORKFLOW_ID:-}" ] && return 0
  \[ -n "${GH_AW_WORKFLOW_FILE:-}" ] && return 0
  \[ "${GITHUB_ACTION:-}" = github/gh-aw-actions/setup ] && return 0
  case "${GITHUB_WORKFLOW_REF:-}" in
    */.github/workflows/*.lock.yml@*) return 0 ;;
  esac
  return 1
}

_otel_enable_coding_agent_otel() {
  \[ "${GITHUB_ACTIONS:-false}" = true ] || return 0
  _otel_enable_coding_agent_otlp_endpoint
  \[ -n "${OTEL_EXPORTER_OTLP_ENDPOINT:-}" ] || return 0
  _otel_enable_coding_agent_otel_copilot
}

_otel_inject_coding_agent_otel() {
  _otel_enable_coding_agent_otel
  _otel_call "$@"
}

if \[ "${GITHUB_ACTIONS:-false}" = true ] && _otel_is_agentic_workflow; then
  _otel_enable_coding_agent_otel
fi

_otel_alias_prepend_function=_otel_alias_prepend
$_otel_alias_prepend_function copilot _otel_inject_coding_agent_otel
$_otel_alias_prepend_function claude _otel_inject_coding_agent_otel
$_otel_alias_prepend_function codex _otel_inject_coding_agent_otel

if \[ "${GITHUB_ACTIONS:-false}" = true ] && \[ "$GITHUB_EVENT_NAME" = dynamic ] && \[ -n "${COPILOT_AGENT_RUNTIME_VERSION:-}" ] && \[ -n "${GITHUB_COPILOT_ACTION_DOWNLOAD_URL:-}" ] && (\[ "$GITHUB_JOB" = copilot ] || \[ "$GITHUB_JOB" = claude ] || \[ "$GITHUB_JOB" = codex ]); then
  _otel_inject_copilot() {
    local exit_code=0
    _otel_call "$@" || local exit_code=$?
    local cmdline="$*"
    cmdline="${cmdline#\\}"
    if \[ "$exit_code" = 0 ] && (\[ "$cmdline" = 'tar -zxvf ./action.tar.gz' ] || \[ "$cmdline" = 'tar -xzf ./action.tar.gz' ] || \[ "$cmdline" = 'tar -zxf ./action.tar.gz' ] || \[ "$cmdline" = 'tar -zxv' ] || \[ "$cmdline" = 'tar -xzv' ]); then
      for script_file in ./*-action-*/*/*.sh "${RUNNER_TEMP}"/*-action-*/*/*.sh; do
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
      done || \true
    fi
    return "$exit_code"
  }
  $_otel_alias_prepend_function tar _otel_inject_copilot
fi
