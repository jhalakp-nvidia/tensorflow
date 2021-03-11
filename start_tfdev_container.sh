#!/bin/bash

CONTAINER="gitlab-master.nvidia.com:5005/dl/dgx/tensorflow:master-py3-base"

if [[ "$1" == "--pull" ]]; then
    docker pull ${CONTAINER}
fi

if [[ ! -z "${CONTAINER_NAME}" ]]; then
  CONTAINER_NAME_FLAG="--name ${CONTAINER_NAME}"
else
  CONTAINER_NAME_FLAG=""
fi
echo "CONTAINER_NAME_FLAG: ${CONTAINER_NAME_FLAG}"

docker run -it --rm --network=host \
    --gpus 2 \
    --shm-size=2g --ulimit memlock=-1 --ulimit stack=67108864 \
    --workdir /opt/tensorflow/tensorflow-source/ \
    -e HOST_IP_ADDRESS="$(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}' | tail -n1)" \
    -v "$(pwd):/opt/tensorflow/tensorflow-source/" \
    -v "${RAID_STORAGE_PATH}/build_cache/$(git rev-parse --abbrev-ref HEAD):/root/.cache/bazel" \
    ${CONTAINER_NAME_FLAG} \
    ${CONTAINER}

# docker run -it --rm --network=host \
#     --gpus="device=1" \
#     --shm-size=2g --ulimit memlock=-1 --ulimit stack=67108864 \
#     --workdir /opt/tensorflow/tensorflow-source/ \
#     -e HOST_IP_ADDRESS="$(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}' | tail -n1)" \
#     -v "$(pwd):/opt/tensorflow/tensorflow-source/" \
#     -v "${RAID_STORAGE_PATH}/build_cache/$(git rev-parse --abbrev-ref HEAD):/root/.cache/bazel" \
#    ${CONTAINER_NAME_FLAG} \
#     ${CONTAINER}
