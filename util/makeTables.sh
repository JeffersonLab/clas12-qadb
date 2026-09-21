#!/bin/bash
# - convert json files into human-readable tables
# - generate misc table files

set -e
source environ.sh

if [ $# -ne 1 ]; then
  echo """USAGE $0 [INPUT]
  INPUT may be either:
    - a path to a \`qaTree.json\` file
    - 'all', to reproduce _all_ tables"""
  exit 2
fi

if [ "$1" = "all" ]; then
  inFiles=()
  while IFS= read -r line; do
    inFiles+=("$line")
  done < <(qadb-info print --qa-tree --no-latest --simple)
else
  inFiles=($1)
fi

if ! command -v run-groovy &> /dev/null; then
  echo "ERROR: \`run-groovy\`, part of COATJAVA, not found" >&2
  exit 1
fi

for file in ${inFiles[@]}; do
  if [ ! -f $file ]; then
    echo "ERROR: file '$file' doesn't exist" >&2
    exit 1
  fi
done

for file in ${inFiles[@]}; do
  run-groovy $QADB/util/parseQaTree.groovy $file
done

for dataset in ${inFiles[@]}; do
  outfile=$QADB/qadb/$dataset/miscTable.md
  qadb-info misc --datasets $dataset --markdown > $outfile
  echo "produced $outfile"
done
