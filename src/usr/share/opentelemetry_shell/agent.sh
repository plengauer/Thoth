#!/bin/false
################################################################################################################
# This file is doing auto-instrumentation, auto-injection and auto-context-propagation.                        #
# It should be sourced at the very top of any shell script that should be observed.                            #
# Only use the "otel_instrument" and "otel_outstrument" functions directly.                                    #
# All other functions and variables are for internal use only and therefore subject to change without notice!  #
################################################################################################################

if \[ "${_otel_shell_injected:-FALSE}" = "TRUE" ]; then
  return 0
fi
_otel_shell_injected=TRUE

case "$-" in
  *r*) \echo "WARNING OpenTelemetry for shell does not support restricted mode (set -r)!" >&2; return 0;;
esac

_otel_shell_conservative_exec="${OTEL_SHELL_CONSERVATIVE_EXEC:-FALSE}"
unset OTEL_SHELL_CONSERVATIVE_EXEC

\. /usr/share/opentelemetry_shell/api.sh
_otel_package_version opentelemetry-shell > /dev/null # to build the cache outside a subshell

if \[ "$_otel_shell" = "bash" ] && \[ -n "${BASHPID:-}" ] && \[ "$$" != "$BASHPID" ]; then
  \echo "WARNING The OpenTelemetry shell file for auto-instrumentation is sourced in a subshell, automatic instrumentation will only be active within that subshell!" >&2
fi

case "$-" in
  *i*) _otel_is_interactive=TRUE;;
  *)   _otel_is_interactive=FALSE;;
esac

if \[ -n "${OTEL_SHELL_AUTO_INSTRUMENTATION_HINT:-}" ]; then
  _otel_shell_auto_instrumentation_hint="$OTEL_SHELL_AUTO_INSTRUMENTATION_HINT"
  unset OTEL_SHELL_AUTO_INSTRUMENTATION_HINT
elif \[ "$_otel_is_interactive" = TRUE ]; then
  \echo "WARNING When using OpenTelemetry in an interactive shell for the first time after startup, it may take some time to create the instrumentation cache! Subsequent interactive shells will start faster. This performance impact does NOT apply in non-interactive shells, like scripts or invocations with -c." >&2
  _otel_shell_auto_instrumentation_hint=""
elif \[ "${OTEL_SHELL_IS_DYNAMIC:-}" = TRUE ]; then
  _otel_shell_auto_instrumentation_hint=""
  unset OTEL_SHELL_IS_DYNAMIC
elif \[ -f "$0" ] && \[ "$(\readlink -f "$0")" != "$(\readlink -f "/proc/$$/exe")" ]; then
  _otel_shell_auto_instrumentation_hint="$0"
else
  _otel_shell_auto_instrumentation_hint="$(_otel_resolve_command_self)"
fi

if \[ "$_otel_shell" = "bash" ]; then
  _otel_source_file_resolver='${BASH_SOURCE[0]}'
else
  _otel_source_file_resolver='$0'
fi
_otel_source_line_resolver='${LINENO:-}'
_otel_source_func_resolver='${FUNCNAME:-}'

if \[ "$_otel_shell" = "bash" ]; then
  shopt -s expand_aliases 1> /dev/null 2> /dev/null
fi

