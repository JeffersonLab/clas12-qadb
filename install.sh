#!/usr/bin/env bash
set -euo pipefail

# parse arguments
clean=false
if [ $# -ge 1 ]; then
  [ "$1" = "clean" ] && clean=true
fi

# print status message
message() {
  echo -e "\e[1;35m[+] $* \e[0m"
}

# run make
build() {
  $clean && make clean -C $1
  make -C $1
}

##################################################################################

message "set environment"
cd $(dirname "${BASH_SOURCE[0]}")
source environ.sh
echo "QADB=$QADB"

message "install rapidjson"
git submodule update --init --recursive

message "build C++ tests"
build srcC/tests

message "build utilities"
build util

message "done"
echo "Installed to $QADB"
