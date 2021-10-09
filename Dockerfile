FROM ubuntu:bionic as builder

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
            autoconf automake \
            autotools-dev curl git python3 \
            libmpc-dev libmpfr-dev \
            libgmp-dev gawk \
            build-essential bison flex \
            texinfo gperf libtool \
            patchutils bc zlib1g-dev \
            libexpat-dev && \
     rm -rf /var/lib/apt/lists/*

WORKDIR /

# RUN git clone --depth 1 --shallow-submodules --recursive https://github.com/riscv/riscv-gnu-toolchain
# See https://github.com/riscv-collab/riscv-gnu-toolchain/issues/652#issuecomment-748411101 for why we are doing this to reduce size.
RUN git clone https://github.com/riscv/riscv-gnu-toolchain.git

WORKDIR /riscv-gnu-toolchain

RUN flock $(git rev-parse --git-dir)/config git submodule init '/riscv-gnu-toolchain/riscv-gcc/' && \
    flock $(git rev-parse --git-dir)/config git submodule update --progress '/riscv-gnu-toolchain/riscv-gcc/'

# RUN git submodule update --init qemu && \
#     git submodule update --depth=1 --init

# ADD https://sourceware.org/bugzilla/attachment.cgi?id=10151&action=diff&collapsed=&headers=1&format=raw /riscv-gnu-toolchain/riscv-glibc/sunrpc/rpc/type.h.patch
# COPY type.h.patch /riscv-gnu-toolchain/riscv-glibc/sunrpc/rpc/type.h.patch

# RUN cd /riscv-gnu-toolchain/riscv-glibc/sunrpc/rpc/ && patch < type.h.patch

# WORKDIR /riscv-gnu-toolchain

RUN ./configure --prefix=/opt/riscv --enable-multilib && make newlib linux

FROM ubuntu:bionic

COPY --from=builder /opt/riscv/ /opt/riscv/

ENV PATH=$PATH:/opt/riscv/bin/ \
    C_INCLUDE_PATH=/opt/riscv/riscv64-unknown-elf/include/ \
    LD_LIBRARY_PATH=/opt/riscv/riscv64-unknown-elf/lib/ \
    CC=/opt/riscv/bin/riscv64-unknown-elf-gcc \
    CXX=/opt/riscv/bin/riscv64-unknown-elf-g++ \

