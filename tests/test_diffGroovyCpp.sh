#!/bin/bash
# run test program to cross check groovy and c++ readers

set -e

if [ -z "$QADB" ]; then
  echo "ERROR: you must source environ.sh first"
  exit 1
fi

cook=latest
if [ $# -lt 2 ]; then
  echo """
USAGE: $0 [test name] [run number or list] [cook(default=$cook)]

- [test name] can be any of:
$(ls src/tests | sed 's/^test//' | sed 's/\.groovy$//')

- [run number or list] is a run number or list of run numbers
  (depends on the test)
  """
  exit 2
fi

testname=$1
run=$2
[ $# -ge 3 ] && cook=$3

mkdir -p ${QADB}/tmp

runSuffix=$(echo $run | sed 's;/;.;g')

# groovy test
echo "EXECUTE GROOVY TEST $testname FOR $run"
pushd ${QADB}/src/tests
groovy -cp "$JYPATH" test${testname}.groovy $run $cook | tee ${QADB}/tmp/groovy.${runSuffix}.out
popd

# c++ test
echo "EXECUTE C++ TEST $testname FOR $run"
pushd ${QADB}/srcC/tests
./test${testname}.exe $run $cook | tee ${QADB}/tmp/cpp.${runSuffix}.out
popd

# compare
echo "DIFFERENCE:"
diff ${QADB}/tmp/{cpp,groovy}.${runSuffix}.out
exit $?