_otel_auto_instrument() {
  local hint="$1"
  local IFS=' 
'

  # cached?
  ## we really have three options for the cache key
  ## (1) using the hint - will not work when scripts are changing or called the same but very fast!
  ## (2) using the resolved hint - will not work when new executables are added onto the system or their shebang changes or new bash.rc aliases are added
  ## (3) using the filtered list of commands - will work in every case but slowest
  local cache_key="$({ _otel_list_path_commands | _otel_filter_commands_by_special | _otel_filter_commands_by_hint "$hint" | \sort -u; \alias; \echo "$PATH" "$_otel_shell_conservative_exec" "${OTEL_SHELL_CONFIG_MUTE_INTERNALS:-}" "${OTEL_SHELL_CONFIG_MUTE_BUILTINS:-}"; } | \md5sum | \cut -d ' ' -f 1)"
  local cache_file="$TMPDIR/opentelemetry_shell_$(_otel_package_version opentelemetry-shell)"_"$_otel_shell"_instrumentation_cache_"$cache_key".aliases
  if \[ -r "$cache_file" ]; then
    \eval "$(\grep -vh '_otel_alias_prepend ' $(_otel_list_special_auto_instrument_files))"
    \. "$cache_file" && return 0 || \true
  fi

  # special instrumentations
  _otel_alias_prepend alias _otel_alias_and_instrument
  _otel_alias_prepend unalias _otel_unalias_and_reinstrument
  if \type hash 1> /dev/null 2> /dev/null; then
    _otel_alias_prepend hash _otel_hash_and_reinstrument
  fi
  _otel_alias_prepend export _otel_export_PATH_and_reinstrument
  _otel_alias_prepend . _otel_instrument_and_source
  if \[ "$_otel_shell" = bash ]; then _otel_alias_prepend source _otel_instrument_and_source; fi

  # deshebangify commands, do special instrumentations, propagate special instrumentations into aliases, instrument all commands
  ## (both otel_filter_commands_by_file and _otel_filter_commands_by_instrumentation are functionally optional, but helps optimizing time because the following loop AND otel_instrument itself is expensive!)
  ## avoid piping directly into the loops, then it will be considered a subshell and aliases won't take effect here
  for cmd in $(_otel_list_path_commands | _otel_filter_commands_by_special | _otel_filter_commands_by_hint "$hint" | \sort -u); do _otel_deshebangify "$cmd" || \true; done
  for otel_custom_file in $(_otel_list_special_auto_instrument_files); do \. "$otel_custom_file"; done
  for cmd in $(_otel_list_alias_commands | _otel_filter_commands_by_special | \sort -u); do _otel_dealiasify "$cmd" || \true; done
  for cmd in $(_otel_list_all_commands | _otel_filter_commands_by_special | _otel_filter_commands_by_instrumentation | _otel_filter_commands_by_mode | _otel_filter_commands_by_hint "$hint" | \sort -u); do otel_instrument "$cmd"; done

  # super special instrumentations
  if \[ "$_otel_shell" = bash ]; then \alias declare='declare $( ( _otel_string_starts_with "${FUNCNAME:-}" _otel_ || \[ "${FUNCNAME:-}" = source ] || \[ "${FUNCNAME:-}" = . ] ) && \echo -g || \true)'; fi
  \alias .='_otel_instrument_and_source "$#" "$@" .'
  if \[ "$_otel_shell" = bash ]; then \alias source='_otel_instrument_and_source "$#" "$@" source'; fi
  if \[ "$_otel_shell_conservative_exec" = TRUE ]; then
    if \[ -n "${LINENO:-}" ]; then
      \alias exec='eval "$(_otel_inject_and_exec_by_location "'$_otel_source_file_resolver'" "'$_otel_source_line_resolver'")"; exec'
    else
      \alias exec='_otel_record_exec; exec'
    fi
  else
    \alias exec='_otel_inject_and_exec_directly exec'
  fi

  # cache
  \[ "$(\alias | \wc -l)" -gt 25 ] && \alias | \sed 's/^alias //' | { \[ -n "$hint" ] && \grep "$(_otel_resolve_instrumentation_hint "$hint" | \sed 's/[]\.^*[]/\\&/g' | \awk '$0=$0"="')" || \cat; } | \awk '{print "\\alias " $0 }' > "$cache_file" || \true
}

_otel_list_special_auto_instrument_files() {
  case "$-" in
    *f*) \ls /usr/share/opentelemetry_shell | \grep -E '^agent.instrumentation.*.sh$' | while \read -r _otel_file_name; do \echo /usr/share/opentelemetry_shell/"$_otel_file_name"; done;;
    *) \echo /usr/share/opentelemetry_shell/agent.instrumentation.*.sh;;
  esac
}

