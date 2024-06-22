# 为Minikube配置Docker镜像加速

通过本机代理的方式为minikube顺利的访问dockerhub

1. 登录到minikube上

   ```shell
   $ minikube ssh
   ```

2. 创建 dockerd 相关的 systemd 目录，这个目录下的配置将覆盖 dockerd 的默认配置

   ```shell
   $ sudo mkdir -p /etc/systemd/system/docker.service.d
   ```

3. 新建代理配置文件

   ```shell
   $ sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<-'EOF'
   [Service]
   Environment="HTTP_PROXY=http://10.0.0.1:7890"
   Environment="HTTPS_PROXY=http://10.0.0.1:7890"
   EOF
   ```

4. 不代理私有仓库

   如果你自己建了私有的镜像仓库，需要 dockerd 绕过代理服务器直连，那么配置 NO PROXy 变量:

   ```shell
   $ sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<-'EOF'
   
   [Service]
   Environment="HTTP_PROXY=http://10.0.0.1:7890"
   Environment="HTTPS_PROXY=http://10.0.0.1:7890"
   Environment="NO_PROXY=your-registry.com,10.10.10.10,*.example.com'
   EOF
   ```

   > 多个`NO_PROXY`变量的值用逗号分隔，而且可以使用通配符`（*）`；极端情况下，如果`NO_PROXY=*`，那么所有请求都将不通过代理服务器。

5. 重新加载配置文件，重启 dockerd

   ```shell
   $ sudo systemctl daemon-reload
   $ sudo systemctl restart docker
   ```