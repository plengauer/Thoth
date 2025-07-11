CONTROL_CONTENT='
Package: opentelemetry-shell
Version: __VERSION__
Architecture: all
Pre-Depends: ash | dash | bash | busybox, coreutils, util-linux, findutils, python3 (>= 3.9), python3-pip, python3-venv, tar
Depends: grep, sed, awk, dpkg, procps, jq, xxd
Recommends: strace
Enhances: ash, dash, bash, busybox
Priority: extra
Maintainer: Philipp Lengauer <p.lengauer@gmail.com>
Homepage: https://github.com/plengauer/opentelemetry-bash
Description: Generate open telemetry traces, metrics, and logs from shell scripts fully automatically
'
SCRIPT_CONTENT='bash -c "echo hello world $@"
if type foo; then echo '\''$1'\''; fi'

if ! type apt-file; then exit 0; fi
sudo apt-file update

. otel.sh
process_packages() { sed 's/^awk$/gawk/g' | sed 's/^python3$/python3-minimal/g'; }
process_commands() { sed 's/^awk$/gawk/g' | grep -vE '^which$' | grep -vE '^print$' | grep -vE '^rpm$';  }
patternify() { grep -v '^$' | grep -P '^[a-zA-Z0-9/_.-]+$' | while read -r pattern; do echo '^'"$pattern"'$'; done }
check_command() {
  local dependencies="$1"
  local command="$2"
  # echo "($dependencies) => $command" >&2
  apt-file search /"$command" | grep -E "/$command\$" | grep -E ': /bin/|: /sbin/|: /usr/bin/|: /usr/sbin/|: /usr/local/bin/|: /usr/local/sbin/' | cut -d : -f 1 | grep -q "$dependencies" && echo "$command OK" || echo "$command UNAVAILABLE"
}
export -f check_command
verify() {
  local dependencies="$(printf '%s' "$CONTROL_CONTENT" | grep -E "$1" | cut -d : -f 2- | tr '|' ',' | tr ',' '\n' | cut -d '(' -f 1 | tr -d ' ' | process_packages | patternify)"
  printf '%s' "$SCRIPT_CONTENT" \
    | grep -v 'SKIP_DEPENDENCY_CHECK' | while read -r line; do line="${line%%#*}"; printf '%s\n' "$line"; done \
    | grep -oP '(^[[:space:]]*|\$\()\\?[a-zA-Z/][a-zA-Z0-9/_.-]*($|[[:space:]])' \
    | while read -r command; do command="${command% }"; command="${command# }"; command="${command#\$\(}"; command="${command#\\}"; [ "${#command}" -gt 1 ] && printf '%s\n' "$command" || true; done \
    | grep -vE '^_otel|^otel_|^OTEL_' | grep -vE "$(compgen -b | patternify)" | grep -vE "$(compgen -k | patternify)" | process_commands \
    | sort -u | tee /dev/stderr | xargs -t -d '\n' -r parallel -t -q check_command "$dependencies" ::: | tee /dev/stderr | grep -q 'UNAVAILABLE' && return 1 || return 0
}
verify '^Pre-Depends:|^Depends:|^Recommends:|^Suggests:'
