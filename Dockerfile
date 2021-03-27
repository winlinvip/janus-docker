
# https://github.com/meetecho/janus-gateway#dependencies
FROM centos:7

RUN yum install -y gcc gcc-c++ make patch sudo unzip perl zlib automake libtool \
    zlib-devel bzip2 bzip2-devel libxml2-devel file git

RUN yum install -y libmicrohttpd-devel jansson-devel \
       openssl-devel libsrtp-devel sofia-sip-devel glib2-devel \
       opus-devel libogg-devel libcurl-devel pkgconfig gengetopt \
       libconfig-devel libtool autoconf automake

ADD libnice-0.1.18.tar.gz /tmp/git/janus-docker
RUN yum install -y python3-pip && pip3 install meson ninja &&
    cd /tmp/git/janus-docker/libnice-0.1.18 && \
    meson build && ninja -C build && ninja -C build install

ADD libsrtp-2.3.0.tar.gz /tmp/git/janus-docker
RUN cd /tmp/git/janus-docker/libsrtp-2.3.0 && \
    ./configure && make && make install

ADD gengetopt-2.22.tar.gz /tmp/git/janus-docker
ADD fileutils.cpp /tmp/git/janus-docker/gengetopt-2.22/src/fileutils.cpp
RUN cd /tmp/git/janus-docker/gengetopt-2.22 && \
    ./configure && make && make install

ADD libmicrohttpd-0.9.59.tar.gz /tmp/git/janus-docker
RUN cd /tmp/git/janus-docker/libmicrohttpd-0.9.59 && \
    ./configure && make && make install

ADD janus-gateway-0.10.10.tar.gz /tmp/git/janus-docker
RUN cd /tmp/git/janus-docker/janus-gateway-0.10.10 && \
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig && \
    bash autogen.sh && ./configure && make && make configs && make install

ENV PATH $PATH:/usr/local/go/bin
RUN cd /usr/local && \
    curl -L -O https://golang.google.cn/dl/go1.16.2.linux-amd64.tar.gz && \
    tar xf go1.16.2.linux-amd64.tar.gz && \
    rm -f go1.16.2.linux-amd64.tar.gz

RUN cd /tmp/git && git clone https://code.aliyun.com/ossrs/go-oryx.git
RUN cd /tmp/git/go-oryx/httpx-static && go build -mod=vendor . && \
    ln -sf `pwd`/httpx-static /usr/local/bin/

ADD index.html /usr/local/share/janus/demos/
ADD videoroomtest.js /usr/local/share/janus/demos/
ADD start.sh /usr/local/bin
CMD ['/usr/local/bin/start.sh']
