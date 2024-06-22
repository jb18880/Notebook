### 确定要拉取的镜像名称

```
gcr.io/distroless/base-debian12
```

### 将gcr.io的镜像通过第三方项目拉取到dockerhub上

> 项目地址：https://github.com/togettoyou/hub-mirror/issues

点击new issue，把想要拉取的镜像放在"hub-mirror"里面

稍后就会拉取的镜像就会出现在DockerHub中，后续通过DockerHub加速工具就可以拉取下来

```
https://github.com/togettoyou/hub-mirror/issues/2406

{
"platform":"",
"hub-mirror": [
"gcr.io/distroless/base-debian12"
]
}
```

等一两分钟就会返回下载链接

```
docker pull docker.io/hubmirrorbytogettoyou/gcr.io.distroless.base-debian12 && docker tag docker.io/hubmirrorbytogettoyou/gcr.io.distroless.base-debian12 gcr.io/distroless/base-debian12
```

### 通过任意第三方的dockerhub加速器从DockerHub仓库下载该镜像到本地

   把`docker.io`换成第三方的加速地址`dockercf.jsdelivr.fyi`就好了

```
docker pull dockercf.jsdelivr.fyi/hubmirrorbytogettoyou/gcr.io.distroless.base-debian12 
#其他镜像加速地址
https://t.me/zero_free/80

回退方案
bakht3.jsdelivr.fyi
bakht2.jsdelivr.fyi
bakht1.jsdelivr.fyi

docker：
dockercf.jsdelivr.fyi
docker.jsdelivr.fyi
dockertest.jsdelivr.fyi
```

### 将本地镜像重新打tag

```
docker tag dockercf.jsdelivr.fyi/hubmirrorbytogettoyou/gcr.io.distroless.base-debian12 gcr.io/distroless/base-debian12
```

  