export TRT_VERSION=7.9.0.0
export TF_TENSORRT_VERSION=7.9.0.0
export TRT=/trt-home/trt-master
export TENSORRT_INSTALL_PATH=$TRT/build/tensorrt-base-dev/master-native-x86_64-ubuntu18.04-cuda11.1/x86_64-gnu/
cp $TRT/include/* $TENSORRT_INSTALL_PATH/
