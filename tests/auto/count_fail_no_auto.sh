set -e
my_span_id=$(otel_span_start INTERNAL myspan)
otel_span_end $my_span_id
echo '$0='"$0" >&2
echo '$*='"$*" >&2
echo '$#='"$#" >&2
echo $#
