# Redis安装

本文档为Ubuntu22.04系统下安装redis-7.4.0的文档



### 单机Redis

1. 下载Redis二进制安装包

   > Redis安装包下载地址：https://download.redis.io/releases/

   ```shell
   wget https://download.redis.io/releases/redis-7.4.0.tar.gz
   ```

2. 解压

   ```
   tar xf redis-7.4.0.tar.gz -C /usr/local/
   ```

3. 编译安装

   ```shell
   sudo apt-get install build-essential tcl pkg-config libsystemd-dev
   cd /usr/local/redis-7.4.0
   make
   #指定redis的安装目录为/usr/local/redis;
   #USE_SYSTEMD=yes：在编译 Redis 时，会包含对 Systemd 的支持，这样 Redis 安装后可以作为 Systemd 服务来管理（启动、停止、自动重启等）；make install 会在安装目录（例如 /usr/local/redis）中生成 redis-server.service 文件模板。但是，这个文件不会自动安装到系统的 systemd 服务目录（通常是 /etc/systemd/system/ 或 /lib/systemd/system/），你需要手动将生成的 .service 文件复制到相应的位置，然后使用 systemctl 命令来启用和管理 Redis 服务。
   make -j 4 PREFIX=/usr/local/redis USE_SYSTEMD=yes install
   ```

4. 配置环境变量

   ```shell
   echo 'export PATH=/usr/local/redis/bin:$PATH' >> /etc/profile.d/redis-path.sh
   source /etc/profile.d/redis-path.sh
   ```

5. 修改配置文件

   ```shell
   mkdir -p /usr/local/redis/{etc,log,data,run}
   cp /usr/local/redis-7.4.0/redis.conf /usr/local/redis/etc/
   ```

6. 启动redis

   - 前台启动

     ```
     /usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf
     ```

   - 后台启动

     ```shell
     #修改redis.conf，把默认的启动方式改为启用后台进程
     vim /usr/local/redis/etc/redis.conf
     daemonize yes
     
     /usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf
     ```

7. 添加Redis为service服务

   ```
   sudo adduser --system --group --no-create-home redis
   #sudo chown -R redis:redis /var/lib/redis
   #sudo chown -R redis:redis /var/log/redis
   touch /usr/local/redis/log/redis.log
   sudo chown -R redis:redis /usr/local/redis/log/redis.log
   cp /usr/local/redis-7.4.0/utils/systemd-redis_server.service /lib/systemd/system/redis-server.service
   
   vim /lib/systemd/system/redis-server.service
   
   [Unit]
   Description=Redis data structure server
   Documentation=https://redis.io/documentation
   Wants=network-online.target
   After=network-online.target
   
   [Service]
   ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf --supervised systemd --daemonize no
   LimitNOFILE=10032
   NoNewPrivileges=yes
   Type=notify
   TimeoutStartSec=infinity
   TimeoutStopSec=infinity
   UMask=0077
   User=redis
   Group=redis
   
   [Install]
   WantedBy=multi-user.target
   Alias=redis.service
   
   
   sudo systemctl daemon-reload
   sudo systemctl enable --now redis-server.service
   sudo systemctl status redis
   ```

8. 安装脚本

   ```shell
   #!/bin/bash
   
   wget https://download.redis.io/releases/redis-7.4.0.tar.gz
   tar xf redis-7.4.0.tar.gz -C /usr/local/
   sudo apt-get update
   sudo apt-get -y install build-essential tcl pkg-config libsystemd-dev
   cd /usr/local/redis-7.4.0
   make -j 4
   make -j 4 PREFIX=/usr/local/redis USE_SYSTEMD=yes install
   echo 'export PATH=/usr/local/redis/bin:$PATH' >> /etc/profile.d/redis-path.sh
   source /etc/profile.d/redis-path.sh
   mkdir -p /usr/local/redis/{etc,log,data,run}
   cp /usr/local/redis-7.4.0/redis.conf /usr/local/redis/etc/
   
   sed -i 's/daemonize no/daemonize yes/' /usr/local/redis/etc/redis.conf
   sed -i 's|^logfile ""|logfile "/usr/local/redis/log/redis.log"|' /usr/local/redis/etc/redis.conf
   
   touch /usr/local/redis/log/redis.log
   
   #sudo adduser --system --group --no-create-home redis
   #sudo chown -R redis:redis /usr/local/redis/log/redis.log
   
   sudo tee /lib/systemd/system/redis-server.service > /dev/null <<EOF
   [Unit]
   Description=Redis data structure server
   Documentation=https://redis.io/documentation
   Wants=network-online.target
   After=network-online.target
   
   [Service]
   ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf --supervised systemd --daemonize no
   ExecStop=/usr/local/redis/bin/redis-cli shutdown
   LimitNOFILE=10032
   NoNewPrivileges=yes
   Type=notify
   TimeoutStartSec=1
   TimeoutStopSec=1
   UMask=0077
   #user=redis
   #group=redis
   
   [Install]
   WantedBy=multi-user.target
   Alias=redis.service
   EOF
   
   
   sudo systemctl daemon-reload
   sudo systemctl enable --now redis-server.service
   
   echo "Redis的安装路径为:/usr/local/redis/bin/"
   echo "Redis的配置文件路径为:/usr/local/redis/etc/redis.conf"
   echo "Redis的日志文件路径为:/usr/local/redis/log/redis.log"
   ```
   

### 主从Redis

#### 临时主从同步

- 主节点配置

  设置主节点密码

  ```
  127.0.0.1:6379>  CONFIG SET masterauth 123456
  OK
  ```

  

- 从节点配置

  设置主节点密码

  ```
  127.0.0.1:6379>  CONFIG SET masterauth 123456
  OK
  ```

  设置Redis主节点的IP和端口

  ```
  127.0.0.1:6379> REPLICAOF 192.168.10.7 6693
  OK
  ```

  

#### 永久主从同步

### 哨兵Redis

### Redis集群   
