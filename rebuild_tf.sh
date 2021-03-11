#!/bin/bash

BAZEL_VERSION=$(bazel version | grep 'Build label:' | sed 's/^.*: //')
echo "Bazel Version: $BAZEL_VERSION"

if [[ ${HOST_IP_ADDRESS} == 192.168.1.* ]]; then
    echo "Deactivate Bazel Cache ...";
    BAZEL_CACHE_FLAG="";
else
    echo "Activate Bazel Cache ...";
    BAZEL_CACHE_FLAG="--bazel-cache";
fi
sleep 2

if [[ "$1" == "--clean" ]]; then
    echo "Clearing build artifacts and cache... Building from scratch"
  	rm -rf /root/.cache/bazel/*
  	rm -f .tf_configure.bazelrc
  	rm -f bazel-*
fi

PYVER=$(python -c 'import sys; print("{}.{}".format(sys.version_info[0], sys.version_info[1]))')

if [[ ! -f ".tf_configure.bazelrc" ]]; then
    echo "Generating a fresh bazel configuration ..."
    /opt/tensorflow/nvbuild.sh --configonly --python$PYVER --v2
fi

if ! grep -Fxq "startup --max_idle_secs=0" .tf_configure.bazelrc; then
  echo "$(printf '\n'; cat .tf_configure.bazelrc)" > .tf_configure.bazelrc
  echo "$(printf 'startup --max_idle_secs=0\n'; cat .tf_configure.bazelrc)" > .tf_configure.bazelrc
  echo "$(printf '# Prevent cache from being invalidated after 3 hours\n'; cat .tf_configure.bazelrc)" > .tf_configure.bazelrc
fi

echo "Building Tensorflow ..."
sleep 5
/opt/tensorflow/nvbuild.sh --noconfig --noclean --python$PYVER --v2 ${BAZEL_CACHE_FLAG}
# /opt/tensorflow/nvbuild.sh --noconfig --noclean --python$PYVER --v1 ${BAZEL_CACHE_FLAG}

mkdir -p build && cp /tmp/pip/*.whl build/
