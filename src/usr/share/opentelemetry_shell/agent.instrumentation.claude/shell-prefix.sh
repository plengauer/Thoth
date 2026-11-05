#!/bin/sh

for _otel_var in $(\env | \cut -d= -f1 | \grep '^__OTEL_' | \sed 's/^__//'); do
  _otel_shadow_var="__$_otel_var"
  \eval "export $_otel_var=\${$_otel_shadow_var}"
done
\. /usr/bin/otel.sh
\eval "$1"
