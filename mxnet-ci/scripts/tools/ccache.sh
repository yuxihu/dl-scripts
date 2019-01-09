#!/usr/bin/env bash
set -eo pipefail

CCACHE_VERSION=3.4.3

if [[ ! -d $HOME/ccache ]]; then
    DIR=$PWD
    # download ccache
    >&2 echo "Loading ccache..."
    mkdir -p $HOME/ccache
    cd $HOME/ccache
    curl -s -L https://www.samba.org/ftp/ccache/ccache-$CCACHE_VERSION.tar.gz -o $HOME/ccache/ccache.tar.gz
    tar -xzf ccache.tar.gz
    cd ccache-$CCACHE_VERSION
    ./configure -q --prefix $HOME/ccache/
    $MAKE
    $MAKE install
    cd $DIR
fi
export PATH=$HOME/ccache/bin:$PATH
export CCACHE=$HOME/ccache/bin/ccache
export CC="$CCACHE $CC"
export CXX="$CCACHE $CXX"
export FC="$CCACHE $FC"
export NVCC="$CCACHE $NVCC"
