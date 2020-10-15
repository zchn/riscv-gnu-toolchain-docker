FROM alpine as builder

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

RUN git clone --recursive https://github.com/riscv/riscv-gnu-toolchain

ADD https://sourceware.org/bugzilla/attachment.cgi?id=10151&action=diff&collapsed=&headers=1&format=raw /riscv-gnu-toolchain/riscv-glibc/sunrpc/rpc/type.h.patch
#COPY type.h.patch /riscv-gnu-toolchain/riscv-glibc/sunrpc/rpc/type.h.patch

RUN cd /riscv-gnu-toolchain/riscv-glibc/sunrpc/rpc/ && patch < type.h.patch

WORKDIR /riscv-gnu-toolchain

RUN ./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32
RUN make

FROM alpine

COPY --from=builder /opt/riscv/ /opt/riscv/

RUN apk add --no-cache --virtual riscv-runtime-dependencies \
    libintl

ENV PATH $PATH:/opt/riscv/bin/
ENV C_INCLUDE_PATH /opt/riscv/riscv32-unknown-elf/include/
ENV LD_LIBRARY_PATH /opt/riscv/riscv32-unknown-elf/lib/
ENV CC /opt/riscv/bin/riscv32-unknown-elf-gcc
ENV CXX /opt/riscv/bin/riscv32-unknown-elf-g++

