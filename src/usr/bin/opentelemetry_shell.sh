#!/bin/sh
###############################################################################################################
# This file is doing auto-instrumentation, auto-injection and auto-context-propagation.                        #
# It should be sourced at the very top of any shell script that should be observed.                            #
# Only use the "otel_instrument" and "otel_outstrument" function directly.                                     #
# All other functions and variables are for internal use only and therefore subject to change without notice!  #
################################################################################################################

if [ "$OTEL_SHELL_INJECTED" = "TRUE" ]; then
  return 0
fi
OTEL_SHELL_INJECTED=TRUE

. /usr/bin/opentelemetry_shell_api.sh

if [ "$otel_shell" = "bash" ] && [ -n "$BASHPID" ] && [ "$$" != "$BASHPID" ]; then
  echo "WARNING The OpenTelemetry shell file for auto-instrumentation is sourced in a subshell, automatic instrumentation will only be active within that subshell!" >&2
fi

case "$-" in
  *i*) otel_is_interactive=TRUE;;
  *)   otel_is_interactive=FALSE;;
esac

if [ "$otel_is_interactive" = "TRUE" ]; then
  otel_shell_auto_instrumentation_hint=""
elif [ -n "$OTEL_SHELL_AUTO_INSTRUMENTATION_HINT" ]; then
  otel_shell_auto_instrumentation_hint="$OTEL_SHELL_AUTO_INSTRUMENTATION_HINT"
elif [ "$(\readlink -f "$(\which "$0")" | \rev | \cut -d/ -f1 | \rev)" = "$(\readlink -f /proc/$$/exe | \rev | \cut -d/ -f1 | \rev)" ]; then
  otel_shell_auto_instrumentation_hint=""
else
  otel_shell_auto_instrumentation_hint="$0"
fi
unset OTEL_SHELL_AUTO_INSTRUMENTATION_HINT

if [ "$otel_shell" = "bash" ]; then
  otel_source_file_resolver='"${BASH_SOURCE[0]}"'
else
  otel_source_file_resolver='"$0"'
fi
otel_source_line_resolver='"$LINENO"'
otel_source_func_resolver='"$FUNCNAME"'

if [ "$otel_shell" = "bash" ]; then
  shopt -s expand_aliases &> /dev/null
fi

otel_unquote() {
  \sed "s/^'\(.*\)'$/\1/"
}

otel_line_join() {
  \sed '/^$/d' | \tr '\n' ' ' | \sed 's/ $//'
}

otel_line_split() {
  \tr ' ' '\n'
}

otel_escape_args() {
  local first=TRUE
  for arg in "$@"; do
    if [ "$first" = TRUE ]; then local first=FALSE; else \echo -n " "; fi
    case "$arg" in  
      *\ * ) \echo -n "\"$arg\"" ;;
      *) \echo -n "$arg" ;;
    esac
  done
}

otel_alias_prepend() {
  local original_command=$1
  local prepend_command=$2

  if [ -z "$(\alias $original_command 2> /dev/null)" ]; then # fastpath
    local new_command="$prepend_command $original_command"
  else
    local previous_command="$(\alias $original_command 2> /dev/null | \cut -d= -f2- | otel_unquote)"
    if [ -z "$previous_command" ]; then local previous_command="$original_command"; fi
    if [ "${previous_command#OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE=}" != "$previous_command" ]; then local previous_command="$(\printf '%s' "$previous_command" | \cut -d" " -f2-)"; fi
    case "$previous_command" in
      *"$prepend_command"*) return 0 ;;
      *) ;;
    esac
    local previous_otel_command="$(\printf '%s' "$previous_command" | otel_line_split | \grep '^otel_' | otel_line_join)"
    local previous_alias_command="$(\printf '%s' "$previous_command" | otel_line_split | \grep -v '^otel_' | otel_line_join)"
    local new_command="$previous_otel_command $prepend_command $previous_alias_command"
  fi
  
  \alias $original_command='OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE="code.filepath='$otel_source_file_resolver',code.lineno='$otel_source_line_resolver',code.function='$otel_source_func_resolver'" '"$new_command"
}

otel_shebang() {
  local path="$(\which $1)"
  if [ -z "$path" ] || [ ! -f "$path" ]; then return 1; fi
  read -r first_line < "$path"
  if [ "$(\echo "$first_line" | \cut -c1-2)" != '#!' ]; then return 2; fi
  \echo "$first_line" | \cut -c3- | \awk '{$1=$1};1'
}

