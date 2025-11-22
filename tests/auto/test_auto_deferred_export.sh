. ./assert.sh

# Simulate GitHub Copilot environment
# This tests that the Copilot instrumentation doesn't crash when initialized
export GITHUB_ACTIONS=true
export GITHUB_WORKFLOW="Copilot coding agent"
export GITHUB_JOB="copilot"
export COPILOT_AGENT_RUNTIME_VERSION="1.0.0"
export GITHUB_COPILOT_ACTION_DOWNLOAD_URL="https://example.com/action.tar.gz"

# Initialize OpenTelemetry
. /usr/bin/opentelemetry_shell.sh

# Run a simple hello world command
echo "hello world"

# Verify we got a span for the echo command (confirms no crash occurred)
resolve_span '.name == "echo hello world"'
