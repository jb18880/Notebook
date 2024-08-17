# Harbor使用

### 配置Harbor-service文件

```shell
vim /usr/lib/systemd/system/harbor.service  

[Unit]
Description=Harbor
After=docker.service systemd-networkd.service systemd-resolved.service
Requires=docker.service
Documentation=http://github.com/vmware/harbor

[Service]
Type=simple
Restart=on-failure
RestartSec=5
ExecStart=/usr/bin/docker-compose -f /usr/local/harbor/docker-compose.yml up
ExecStop =/usr/bin/docker-compose -f /usr/local/harbor/docker-compose.yml stop

[Install]
WantedBy=multi-user.target
```



### Harbor管理命令

```shell
systemctl start harbor
systemctl status harbor
systemctl stop harbor
systemctl enable --now harbor
docker-compose up -d
docker-compose down   #删除项目涉及的容器
docker-compose stop   #停止项目涉及的容器
docker-compose ps
docker-compose ls
```



### 登录到Harbor

1. 信任不安全域名

   ```shell
   vim /etc/docker/daemon.json
   
   {
    "registry-mirrors": [ "https://docker.soak.asia" ],
    "insecure-registries": [ "192.168.10.10" ]
   }
   ```

2. 重启docker和harbor   

   ```shell
   systemctl daemon-reload
   systemctl restart docker
   systemctl restart harbor
   ```

3. 登录

   ```shell
   docker login 192.168.10.10
   ```



### 配置Harbor为本地Docker代理

# 呃，不好用，ummm，可能是不会用

背景：经常去DockerHub下载镜像还是很慢，可以使用Harbor搭建一个本地的仓库，供Docker使用

1. 通过Cloudflare搭建个人的Docker仓库代理

   https://www.youtube.com/watch?v=l2jwq9CagNQ&t=48s

   当当当当，会获得一个闪亮亮的Docker代理的域名。

2. 安装Harbor

   [安装Harbor](https://github.com/jb18880/Notebook/blob/main/Docker/%E5%AE%89%E8%A3%85Harbor.md)

3. 创建Docker代理仓库

   [Harbor使用DockerHub进行代理缓存](https://juejin.cn/post/7309158089374187571)

   创建DockerHub代理仓库

   ![创建DockerHub代理仓库](https://telegraph-image-67p.pages.dev/file/3faac141b3ecb1064722e.png)

   

   修改library项目为缓存代理项目

   删除library项目

   创建library项目

   ![创建lirbary项目](https://telegraph-image-67p.pages.dev/file/b0254cf1cc6c0f1f2da50.png)

   

   测试拉取镜像

   ```shell
   $ docker pull 192.168.10.10/library/mysql  
   Using default tag: latest
   latest: Pulling from library/mysql
   d9a40b27c30f: Pull complete
   fe4b01031aab: Pull complete
   aa72c34c4347: Pull complete
   473ade985fa2: Pull complete
   cc168a9482de: Pull complete
   3ca3786815dd: Pull complete
   3e3fac98ea83: Pull complete
   10e5505c3ae4: Pull complete
   a79ade39aab9: Pull complete
   ae34d51c6da2: Pull complete
   Digest: sha256:d8df069848906979fd7511db00dc22efeb0a33a990d87c3c6d3fcdafd6fc6123
   Status: Downloaded newer image for 192.168.10.10/library/mysql:latest
   192.168.10.10/library/mysql:latest
   ```

   经过上述步骤可以正常从Harbor代理到DockerHub下载镜像了，但是每次拉取镜像的时候需要输入harbor 的地址，不是很方便

4. Docker配置Harbor域名为默认仓库

   ```shell
   ❯ vim /etc/docker/daemon.json
   
   {
     "registry-mirrors": [ "http://192.168.10.10:80" ],
     "insecure-registries": [ "192.168.10.10" ]
   }
   
   systemctl daemon-reload
   systemctl restart docker
   ```

   下次拉取镜像的时候就会从Harbor中拉取了，如果Harbor中没有这个镜像，就会从cloudflare代理的DockerHub镜像站点拉取，然后缓存到本地。
