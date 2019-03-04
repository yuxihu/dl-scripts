FROM ubuntu:16.04

WORKDIR /build

ARG S3_PREFIX=https://s3-us-west-2.amazonaws.com/mxnet-python-packages-gcc5/mxnet-deps-lib/1604

# Install required libraries
RUN apt-get update && apt-get install -y \
    vim \
    git \
    curl \
    wget \
    unzip \
    cmake \
    python \
    python-dev \
    python3 \
    python3-dev \
    gfortran \
    pkg-config \
    pandoc

# Install pip
RUN wget -q https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    python2 get-pip.py && \
    rm get-pip.py

# Install pip packages
RUN pip install numpy wheel pypandoc

# Download mxnet
RUN git clone --recursive https://github.com/apache/incubator-mxnet.git mxnet-build

# Update gcc version
RUN cd mxnet-build && \
    sed -i 's/4.8/5.4.0/' tools/staticbuild/build_lib.sh

# Downloand dependency library
RUN cd mxnet-build && \
    mkdir -p staticdeps && \
    cd staticdeps && \
    curl ${S3_PREFIX}/zlib-1.2.6.tar.gz | tar xvz && \
    curl ${S3_PREFIX}/libjpeg-turbo-1.5.90.tar.gz | tar xvz && \
    curl ${S3_PREFIX}/libpng-1.6.34.tar.gz | tar xvz && \
    curl ${S3_PREFIX}/libtiff-4-0-9.tar.gz | tar xvz && \
    curl ${S3_PREFIX}/openssl-1_0_2l.tar.gz | tar xvz && \
    curl ${S3_PREFIX}/curl-7_61_0.tar.gz | tar xvz && \
    curl ${S3_PREFIX}/eigen-3.3.4.tar.gz | tar xvz && \
    curl ${S3_PREFIX}/opencv-3.4.2.tar.gz | tar xvz && \
    curl ${S3_PREFIX}/protobuf-3.5.1.tar.gz | tar xvz && \
    curl ${S3_PREFIX}/cityhash-1.1.1.tar.gz | tar xvz && \
    curl ${S3_PREFIX}/libzmq-4.2.2.tar.gz | tar xvz && \
    curl ${S3_PREFIX}/lz4-r130.tar.gz | tar xvz && \
    curl ${S3_PREFIX}/OpenBLAS-0.3.2.tar.gz | tar xvz

COPY MANIFEST.in /build
COPY setup.py /build
COPY buildmx.sh /build
RUN chmod +x /build/buildmx.sh
