#!/bin/bash
# git pre-commit hook:
# - convert json files into human-readable tables
# - generate misc table files

set -e
source environ.sh

pushd $QADB
for file in $(find -P qadb -name "qaTree.json"); do
  run-groovy util/parseQaTree.groovy $file
  util/makeMiscTable.rb $file
done
popd

git status --porcelain=v1 |\
  grep -E '\.table$|miscTable\.md$' \
  && { echo "generated files have changed" >&2; exit 1; } \
  || exit 0
