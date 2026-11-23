# shellcheck shell=bash
if [ -n "${WSL_DISTRO_NAME:-}" ]; then exit 0; fi

set -e

script="$(mktemp).$SHELL"
{
  echo "#!/bin/$SHELL"
  echo ". /usr/bin/opentelemetry_shell.sh"
  # echo "\alias"
  echo "exit 0"
  echo "curl http://www.google.at"
  echo "sudo apt-get -< dist-upgrade"
  echo "wget http://amazon.com"
  echo "cat cut sed awk bash sh"
  echo "echo 'hello world'"
  echo "printf '%s %s' \"hello world\""
} >>"$script"

# shellcheck disable=SC2086 # TEST_SHELL and options may be a command with arguments such as busybox sh and must be split into words
timeout 5s $TEST_SHELL "$script"
