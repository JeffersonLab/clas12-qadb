#!/bin/bash
# print out text file tables in `text/`
if [ -z "$QADB" ]; then
  echo "ERROR: you must source env.sh first"; exit
fi

# run groovy script $1, filter out header lines, redirect to output file $2
function exe() {
  printf "\n\nEXECUTING $1 ...\n\n"
  run-groovy $1
  printf "\nPRODUCED $(ls -t text/*|head -n1)\n\n"
}

# format text file
function col() {
  column -t $1 > $1.tmp
  mv $1{.tmp,}
}

# execution
exe util/printGoldenRuns.groovy
exe util/printGoldenFiles.groovy
exe util/printSummary.groovy

# re-format
col text/summary.txt
