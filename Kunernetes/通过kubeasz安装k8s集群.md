# 通过kubeasz安装k8s集群

### 环境准备

1. 允许root登录

   ```
   hjb@node02:~$ sudo -i
   
   root@node02:~# passwd
   New password: 
   Retype new password: 
   passwd: password updated successfully
   
   
   ```

   ```
   vim /etc/ssh/sshd_config
   PermitRootLogin yes
   PasswordAuthentication yes
   
   sudo systemctl restart ssh
   ```

   

2. 配置代理

   ```
   vim ~/.bashrc
   
   export http_proxy=http://192.168.10.6:10809
   export https_proxy=http://192.168.10.6:10809
   export no_proxy=127.0.0.1,localhost,192.168.*,10.0.*,archive.ubuntu.com
   ```

   

3. 配置软件源

   ```
   bash <(curl -sSL https://linuxmirrors.cn/main.sh)
   
   13
   ```

   

4. 安装时间同步工具

   ```
   apt -y install chrony
   timedatectl status 
   timedatectl set-ntp on
   timedatectl set-timezone Asia/Shanghai
   systemctl restart chronyd
   ```

5. ssh免密登录

   ```
   ssh-keygen
   ssh-copy-id ${HOST}
   ```

6. 安装docker

   ```
   export DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/docker-ce"
   # 如您使用 curl
   curl -fsSL https://get.docker.com/ | sh
   # 如您使用 wget
   wget -O- https://get.docker.com/ | sh
   ```

   

7. 修改docker镜像源

   ```
   sudo mkdir -p /etc/docker
   
   
   sudo tee /etc/docker/daemon.json <<-'EOF'
   {
    "registry-mirrors": [
        "https://docker.soak.asia"
    ]
   }
   EOF
   
   
   
   
   sudo systemctl daemon-reload
   
   sudo systemctl restart docker
   ```

   

8. 配置docker-ansible

   ```
   vim ~/.bashrc
   
   alias ansible='docker run --rm -it -v $(pwd):/ansible -v ~/.ssh/id_rsa:/root/.ssh/id_rsa --workdir=/ansible willhallonline/ansible:latest /bin/sh'
   
   source ~/.bashrc
   ```
