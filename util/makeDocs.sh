#!/usr/bin/env bash
set -euo pipefail

source $(dirname $0)/../environ.sh

if [ $# -ne 1 ]; then
  echo "USAGE: $0 [NUM_THREADS]"
  exit 2
fi
num_threads=$1

# make output dir
DOCDIR=$QADB/docs/tables
mkdir -p $DOCDIR
rm -r $DOCDIR
mkdir -p $DOCDIR
echo "producing docs in $DOCDIR"
echo "using $num_threads threads"

# make defect bits table
$QADB/util/docs/makeDefectTable.rb $DOCDIR/bitdefs.md

# get list of datasets
datasets=()
while IFS= read -r line; do
  datasets+=("$line")
done < <($QADB/bin/qadb-info print --list --no-latest --simple)

# build text file index page
txtindex=$DOCDIR/index_txt.md
echo """# Index of QADB Text Files

These are human-readable text files; see [Usage Guide](../usage.md) for more information.

""" > $txtindex
for dataset in ${datasets[@]}; do
  echo "- [\`$dataset\`]($dataset/qaTree.txt)" >> $txtindex
done

# build Misc table index page
miscindex=$DOCDIR/index_misc.md
echo """# Index of \`Misc\` Bit Tables

These are tables of \`Misc\` bit assignments for each run.
""" > $miscindex
for dataset in ${datasets[@]}; do
  echo "- [\`$dataset\`]($dataset/miscTable.md)" >> $miscindex
done

# build raw file index page
rawindex=$DOCDIR/index_raw.md
echo '''# Index of Raw Table Files

These are raw ASCII tables with all of the QADB information, except for comments. The tables just contain numbers, while
the table columns are provided in a separate file.

The tables are compressed; you may decompress one with
```bash
zstd -d qaRaw.table.txt.zst
```
A SHA-256 checksum of the original uncompressed table is provided, if you want to validate that nothing went wrong in
compression or transmission:
```bash
sha256sum -c qaRaw.table.txt.sha256
```
It will say "OK" upon success or "FAILED" upon failure.

| Dataset | Table | Columns | Checksum |
| --- | --- | --- | --- |''' > $rawindex
for dataset in ${datasets[@]}; do
  echo "| \`$dataset\` | [Table]($dataset/qaRaw.table.txt.zst) | [Columns]($dataset/qaRaw.columns.md) | [Checksum]($dataset/qaRaw.table.txt.sha256) |" >> $rawindex
done

# make tables for each dataset
table_jobs=$QADB/docs/tables/make.sh
> $table_jobs
for dataset in ${datasets[@]}; do
  echo "$QADB/util/docs/makeAllTables.sh $dataset $DOCDIR" >> $table_jobs
done
parallel -j $num_threads --line-buffer --tagstring "(job{#})>>>" {} 2>&1 :::: $table_jobs 2>&1
rm $table_jobs

# done
echo """
DONE: populated $DOCDIR

Now run 'zensical serve' from the top-level QADB directory.
"""
