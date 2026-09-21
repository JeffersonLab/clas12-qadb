#!/bin/bash
# - convert json files into human-readable tables
# - generate misc table files

set -euo pipefail
source environ.sh

if [ $# -ne 1 ]; then
  echo """USAGE $0 [INPUT]
  INPUT may be either:
    - a dataset name, e.g., \`pass1/rgc_su22\`
    - 'all', to reproduce _all_ tables"""
  exit 2
fi

if [ "$1" = "all" ]; then
  datasets=()
  while IFS= read -r line; do
    datasets+=("$line")
  done < <(qadb-info print --list --no-latest --simple)
else
  datasets=($1)
fi

if ! command -v run-groovy &> /dev/null; then
  echo "ERROR: \`run-groovy\`, part of COATJAVA, not found" >&2
  exit 1
fi

for dataset in ${datasets[@]}; do
  infile=$QADB/qadb/$dataset/qaTree.json
  miscfile=$QADB/qadb/$dataset/miscTable.md
  echo "[+] producing qaTree.json.table file from $infile ..."
  [ ! -f $infile ] && echo "ERROR: file '$infile' doesn't exist" >&2 && exit 1
  run-groovy $QADB/util/parseQaTree.groovy $infile
  echo "[+] producing miscTable.md file from $infile ..."
  qadb-info misc --datasets $dataset --markdown > $miscfile
  echo "[+] produced $miscfile"
done
