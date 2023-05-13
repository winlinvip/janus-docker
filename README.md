# janus-docker 

For https://github.com/winlinvip/janus-docker

## Usage

Start janus:

```bash
ip=$(ifconfig en0 inet|grep inet|awk '{print $2}') &&
sed -i '' "s/nat_1_1_mapping.*/nat_1_1_mapping=\"$ip\"/g" janus.jcfg &&
docker run --rm -it -p 8081:8080 -p 8188:8188 -p 8443:8443 -p 20000-20010:20000-20010/udp \
    -v $(pwd)/janus.jcfg:/usr/local/etc/janus/janus.jcfg \
    -v $(pwd)/janus.plugin.videoroom.jcfg:/usr/local/etc/janus/janus.plugin.videoroom.jcfg \
    -v $(pwd)/janus.transport.http.jcfg:/usr/local/etc/janus/janus.transport.http.jcfg \
    -v $(pwd)/janus.transport.websockets.jcfg:/usr/local/etc/janus/janus.transport.websockets.jcfg \
    -v $(pwd)/videoroomtest.js:/usr/local/share/janus/demos/videoroomtest.js \
    ossrs/janus:v1.0.11
```

> Note: 国内可以用阿里云镜像`registry.cn-hangzhou.aliyuncs.com/ossrs/janus`。

> Note: Docker images at [here](https://hub.docker.com/r/ossrs/janus/tags)

打开页面，自动入会：[http://localhost:8081](http://localhost:8081)。

> Note: HTTPS页面请访问[https://localhost:8443](https://localhost:8443)。

> Note: 由于是自签名证书，打开页面后，点击页面空白处，敲单词（无空格）`thisisunsafe`。

也可以只启动Janus，不启动videoroom页面：

```bash
ip=$(ifconfig en0 inet|grep inet|awk '{print $2}') &&
sed -i '' "s/nat_1_1_mapping.*/nat_1_1_mapping=\"$ip\"/g" janus.jcfg &&
docker run --rm -it -p 8080:8080 -p 8188:8188 -p 8443:8443 -p 20000-20010:20000-20010/udp \
    -v $(pwd)/janus.jcfg:/usr/local/etc/janus/janus.jcfg \
    -v $(pwd)/janus.plugin.videoroom.jcfg:/usr/local/etc/janus/janus.plugin.videoroom.jcfg \
    -v $(pwd)/janus.transport.http.jcfg:/usr/local/etc/janus/janus.transport.http.jcfg \
    -v $(pwd)/janus.transport.websockets.jcfg:/usr/local/etc/janus/janus.transport.websockets.jcfg \
    -v $(pwd)/videoroomtest.js:/usr/local/share/janus/demos/videoroomtest.js \
    -v $(pwd)/janus.sh:/usr/local/bin/janus.sh \
    ossrs/janus:v1.0.11 /usr/local/bin/janus.sh
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

## WHIP

可以用这个Docker，实现[WISH, WHIP and Janus: Part II](https://www.meetecho.com/blog/whip-janus-part-ii/)中的WHIP推流。

首先，启动Janus，注意要开启websocket支持：

```bash
ip=$(ifconfig en0 inet|grep inet|awk '{print $2}') &&
sed -i '' "s/nat_1_1_mapping.*/nat_1_1_mapping=\"$ip\"/g" janus.jcfg &&
docker run --rm -it -p 8081:8080 -p 8188:8188 -p 20000-20010:20000-20010/udp \
    -v $(pwd)/janus.jcfg:/usr/local/etc/janus/janus.jcfg \
    -v $(pwd)/janus.plugin.videoroom.jcfg:/usr/local/etc/janus/janus.plugin.videoroom.jcfg \
    -v $(pwd)/janus.transport.http.jcfg:/usr/local/etc/janus/janus.transport.http.jcfg \
    -v $(pwd)/janus.transport.websockets.jcfg:/usr/local/etc/janus/janus.transport.websockets.jcfg \
    -v $(pwd)/videoroomtest.js:/usr/local/share/janus/demos/videoroomtest.js \
    -v $(pwd)/janus.sh:/usr/local/bin/janus.sh \
    ossrs/janus:v1.0.11 /usr/local/bin/janus.sh
```

打开浏览器，访问[http://localhost:8081/videoroomtest.html?room=2345](http://localhost:8081/videoroomtest.html?room=2345)，自动入会。

> Note: 房间1234是VP8+OPUS，而2345是H.264+OPUS。

然后，下载和启动[Simple WHIP Server](https://github.com/meetecho/simple-whip-server)，命令如下：

```bash
git clone https://github.com/meetecho/simple-whip-server.git
cd simple-whip-server
npm install
npm run build
npm run start
```

接着，需要创建一个WHIP的可接入ID：

```bash
curl -H 'Content-Type: application/json' -d '{"id": "abc123", "room": 2345}' http://localhost:7080/whip/create
```

> Note: 房间1234是VP8+OPUS，而2345是H.264+OPUS。

最后，运行SRS，这样可以用SRS的WebRTC播放器：

```bash
./objs/srs -c conf/rtc.conf
```

打开浏览器，访问[http://localhost:8080/players/whip.html?api=7080&path=/whip/endpoint/abc123](http://localhost:8080/players/whip.html?api=7080&path=/whip/endpoint/abc123)，输入地址：

```text
http://localhost:7080/whip/endpoint/abc123
```

然后点推流。

Winlin 2021.03
