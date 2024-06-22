通过二进制安装包的方式安装redis-server

```shell
通过二进制安装包的方式安装redis-server

#!/bin/bash

#通过二进制安装包的方式安装redis-server

#####################
#安装必要工具
yum -y install wget gcc tar
#下载redis安装包
wget https://download.redis.io/redis-stable.tar.gz

#解压到/usr/local/目录下
tar xf redis-stable.tar.gz -C /usr/local/

#编译安装redis
cd /usr/local/redis-stable;make;make install

#修改redis初始化脚本
sed -i "78,83s/^/#/g" /usr/local/redis-stable/utils/install_server.sh

#初始化redis
bash /usr/local/redis-stable/utils/install_server.sh

#选择部署模式
select i in replica sentinel quit
do
case $i in
     replica)
            sed -i "s/bind 127.0.0.1/bind 0.0.0.0/" /etc/redis/6379.conf
            echo "requirepass 123456" >> /etc/redis/6379.conf
            redis-cli shutdown
            redis-server /etc/redis/6379.conf &
    ;;
    sentinel)
            sed -i "s/bind 127.0.0.1/bind 0.0.0.0/" /etc/redis/6379.conf
            echo "masterauth 123456" >> /etc/redis/6379.conf
            echo "requirepass 123456" >> /etc/redis/6379.conf
            redis-cli shutdown
            redis-server /etc/redis/6379.conf &
    ;;
    quit)
         exit
    ;;
esac
done

```

