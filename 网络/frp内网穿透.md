# FRP内网穿透

通过一个`云服务器`做FRP服务端实现通过云服务器的一个端口访问`其他局域网`中的设备。

> FRP项目地址
>
> https://github.com/fatedier/frp
>
> https://gofrp.org/zh-cn/

家中的服务器，有好多虚拟机   -->   云厂商服务器

A						-->  B

### 资源准备

- 公网IP(任意云厂商的服务器)
- 局域网内服务器（被访问）
- FRP跳转服务器(任意云厂商的服务器)

### 中转服务器配置

> 这就是云厂商的服务器，使用该服务器的作用，主要就是提供一个公网的IP地址

1. 判断主机架构

   ```shell
   $ dpkg --print-architecture;arch
   ```

2. 下载对应的安装包

   https://github.com/fatedier/frp/releases

3. 解压

   ```shell
   $ tar zxvf frp_0.58.1_linux_amd64.tar.gz -C /root/.frp
   ```

4. 删除frpc相关文件(客户端文件)

   ```shell
   $ rm -rf frpc*                           
   $ ls
   frps  frps.toml  LICENSE
   ```

5. 启动frps

   ```shell
   $ ./frps -c ./frps.toml
   ```

6. 配置自启动脚本(可选)

   ```shell
   $ sudo vim /etc/systemd/system/frps.service
   
   [Unit]
   # 服务名称，可自定义
   Description = frp server
   After = network.target syslog.target
   Wants = network.target
   
   [Service]
   Type = simple
   # 启动frps的命令，需修改为您的frps的安装路径
   ExecStart = /root/.frp/frps -c /root/.frp/frps.toml
   
   [Install]
   WantedBy = multi-user.target
   ```

   ```shell
   sudo systemctl daemon-reload
   sudo systemctl enable --now frps
   sudo systemctl status frps
   ```

7. 检查端口是否开启

   ```shell
   ☁  ~  ss -antlp
   ```
   目前只启动了frps服务，只能看到7000端口开启；
   当客户端的frpc服务启动后，可以看到6000端口开启。

8. 修改云服务器安全组，将6000和7000端口放开

### 客户端配置

1. 判断主机架构

2. 下载对应安装包

3. 解压

4. 删除frps相关文件(服务器端文件)

   ```shell
   $ rm -rf frps*                           
   $ ls
   frpc  frpc.toml  LICENSE
   ```

5. 编辑frpc配置文件

   ```shell
   vim /root/.frp/frpc.toml
   
   serverAddr = "云服务器的公网IP"
   serverPort = 7000
   
   [[proxies]]
   name = "ssh"
   type = "tcp"
   localIP = "127.0.0.1"
   localPort = 22
   remotePort = 6000   # 可以根据需要改成其他端口
   ```

6. 启动frpc

   ```shell
   $ ./frpc -c ./frpc.toml
   ```

7. 配置自启动脚本(可选)

   ```shell
   $ sudo vim /etc/systemd/system/frpc.service
   
   [Unit]
   # 服务名称，可自定义
   Description = frp client
   After = network.target syslog.target
   Wants = network.target
   
   [Service]
   Type = simple
   # 启动frps的命令，需修改为您的frps的安装路径
   ExecStart = /root/.frp/frpc -c /root/.frp/frpc.toml
   
   [Install]
   WantedBy = multi-user.target
   ```

   ```shell
   sudo systemctl daemon-reload
   sudo systemctl enable frpc --now
   ```

### 通过云服务器连接局域网服务器

```shell
☁  ~  ssh -oPort=6000 username@IP
#username为局域网服务器的用户
#passwd为局域网服务器用户的passwd
#IP为云服务器的公网IP
```
