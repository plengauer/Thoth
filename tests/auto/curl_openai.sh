. /usr/bin/opentelemetry_shell.sh
curl --no-progress-meter --fail -X POST https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_TOKEN" \
  -d '{"model":"gpt-4o-mini","messages":[{"role":"user","content":"Say hello!"}]}'
