# shellcheck shell=bash
set -e
my_span_id=$(otel_span_start INTERNAL myspan)
otel_span_end $my_span_id
# shellcheck disable=SC2016 # single quotes are intentional, the text is meant to be expanded later by another shell or tool
echo '$0='"$0" >&2
echo '$*='"$*" >&2
echo '$#='"$#" >&2
echo $#
