#!/usr/bin/env bash
make_config=config/pip_${PLATFORM}_${VARIANT}.mk
if [[ ! -f $make_config ]]; then
    >&2 echo "Couldn't find make config $make_config for the current settings."
    exit 1
fi

# If a travis build is from a tag, use this tag for fetching the corresponding release
if [[ ! -z $TRAVIS_TAG ]]; then
    GIT_ADDITIONAL_FLAGS="-b $(echo $TRAVIS_TAG | sed 's/^patch-[^-]*-//g')"
fi

rm -rf mxnet-build
git clone --recursive https://github.com/dmlc/mxnet mxnet-build $GIT_ADDITIONAL_FLAGS
DMLC_CORE_COMMIT=$(cd mxnet-build/3rdparty/dmlc-core; git rev-parse HEAD)
NNVM_COMMIT=$(cd mxnet-build/3rdparty/tvm/nnvm; git rev-parse HEAD)
PS_COMMIT=$(cd mxnet-build/3rdparty/ps-lite; git rev-parse HEAD)
MKLDNN_COMMIT=$(cd mxnet-build/3rdparty/mkldnn; git rev-parse HEAD)

>&2 echo "Now building mxnet modules..."
cp $make_config mxnet-build/config.mk
cd mxnet-build

if [[ ! -f $HOME/.mxnet/dmlc-core/$DMLC_CORE_COMMIT/libdmlc.a ]]; then
    $MAKE DEPS_PATH=$DEPS_PATH DMLCCORE
    mkdir -p $HOME/.mxnet/dmlc-core/$DMLC_CORE_COMMIT
    cp 3rdparty/dmlc-core/libdmlc.a $HOME/.mxnet/dmlc-core/$DMLC_CORE_COMMIT/
else
    cp $HOME/.mxnet/dmlc-core/$DMLC_CORE_COMMIT/libdmlc.a 3rdparty/dmlc-core/
fi

if [[ ! -f $HOME/.mxnet/nnvm/$NNVM_COMMIT/libnnvm.a ]]; then
    $MAKE DEPS_PATH=$DEPS_PATH $PWD/3rdparty/tvm/nnvm/lib/libnnvm.a
    mkdir -p $HOME/.mxnet/nnvm/$NNVM_COMMIT
    cp 3rdparty/tvm/nnvm/lib/libnnvm.a $HOME/.mxnet/nnvm/$NNVM_COMMIT/
else
    mkdir -p 3rdparty/tvm/nnvm/lib/
    cp $HOME/.mxnet/nnvm/$NNVM_COMMIT/libnnvm.a 3rdparty/tvm/nnvm/lib/
fi

if [[ ! -f $HOME/.mxnet/ps-lite/$PS_COMMIT/libps.a ]]; then
    $MAKE DEPS_PATH=$DEPS_PATH PSLITE
    mkdir -p $HOME/.mxnet/ps-lite/$PS_COMMIT
    cp 3rdparty/ps-lite/build/libps.a $HOME/.mxnet/ps-lite/$PS_COMMIT/
else
    mkdir -p 3rdparty/ps-lite/build/
    cp $HOME/.mxnet/ps-lite/$PS_COMMIT/libps.a 3rdparty/ps-lite/build/
fi

if [[ $VARIANT == *mkl ]]; then
    MKLDNN_LICENSE='license.txt'
    if [[ $PLATFORM == 'linux' ]]; then
        IOMP_LIBFILE='libiomp5.so'
        MKLML_LIBFILE='libmklml_intel.so'
        MKLDNN_LIBFILE='libmkldnn.so.0'
    else
        IOMP_LIBFILE='libiomp5.dylib'
        MKLML_LIBFILE='libmklml.dylib'
        MKLDNN_LIBFILE='libmkldnn.0.dylib'
    fi
    if [[ ! -f $HOME/.mxnet/mkldnn/$MKLDNN_COMMIT/lib/$MKLDNN_LIBFILE ]]; then
        $MAKE DEPS_PATH=$DEPS_PATH mkldnn
        mkdir -p $HOME/.mxnet/mkldnn/$MKLDNN_COMMIT
        cp -r 3rdparty/mkldnn/build/install/* $HOME/.mxnet/mkldnn/$MKLDNN_COMMIT/
    else
        mkdir -p 3rdparty/mkldnn/install
        mkdir -p lib
        cp -r $HOME/.mxnet/mkldnn/$MKLDNN_COMMIT/* 3rdparty/mkldnn/build/install
        cp 3rdparty/mkldnn/build/install/lib/$IOMP_LIBFILE lib
        cp 3rdparty/mkldnn/build/install/lib/$MKLML_LIBFILE lib
        cp 3rdparty/mkldnn/build/install/lib/$MKLDNN_LIBFILE lib
        cp 3rdparty/mkldnn/build/install/$MKLDNN_LICENSE lib
    fi
fi

cd ../
