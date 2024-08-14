# 通过kubeasz安装k8s集群

### 环境准备

1. 安装时间同步工具

   ```
   apt -y install chrony
   timedatectl ststus 
   timedatectl set-ntp on
   timedatectl set-timezone Asia/Shanghai
   systemctl restart chronyd
   ```

2. ssh免密登录

   ```
   ssh-keygen
   ssh-copy-id ${HOST}
   ```

3. 仅部署节点安装ansible

   ```
   apt -y install ansible
   ```