otel_deshebangify() {
  local cmd=$1 # e.g., "upgrade"
  if [ -n "$(\alias $1 2> /dev/null)" ]; then return 1; fi
  local shebang="$(otel_shebang $1)" # e.g., "/bin/bash -x"
  if [ -z "$shebang" ]; then return 2; fi
  local shebang_cmd="$(\echo "$shebang" | \cut -d' ' -f1 | \rev | \cut -d/ -f1 | \rev)" # e.g., "bash"
  local aliased_shebang="$(\alias "$shebang_cmd" 2> /dev/null | \cut -d= -f2- | otel_unquote)" # e.g., "otel_inject_shell_with_source bash"
  if [ -z "$aliased_shebang" ]; then return 3; fi
  \alias $1="$aliased_shebang $(\echo "$shebang" | \cut -s -d ' ' -f2-) $(\which $1)"  # e.g., upgrade => otel_inject_shell_with_source bash -x /usr/bin/upgrade
}

otel_instrument() {
  otel_alias_prepend $1 'otel_observe'
}

otel_outstrument() {
  \unalias $1 1> /dev/null 2> /dev/null || true
}

otel_filter_commands_by_hint() {
  local hint="$1"
  if [ -n "$hint" ]; then
    if [ -f "$hint" ] && [ "$(\readlink -f /proc/$$/exe)" != "$(\readlink -f $hint)" ] && [ "$hint" != "/usr/bin/opentelemetry_shell.sh" ]; then local hint="$(\cat "$hint")"; fi
    \grep -xF "$(\echo "$hint" | \tr -s ' $=";(){}[]/\\!#~^'\' '\n' | \grep -E '^[a-zA-Z0-9 ._-]*$')"
  else
    \cat
  fi
}

otel_filter_commands_by_instrumentation() {
  local pre_instrumented_executables="$(\alias | \grep -F 'otel_observe' | \sed 's/^alias //' | \cut -d= -f1)"
  if [ -n "$pre_instrumented_executables" ]; then
    \grep -xFv "$pre_instrumented_executables" 
  else
    \cat
  fi
}

otel_list_path_executables() {
  \echo "$PATH" | \tr ' ' '\n' | \tr ':' '\n' | while read dir; do \find $dir -maxdepth 1 -type f,l -executable 2> /dev/null; done
}

otel_list_path_commands() {
  otel_list_path_executables | \rev | \cut -d / -f1 | \rev | \grep -vF '['
}

otel_list_alias_commands() {
  \alias | \sed 's/^alias //' | \awk -F'=' '{ var=$1; sub($1 FS,""); } ! ($0 ~ "^'\''((OTEL_|otel_).* )*" var "'\''$") { print var }'
}

otel_list_builtin_commands() {
  \echo printenv
  \echo type
  if [ "$otel_shell" = "bash" ]; then
    \echo history
  fi
}

otel_list_all_commands() {
  otel_list_path_commands
  otel_list_alias_commands
  otel_list_builtin_commands
}

otel_auto_instrument() {
  local hint="$1"
  # both otel_filter_commands_by_file and otel_filter_commands_by_instrumentation are functionally optional, but helps optimizing time because the following loop AND otel_instrument itself is expensive!
  local executables="$(otel_list_all_commands | otel_filter_commands_by_instrumentation | otel_filter_commands_by_hint "$hint" | \sort -u | otel_line_join)"
  for cmd in $executables; do otel_deshebangify $cmd || true; done
  for cmd in $executables; do otel_instrument $cmd; done
}

otel_alias_and_instrument() {
  local exit_code=0
  "$@" || local exit_code=$?
  shift
  local commands="$(\echo "$@" | otel_line_split | \grep -m1 '=' 2> /dev/null | \cut -d= -f1)"
  for cmd in $commands; do otel_instrument $cmd; done
  return $exit_code
}

otel_unalias_and_reinstrument() {
  local exit_code=0
  "$@" || local exit_code=$?
  shift
  if [ "-a" = "$*" ]; then
    local commands="$(otel_list_all_commands)"
  else
    local commands="$(otel_list_all_commands | \grep -Fx "$(\echo "$@" | otel_line_split 2> /dev/null)" 2> /dev/null)"
  fi
  for cmd in $commands; do otel_instrument $cmd; done
  return $exit_code
}

