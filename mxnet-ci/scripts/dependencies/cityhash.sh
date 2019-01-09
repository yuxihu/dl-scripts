#!/usr/bin/env bash
set -eo pipefail

CITYHASH_VERSION=1.1.1
if [[ ! -f $DEPS_PATH/lib/libcityhash.a ]]; then
    # Download and build cityhash
    >&2 echo "Building cityhash..."
    git clone https://github.com/google/cityhash $DEPS_PATH/cityhash-$CITYHASH_VERSION
    cd $DEPS_PATH/cityhash-$CITYHASH_VERSION
    git reset --hard 8af9b8c2b889d80c22d6bc26ba0df1afb79a30db
    ./configure -prefix=$DEPS_PATH --enable-sse4.2
    $MAKE CXXFLAGS="-g -O3 -msse4.2"
    $MAKE install
    cd -
fi
