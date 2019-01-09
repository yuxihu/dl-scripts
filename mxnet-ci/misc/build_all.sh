#!/bin/bash

cd ~/mxnet-distro
git pull --rebase

source ~/clean_env.sh
export mxnet_variant=CU80
source scripts/set_environment.sh $mxnet_variant
rm -rf ~/.mxnet/{mxnet,dmlc-core,nnvm}
all_steps
git clean -ff -d -x --exclude=deps/lib --exclude=deps/include --exclude=deps/usr --exclude=deps/bin --exclude=deps/licenses

source ~/clean_env.sh
export mxnet_variant=CU80MKL
source scripts/set_environment.sh $mxnet_variant
rm -rf ~/.mxnet/{mxnet,dmlc-core,nnvm}
all_steps
git clean -ff -d -x --exclude=deps/lib --exclude=deps/include --exclude=deps/usr --exclude=deps/bin --exclude=deps/licenses

source ~/clean_env.sh
export mxnet_variant=CU90
source scripts/set_environment.sh $mxnet_variant
rm -rf ~/.mxnet/{mxnet,dmlc-core,nnvm}
all_steps
git clean -ff -d -x --exclude=deps/lib --exclude=deps/include --exclude=deps/usr --exclude=deps/bin --exclude=deps/licenses

source ~/clean_env.sh
export mxnet_variant=CU90MKL
source scripts/set_environment.sh $mxnet_variant
rm -rf ~/.mxnet/{mxnet,dmlc-core,nnvm}
all_steps
git clean -ff -d -x --exclude=deps/lib --exclude=deps/include --exclude=deps/usr --exclude=deps/bin --exclude=deps/licenses

source ~/clean_env.sh
export mxnet_variant=CU92
source scripts/set_environment.sh $mxnet_variant
rm -rf ~/.mxnet/{mxnet,dmlc-core,nnvm}
all_steps
git clean -ff -d -x --exclude=deps/lib --exclude=deps/include --exclude=deps/usr --exclude=deps/bin --exclude=deps/licenses

source ~/clean_env.sh
export mxnet_variant=CU92MKL
source scripts/set_environment.sh $mxnet_variant
rm -rf ~/.mxnet/{mxnet,dmlc-core,nnvm}
all_steps
git clean -ff -d -x --exclude=deps/lib --exclude=deps/include --exclude=deps/usr --exclude=deps/bin --exclude=deps/licenses

source ~/clean_env.sh
export mxnet_variant=CU100
source scripts/set_environment.sh $mxnet_variant
rm -rf ~/.mxnet/{mxnet,dmlc-core,nnvm}
all_steps
git clean -ff -d -x --exclude=deps/lib --exclude=deps/include --exclude=deps/usr --exclude=deps/bin --exclude=deps/licenses

source ~/clean_env.sh
export mxnet_variant=CU100MKL
source scripts/set_environment.sh $mxnet_variant
rm -rf ~/.mxnet/{mxnet,dmlc-core,nnvm}
all_steps
git clean -ff -d -x --exclude=deps/lib --exclude=deps/include --exclude=deps/usr --exclude=deps/bin --exclude=deps/licenses

