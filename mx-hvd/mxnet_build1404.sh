#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Install required cmake version
apt-get update
apt-get install -y software-properties-common
add-apt-repository -y ppa:george-edison55/cmake-3.x
apt-get update
apt-get install -y cmake

# Install required libraries
apt-get install -y --no-install-recommends \
	vim \
	wget \
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
	nasm \
	zlib1g-dev \
	gfortran \
	libopencv-dev \
	libopenblas-dev \
	liblapack-dev \
	pandoc
pip install numpy pypandoc twine