_otel_list_all_commands() {
  _otel_list_path_commands
  _otel_list_alias_commands
  _otel_list_builtin_commands
}

_otel_list_path_commands() {
  _otel_list_path_executables | \rev | \cut -d / -f 1 | \rev
}

_otel_list_path_executables() {
  \echo "$PATH" | \tr ':' '\n' | while \read dir; do \find "$dir" -maxdepth 1 -type f -executable 2> /dev/null || \true; \find "$dir" -maxdepth 1 -type l -executable 2> /dev/null || \true; done
}

_otel_list_alias_commands() {
  \alias | while \read -r line; do
    line="${line#alias }"
    line="$(\eval "\\printf '%s\n' $line")"
    \printf '%s\n' "${line%%=*}"
  done
}

_otel_list_builtin_commands() {
  if \type compgen 1> /dev/null 2> /dev/null; then
    \compgen -b
  else
    for _otel_builtin in break cd chdir command . echo eval exec exit export false getopts hash jobs local printf pwd read return set shift times trap true : type umask unalias unset wait alias ulimit test [ kill; do \echo "$_otel_builtin"; done
  fi
}

_otel_filter_commands_by_hint() {
  local hint="$1"
  if \[ -n "$hint" ]; then
    if \[ "$_otel_shell" = 'busybox sh' ]; then
      "$(\which grep)" -xF "$(_otel_resolve_instrumentation_hint "$hint")"
    else
      \grep -xF "$(_otel_resolve_instrumentation_hint "$hint")"
    fi
  elif \[ -n "${WSL_DISTRO_NAME:-}" ]; then
    # in WSL, path may include a directory of windows executables
    # there, a bunch of files have the executable bit set, but are not really executable binaries (like .dll, ....)
    # usually, they are excluded by the hint, but if there is no hint, lets exclude the usual suspects to increase startup performance
    \grep -vE '.dll$|.DLL$|.mof$|.config$|.log$|.scr$|.ax$|.NLS$|.json$|.xml$|.xsl$|.xsd$|.ps1xml$|.txt$|.png$|.ico$'
  else
    \cat
  fi
}

_otel_resolve_instrumentation_hint() {
  local hint="$1"
  { \[ -f "$hint" ] && \[ "$(\readlink -f "$hint")" != "$(\readlink -f "/proc/$$/exe")" ] && \[ "$(\readlink -f "$hint")" != /usr/share/opentelemetry_shell/agent.sh ] && \cat "$hint" || \echo "$hint"; } | \tr -s ' $=";(){}/\\!#~^'\' '\n' | _otel_filter_by_validity | \sort -u
}

_otel_filter_commands_by_instrumentation() {
  local pre_instrumented_executables="$(\alias | \grep -F '_otel_observe' | \sed 's/^alias //' | \cut -d = -f 1)"
  if \[ -n "$pre_instrumented_executables" ]; then
    \grep -xFv "$pre_instrumented_executables" 
  else
    \cat
  fi
}

_otel_filter_commands_by_mode() {
  if \[ "${OTEL_SHELL_CONFIG_MUTE_INTERNALS:-FALSE}" = TRUE ]; then
    \cat > /dev/null # all of them are internal
  else
    \cat
  fi | if \[ "${OTEL_SHELL_CONFIG_MUTE_BUILTINS:-FALSE}" = TRUE ]; then
    while \read -r command; do
      \[ "$(_otel_command_type "$command")" != builtin ] && \echo "$command" || \true
    done
  else
    \cat
  fi
}

_otel_filter_commands_by_special() {
  # we need to exclude all well-known builtins that would change their semantics if they are used in an alias or within a function.
  # for example, set resets options but also arguments of the current script and/or function. since instrumentation is done via functions, instrumenting set would change its behavior
  \grep -vE '^(break|command|continue|builtin|declare|\.|source|eval|exec|exit|export|hash|local|return|set|shift|trap|:|unalias|unset|alias|read|nohup)$' | \grep -vE '^(OTEL_|_otel_|otel_)'
}

_otel_filter_by_validity() {
  \grep -aE '^[a-zA-Z0-9._\[][a-zA-Z0-9 ._-]*$'
}

_otel_deshebangify() {
  local cmd="$1" # e.g., "upgrade"
  if \[ "$(_otel_command_type "$cmd")" != file ]; then return 1; fi
  local shebang="$(_otel_resolve_shebang "$1")" # e.g., "/bin/bash -x"
  if \[ -z "$shebang" ]; then return 2; fi
  \alias "$1=OTEL_SHELL_COMMAND_TYPE_OVERRIDE=file $shebang $(\which "$1" 2> /dev/null)" # e.g., alias upgrade='/bin/bash -x /usr/bin/upgrade'
}

_otel_resolve_shebang() {
  local path="$(\which "$1" 2> /dev/null)"
  if \[ -z "$path" ] || ! \[ -x "$path" ]; then return 1; fi
  \read -r first_line < "$path"
  if ! _otel_string_starts_with "$first_line" "#!"; then return 2; fi
  local shebang="${first_line#\#\!}"
  local shebang="${shebang#"${shebang%%[![:space:]]*}"}"
  \echo "$shebang"
}

_otel_dealiasify() {
  # e.g., alias upgrade='/bin/bash -x /usr/bin/upgrade'
  # e.g., alias bash='_otel_inject_shell _otel_observe bash'
  # e.g., alias ai=bash-ai -v
  # e.g., alias bash-ai='/bin/bash -x /usr/bin/bash-ai'
  # e.g., alias l=ls --color=auto
  # e.g., alias ls=ls --color=auto
  local cmd="$1" # e.g., "upgrade", "ai", "l"
  if ! _otel_has_alias "$cmd"; then return 1; fi
  local full_alias="$(_otel_resolve_alias "$cmd")"
  while _otel_string_starts_with "$full_alias" 'OTEL_'; do local full_alias="${full_alias#* }"; done
  if ! _otel_string_starts_with "$full_alias" / && ! _otel_string_starts_with "$full_alias" .; then return 2; fi
  local cmd_alias="$(\printf '%s' "$full_alias" | _otel_line_split | \grep -v '^OTEL_' | \grep -v '^_otel_' | \head -n1 | \rev | \cut -d / -f 1 | \rev)" # e.g., upgrade => bash
  if \[ -z "$cmd_alias" ]; then return 3; fi
  local cmd_aliased="$(_otel_resolve_alias $cmd_alias)" # e.g., bash => _otel_inject_shell bash
  if \[ -z "$cmd_aliased" ]; then return 4; fi
  local otel_cmds="$(\printf '%s' "$cmd_aliased" | _otel_line_split | \grep '^_otel_' | \grep -v '^_otel_observe' | _otel_line_join)" # e.g., _otel_inject_shell bash => _otel_inject_shell
  if \[ -z "$otel_cmds" ]; then return 5; fi
  _otel_alias_prepend "$cmd" "$otel_cmds" # e.g., alias upgrade='_otel_inject_shell /bin/bash -x /usr/bin/upgrade'
}

_otel_has_alias() {
  \alias "$1" 1> /dev/null 2> /dev/null # for some reason &> does not work in built-in alias
}

_otel_resolve_alias() {
  local my_alias="$(\alias "$1" 2> /dev/null)"
  local my_alias="${my_alias#alias }"
  local my_alias="$(\eval "\\printf '%s\n' $my_alias")"
  \printf '%s\n' "${my_alias#*=}"
}

otel_instrument() {
  _otel_alias_prepend "$1" '_otel_observe'
}

otel_outstrument() {
  \unalias "$1" 1> /dev/null 2> /dev/null || true
}

_otel_alias_prepend() {
  local original_command="$1"
  local prepend_command="$2"

  if ! _otel_has_alias "$original_command"; then # fastpath
    local new_command="$(\printf '%s' "OTEL_SHELL_COMMAND_TYPE_OVERRIDE=$(_otel_command_type "$original_command") $prepend_command '\\$original_command'")" # need to use printf to handle backslashes consistently across shells
  else
    local previous_command="$(_otel_resolve_alias "$original_command")"
    for prepend_command_part in $prepend_command; do
      if _otel_string_contains "$previous_command" "$prepend_command_part"; then return 0; fi      
    done
    if _otel_string_contains "$previous_command" "OTEL_SHELL_COMMAND_TYPE_OVERRIDE="; then
      local command_type="$previous_command"
      local command_type="${command_type#*OTEL_SHELL_COMMAND_TYPE_OVERRIDE=}"
      local command_type="${command_type%% *}"
    else
      local command_type="alias"
    fi
    if _otel_string_contains "$previous_command" "OTEL_SHELL_SPAN_KIND_OVERRIDE="; then
      local span_kind="$previous_command"
      local span_kind="${span_kind#*OTEL_SHELL_SPAN_KIND_OVERRIDE=}"
      local span_kind="${span_kind%% *}"
    fi
    while _otel_string_starts_with "$previous_command" "OTEL_"; do local previous_command="${previous_command#* }"; done
    local overrides="OTEL_SHELL_COMMAND_TYPE_OVERRIDE=$command_type"
    if \[ -n "${span_kind:-}" ]; then local overrides="$overrides OTEL_SHELL_SPAN_KIND_OVERRIDE=$span_kind"; fi
    local previous_otel_command="$(\printf '%s' "$previous_command" | _otel_line_split | \grep '^_otel_' | _otel_line_join)"
    local previous_alias_command="$(\printf '%s' "$previous_command" | _otel_line_split | \grep -v '^_otel_' | _otel_line_join)"
    case "$previous_alias_command" in
      "$original_command") local previous_alias_command="$(\printf '%s' "'\\$original_command'")";;
      "$original_command "*) local previous_alias_command="$(\printf '%s' "'\\$original_command' $(_otel_string_contains "$previous_alias_command" " " && \printf '%s' "${previous_alias_command#* }" || \printf '%s' "$previous_alias_command")")";; 
      "\\$original_command") local previous_alias_command="$(\printf '%s' "'\\$original_command'")";;
      "\\$original_command "*) local previous_alias_command="$(\printf '%s' "'\\$original_command' $(_otel_string_contains "$previous_alias_command" " " && \printf '%s' "${previous_alias_command#* }" || \printf '%s' "$previous_alias_command")")";;
      *) ;;
    esac
    local new_command="$overrides $prepend_command $previous_otel_command $previous_alias_command"
  fi

  \alias "$original_command"='OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE="code.filepath='$_otel_source_file_resolver',code.lineno='$_otel_source_line_resolver',code.function='$_otel_source_func_resolver'" '"$new_command"
}

