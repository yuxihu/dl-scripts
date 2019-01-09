#!/usr/bin/env bash
set -eo pipefail

LZ4_VERSION=r130
if [[ ! -f $DEPS_PATH/lib/liblz4.a ]]; then
    # Download and build lz4
    >&2 echo "Building lz4..."
    curl -s -L https://github.com/lz4/lz4/archive/$LZ4_VERSION.zip -o $DEPS_PATH/lz4.zip
    unzip -q $DEPS_PATH/lz4.zip -d $DEPS_PATH
    cd $DEPS_PATH/lz4-$LZ4_VERSION
    $MAKE
    $MAKE PREFIX=$DEPS_PATH install
    cd -
fi
