#/bin/false
if [ -n "${INPUT___KILL_SWITCH:-}" ]; then
  echo "::warning ::OpenTelemetry for GitHub actions disabled by kill switch!" && exit 0
fi
_otel_load_github_variables() {
  for _otel_variables_scope in repos/"$GITHUB_REPOSITORY"/actions/variables repos/"$GITHUB_REPOSITORY"/actions/organization-variables; do
    _otel_variables_page=1
    while [ "$_otel_variables_page" -le 100 ]; do
      _otel_variables_response="$(curl -sf -H "Authorization: ******" "${GITHUB_API_URL:-https://api.github.com}/$_otel_variables_scope?per_page=30&page=$_otel_variables_page" 2>/dev/null || true)"
      _otel_variables_count="$(printf '%s' "$_otel_variables_response" | jq -r '.variables | length' 2>/dev/null || true)"
      case "${_otel_variables_count:-}" in '' | *[!0-9]*) break ;; esac
      _otel_variables_lines="$(printf '%s' "$_otel_variables_response" | jq -r '.variables[] | select((.name | test("^OTEL_[A-Za-z0-9_]+$")) and ((.value // "") | contains("\n") | not)) | .name + "=" + (.value // "")' 2>/dev/null || true)"
      while IFS= read -r _otel_variable_line; do
        [ -n "$_otel_variable_line" ] || continue
        _otel_variable_name="${_otel_variable_line%%=*}"
        eval "[ -n \"\${$_otel_variable_name:-}\" ]" || export "$_otel_variable_name=${_otel_variable_line#*=}"
      done <<EOF_OTEL_VARIABLES
$_otel_variables_lines
EOF_OTEL_VARIABLES
      [ "$_otel_variables_count" -ge 30 ] || break
      _otel_variables_page=$((_otel_variables_page + 1))
    done
  done
}
if [ -n "${INPUT_GITHUB_TOKEN:-}" ] && [ -n "${GITHUB_REPOSITORY:-}" ]; then
  _otel_load_github_variables || true
fi
if [ -n "${OTEL_KILL_SWITCH:-}" ]; then
  echo "::warning ::OpenTelemetry for GitHub actions disabled by kill switch!" && exit 0
fi
if [ "${OTEL_LOGS_EXPORTER:-otlp}" != otlp ] && [ "${OTEL_LOGS_EXPORTER:-otlp}" != console ] && [ "${OTEL_LOGS_EXPORTER:-otlp}" != none ] && [ "${OTEL_LOGS_EXPORTER:-otlp}" != deferred ]; then
  echo "::error ::OpenTelemetry for GitHub actions only supports otlp exporters ($OTEL_LOGS_EXPORTER). For other exporters, pipe the data through a collector outside of GitHub to translate the data to a different protocol." && false
fi
if [ "${OTEL_METRICS_EXPORTER:-otlp}" != otlp ] && [ "${OTEL_METRICS_EXPORTER:-otlp}" != console ] && [ "${OTEL_METRICS_EXPORTER:-otlp}" != none ] && [ "${OTEL_METRICS_EXPORTER:-otlp}" != deferred ]; then
  echo "::error ::OpenTelemetry for GitHub actions only supports otlp exporters ($OTEL_METRICS_EXPORTER). For other exporters, pipe the data through a collector outside of GitHub to translate the data to a different protocol." && false
fi
if [ "${OTEL_TRACES_EXPORTER:-otlp}" != otlp ] && [ "${OTEL_TRACES_EXPORTER:-otlp}" != console ] && [ "${OTEL_TRACES_EXPORTER:-otlp}" != none ] && [ "${OTEL_TRACES_EXPORTER:-otlp}" != deferred ]; then
  echo "::error ::OpenTelemetry for GitHub actions only supports otlp exporters ($OTEL_TRACES_EXPORTER). For other exporters, pipe the data through a collector outside of GitHub to translate the data to a different protocol." && false
fi
if [ "$GITHUB_EVENT_NAME" = dynamic ]; then
  echo "::notice ::OpenTelemetry for GitHub actions detected a dynamic workflow, which is unable to extract data directly, reconfiguring all otlp exporters for deferred export. This needs the workflow-level instrumentation to forward the data."
  [ -n "${OTEL_EXPORTER_OTLP_LOGS_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-}}" ] || export OTEL_LOGS_EXPORTER=deferred
  [ -n "${OTEL_EXPORTER_OTLP_METRICS_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-}}" ] || export OTEL_METRICS_EXPORTER=deferred
  [ -n "${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-}}" ] || export OTEL_TRACES_EXPORTER=deferred
fi
if [ -z "${OTEL_EXPORTER_OTLP_LOGS_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-}}" ] && [ -z "${OTEL_LOGS_EXPORTER:-}" ]; then
  export OTEL_LOGS_EXPORTER=none
  echo "::notice ::OpenTelemetry for GitHub actions has no logs export configured. Consult the documentation for instructions."
fi
if [ -z "${OTEL_EXPORTER_OTLP_METRICS_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-}}" ] && [ -z "${OTEL_METRICS_EXPORTER:-}" ]; then
  export OTEL_METRICS_EXPORTER=none
  echo "::notice ::OpenTelemetry for GitHub actions has no metrics export configured. Consult the documentation for instructions."
fi
if [ -z "${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT:-}}" ] && [ -z "${OTEL_TRACES_EXPORTER:-}" ]; then
  export OTEL_TRACES_EXPORTER=none
  echo "::notice ::OpenTelemetry for GitHub actions has no traces export configured. Consult the documentation for instructions."
fi
if [ "${OTEL_LOGS_EXPORTER:-}" = console ] || [ "${OTEL_METRICS_EXPORTER:-}" = console ] || [ "${OTEL_TRACES_EXPORTER:-}" = console ]; then
  export OTEL_SHELL_SDK_OUTPUT_REDIRECT="${OTEL_SHELL_SDK_OUTPUT_REDIRECT:-/dev/stderr}"
fi
export OTEL_EXPORTER_OTLP_PROTOCOL="${OTEL_EXPORTER_OTLP_PROTOCOL:-http/protobuf}"                                     # default is not uniform, so lets pin it here
export OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE="${OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE:-delta}" # default to delta for volatile environments
