# 安装Harbor

### 安装Docker

- 自动安装

  ```shell
  export DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/docker-ce"
  # 如您使用 curl
  curl -fsSL https://get.docker.com/ | sh
  # 如您使用 wget
  wget -O- https://get.docker.com/ | sh
  ```

- 手动安装

  1. 卸载docker相关内容

     ```shell
     for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
     ```

  2. 安装apt repository

     ```shell
     # Add Docker's official GPG key:
     sudo apt-get update
     sudo apt-get install ca-certificates curl
     sudo install -m 0755 -d /etc/apt/keyrings
     #sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
     sudo wget https://download.docker.com/linux/ubuntu/gpg -O /etc/apt/keyrings/docker.asc
     sudo chmod a+r /etc/apt/keyrings/docker.asc
     
     # Add the repository to Apt sources:
     echo \
       "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
       $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
       sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
     sudo apt-get update
     ```

  3. 安装docker

     ```shell
     sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
     ```

  4. 测试docker

     ```shell
     sudo docker run hello-world
     ```

     

### 安装Docker Compose

#### 通过仓库安装docker compose

> [!NOTE]
>
> 通过“安装docker”步骤中的“安装apt repositry”步骤之后，仓库中就会有docker compose组件，可以直接安装；否则，需要先安装apt repository

1. 安装docker compose

   ```shell
   sudo apt-get update
   sudo apt-get install docker-compose-plugin
   ```

2. 验证docker compose

   ```shell
   docker compose version
   ```

#### 手动安装docker compose

1. 下载docker compose plugin

   ```shell
   DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
   mkdir -p $DOCKER_CONFIG/cli-plugins
   curl -SL https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
   ```

   > [!NOTE]
   >
   > `DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}`配置该参数表明只为当前用户安装docker compose，如果需要为所有用户安装docker compose，需要使用`DOCKER_CONFIG=/usr/local/lib/docker`

2.  为docker compose添加执行权限

   ```shell
   chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
   ```

3. 检查是否安装成功

   ```shell
   docker compose version
   ```

   

#### 更新docker compose

```shell
sudo apt-get update
sudo apt-get install docker-compose-plugin
```

### 安装Harbor

1. 下载Harbor安装包

   > harbor项目地址：https://github.com/goharbor/harbor
   >
   > harbor安装包地址：https://github.com/goharbor/harbor/releases

   ```shell
   #可以下载离线安装包或者在线安装包
   #本例中使用的是在线安装包
   wget https://github.com/goharbor/harbor/releases/download/v2.11.0/harbor-online-installer-v2.11.0.tgz
   ```

2. 解压Harbor安装包

   ```shell
   tar xf  harbor-online-installer-v2.11.0.tgz  -C /usr/local/
   ```

   

3. 修改Harbor配置文件

   ```yaml
   cd /usr/local/harbor
   cp harbor.yml.tmpl harbor.yml
   vim harbor.yml
   
   # 1. 修改harbor的域名
   hostname: 192.168.10.10
   
   # 2. https选项全部注释掉
   # https related config
   #https:
     # https port for harbor, default is 443
     #  port: 443
     # The path of cert and key files for nginx
     # certificate: /your/certificate/path
     #private_key: /your/private/key/path
     # enable strong ssl ciphers (default: false)
     # strong_ssl_ciphers: false
    
    
   # 3. 修改harbor管理员登录密码
   harbor_admin_password: 123456
   ```

   

4. 运行Harbor安装脚本

   ```shell
   cd /usr/local/harbor
   ./install.sh
   ```

5. 验证是否安装成功

   在浏览器输入harbor服务器的ip

   ![harbor主页](https://telegraph-image-67p.pages.dev/file/07c79febf4fa0b911a222.png)

6. docker compose 管理命令

   ```
   docker compose up -d
   docker compose down -v
   docker compose ls
   docker compose ps
   ```

   
