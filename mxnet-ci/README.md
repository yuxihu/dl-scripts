MXNet Python Package
====================
[![Nightly Build Status](https://travis-ci.com/dmlc/mxnet-distro.svg?token=bTKzx7LfqrhHk24rGvWK&branch=master)](https://travis-ci.com/dmlc/mxnet-distro)

MXNet is a deep learning framework designed for both *efficiency* and *flexibility*.
It allows you to mix the flavours of deep learning programs together to maximize the efficiency and your productivity.


Build Process
-------------
1. Set environment
```bash
export mxnet_variant={CPU,CU75,CU80,CU90,CU91,CU92,MKL,CU75MKL,CU80MKL,CU90MKL,CU91MKL,CU92MKL}
source scripts/set_environment.sh $mxnet_variant
```

2. Start build for lib
```bash
build_lib
```

3. Release
In step 1., also do:
```bash
export TRAVIS_TAG=1.3.0
# or export TRAVIS_TAG=patch-1.3.0.post0-v1.3.0 to use v1.3.0 branch to issue post-release
```

4. Debug
To enable verbose output, in step 1. do:
```
export DEBUG=1
```

5. Nightly
The scripts respond to `TRAVIS_EVENT_TYPE=cron`, which is set by Travis-CI automatically.
