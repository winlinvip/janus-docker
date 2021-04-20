# janus-docker 

For https://github.com/winlinvip/janus-docker

## Usage

Start janus:

```bash
ip=$(ifconfig en0 inet|grep inet|awk '{print $2}') &&
sed -i '' "s/nat_1_1_mapping.*/nat_1_1_mapping=\"$ip\"/g" janus.jcfg &&
docker run --rm -it -p 8080:8080 -p 8443:8443 -p 20000-20010:20000-20010/udp \
    -v $(pwd)/janus.jcfg:/usr/local/etc/janus/janus.jcfg \
    -v $(pwd)/janus.plugin.videoroom.jcfg:/usr/local/etc/janus/janus.plugin.videoroom.jcfg \
    -v $(pwd)/janus.transport.http.jcfg:/usr/local/etc/janus/janus.transport.http.jcfg \
    -v $(pwd)/videoroomtest.js:/usr/local/share/janus/demos/videoroomtest.js \
    registry.cn-hangzhou.aliyuncs.com/ossrs/janus:v1.0.10
```

> Note: Docker images at [here](https://cr.console.aliyun.com/repository/cn-hangzhou/ossrs/janus/images)

打开页面，自动入会：[http://localhost:8080](http://localhost:8080)。

> Note: HTTPS页面请访问[https://localhost:8443](https://localhost:8443)。

> Note: 由于是自签名证书，打开页面后，点击页面空白处，敲单词（无空格）`thisisunsafe`。

也可以只启动Janus，不启动videoroom页面：

```bash
ip=$(ifconfig en0 inet|grep inet|awk '{print $2}') &&
sed -i '' "s/nat_1_1_mapping.*/nat_1_1_mapping=\"$ip\"/g" janus.jcfg &&
docker run --rm -it -p 8080:8088 -p 8443:8443 -p 20000-20010:20000-20010/udp \
    -v $(pwd)/janus.jcfg:/usr/local/etc/janus/janus.jcfg \
    -v $(pwd)/janus.plugin.videoroom.jcfg:/usr/local/etc/janus/janus.plugin.videoroom.jcfg \
    -v $(pwd)/janus.transport.http.jcfg:/usr/local/etc/janus/janus.transport.http.jcfg \
    -v $(pwd)/videoroomtest.js:/usr/local/share/janus/demos/videoroomtest.js \
    registry.cn-hangzhou.aliyuncs.com/ossrs/janus:v1.0.10 \
    /usr/local/bin/janus
```

> Note: Janus的API侦听在8088端口，我们转到了8080端口，压测工具可以直接访问，不依赖页面。

若部署在外网，那么需要将IP设置为外网IP，并通过HTTPS访问：https://ip:8443

> Note: 由于是自签名证书，打开页面后，点击页面空白处，敲单词（无空格）`thisisunsafe`。


## Benchmark

Please read [srs-bench](https://github.com/ossrs/srs-bench/tree/feature/rtc#janus):

```bash
./objs/srs_bench -sfu=janus -pr webrtc://localhost:8080/2345/livestream \
  -sa a.ogg -sv v.h264 -fps 25 -sn 100 -delay 1000
```

Winlin 2021.03
