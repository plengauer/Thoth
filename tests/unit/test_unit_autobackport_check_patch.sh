. ./assert.sh

repo="$(mktemp -d)"
trap 'rm -rf "$repo"' EXIT

cd "$repo" || exit 1
git init -q
git config user.name test
git config user.email test@example.com

echo 1 > VERSION
git add VERSION
git commit -q -m init

should_backport="$(if git diff --quiet; then echo false; else echo true; fi)"
assert_equals false "$should_backport"

echo 2 > VERSION
should_backport="$(if git diff --quiet; then echo false; else echo true; fi)"
assert_equals true "$should_backport"
