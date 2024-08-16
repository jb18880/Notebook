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





