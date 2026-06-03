. ./assert.sh

_otel_alias_prepend() { :; }
. ../src/usr/share/opentelemetry_shell/agent.instrumentation.curl.sh

unset OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT
if _otel_curl_genai_capture_prompt_on_spans; then enabled=1; else enabled=0; fi
assert_equals 0 "$enabled"

OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=NO_CONTENT
if _otel_curl_genai_capture_prompt_on_spans; then enabled=1; else enabled=0; fi
assert_equals 0 "$enabled"

OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=EVENT_ONLY
if _otel_curl_genai_capture_prompt_on_spans; then enabled=1; else enabled=0; fi
assert_equals 0 "$enabled"

OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=SPAN_ONLY
if _otel_curl_genai_capture_prompt_on_spans; then enabled=1; else enabled=0; fi
assert_equals 1 "$enabled"

OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=SPAN_AND_EVENT
if _otel_curl_genai_capture_prompt_on_spans; then enabled=1; else enabled=0; fi
assert_equals 1 "$enabled"

OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=true
if _otel_curl_genai_capture_prompt_on_spans; then enabled=1; else enabled=0; fi
assert_equals 1 "$enabled"

request_file="$(\mktemp)"
\printf '{"messages":[{"role":"user","content":"hello"}]}' > "$request_file"
assert_equals '[{"role":"user","content":"hello"}]' "$(_otel_curl_genai_extract_prompt_messages "$request_file")"

\printf '{"input":"hello"}' > "$request_file"
assert_equals '[{"role":"user","content":"hello"}]' "$(_otel_curl_genai_extract_prompt_messages "$request_file")"

\printf '{"prompt":"hello"}' > "$request_file"
assert_equals '[{"role":"user","content":"hello"}]' "$(_otel_curl_genai_extract_prompt_messages "$request_file")"

\printf '{"model":"gpt-4o"}' > "$request_file"
assert_equals 'null' "$(_otel_curl_genai_extract_prompt_messages "$request_file")"
