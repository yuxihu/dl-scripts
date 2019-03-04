#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    >&2 echo "Usage: buildmx.sh <VARIANT>"
fi

# Build MXNet shared library
export mxnet_variant=$(echo $1 | tr '[:upper:]' '[:lower:]')
cd mxnet-build
source tools/staticbuild/build.sh $mxnet_variant pip

# Build wheel
echo $(git rev-parse HEAD) >> python/mxnet/COMMIT_HASH
cd -

python setup.py bdist_wheel
wheel_name=$(ls -t dist | head -n 1)