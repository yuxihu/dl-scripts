#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

if [[ $(grep jessie /etc/os-release) ]]; then
    echo deb http://deb.debian.org/debian jessie-backports main >> /etc/apt/sources.list 	
fi

# Install necessary network tools
apt-get update
apt-get install -y --no-install-recommends \
	vim \
	wget \
	openssh-client \
	git \
	build-essential \
	ca-certificates

if [[ $(grep jessie /etc/os-release) ]]; then
    apt install -t jessie-backports -y openjdk-8-jdk-headless
else
    apt install -y openjdk-8-jdk-headless
fi

# Install the python version you like to test with: 2.7, 3.5,3.6
if [[ $(grep jessie /etc/os-release) ]]; then
    apt-get install -y python2.7 python2.7-dev
    ln -s /usr/bin/python2.7 /usr/bin/python
fi

if [[ $(grep stretch /etc/os-release) ]]; then
    apt-get install -y python3.5 python3.5-dev
    ln -s /usr/bin/python3.5 /usr/bin/python
fi

if [[ $(grep buster /etc/os-release) ]]; then
    apt-get install -y python3.6 python3.6-dev python3-distutils
    ln -s /usr/bin/python3.6 /usr/bin/python
fi

wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py && rm get-pip.py
pip install -U --force pip setuptools requests

# Install OpenMPI
wget -O /tmp/openmpi-3.0.0-bin.tar.gz https://github.com/uber/horovod/files/1596799/openmpi-3.0.0-bin.tar.gz
cd /usr/local && tar -zxf /tmp/openmpi-3.0.0-bin.tar.gz && ldconfig
rm -f /tmp/openmpi-3.0.0-bin.tar.gz

# Install pytest
pip install pytest

