#!/bin/false

if \[ "${GITHUB_ACTIONS:-false}" = true ] && \[ "${GITHUB_ACTION_REPOSITORY:-}" = super-linter/super-linter ] && \[ -d /action/lib/ ] && ! \[ -r /action/lib/.otel ]; then
  \parallel --help 1>&2
  \touch /action/lib/.otel
  \find /action/lib -iname '*.sh' | while \read -r path; do
    \sed -i -E 's/\| ("\$\{[a-zA-Z0-9_]*\[@\]\}")/| \\eval "$(_otel_escape_args \1)"/g' "$path" || \true
    \sed -i -E 's/! ("\$\{[a-zA-Z0-9_]*\[@\]\}")/! \\eval "$(_otel_escape_args \1)"/g' "$path" || \true
  done
fi
