#!/usr/bin/env bash

GPUS=$(nvidia-smi -L 2>/dev/null| wc -l || echo 1)

if [[ ${HOST_IP_ADDRESS} == 192.168.1.* ]]; then
    echo "Deactivate Bazel Cache ...";
else
    echo "Activate Bazel Cache ...";
    if [[ $(wc -l < ../nvbazelcache) -eq 1 ]]; then
        bazel_cache_flag="$(cat ../nvbazelcache)"
    else
        bazel_cache_flag="$(../nvbazelcache)"  # new behavior
    fi
fi
sleep 2
echo "Bazel Cache Flag: $bazel_cache_flag"

PYVER=$(python -c 'import sys; print("{}.{}".format(sys.version_info[0], sys.version_info[1]))')

if [[ ! -f ".tf_configure.bazelrc" ]]; then
    echo "Generating a fresh bazel configuration ..."
    /opt/tensorflow/nvbuild.sh --configonly --python$PYVER --v2
fi

if ! grep -Fxq "startup --max_idle_secs=0" .tf_configure.bazelrc; then
    echo "$(echo -n '\n'; cat .tf_configure.bazelrc)" > .tf_configure.bazelrc
    echo "$(echo -n 'startup --max_idle_secs=0\n'; cat .tf_configure.bazelrc)" > .tf_configure.bazelrc
    echo "$(echo -n '# Prevent cache from being invalidated after 3 hours\n'; cat .tf_configure.bazelrc)" > .tf_configure.bazelrc
fi

# C++ Unittests
bazel test --verbose_failures $(cat ../nvbuildopts) ${bazel_cache_flag} \
  --cache_test_results=no --local_test_jobs=$GPUS \
  --run_under=//tensorflow/tools/ci_build/gpu_build:parallel_gpu_execute \
  //tensorflow/compiler/tf2tensorrt/...

# Python Unittests
bazel test --verbose_failures $(cat ../nvbuildopts) ${bazel_cache_flag} \
  --cache_test_results=no --local_test_jobs=$GPUS \
  --run_under=//tensorflow/tools/ci_build/gpu_build:parallel_gpu_execute \
  //tensorflow/python/compiler/tensorrt/...
