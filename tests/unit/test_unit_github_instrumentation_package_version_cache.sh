. ./assert.sh

work_dir="$(pwd)"
version="$(cat ../VERSION)"

for script_dir in workflow repository checksuite; do
  unset OTEL_SHELL_PACKAGE_VERSION_CACHE_opentelemetry_shell
  export GITHUB_EVENT_NAME=push
  cd ../actions/instrument/"$script_dir"
  . ../shared/config_validation.sh
  cd "$work_dir"
  assert_equals "$version" "${OTEL_SHELL_PACKAGE_VERSION_CACHE_opentelemetry_shell:-}"
done

export OTEL_SHELL_PACKAGE_VERSION_CACHE_opentelemetry_shell=9.9.9
export GITHUB_EVENT_NAME=push
cd ../actions/instrument/workflow
. ../shared/config_validation.sh
cd "$work_dir"
assert_equals 9.9.9 "$OTEL_SHELL_PACKAGE_VERSION_CACHE_opentelemetry_shell"
