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
rawindex=$outdir/index_raw.md
echo """# Index of QADB Text Files

These are human-readable text files; see [Usage Guide](../usage.md) for more information.

""" > $txtindex
echo """# Index of \`Misc\` Bit Tables

These are tables of \`Misc\` bit assignments for each run.
""" > $miscindex
echo """# Index of Raw Table Files

These are raw ASCII tables with all of the QADB information, except for comments. The tables just contain numbers, while
the table columns are provided in a separate file.

| Dataset | Table | Columns |
| --- | --- | --- |""" > $rawindex

# loop over dataset(s)
for dataset in ${datasets[@]}; do
  echo """


  """

  # define inputs and outputs
  qadir=$QADB/qadb/$dataset
  infile=$qadir/qaTree.json
  txtfile=$outdir/$dataset/qaTree.txt
  miscfile=$outdir/$dataset/miscTable.md
  rawbase=$outdir/$dataset/qaRaw
  mkdir -p $outdir/$dataset

  # populate index pages
  echo "- [\`$dataset\`]($dataset/qaTree.txt)" >> $txtindex
  echo "- [\`$dataset\`]($dataset/miscTable.md)" >> $miscindex
  echo "| \`$dataset\` | [Table]($dataset/qaRaw.table.txt) | [Columns]($dataset/qaRaw.columns.md) |" >> $rawindex

  echo "[+] producing qaTree.txt file for $dataset ..."
  [ ! -f $infile ] && echo "ERROR: file '$infile' doesn't exist" >&2 && exit 1
  run-groovy $QADB/util/parseQaTree.groovy $infile
  echo "dataset: $dataset" > $txtfile
  cat $infile.table >> $txtfile
  rm $infile.table
  echo "[+] produced $txtfile"

  echo "[+] producing miscTable.md file for $dataset ..."
  qadb-info misc --datasets $dataset --markdown > $miscfile
  echo "[+] produced $miscfile"

  echo "[+] producing qaRaw.* files for $dataset ..."
  $QADB/util/makeRawTable.rb $dataset $qadir $rawbase
  echo "[+] produced $rawbase.*"
done
