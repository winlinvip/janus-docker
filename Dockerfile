
# https://github.com/meetecho/janus-gateway#dependencies
FROM ubuntu:focal

# https://serverfault.com/questions/949991/how-to-install-tzdata-on-a-ubuntu-docker-image
ENV DEBIAN_FRONTEND=noninteractive

# To use if in RUN, see https://github.com/moby/moby/issues/7281#issuecomment-389440503
# Note that only exists issue like "/bin/sh: 1: [[: not found" for Ubuntu20, no such problem in CentOS7.
SHELL ["/bin/bash", "-c"]

RUN apt-get update -y && apt-get install -y libmicrohttpd-dev libjansson-dev libssl-dev libsrtp2-dev \
    libsofia-sip-ua-dev libglib2.0-dev libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
    libconfig-dev pkg-config gengetopt libtool automake libwebsockets-dev cmake perl zlib1g-dev \
    meson ninja-build git gcc g++ make patch sudo unzip perl zlib1g automake libtool curl

WORKDIR /tmp/git/janus-docker
ADD openssl-1.1-fit.tar.bz2 /tmp/git/janus-docker
RUN cd openssl-1.1-fit && ./config && make && make install_sw

ADD libwebsockets-3.2.tar.gz /tmp/git/janus-docker
RUN cd libwebsockets-3.2 && mkdir -p build && cd build && \
    cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. && \
    make && make install

ADD libnice-0.1.18.tar.gz /tmp/git/janus-docker
RUN cd libnice-0.1.18 && meson build && ninja -C build && ninja -C build install

ADD gengetopt-2.22.tar.gz /tmp/git/janus-docker
ADD fileutils.cpp gengetopt-2.22/src/fileutils.cpp
RUN cd gengetopt-2.22 && ./configure && make && make install

ADD libmicrohttpd-0.9.59.tar.gz /tmp/git/janus-docker
RUN cd libmicrohttpd-0.9.59 && ./configure && make && make install

ENV PATH=$PATH:/usr/local/go/bin
RUN cd /usr/local && curl -L https://go.dev/dl/go1.16.12.linux-amd64.tar.gz |tar -xz -C /usr/local

ADD go-oryx-1.0.27.tar.gz /tmp/git/janus-docker
RUN cd go-oryx-1.0.27/httpx-static && go build -mod=vendor . && mv httpx-static /usr/local/bin/

ADD libsrtp-2.3.0.tar.gz /tmp/git/janus-docker
RUN cd libsrtp-2.3.0 && ./configure && make && make install

# https://github.com/meetecho/janus-gateway/issues/2024
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig
ADD janus-gateway-0.10.10.tar.gz /tmp/git/janus-docker
RUN cd janus-gateway-0.10.10 && \
    bash autogen.sh && ./configure --disable-aes-gcm --enable-websockets && \
    make && make configs && make install

ENV LD_LIBRARY_PATH=/usr/local/lib64
ADD index.html /usr/local/share/janus/demos/
ADD videoroomtest.js /usr/local/share/janus/demos/

# Extra tools.
RUN apt-get install -y net-tools

# For HTTPS.
ADD server.key /usr/local/etc/
ADD server.crt /usr/local/etc/

WORKDIR /usr/local
ADD start.sh /usr/local/bin
ADD janus.sh /usr/local/bin
CMD [ "/usr/local/bin/start.sh" ]
