#!/bin/bash
# git pre-commit hook:
# - convert json files into human-readable tables
# - generate misc table files

set -e
source environ.sh

for file in $(qadb-info print --qa-tree --no-latest --simple); do
  $QADB/util/parseQaTree.rb $file
done

for dataset in $(qadb-info print --list --no-latest --simple); do
  outfile=$QADB/qadb/$dataset/miscTable.md
  qadb-info misc --datasets $dataset --markdown > $outfile
  echo "produced $outfile"
done