otel_instrument_and_source() {
  local file="$2"
  if [ -f "$file" ]; then
    otel_auto_instrument "$file"
  fi
  "$@"
}

otel_propagate_wget() {
  local command="$(\echo "$*" | \sed 's/^otel_observe //')"
  local url=$(\echo "$@" | \awk '{for(i=1;i<=NF;i++) if ($i ~ /^http/) print $i}')
  local scheme=http # TODO
  local target=$(\echo /${url#*//*/})
  local host=$(\echo ${url} | \awk -F/ '{print $3}')
  local method=GET
  OTEL_SHELL_SPAN_NAME_OVERRIDE="$command" OTEL_SHELL_SPAN_KIND_OVERRIDE=CLIENT OTEL_SHELL_COMMANDLINE_OVERRIDE="$command" \
    OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE="http.url=$url,http.scheme=$scheme,http.host=$host,http.target=$target,http.method=$method,$OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE" \
    OTEL_SHELL_ADDITIONAL_ARGUMENTS_POST_0='--header=traceparent: $OTEL_TRACEPARENT' \
    "$@"
}

otel_propagate_curl() {
  local command="$(\echo "$*" | \sed 's/^otel_observe //')"
  local url=$(\echo "$@" | \awk '{for(i=1;i<=NF;i++) if ($i ~ /^http/) print $i}')
  local scheme=http # TODO
  local target=$(\echo /${url#*//*/})
  local host=$(\echo ${url} | \awk -F/ '{print $3}')
  local method=$(\echo "$@" | \awk '{for(i=1;i<=NF;i++) if ($i == "-X") print $(i+1)}')
  if [ -z "$method" ]; then
    local method=GET
  fi
  OTEL_SHELL_SPAN_NAME_OVERRIDE="$command" OTEL_SHELL_SPAN_KIND_OVERRIDE=CLIENT OTEL_SHELL_COMMANDLINE_OVERRIDE="$command" \
    OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE="http.url=$url,http.scheme=$scheme,http.host=$host,http.target=$target,http.method=$method,$OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE" \
    OTEL_SHELL_ADDITIONAL_ARGUMENTS_POST_0='-H' OTEL_SHELL_ADDITIONAL_ARGUMENTS_POST_1='traceparent: $OTEL_TRACEPARENT' \
    "$@"
}

otel_inject_shell_with_copy() {
  # resolve executable
  if [ "$1" = "otel_observe" ]; then
    shift; local cmdline="$*"; local executable="otel_observe $1"; local dollar_zero="$1"; shift
  else
    local cmdline="$*"; local executable=$1; local dollar_zero="$1"; shift
  fi
  # decompile command
  local options=""; local cmd=""; local args="";
  local is_next_command_string="FALSE"; local is_parsing_arguments="FALSE"; local is_next_option="FALSE";
  for arg in "$@"; do
    if [ "$arg" = "-c" ]; then
      local is_next_command_string="TRUE"
    elif [ "$is_next_command_string" = "TRUE" ]; then
      local cmd="$arg"
      local is_next_command_string="FALSE"
      local is_parsing_command="TRUE"
    elif [ "$is_parsing_command" = "TRUE" ]; then
      local args="$args \"$arg\""
    elif [ "$is_next_option" = "TRUE" ]; then
      local options="$options $arg"
      local is_next_option="FALSE"
    else
      case "$arg" in
        -*file) local options="$options $arg"; local is_next_option="TRUE" ;;
        -*) local options="$options $arg" ;;
        *) local is_parsing_command="TRUE"; local cmd="$arg"; local dollar_zero="$arg" ;;
      esac
    fi
  done
  if [ -n "$cmd" ]; then
    # prepare temporary script
    local temporary_script=$(\mktemp -u)
    \touch $temporary_script
    \echo "set -- $args" >> $temporary_script
    \echo "OTEL_SHELL_AUTO_INSTRUMENTATION_HINT=\"$temporary_script\"" >> $temporary_script
    \echo ". /usr/bin/opentelemetry_shell.sh" >> $temporary_script
    if [ -f "$cmd" ]; then
      \cat $cmd >> $temporary_script
    else
      \echo "$cmd" >> $temporary_script
    fi
    \chmod +x $temporary_script
    # compile command
    set -- $executable $options $temporary_script
  else
    set -- $executable $options
  fi
  # run command
  local exit_code=0
  OTEL_SHELL_COMMANDLINE_OVERRIDE="$cmdline" OTEL_SHELL_SPAN_NAME_OVERRIDE="$cmdline" OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE="$OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE" \
    OTEL_SHELL_AUTO_INJECTED=TRUE "$@" || local exit_code=$?
  \rm $temporary_script || true
  return $exit_code
}

otel_inject_shell_with_c_flag() {
  # type 0 - interactive or from stdin: bash, bash -x
  # type 1 - script: bash +x script.sh foo bar baz
  # type 2 - "-c": bash +x -c "echo $0" foo
  # resolve executable
  if [ "$1" = "otel_observe" ]; then
    shift; local cmdline="$*"; local executable="otel_observe $1"; local dollar_zero="$1"; shift
  else
    local cmdline="$*"; local executable=$1; local dollar_zero="$1"; shift
  fi
  # decompile command
  local options=""; local cmd=""; local args="";
  local is_next_command_string="FALSE"; local is_parsing_arguments="FALSE"; local is_next_option="FALSE";
  for arg in "$@"; do
    if [ "$arg" = "-c" ]; then
      local is_next_command_string="TRUE"
    elif [ "$is_next_command_string" = "TRUE" ]; then
      local cmd="
$arg"
      # aliases need at least a linefeed or a source to become active in a -c command. Dunno why, but its like that
      # also, we cant just introduce ALWAYS a linefeed, because then argument ordering is confused for sourced scripts
      local is_next_command_string="FALSE"
      local is_parsing_command="TRUE"
    elif [ "$is_parsing_command" = "TRUE" ]; then
      local args="$args \"$arg\""
    elif [ "$is_next_option" = "TRUE" ]; then
      local options="$options $arg"
      local is_next_option="FALSE"
    else
      case "$arg" in
        -*file) local options="$options $arg"; local is_next_option="TRUE" ;;
        -*) local options="$options $arg" ;;
        *) local is_parsing_command="TRUE"; local cmd="$arg"; local dollar_zero="$arg" ;;
      esac
    fi
  done
  # compile command
  if [ -n "$cmd" ]; then
    if [ -f "$cmd" ]; then
      local cmd=". $cmd"
    fi
    set -- $executable $options -c ". /usr/bin/opentelemetry_shell.sh; $cmd $args" "$dollar_zero"
  else
    set -- $executable $options
  fi
  # run command
  local exit_code=0
  OTEL_SHELL_COMMANDLINE_OVERRIDE="$cmdline" OTEL_SHELL_SPAN_NAME_OVERRIDE="$cmdline" OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE="$OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE" \
    OTEL_SHELL_AUTO_INJECTED=TRUE OTEL_SHELL_AUTO_INSTRUMENTATION_HINT="$cmd $args" "$@" || local exit_code=$?
  return $exit_code
}

