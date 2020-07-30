FROM alpine:3.12.0 as builder

RUN apk --no-cache add --virtual build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
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

RUN cd /riscv-gnu-toolchain/riscv-glibc/sunrpc/rpc/ && patch < type.h.patch

WORKDIR /riscv-gnu-toolchain

RUN ./configure --prefix=/opt/riscv
RUN make

FROM alpine:3.12.0

COPY --from=builder /opt/riscv/ /opt/riscv/

ENV PATH $PATH:/opt/riscv/bin/

