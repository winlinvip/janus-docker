# janus-docker 

For https://github.com/winlinvip/janus-docker

## Usage

Start janus:

```bash
docker run --rm -it -p 8080:8080 \
    registry.cn-hangzhou.aliyuncs.com/ossrs/janus:v1.0.4
```

> Note: Docker images at [here](https://cr.console.aliyun.com/repository/cn-hangzhou/ossrs/janus/images)

打开页面，自动入会：http://localhost:8080

也可以只启动Janus，不启动videoroom页面：

```bash
docker run --rm -it -p 8080:8088 \
    registry.cn-hangzhou.aliyuncs.com/ossrs/janus:v1.0.4 \
    /usr/local/bin/janus
```

> Note: Janus的API侦听在8088端口，我们转到了8080端口，压测工具可以直接访问，不依赖页面。

Winlin 2021.03
