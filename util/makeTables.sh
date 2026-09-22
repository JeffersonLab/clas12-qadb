#!/bin/bash
# - convert json files into human-readable tables
# - generate misc table files

set -euo pipefail
source environ.sh

# parse args
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

# make sure we have `run-groovy`
if ! command -v run-groovy &> /dev/null; then
  echo "ERROR: \`run-groovy\`, part of COATJAVA, not found" >&2
  exit 1
fi

# make output dir
outdir=$QADB/docs/tables
mkdir -p $outdir
rm -r $outdir
mkdir -p $outdir

# start index pages
txtindex=$outdir/index_txt.md
miscindex=$outdir/index_misc.md
echo """# Index of QADB Text Files
""" > $txtindex
echo """# Index of \`Misc\` Bit Tables
""" > $miscindex

# loop over dataset(s)
for dataset in ${datasets[@]}; do
  echo """


  """

  # populate index pages
  echo "- [\`$dataset\`]($dataset/qaTree.txt)" >> $txtindex
  echo "- [\`$dataset\`]($dataset/miscTable.md)" >> $miscindex

  # define inputs and outputs
  infile=$QADB/qadb/$dataset/qaTree.json
  txtfile=$outdir/$dataset/qaTree.txt
  miscfile=$outdir/$dataset/miscTable.md
  mkdir -p $outdir/$dataset

  # produce `qaTree.json.table` file
  echo "[+] producing qaTree.txt file for $dataset ..."
  [ ! -f $infile ] && echo "ERROR: file '$infile' doesn't exist" >&2 && exit 1
  run-groovy $QADB/util/parseQaTree.groovy $infile
  echo "dataset: $dataset" > $txtfile
  cat $infile.table >> $txtfile
  rm $infile.table
  echo "[+] produced $txtfile"

  # produce `miscTable.md` file
  echo "[+] producing miscTable.md file for $dataset ..."
  qadb-info misc --datasets $dataset --markdown > $miscfile
  echo "[+] produced $miscfile"
done
