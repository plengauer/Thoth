#!/bin/false

if \[ "${GITHUB_ACTIONS:-false}" = true ] && \[ "${GITHUB_ACTION_REPOSITORY:-}" = super-linter/super-linter ] && \[ -d /action/lib/ ] && ! \[ -r /action/lib/.otel ]; then
  \touch /action/lib/.otel
  # \export OTEL_SHELL_CONFIG_OBSERVE_SUBPROCESSES=FALSE
  # \export OTEL_SHELL_CONFIG_OBSERVE_SIGNALS=FALSE
  # \export OTEL_SHELL_CONFIG_OBSERVE_PIPES=FALSE
  \find /action/lib -iname '*.sh' | while \read -r path; do
    \sed -i -E 's/\| ("\$\{[a-zA-Z0-9_]*\[@\]\}")/| \\eval "$(_otel_escape_args \1)"/g' "$path" || \true
    \sed -i -E 's/! ("\$\{[a-zA-Z0-9_]*\[@\]\}")/! \\eval "$(_otel_escape_args \1)"/g' "$path" || \true
    \sed -i -E 's/^PARALLEL_COMMAND_OUTPUT=/if \command -v _otel_inject_parallel_arguments >\/dev\/null 2>\&1; then _otel_inject_parallel_arguments "${PARALLEL_COMMAND[@]}" >\&2; fi; PARALLEL_COMMAND_OUTPUT=/g' "$path" || \true
  done
fi
