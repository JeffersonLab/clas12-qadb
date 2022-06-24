#!/bin/bash

if [ -z "${BASH_SOURCE[0]}" ]; then
  export QADB=$(dirname $(realpath $0))
else
  export QADB=$(dirname $(realpath ${BASH_SOURCE[0]}))
fi

JYPATH="${JYPATH}:${QADB}/src/"
export JYPATH=$(echo $JYPATH | sed 's/^://')

env|grep --color -w QADB
env|grep --color -w JYPATH
echo "---"
ls $QADB
echo "---"
