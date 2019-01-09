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

# assuming already checked out in previous step
# rm -rf mxnet-build
# git clone --recursive https://github.com/dmlc/mxnet mxnet-build $GIT_ADDITIONAL_FLAGS
MXNET_COMMIT=$(cd mxnet-build; git rev-parse HEAD)

>&2 echo "Now building mxnet..."
cp $make_config mxnet-build/config.mk
cd mxnet-build

if [[ ! -f $HOME/.mxnet/mxnet/$MXNET_COMMIT/libmxnet.a ]] || [[ ! -f $HOME/.mxnet/mxnet/$MXNET_COMMIT/libmxnet.so ]]; then
    $MAKE DEPS_PATH=$DEPS_PATH || exit 1;
    mkdir -p $HOME/.mxnet/mxnet/$MXNET_COMMIT
    cp lib/libmxnet.a $HOME/.mxnet/mxnet/$MXNET_COMMIT/
    cp lib/libmxnet.so $HOME/.mxnet/mxnet/$MXNET_COMMIT/
else
    mkdir -p lib
    cp $HOME/.mxnet/mxnet/$MXNET_COMMIT/libmxnet.a lib
    cp $HOME/.mxnet/mxnet/$MXNET_COMMIT/libmxnet.so lib
fi

# copy lapack dependencies
if [[ $PLATFORM == 'linux' ]]; then
    cp -L /usr/lib/gcc/x86_64-linux-gnu/4.8/libgfortran.so lib/libgfortran.so.3
    cp -L /usr/lib/x86_64-linux-gnu/libquadmath.so.0 lib/libquadmath.so.0
fi

if [[ $VARIANT == *mkl ]]; then
    >&2 echo "Copying MKL license."
    cp 3rdparty/mkldnn/LICENSE ./MKLML_LICENSE
    rm lib/libmkldnn.{so,dylib}
    rm lib/libmkldnn.0.*.dylib
    rm lib/libmkldnn.so.0.*
fi

# Print the linked objects on libmxnet.so
>&2 echo "Checking linked objects on libmxnet.so..."
if [[ ! -z $(command -v readelf) ]]; then
    readelf -d lib/libmxnet.so
    strip --strip-unneeded lib/libmxnet.so
elif [[ ! -z $(command -v otool) ]]; then
    otool -L lib/libmxnet.so
    strip -u -r -x lib/libmxnet.so
else
    >&2 echo "Not available"
fi

echo "Libraries in lib path"
ls -al lib

cd ../
