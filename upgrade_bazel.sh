#!/bin/bash

#BAZEL_VERSION="0.24.1"
# BAZEL_VERSION="1.0.0"
# BAZEL_VERSION="1.0.1"
# BAZEL_VERSION="1.1.0"
# BAZEL_VERSION="1.2.0"
# BAZEL_VERSION="1.2.1"
# BAZEL_VERSION="2.0.0"
# BAZEL_VERSION="2.1.0"
BAZEL_VERSION="3.1.0"

curl https://bazel.build/bazel-release.pub.gpg | apt-key add -
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list

apt update && apt -y install "bazel-${BAZEL_VERSION}"

rm -f /usr/bin/bazel || true
rm -f /usr/local/bin/bazel|| true
ln -s "/usr/bin/bazel-${BAZEL_VERSION}" /usr/bin/bazel

echo "=================================================================="
bazel version

# Restoring Python 3.6 as default
rm -f /usr/bin/python
ln -s /usr/bin/python3.6 /usr/bin/python