_otel_unquote() {
  # '\'' => ', '"'"' => ', '"'"$ => '', '"''"$ => ''' => '
  \sed -e 's/'\''\\'\'''\''/'\''/g' -e 's/'\''"'\''"'\''/'\''/g' -e 's/'\''"'\''"$/'\'''\''/g' -e 's/'\''"'\'\''"$/'\''/g' -e "s/^'\(.*\)'$/\1/"
}

_otel_observe() {
  otel_observe "$@"
}

_otel_alias_and_instrument() {
  shift
  local exit_code=0
  \eval "'alias'" "$(_otel_escape_args "$@")" || local exit_code="$?"
  if \[ -n "$*" ] && \[ "${*#*=*}" != "$*" ]; then
    _otel_auto_instrument "$(_otel_dollar_star "$@" | _otel_line_split | \grep -m1 '=' 2> /dev/null | \tr '=' ' ')"
  fi
  return "$exit_code"
}

_otel_unalias_and_reinstrument() {
  shift
  local exit_code=0
  \eval "'unalias'" "$(_otel_escape_args "$@")" || local exit_code="$?"
  if \[ "-a" = "$*" ]; then
    _otel_auto_instrument "$_otel_shell_auto_instrumentation_hint"
  else
    _otel_auto_instrument "$(_otel_dollar_star "$@")"
  fi
  return "$exit_code"
}

