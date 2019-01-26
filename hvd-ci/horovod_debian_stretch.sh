#!/usr/bin/env bash
set -e

docker run debian:stretch /bin/sh -c "sleep 3600" &
sleep 5
export CONTAINER=$(docker ps -q | head -n 1)

docker exec ${CONTAINER} /bin/sh -c "apt-get update -qq"
docker exec ${CONTAINER} /bin/sh -c "apt-get install -y wget openssh-client git build-essential"
docker exec ${CONTAINER} /bin/sh -c "apt-get install -y libopenblas-dev libopencv-dev"

docker exec ${CONTAINER} /bin/sh -c "apt-get install -y python3.5 python3.5-dev"
docker exec ${CONTAINER} /bin/sh -c "ln -sf /usr/bin/python3.5 /usr/bin/python"
docker exec ${CONTAINER} /bin/sh -c "wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py && rm get-pip.py"
docker exec ${CONTAINER} /bin/sh -c "pip install -U --force pip setuptools requests"

docker exec ${CONTAINER} /bin/sh -c "wget -O /tmp/openmpi-3.0.0-bin.tar.gz https://github.com/uber/horovod/files/1596799/openmpi-3.0.0-bin.tar.gz"
docker exec ${CONTAINER} /bin/sh -c "cd /usr/local && tar -zxf /tmp/openmpi-3.0.0-bin.tar.gz && ldconfig"

docker exec ${CONTAINER} /bin/sh -c "git clone --recursive https://github.com/apache/incubator-mxnet.git mxnet"
docker exec ${CONTAINER} /bin/sh -c "cd /mxnet && cp make/config.mk ./ && sed -i 's/atlas/openblas/' config.mk && make --quiet -j $(nproc)"
docker exec ${CONTAINER} /bin/sh -c "cd /mxnet && pip install -e python"

