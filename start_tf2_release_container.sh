#!/bin/bash

TFTRT=/home/jhalakp/dev/tftrt
TF2_RELEASE=21.02-tf2-py3
CONTAINER=${TF2_RELEASE}
docker pull nvcr.io/nvidia/tensorflow:${CONTAINER}

docker run -it --rm --gpus 0 \
    --shm-size=2g --ulimit memlock=-1 --ulimit stack=67108864 \
    --workdir /opt/tensorflow/tensorflow-source/ \
    -e HOST_IP_ADDRESS="$(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}' | tail -n1)" \
    --cap-add=SYS_ADMIN \
    --device /dev/fuse \
    --security-opt apparmor:unconfined \
    -v "/home/jhalakp/trt-home/:/trt-home/" \
    -v "$(pwd):/opt/tensorflow/tensorflow-source/" \
    -v "${TFTRT}/tf_cache/$(git rev-parse --abbrev-ref HEAD):/root/.cache/bazel" \
    -v "${TFTRT}/debug:/opt/tensorflow/debug/" \
    nvcr.io/nvidia/tensorflow:${CONTAINER}