otel_inject_inner_command() {
  local more_args="$MORE_ARGS"
  unset MORE_ARGS
  if [ "$1" = "otel_observe" ]; then
    shift; local executable="otel_observe $1"
  else
    local executable=$1
  fi
  local cmdline="$*"
  shift
  for arg in "$@"; do
    if ! [ "${arg%"${arg#?}"}" = "-" ] && ([ -n "$(\which $arg)" ] || [ -x "$arg" ]); then break; fi
    local executable="$executable $1"
    shift
  done
  local exit_code=0
  if [ -z "$*" ]; then
    OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE="$OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE" $executable || local exit_code=$?
  else
    export OTEL_SHELL_AUTO_INJECTED=TRUE
    export OTEL_SHELL_AUTO_INSTRUMENTATION_HINT="$*"
    OTEL_SHELL_COMMANDLINE_OVERRIDE="$cmdline" OTEL_SHELL_SPAN_NAME_OVERRIDE="$cmdline" OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE="$OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE" \
      $executable $more_args sh -c ". /usr/bin/opentelemetry_shell.sh
$(otel_escape_args "$@")" || local exit_code=$?
    unset OTEL_SHELL_AUTO_INSTRUMENTATION_HINT
    unset OTEL_SHELL_AUTO_INJECTED
  fi
  return $exit_code
}

otel_inject_sudo() {
  MORE_ARGS="--preserve-env=$(\printenv | \grep '^OTEL_' | \cut -d= -f1 | \tr '\n' ','),OTEL_SHELL_AUTO_INJECTED,OTEL_SHELL_AUTO_INSTRUMENTATION_HINT" otel_inject_inner_command "$@"
}

otel_inject_xargs() {
  if [ "$(\expr "$*" : ".* -I .*")" -gt 0 ]; then
    otel_inject_inner_command "$@"
  else
    if [ "$1" = "otel_observe" ]; then
      shift; local executable="otel_observe $1"
    else
      local executable=$1
    fi
    shift
    otel_inject_xargs $executable -I '{}' "$@" '{}' # TODO we should fake the commandline and span name and also adjust the test!
  fi
}

otel_inject_find_arguments() {
  local in_exec=0
  local first=1
  for arg in "$@"; do
    if [ "$first" = 1 ]; then local first=0; else \echo -n ' '; fi
    if [ "$in_exec" -eq 0 ] && ([ "$arg" = "-exec" ] || [ "$arg" = "-execdir" ]); then
      local in_exec=1
      \echo -n "$arg sh -c '. /usr/bin/opentelemetry_shell.sh
"
    elif [ "$in_exec" -eq 1 ] && ([ "$arg" = ";" ] || [ "$arg" = "+" ]); then
      local in_exec=0
      \echo -n "' '' {} '$arg'"
    elif [ "$in_exec" -eq 1 ] && [ "$arg" = "{}" ]; then
      \echo -n '"$@"'
    else
      if [ "$(\expr "$arg" : ".* .*")" -gt 0 ] || [ "$(\expr "$arg" : ".*\*.*")" -gt 0 ]; then
        \echo -n '"'$arg'"'
      else
        \echo -n "$arg"
      fi
    fi
  done
}

otel_inject_find() {
  if [ "$(\expr "$*" : ".* -exec .*")" -gt 0 ] || [ "$(\expr "$*" : ".* -execdir .*")" -gt 0 ]; then
    if [ "$1" = "otel_observe" ]; then
      shift; local executable="otel_observe $1"
    else
      local executable=$1
    fi
    local cmdline="$*"
    shift
    OTEL_SHELL_COMMANDLINE_OVERRIDE="$cmdline" OTEL_SHELL_SPAN_NAME_OVERRIDE="$cmdline" OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE="$OTEL_SHELL_SPAN_ATTRIBUTES_OVERRIDE" \
      OTEL_SHELL_AUTO_INJECTED=TRUE OTEL_SHELL_AUTO_INSTRUMENTATION_HINT="$*" eval $executable "$(otel_inject_find_arguments "$@")"
  else
    $executable "$@"
  fi
}

otel_record_exec() {
  local file="$1"
  local line="$2"
  if [ -n "$file" ] && [ -n "$line" ] && [ -f "$file" ]; then local command="$(\cat "$file" | \sed -n "$line"p | \grep -F 'exec' | \sed 's/^.*exec /exec /')"; fi
  if [ -z "$command" ]; then local command="exec"; fi
  local span_id=$(otel_span_start INTERNAL "$command")
  if [ "$(\printf '%s' "$command" | \sed 's/ [0-9]*>.*$//')" != "exec" ]; then
    otel_span_activate $span_id
  fi
  otel_span_end $span_id
  otel_sdk_communicate 'SPAN_AUTO_END'
}

otel_start_script() {
  otel_init || return $?
  if [ "$OTEL_SHELL_AUTO_INJECTED" != "TRUE" ]; then
    if [ -n "$SSH_CLIENT"  ] && [ -n "$SSH_CONNECTION" ]; then
      otel_root_span_id=$(otel_span_start SERVER ssh)
      otel_span_attribute $otel_root_span_id ssh.ip=$(\echo $SSH_CONNECTION | \cut -d' ' -f3)
      otel_span_attribute $otel_root_span_id ssh.port=$(\echo $SSH_CONNECTION | \cut -d' ' -f4)
      otel_span_attribute $otel_root_span_id net.peer.ip=$(\echo $SSH_CLIENT | \cut -d' ' -f1)
      otel_span_attribute $otel_root_span_id net.peer.port=$(\echo $SSH_CLIENT | \cut -d' ' -f2)
    elif [ -n "$SERVER_SOFTWARE"  ] && [ -n "$SCRIPT_NAME" ] && [ -n "$SERVER_NAME" ] && [ -n "$SERVER_PROTOCOL" ]; then
      otel_root_span_id=$(otel_span_start SERVER GET)
      otel_span_attribute $otel_root_span_id http.flavor=$(\echo $SERVER_PROTOCOL | \cut -d'/' -f2)
      otel_span_attribute $otel_root_span_id http.host=$SERVER_NAME:$SERVER_PORT
      otel_span_attribute $otel_root_span_id http.route=$SCRIPT_NAME
      otel_span_attribute $otel_root_span_id http.scheme=$(\echo $SERVER_PROTOCOL | \cut -d'/' -f1 | \tr '[:upper:]' '[:lower:]')
      otel_span_attribute $otel_root_span_id http.method=GET
      otel_span_attribute $otel_root_span_id http.status_code=200
      otel_span_attribute $otel_root_span_id http.status_text=OK
      otel_span_attribute $otel_root_span_id http.target=$SCRIPT_NAME
      otel_span_attribute $otel_root_span_id http.url=$(\echo $SERVER_PROTOCOL | \cut -d'/' -f1 | \tr '[:upper:]' '[:lower:]')://$SERVER_NAME:$SERVER_PORT$SCRIPT_NAME
      otel_span_attribute $otel_root_span_id net.peer.ip=$REMOTE_ADDR
    elif [ "$(otel_command_self | \cut -d' ' -f2 | \rev | \cut -d/ -f2- | \rev)" = "/var/lib/dpkg/info" ] || [ "$(otel_command_self | \cut -d' ' -f2 | \rev | \cut -d/ -f2- | \rev)" = "/var/lib/dpkg/tmp.ci" ]; then
      if [ -z "$OTEL_TRACEPARENT" ]; then
        otel_root_span_id=$(otel_span_start SERVER $(otel_command_self | \cut -d' ' -f2 | \rev | \cut -d/ -f1 | \cut -d. -f1 | \rev))
      else
        otel_root_span_id=$(otel_span_start INTERNAL $(otel_command_self | \cut -d' ' -f2 | \rev | \cut -d/ -f1 | \cut -d. -f1 | \rev))
      fi
      otel_span_attribute $otel_root_span_id debian.package.operation=$(otel_command_self | \cut -d' ' -f2 | \rev | \cut -d/ -f1 | \rev | \cut -d. -f2) $(otel_command_self | \cut -d' ' -f3)
      otel_span_attribute $otel_root_span_id debian.package.name=$(otel_command_self | \cut -d' ' -f2 | \rev | \cut -d/ -f1 | \rev | \cut -d. -f1)
    else
      otel_root_span_id=$(otel_span_start SERVER $(otel_command_self))
    fi
    otel_span_activate $otel_root_span_id
  fi
  unset OTEL_SHELL_AUTO_INJECTED
}

otel_end_script() {
  local exit_code=$?
  if [ -n "$otel_root_span_id" ]; then
    if [ "$exit_code" -ne "0" ]; then
      otel_span_error $otel_root_span_id
    fi
    otel_span_deactivate
    otel_span_end $otel_root_span_id
  fi
  otel_shutdown
}

otel_alias_prepend wget otel_propagate_wget
otel_alias_prepend curl otel_propagate_curl
otel_alias_prepend sh otel_inject_shell_with_copy # cant really know what kind of shell it actually is, so lets play it safe
otel_alias_prepend ash otel_inject_shell_with_copy # sourced files do not support arguments
otel_alias_prepend dash otel_inject_shell_with_copy # sourced files do not support arguments
otel_alias_prepend bash otel_inject_shell_with_c_flag
otel_alias_prepend sudo otel_inject_sudo
otel_alias_prepend time otel_inject_inner_command
otel_alias_prepend timeout otel_inject_inner_command
otel_alias_prepend xargs otel_inject_xargs
otel_alias_prepend find otel_inject_find

otel_alias_prepend alias otel_alias_and_instrument
otel_alias_prepend unalias otel_unalias_and_reinstrument
otel_alias_prepend . otel_instrument_and_source
if [ "$otel_shell" = "bash" ]; then
  otel_alias_prepend source otel_instrument_and_source
fi

otel_auto_instrument "$otel_shell_auto_instrumentation_hint"

\alias exec='otel_record_exec '$otel_source_file_resolver' '$otel_source_line_resolver'; exec'
trap otel_end_script EXIT

otel_start_script
