# 通过配置代理的方式设置Docker镜像加速

通过本机代理的方式访问dockerhub

1. 创建 dockerd 相关的 systemd 目录，这个目录下的配置将覆盖 dockerd 的默认配置

   ```shell
   $ sudo mkdir -p /etc/systemd/system/docker.service.d
   ```

2. 新建代理配置文件

   ```shell
   $ vim /etc/systemd/system/docker.service.d/http-proxy.conf
   
   [Service]
   Environment="HTTP_PROXY=http://10.0.0.1:7890"
   Environment="HTTPS_PROXY=http://10.0.0.1:7890"
   ```

3. 不代理私有仓库

   如果你自己建了私有的镜像仓库，需要 dockerd 绕过代理服务器直连，那么配置 `NO_PROXY` 变量:

   ```shell
   $ vim /etc/systemd/system/docker.service.d/http-proxy.conf
   
   [Service]
   Environment="HTTP_PROXY=http://10.0.0.1:7890"
   Environment="HTTPS_PROXY=http://10.0.0.1:7890"
   Environment="NO_PROXY=your-registry.com,10.10.10.10,*.example.com'
   ```

   > 多个`NO_PROXY`变量的值用逗号分隔，而且可以使用通配符`（*）`；极端情况下，如果`NO_PROXY="*"`，那么所有请求都将不通过代理服务器。

4. 重新加载配置文件，重启 dockerd

   ```shell
   $ sudo systemctl daemon-reload
   $ sudo systemctl restart docker
   ```



# 通过修改镜像源的方式设置Docker镜像加速
   ```shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
   {
    "registry-mirrors": [
        "https://hub.uuuadc.top",
        "https://docker.anyhub.us.kg",
        "https://dockerhub.jobcher.com",
        "https://dockerhub.icu",
        "https://docker.ckyl.me",
        "https://docker.awsl9527.cn"
    ]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
   ```