_otel_hash_and_reinstrument() {
  shift
  local exit_code=0
  \hash "$@" || local exit_code="$?"
  if \[ "$1" = -r ]; then
    local aliases_pre="$(\mktemp)"
    local aliases_new="$(\mktemp)"
    \alias | \sed 's/^alias //' | \awk '{print "\\alias " $0 }' > "$aliases_pre"
    \unalias -a
    _otel_auto_instrument "$_otel_shell_auto_instrumentation_hint"
    \alias | \sed 's/^alias //' | \awk '{print "\\alias " $0 }' > "$aliases_new"
    \unalias -a
    \. "$aliases_pre"
    \. "$aliases_new"
    \rm "$aliases_pre" "$aliases_new"
  fi
  return "$exit_code"
}

_otel_export_PATH_and_reinstrument() {
  shift
  local exit_code=0
  \export "$@" || local exit_code="$?"
  if \[ "$1" = PATH ] || _otel_string_starts_with "$1" PATH=; then
    local aliases_pre="$(\mktemp)"
    local aliases_new="$(\mktemp)"
    \alias | \sed 's/^alias //' | \awk '{print "\\alias " $0 }' > "$aliases_pre"
    \unalias -a
    _otel_auto_instrument "$_otel_shell_auto_instrumentation_hint"
    \alias | \sed 's/^alias //' | \awk '{print "\\alias " $0 }' > "$aliases_new"
    \unalias -a
    \. "$aliases_pre"
    \. "$aliases_new"
    \rm "$aliases_pre" "$aliases_new"
  fi
  return "$exit_code"
}

