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

   

8. 配置docker-ansible

   ```
   vim ~/.bashrc
   
   alias ansible='docker run --rm -it -v $(pwd):/ansible -v ~/.ssh/id_rsa:/root/.ssh/id_rsa --workdir=/ansible willhallonline/ansible:latest /bin/sh'
   
   source ~/.bashrc
   ```



### 配置kubeasz

1. 下载工具脚本ezdown，举例使用kubeasz版本3.6.4

   ```
   export release=3.6.4
   wget https://github.com/easzlab/kubeasz/releases/download/${release}/ezdown
   chmod +x ./ezdown
   ```

2. 下载kubeasz代码、二进制、默认容器镜像（更多关于ezdown的参数，运行./ezdown 查看）

   ```
   # 国内环境
   ./ezdown -D
   # 海外环境
   #./ezdown -D -m standard
   ```

3. 配置Docker镜像源

   ```
   vim  /etc/docker/daemon.json
   
   {
    "registry-mirrors": [ "https://docker.soak.asia" ]
   }
   
   
   
   sudo systemctl daemon-reload
   
   sudo systemctl restart docker
   ```

   

4. 创建集群配置实例

   ```
   root@master01:~# ./ezdown -S
   2024-08-15 09:08:13 INFO Action begin: start_kubeasz_docker
   ...
   
   root@master01:~# docker exec -it kubeasz ezctl new k8s-01
   2024-08-15 09:08:28 DEBUG generate custom cluster files in /etc/kubeasz/clusters/k8s-01
   2024-08-15 09:08:28 DEBUG set versions
   2024-08-15 09:08:28 DEBUG cluster k8s-01: files successfully created.
   2024-08-15 09:08:28 INFO next steps 1: to config '/etc/kubeasz/clusters/k8s-01/hosts'
   2024-08-15 09:08:28 INFO next steps 2: to config '/etc/kubeasz/clusters/k8s-01/config.yml'
   ```

5. 配置hosts信息

   ```
   vim  /etc/kubeasz/clusters/k8s-01/hosts
   
   [etcd]
   192.168.10.7
   192.168.10.102
   192.168.10.9
   
   [kube_master]
   192.168.10.7 k8s_nodename='master-01'
   192.168.10.102 k8s_nodename='master-02'
   192.168.10.9 k8s_nodename='master-03'
   
   [kube_node]
   192.168.10.103 k8s_nodename='worker-01'
   192.168.10.104 k8s_nodename='worker-02'
   
   ```

   

6. 安装集群

   ```
   # 一键安装，等价于执行docker exec -it kubeasz ezctl setup k8s-01 all
   dk ezctl setup k8s-01 all
   
   # 或者分步安装，具体使用 dk ezctl help setup 查看分步安装帮助信息
   # dk ezctl setup k8s-01 01
   # dk ezctl setup k8s-01 02
   # dk ezctl setup k8s-01 03
   # dk ezctl setup k8s-01 04
   # dk ezctl setup k8s-01 05
   # dk ezctl setup k8s-01 06
   # dk ezctl setup k8s-01 07
   ```



### 安装kubectl

1. 在配置中添加镜像（注意修改为自己需要的版本号）：

   ```
   echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
   ```

   如果需要使用 CRI-O，执行以下命令：

   ```
   echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.ustc.edu.cn/kubernetes/addons:/cri-o:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/cri-o.list
   ```

2. 添加公钥（所有仓库均使用相同公钥，因此 URL 中版本号可以忽略）：

   ```
   curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
   ```

3. 更新软件源：

   ```
   sudo apt-get update
   ```

4. 安装组件

   ```
   apt-get install -y kubelet kubeadm kubectl
   ```

   
