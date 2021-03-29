# janus-docker 

For https://github.com/winlinvip/janus-docker

## Usage

Start janus:

```bash
ip=$(ifconfig en0 inet|grep inet|awk '{print $2}') &&
sed -i '' "s/nat_1_1_mapping.*/nat_1_1_mapping=\"$ip\"/g" janus.jcfg &&
docker run --rm -it -p 8080:8080 -p 20000-20010:20000-20010/udp \
    -v $(pwd)/janus.jcfg:/usr/local/etc/janus/janus.jcfg \
    -v $(pwd)/janus.plugin.videoroom.jcfg:/usr/local/etc/janus/janus.plugin.videoroom.jcfg \
    registry.cn-hangzhou.aliyuncs.com/ossrs/janus:v1.0.7
```

> Note: Docker images at [here](https://cr.console.aliyun.com/repository/cn-hangzhou/ossrs/janus/images)

打开页面，自动入会：http://localhost:8080

也可以只启动Janus，不启动videoroom页面：

```bash
ip=$(ifconfig en0 inet|grep inet|awk '{print $2}') &&
sed -i '' "s/nat_1_1_mapping.*/nat_1_1_mapping=\"$ip\"/g" janus.jcfg &&
docker run --rm -it -p 8080:8088 -p 20000-20010:20000-20010/udp \
    -v $(pwd)/janus.jcfg:/usr/local/etc/janus/janus.jcfg \
    -v $(pwd)/janus.plugin.videoroom.jcfg:/usr/local/etc/janus/janus.plugin.videoroom.jcfg \
    registry.cn-hangzhou.aliyuncs.com/ossrs/janus:v1.0.7 \
    /usr/local/bin/janus
```

> Note: Janus的API侦听在8088端口，我们转到了8080端口，压测工具可以直接访问，不依赖页面。

Winlin 2021.03
