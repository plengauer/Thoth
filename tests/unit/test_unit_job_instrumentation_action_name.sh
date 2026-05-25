. ./assert.sh

_test_base="$(mktemp -d)"

resolve_github_action_name() {
  action_name="$GITHUB_ACTION_REPOSITORY"
  if [ -n "${GITHUB_ACTION_REPOSITORY:-}" ] && [ -n "${GITHUB_ACTION_REF:-}" ]; then
    action_path_prefix="$_test_base/$GITHUB_ACTION_REPOSITORY/$GITHUB_ACTION_REF/"
    github_action_path="${GITHUB_ACTION_PATH:-}"
    if [ -z "$github_action_path" ] && [ -n "${_OTEL_GITHUB_STEP_ACTION_HINT_PATH:-}" ]; then
      hint_dir="${_OTEL_GITHUB_STEP_ACTION_HINT_PATH%/}"
      [ -f "$hint_dir" ] && hint_dir="$(dirname "$hint_dir")"
      while [ -n "$hint_dir" ] && [ "$hint_dir" != "/" ]; do
        if [ -f "$hint_dir/action.yml" ] || [ -f "$hint_dir/action.yaml" ]; then
          github_action_path="$hint_dir"
          break
        fi
        hint_dir="$(dirname "$hint_dir")"
      done
    fi
    case "$github_action_path" in
      *"$action_path_prefix"*)
        action_path="${github_action_path#*"$action_path_prefix"}"
        [ -z "$action_path" ] || action_name="$action_name/$action_path"
        ;;
    esac
  fi
  printf '%s' "$action_name"
}

GITHUB_ACTION_REPOSITORY=owner/repo
GITHUB_ACTION_REF=ref

# Composite action at root - GITHUB_ACTION_PATH set, action in root
mkdir -p "$_test_base/owner/repo/ref"
touch "$_test_base/owner/repo/ref/action.yml"
GITHUB_ACTION_PATH="$_test_base/owner/repo/ref"
_OTEL_GITHUB_STEP_ACTION_HINT_PATH=""
assert_equals "owner/repo" "$(resolve_github_action_name)"

# Composite action in subdir - GITHUB_ACTION_PATH set, action in subdir
mkdir -p "$_test_base/owner/repo/ref/subdir"
touch "$_test_base/owner/repo/ref/subdir/action.yml"
GITHUB_ACTION_PATH="$_test_base/owner/repo/ref/subdir"
_OTEL_GITHUB_STEP_ACTION_HINT_PATH=""
assert_equals "owner/repo/subdir" "$(resolve_github_action_name)"

# JavaScript action at root - GITHUB_ACTION_PATH not set, hint is node script
GITHUB_ACTION_PATH=""
_OTEL_GITHUB_STEP_ACTION_HINT_PATH="$_test_base/owner/repo/ref/dist/index.js"
mkdir -p "$_test_base/owner/repo/ref/dist"
touch "$_test_base/owner/repo/ref/dist/index.js"
assert_equals "owner/repo" "$(resolve_github_action_name)"

# JavaScript action in subdir - GITHUB_ACTION_PATH not set, hint is node script inside subdir
GITHUB_ACTION_PATH=""
_OTEL_GITHUB_STEP_ACTION_HINT_PATH="$_test_base/owner/repo/ref/subdir/dist/index.js"
mkdir -p "$_test_base/owner/repo/ref/subdir/dist"
touch "$_test_base/owner/repo/ref/subdir/dist/index.js"
assert_equals "owner/repo/subdir" "$(resolve_github_action_name)"

# Docker action at root - GITHUB_ACTION_PATH not set, hint is action dir
GITHUB_ACTION_PATH=""
_OTEL_GITHUB_STEP_ACTION_HINT_PATH="$_test_base/owner/repo/ref"
assert_equals "owner/repo" "$(resolve_github_action_name)"

# Docker action in subdir - GITHUB_ACTION_PATH not set, hint is action subdir
GITHUB_ACTION_PATH=""
_OTEL_GITHUB_STEP_ACTION_HINT_PATH="$_test_base/owner/repo/ref/subdir"
assert_equals "owner/repo/subdir" "$(resolve_github_action_name)"

# No hint path set - falls back to just repository name
GITHUB_ACTION_PATH=""
_OTEL_GITHUB_STEP_ACTION_HINT_PATH=""
assert_equals "owner/repo" "$(resolve_github_action_name)"

rm -rf "$_test_base"
