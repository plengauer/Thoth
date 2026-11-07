#!/bin/bash

for _otel_var in $(\env | \cut -d= -f1 | \grep -E '^__OTEL_[A-Za-z_][A-Za-z0-9_]*$' | \sed 's/^__//'); do
  _otel_shadow_var="__$_otel_var"
  \eval "export $_otel_var=\${$_otel_shadow_var}"
done
\export OTEL_SHELL_AUTO_INJECTED=TRUE
\export OTEL_SHELL_AUTO_INSTRUMENTATION_HINT="$1"
\. otel.sh
\eval "$1"
