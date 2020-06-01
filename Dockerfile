FROM ubuntu:latest
LABEL maintainer="andrea@picciau.net"

ENV DEBIAN_FRONTEND noninteractive

# Update and install build-essential
RUN apt-get update -q \
    && apt-get upgrade -yq \
    && apt-get install -yq \
        alien \
        build-essential \
        cmake \
        git \
        lcov \
        libgtest-dev \
        libnuma-dev \
        lsb-core \
        mlocate \
        oclgrind \
        opencl-headers \
        unzip \
        valgrind \
        wget

# Install some packages without dependencies
RUN cd /tmp \
    && apt-get download \
        clinfo \
        mesa-common-dev \
    && dpkg --force-all -i *.deb

# Clean the cache
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Compiling Google Test
RUN cd /usr/src/gtest \
    && cmake CMakeLists.txt \
    && make \
    && find . -name "*.a" -exec mv {} /usr/lib/ \;

# Download the Intel OpenCL CPU runtime and convert to .deb packages
RUN export RUNTIME_URL="http://registrationcenter-download.intel.com/akdlm/irc_nas/vcp/15532/l_opencl_p_18.1.0.015.tgz" \
    && export TAR=$(basename ${RUNTIME_URL}) \
    && export DIR=$(basename ${RUNTIME_URL} .tgz) \
    && wget -q ${RUNTIME_URL} \
    && tar -xf ${TAR} \
    && for i in ${DIR}/rpm/*.rpm; do alien --to-deb $i; done \
    && rm -rf ${DIR} ${TAR} \
    && dpkg -i *.deb \
    && rm *.deb

# Register Intel OpenCL SDK
RUN export INTEL_OCL_LIB="/opt/intel/opencl_compilers_and_libraries_18.1.0.015/linux/compiler/lib/intel64_lin" \
    && mkdir -p /etc/OpenCL/vendors/ \
    && echo "${INTEL_OCL_LIB}/libintelocl.so" > /etc/OpenCL/vendors/intel.icd \
    && ln -sf ${INTEL_OCL_LIB}/* /usr/lib/

# Check that clinfo works
RUN ldd $(which clinfo) \
    && valgrind $(which clinfo)