FROM apicciau/opencl_ubuntu
LABEL maintainer="andrea@picciau.net"

RUN apt-get update -y -q \
  && apt-get upgrade -y -q \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
    cmake \
    googletest \
    clinfo \
    ocl-icd-opencl-dev \
    ocl-icd-libopencl1