_otel_instrument_and_source() {
  local n="$1"
  shift
  local command="$(eval '\echo ${'"$(($n+1))"'}')"
  local file="$(eval '\echo ${'"$(($n+2))"'}')"
  if \[ -f "$file" ]; then _otel_auto_instrument "$file"; fi
  \eval "'$command' '$file' $(if \[ $# -gt $(($n + 2)) ]; then \seq $(($n + 2 + 1)) $#; else \seq 1 $n; fi | while \read i; do \echo '"${'"$i"'}"'; done | _otel_line_join)"
}

_otel_inject_and_exec_directly() { # this function assumes there is no fd fuckery
  if \[ "$#" = 1 ]; then
    \export OTEL_SHELL_CONSERVATIVE_EXEC=TRUE
    _otel_end_script
    if \[ -n "$_otel_commandline_override" ]; then
      \export OTEL_SHELL_COMMANDLINE_OVERRIDE="$_otel_commandline_override"
      \export OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE="$PPID"
    fi
    \eval '"exec"' "$(\xargs -0 $_otel_shell -c '. otelapi.sh; _otel_escape_args "$@"' sh < /proc/$$/cmdline)"
  fi

  local span_id="$(otel_span_start INTERNAL "$@")"
  otel_span_activate "$span_id"
  local my_traceparent="$TRACEPARENT"
  otel_span_deactivate "$span_id"
  otel_span_end "$span_id"
  _otel_end_script

  \export TRACEPARENT="$my_traceparent"
  \export OTEL_SHELL_AUTO_INJECTED=TRUE
  \export OTEL_SHELL_COMMANDLINE_OVERRIDE="$(_otel_command_self)"
  \export OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE="$PPID"
  shift
  \exec $_otel_shell -c '. otel.sh
eval _otel_inject "$(_otel_escape_args "$@")"' sh "$@"
}

