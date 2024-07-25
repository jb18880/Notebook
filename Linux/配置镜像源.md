# 配置YUM源

### 配置DNS解析

```shell
sudo tee /etc/resolv.conf << EOF
nameserver 114.114.114.114
nameserver 223.5.5.5
nameserver 180.76.76.76
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
```

配置YUM源sudo 

```shell
sudo tee /etc/apt/sources.list  << EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.ustc.edu.cn/ubuntu/ focal main restricted universe multiverse
# deb-src https://mirrors.ustc.edu.cn/ubuntu/ focal main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/  focal-updates main restricted universe multiverse
# deb-src https://mirrors.ustc.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/  focal-backports main restricted universe multiverse
# deb-src https://mirrors.ustc.edu.cn/ubuntu/ focal-backports main restricted universe multiverse

# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换
deb  https://mirrors.ustc.edu.cn/ubuntu/  focal-security main restricted universe multiverse
# deb-src https://mirrors.ustc.edu.cn/ubuntu/ focal-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.ustc.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
# # deb-src https://mirrors.ustc.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse

EOF
```

```shell
apt update
```

