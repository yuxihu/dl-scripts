#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    >&2 echo "Usage: source set_environment.sh <VARIANT>[CPU|MKL|CU75|CU80|CU90|CU91|CU92|CU100|CU75MKL|CU80MKL|CU90MKL|CU91MKL|CU92MKL|CU100MKL]"
fi
echo $PWD
export DEPS_PATH=$PWD/deps
export SCRIPT_PATH=$PWD/scripts
export VARIANT=$(echo $1 | tr '[:upper:]' '[:lower:]')
export PLATFORM=$(uname | tr '[:upper:]' '[:lower:]')

# Build tool variables
NUM_PROC=1
if [[ ! -z $(command -v nproc) ]]; then
    NUM_PROC=$(nproc)
elif [[ ! -z $(command -v sysctl) ]]; then
    NUM_PROC=$(sysctl -n hw.ncpu)
else
    >&2 echo "Can't discover number of cores."
fi
export NUM_PROC
>&2 echo "Using $NUM_PROC parallel jobs in building."

if [[ $DEBUG -eq 1 ]]; then
    export ADD_MAKE_FLAG="-j $NUM_PROC"
else
    export ADD_MAKE_FLAG="--quiet -j $NUM_PROC"
    export ADD_CMAKE_FLAG="-q"
fi
export MAKE="make $ADD_MAKE_FLAG"
export CMAKE="cmake $ADD_CMAKE_FLAG"
export CC="gcc -fPIC"
export CXX="g++ -fPIC"
export FC="gfortran"
export CCACHE_MAXSIZE=20G
export CCACHE_CPP2=true
export CCACHE_HARDLINK=true
export CCACHE_SLOPPINESS=file_macro,time_macros,include_file_mtime,include_file_ctime,file_stat_matches


export PKG_CONFIG_PATH=$DEPS_PATH/lib/pkgconfig:$DEPS_PATH/lib64/pkgconfig:$DEPS_PATH/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
export CPATH=$DEPS_PATH/include:$CPATH

function build_dependencies() { source scripts/build_dependencies.sh; }
function build_modules() { source scripts/build_dependencies.sh && scripts/build_modules.sh; }
function build_lib() { source scripts/build_dependencies.sh && scripts/build_modules.sh && scripts/build_lib.sh; }
function all_steps() {
    source scripts/build_dependencies.sh && scripts/build_modules.sh && scripts/build_lib.sh;
    if [[ ! $DEPENDENCIES_ONLY == true ]]; then
        scripts/build_wheel.sh && scripts/deploy.sh;
    fi
}

env
