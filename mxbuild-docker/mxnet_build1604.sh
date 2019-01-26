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

# Init git
cd /mxbuild/mxnet-ci
git init
git config --global user.email "darrenyxhu@gmail.com"
git config --global user.name "Yuxi Hu"
git add *
git commit -m "initial commit"

# Downloand dependency library
mkdir -p deps && cd deps
S3_PREFIX="https://s3.amazonaws.com/hyuxi-mxnet/mxnet-deps-lib/1604"
OPENBLAS_VERSION="0.3.2"
ZLIB_VERSION="1.2.6"
TURBO_JPEG_VERSION="1.5.90"
PNG_VERSION="1.6.34"
TIFF_VERSION="4-0-9"
OPENSSL_VERSION="1_0_2l"
LIBCURL_VERSION="7_61_0"
EIGEN_VERSION="3.3.4"
OPENCV_VERSION="3.4.2"
PROTOBUF_VERSION="3.5.1"
CITYHASH_VERSION="1.1.1"
ZEROMQ_VERSION="4.2.2"
LZ4_VERSION="r130"
curl ${S3_PREFIX}/zlib-${ZLIB_VERSION}.tar.gz | tar xvz
curl ${S3_PREFIX}/libjpeg-turbo-${TURBO_JPEG_VERSION}.tar.gz | tar xvz
curl ${S3_PREFIX}/libpng-${PNG_VERSION}.tar.gz | tar xvz
curl ${S3_PREFIX}/libtiff-${TIFF_VERSION}.tar.gz | tar xvz
curl ${S3_PREFIX}/openssl-${OPENSSL_VERSION}.tar.gz | tar xvz
curl ${S3_PREFIX}/curl-${LIBCURL_VERSION}.tar.gz | tar xvz
curl ${S3_PREFIX}/eigen-${EIGEN_VERSION}.tar.gz | tar xvz
curl ${S3_PREFIX}/opencv-${OPENCV_VERSION}.tar.gz | tar xvz
curl ${S3_PREFIX}/protobuf-${PROTOBUF_VERSION}.tar.gz | tar xvz
curl ${S3_PREFIX}/cityhash-${CITYHASH_VERSION}.tar.gz | tar xvz
curl ${S3_PREFIX}/libzmq-${ZEROMQ_VERSION}.tar.gz | tar xvz
curl ${S3_PREFIX}/lz4-${LZ4_VERSION}.tar.gz | tar xvz
curl ${S3_PREFIX}/OpenBLAS-${OPENBLAS_VERSION}.tar.gz | tar xvz

# Update gcc version
sed -i 's/4.8/5.4.0/' /mxbuild/mxnet-ci/scripts/build_lib.sh

