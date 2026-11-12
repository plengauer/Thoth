# shellcheck shell=bash
if [ -n "${WSL_DISTRO_NAME:-}" ]; then exit 0; fi

set -e

script="$(mktemp).$SHELL"
echo "#!/bin/$SHELL" >>"$script"
echo ". /usr/bin/opentelemetry_shell.sh" >>"$script"
# echo "\alias" >> "$script"
echo "exit 0" >>"$script"
echo "curl http://www.google.at" >>"$script"
echo "sudo apt-get -< dist-upgrade" >>"$script"
echo "wget http://amazon.com" >>"$script"
echo "cat cut sed awk bash sh" >>"$script"
echo "echo 'hello world'" >>"$script"
echo "printf '%s %s' \"hello world\"" >>"$script"

# shellcheck disable=SC2086 # TEST_SHELL and options may be a command with arguments such as busybox sh and must be split into words
timeout 5s $TEST_SHELL "$script"
