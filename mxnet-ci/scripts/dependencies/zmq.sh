#!/usr/bin/env bash
set -eo pipefail

ZEROMQ_VERSION=4.2.2
if [[ ! -f $DEPS_PATH/lib/libzmq.a ]]; then
    # Download and build zmq
    >&2 echo "Building zmq..."
    curl -s -L https://github.com/zeromq/libzmq/archive/v$ZEROMQ_VERSION.zip -o $DEPS_PATH/zeromq.zip
    unzip -q $DEPS_PATH/zeromq.zip -d $DEPS_PATH
    mkdir -p $DEPS_PATH/libzmq-$ZEROMQ_VERSION/build
    cd $DEPS_PATH/libzmq-$ZEROMQ_VERSION/build
    $CMAKE \
          -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=$DEPS_PATH \
          -D WITH_LIBSODIUM=OFF \
          -D BUILD_SHARED_LIBS=OFF ..
    $MAKE
    $MAKE install
    set +e
    cp $DEPS_PATH/lib/x86_64-linux-gnu/libzmq.a $DEPS_PATH/lib/libzmq.a
    set -e
    cd -
fi