_otel_inject_and_exec_by_location() {
  local file="$1"
  local line="$2"
  if \[ -n "$file" ] && \[ -n "$line" ] && \[ -f "$file" ]; then local command="$(\cat "$file" | \sed -n "$line"p | \grep -F 'exec' | \sed 's/^.*exec /exec /')"; fi
  if _otel_string_contains "$command" ';'; then local command="$(\printf '%s' "$command" | \cut -d ';' -f 1)"; fi
  if \[ -z "$command" ] || \[ "$(\printf '%s' "$command" | \sed 's/ [0-9]*>.*$//')" = "exec" ]; then return 0; fi
  local command="$(\printf '%s' "$command" | \cut -d ' ' -f 2-)"

  local span_id="$(otel_span_start INTERNAL exec)"
  otel_span_activate "$span_id"
  local my_traceparent="$TRACEPARENT"
  otel_span_deactivate "$span_id"
  otel_span_end "$span_id"
  _otel_end_script

  \printf '%s\n' "$(_otel_escape_args export TRACEPARENT="$my_traceparent")"
  \printf '%s\n' "$(_otel_escape_args export OTEL_SHELL_AUTO_INJECTED=TRUE)"
  \printf '%s\n' "$(_otel_escape_args export OTEL_SHELL_COMMANDLINE_OVERRIDE="$(_otel_command_self)")"
  \printf '%s\n' "$(_otel_escape_args export OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE="$PPID")"
  \echo -n '"exec" '; _otel_escape_args $_otel_shell -c '. otel.sh
_otel_inject '"$command"; \echo -n ' "$0" "$@"'
}

_otel_record_exec() {
  local span_id="$(otel_span_start INTERNAL exec)"
  otel_span_activate "$span_id"
  local my_traceparent="$TRACEPARENT"
  otel_span_deactivate "$span_id"
  otel_span_end "$span_id"
  _otel_sdk_communicate 'SPAN_AUTO_END'
  \export TRACEPARENT="$my_traceparent"
}

command() {
  if \[ "$#" = 2 ] && \[ "$1" = -v ] && _otel_string_contains "$(\alias "$2")" " OTEL_SHELL_COMMAND_TYPE_OVERRIDE=file "; then
    \which "$2"
  else
    \command "$@"
  fi
}

