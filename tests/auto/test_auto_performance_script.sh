if [ -n "${WSL_DISTRO_NAME:-}" ]; then exit 0; fi

set -e

script="$(mktemp).$SHELL"
echo "#!/bin/$SHELL" >> "$script"
echo ". /usr/bin/opentelemetry_shell.sh" >> "$script"
# echo "\alias" >> "$script"
echo "exit 0" >> "$script"
echo "curl http://www.google.at" >> "$script"
echo "sudo apt-get -< dist-upgrade" >> "$script"
echo "wget http://amazon.com" >> "$script"
echo "cat cut sed awk bash sh" >> "$script"
echo "echo 'hello world'" >> "$script"
echo "printf '%s %s' \"hello world\"" >> "$script"

timeout 5s $SHELL "$script"

