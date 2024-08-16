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

背景：经常去DockerHub下载镜像还是很慢，可以使用Harbor搭建一个本地的仓库，供Docker使用

1. 通过Cloudflare搭建个人的Docker仓库代理

   https://www.youtube.com/watch?v=l2jwq9CagNQ&t=48s

   当当当当，会获得一个闪亮亮的Docker代理的域名。

2. 安装Harbor

3. 创建Docker代理仓库

   [Harbor使用DockerHub进行代理缓存](https://juejin.cn/post/7309158089374187571)

   经过上述步骤可以正常从Harbor代理到DockerHub下载镜像了，但是每次拉取镜像的时候需要输入harbor 的地址，不是很方便

4. Harbor配置项目

   配置library项目指向代理仓库

   开启镜像代理，指向代理仓库

5. Docker配置Harbor域名为默认仓库

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
