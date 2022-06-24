#!/bin/bash
# loop over runs in specified dataset, running test_diffGroovyCpp.sh on each run

if [ -z "$QADB" ]; then
  echo "ERROR: you must source env.sh first"; exit
fi

if [ $# -lt 1 ]; then
  echo "USAGE: $0 [dataset]"; exit
fi

dataset=$1

grep -E '^RUN: ' ${QADB}/qadb/qa.${dataset}/qaTree.json.table | \
awk '{print $2}' > ${QADB}/tmp/runlist.${dataset}

while read run; do
  ${QADB}/util/test_diffGroovyCpp.sh 2 $run 1
done < ${QADB}/tmp/runlist.${dataset}
