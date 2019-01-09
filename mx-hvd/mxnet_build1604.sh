#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Install required libraries
apt-get update
apt-get install -y --no-install-recommends \
	vim \
	wget \
	cmake \
	python \
	python3 \
	build-essential \
	unzip \
	git \
	curl \
	python-pip \
	python-dev \
	python3-pip \
	python3-dev \
	python-setuptools \
	nasm \
	zlib1g-dev \
	gfortran \
	libopencv-dev \
	libopenblas-dev \
	liblapack-dev \
	libssl-dev \
	pandoc
pip install numpy wheel pypandoc twine

# Update gcc version
sed -i 's/4.8/5.4.0/' /mxbuild/mxnet-distro/scripts/build_lib.sh

