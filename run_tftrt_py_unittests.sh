#!/bin/bash

# Searches for a string (key) in an array of strings
#   1st-arg: key
#   2nd-arg: array of strings
function containsElement {
  local key=$1
  shift
  local list=("$@")
  for l in ${list[@]}; do
    if [[ "$l" == "$key" ]]; then
      echo 1
      return
    fi
  done
  echo 0
}

tests="$(find './tensorflow/python/compiler/tensorrt/test/' -type f -name '*_test.py' | sort)"

# echo tests ${tests[@]}

# Array that specifies which test scripts should not be run.
# We ignore test scripts if running them has no benefit which
# is mostly because of bugs in test scripts.
# Ensure to prepend each test string with ./
#
#./custom_plugin_examples/plugin_test.py
#    It's currently broken. We don't use plugins yet. Once we
#    start using plugins from the registry, then we should
#    write some tests.
#./test/quantization_mnist_test.py
#    It's ignored because it uses data from testdata directory
#    and it's too complicated to set that path of that dir
#    such that it works for both bazel and python.
#./test/dynamic_input_shapes_test.py
#    Currently failing due to TRT caching issue.
#    https://github.com/tensorflow/tensorflow/issues/36675

ignored_tests="
./tensorflow/python/compiler/tensorrt/test/quantization_mnist_test.py
./tensorflow/python/compiler/tensorrt/test/dynamic_input_shapes_test.py
"

# Workaround for TitanV and Pascal.
# See nvbug 200634038.
export TF_DEVICE_MIN_SYS_MEMORY_IN_MB=1536

tmp_logfile="/tmp/tf_trt_test.log"
test_count=0
retval=0

for test_script in $tests; do
    found=$(containsElement $test_script ${ignored_tests[@]})
    if [ $found = "1" ]; then
        echo "Running $test_script ... [IGNORED]"
    else
      echo -ne "Running $test_script ...\r"
      if ! python -u $test_script >& $tmp_logfile ; then
          echo -ne "Running $test_script ... [FAILURE]\r"
          echo ""
          cat $tmp_logfile
          retval=$(expr $retval + 1)
      else
          echo -ne "Running $test_script ... [SUCCESS]\r"
          echo ""
      fi
      test_count=$(expr $test_count + 1)
    fi
done

rm -f $tmp_logfile

if [ "$retval" == "0" ] ; then
    echo "All $test_count tests PASSED"
else
    echo "$retval / $test_count tests FAILED"
fi

exit $retval
