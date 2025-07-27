set -e
span_id=$(otel_span_start INTERNAL myspan)
otel_span_end $span_id
