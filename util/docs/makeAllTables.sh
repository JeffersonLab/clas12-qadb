#!/usr/bin/env bash

set -euo pipefail
source environ.sh

# parse args
if [ $# -ne 2 ]; then
  echo "USAGE $0 [DATASET] [OUTDIR]"
  exit 2
fi
dataset=$1
outdir=$2

# make output subdir
outsubdir=$outdir/$dataset
mkdir -p $outsubdir

# define inputs and outputs
qadir=$QADB/qadb/$dataset
infile=$qadir/qaTree.json
txtfile=$outsubdir/qaTree.txt
miscfile=$outsubdir/miscTable.md
rawbase=$outsubdir/qaRaw

# make text files
echo "[+] producing qaTree.txt file for $dataset ..."
[ ! -f $infile ] && echo "ERROR: file '$infile' doesn't exist" >&2 && exit 1
run-groovy $QADB/util/docs/parseQaTree.groovy $infile
echo "dataset: $dataset" > $txtfile
cat $infile.table >> $txtfile
rm $infile.table
echo "[+] produced $txtfile"

# make misc table
echo "[+] producing miscTable.md file for $dataset ..."
$QADB/bin/qadb-info misc --datasets $dataset --markdown > $miscfile
echo "[+] produced $miscfile"

# make raw files
echo "[+] producing qaRaw.* files for $dataset ..."
$QADB/util/docs/makeRawTable.rb $dataset $qadir $rawbase
cd $outsubdir
rawbase_table=qaRaw.table.txt
echo "[+] compressing $rawbase_table ..."
sha256sum $rawbase_table > $rawbase_table.sha256
zstd -19 -T1 $rawbase_table
zstd -t $rawbase_table.zst
rm $rawbase_table
cd -
echo "[+] produced $rawbase.*"
