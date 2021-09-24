FROM alpine:latest as builder

RUN apk --no-cache add --virtual riscv-build-dependencies \
    build-base \
    gawk \
    texinfo \
    bison \
    git \
    autoconf \
    automake \
    curl \
    python3 \
    mpc1-dev \
    mpfr-dev \
    gmp-dev \
    flex \
    gperf \
    libtool \
    patchutils \
    bc \
    zlib-dev \
    expat-dev \
    gettext-dev

WORKDIR /

# RUN git clone --depth 1 --shallow-submodules --recursive https://github.com/riscv/riscv-gnu-toolchain
RUN git clone https://github.com/riscv/riscv-gnu-toolchain.git && \
    cd riscv-gnu-toolchain && \
    git submodule update --init qemu && \
    git submodule update --depth=1 --init

# ADD https://sourceware.org/bugzilla/attachment.cgi?id=10151&action=diff&collapsed=&headers=1&format=raw /riscv-gnu-toolchain/riscv-glibc/sunrpc/rpc/type.h.patch
# COPY type.h.patch /riscv-gnu-toolchain/riscv-glibc/sunrpc/rpc/type.h.patch

# RUN cd /riscv-gnu-toolchain/riscv-glibc/sunrpc/rpc/ && patch < type.h.patch

WORKDIR /riscv-gnu-toolchain

RUN ./configure --prefix=/opt/riscv && make

FROM alpine:latest

COPY --from=builder /opt/riscv/ /opt/riscv/

RUN apk add --no-cache --virtual riscv-runtime-dependencies \
    libintl \
    mpc1 \
    gmp \
    mpfr4

ENV PATH=$PATH:/opt/riscv/bin/ \
    C_INCLUDE_PATH=/opt/riscv/riscv64-unknown-elf/include/ \
    LD_LIBRARY_PATH=/opt/riscv/riscv64-unknown-elf/lib/ \
    CC=/opt/riscv/bin/riscv64-unknown-elf-gcc \
    CXX=/opt/riscv/bin/riscv64-unknown-elf-g++ \