_otel_inject() {
  if _otel_string_contains "$1" / && \[ -x "$1" ]; then
    local path="$1"
    if ! \alias "${path##*/}" 1> /dev/null 2> /dev/null; then # in case its an absolute command that is not on the path at all, we need to make sure it is to have proper shebang resolution and the resulting instrumentation on hand
      local PATH="${path%/*}:$PATH"
      _otel_auto_instrument "$path " # this is a load-bearing whitespace so its not interpreted as a file hint
    fi
    local instrumentation="$(_otel_resolve_alias "${path##*/}")"
    if \[ -n "$instrumentation" ]; then
      local instrumentation="${instrumentation% *}"
      local instrumentation="$(\printf '%s' "$instrumentation" | _otel_line_split | \grep -v '^OTEL_' | _otel_line_join)"
    else
      local instrumentation=_otel_observe
    fi
    \eval "set -- $instrumentation $(_otel_escape_args "$@")"
  fi
  \eval "$(_otel_escape_args "$@")"
}

_otel_start_script() {
  otel_init || return $?
  if \[ -n "${SSH_CLIENT:-}"  ] && \[ -n "${SSH_CONNECTION:-}" ] && \[ "${PPID:-}" != 0 ] && \[ "$(\cat /proc/$PPID/cmdline | \tr -d '\000' | \cut -d ' ' -f 1)" = "sshd:" ]; then
    _root_span_handle="$(otel_span_start SERVER ssh)"
    otel_span_attribute_typed $_root_span_handle string ssh.ip="$(\echo $SSH_CONNECTION | \cut -d ' ' -f 3)"
    otel_span_attribute_typed $_root_span_handle int ssh.port="$(\echo $SSH_CONNECTION | \cut -d ' ' -f 4)"
    otel_span_attribute_typed $_root_span_handle string network.peer.ip="$(\echo $SSH_CLIENT | \cut -d ' ' -f 1)"
    otel_span_attribute_typed $_root_span_handle int network.peer.port="$(\echo $SSH_CLIENT | \cut -d ' ' -f 2)"
  elif \[ -n "${SERVER_SOFTWARE:-}"  ] && \[ -n "${SCRIPT_NAME:-}" ] && \[ -n "${SERVER_NAME:-}" ] && \[ -n "${SERVER_PROTOCOL:-}" ] && ! \[ "${OTEL_SHELL_AUTO_INJECTED:FALSE}" = "TRUE" ] && \[ "${PPID:-}" != 0 ] && \[ "$(\cat "/proc/$PPID/cmdline" | \tr '\000' ' ' | \cut -d ' ' -f 1 | \rev | \cut -d / -f 1 | \rev)" = "python3" ]; then
    _root_span_handle="$(otel_span_start SERVER GET)"
    otel_span_attribute_typed $_root_span_handle string network.protocol.name=http
    otel_span_attribute_typed $_root_span_handle string network.transport=tcp
    otel_span_attribute_typed $_root_span_handle string network.peer.address="$REMOTE_ADDR"
    otel_span_attribute_typed $_root_span_handle string http.request.method=GET
    otel_span_attribute_typed $_root_span_handle string http.route="$SCRIPT_NAME"
    otel_span_attribute_typed $_root_span_handle string server.address="$SERVER_NAME"
    otel_span_attribute_typed $_root_span_handle int server.port="$SERVER_PORT"
    otel_span_attribute_typed $_root_span_handle string url.full="$(\echo "$SERVER_PROTOCOL" | \cut -d / -f 1 | \tr '[:upper:]' '[:lower:]')://$SERVER_NAME:$SERVER_PORT$SCRIPT_NAME"
    otel_span_attribute_typed $_root_span_handle string url.path="$SCRIPT_NAME"
    otel_span_attribute_typed $_root_span_handle string url.query=""
    otel_span_attribute_typed $_root_span_handle string url.scheme="$(\echo "$SERVER_PROTOCOL" | \cut -d / -f 1 | \tr '[:upper:]' '[:lower:]')"
    otel_span_attribute_typed $_root_span_handle string http.response.status_code=200
  elif _otel_command_self | \grep -q '/var/lib/dpkg/' > /dev/null; then
    local cmdline="$(_otel_command_self | \sed 's/^.* \(\/var\/lib\/dpkg\/.*\)$/\1/')"
    _root_span_handle="$(otel_span_start SERVER "$(\echo "$cmdline" | \cut -d . -f 2- | \cut -d ' ' -f 1)")"
    otel_span_attribute_typed $_root_span_handle string debian.package.name="$(\echo "$cmdline" | \rev | \cut -d / -f 1 | \rev | \cut -d . -f 1)"
    otel_span_attribute_typed $_root_span_handle string debian.package.operation="$(\echo "$cmdline" | \cut -d . -f 2-)"
  elif ! \[ "${OTEL_SHELL_AUTO_INJECTED:-FALSE}" = TRUE ] && \[ -z "${TRACEPARENT:-}" ]; then
    _root_span_handle="$(otel_span_start SERVER "$(_otel_command_self)")"
  elif ! \[ "${OTEL_SHELL_AUTO_INJECTED:-FALSE}" = TRUE ] && \[ -n "${TRACEPARENT:-}" ]; then
    _root_span_handle="$(otel_span_start INTERNAL "$(_otel_command_self)")"
  fi
  if \[ -n "${_root_span_handle:-}" ]; then otel_span_activate "$_root_span_handle"; fi
  unset OTEL_SHELL_AUTO_INJECTED
}

_otel_end_script() {
  local exit_code="$?"
  if \[ -n "${_root_span_handle:-}" ]; then
    if \[ "$exit_code" -ne 0 ]; then
      otel_span_error "$_root_span_handle"
    fi
    otel_span_deactivate
    otel_span_end "$_root_span_handle"
  fi
  otel_shutdown
}

_otel_auto_instrument "$_otel_shell_auto_instrumentation_hint"
trap _otel_end_script EXIT

_otel_start_script
