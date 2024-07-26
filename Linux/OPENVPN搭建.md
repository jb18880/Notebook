# OPENVPN搭建

![](https://telegraph-image-67p.pages.dev/file/dbb3811c0cbdf112682ee.png)

> 服务端A配置
>
> 1. 下载一键安装脚本
> 2. 自动安装

> 客户端B配置
>
> 1. 安装OPENVPN
> 2. 导入配置文件

### 服务端配置

1. 下载一键安装脚本

   ```shell
   wget -O openvpn.sh https://get.vpnsetup.net/ovpn
   ```

2. 打开云服务器的`UDP:1194`端口

3. 自动安装

   ```shell
   sudo bash openvpn.sh --auto
   ```

4. 导出`client.ovpn`文件

   ```shell
   The client configuration is available in: /root/client.ovpn
   ```

### 客户端配置

#### Ubuntu客户端配置

1. 安装openvpn

   ```shell
    sudo apt install openvpn -y
   ```

2. 导入client.ovpn文件

3. 放到client目录下

   ```shell
   /etc/openvpn/client/client.ovpn
   ```


4. 启动客户端

   ```shell
   sudo openvpn --daemon --cd /etc/openvpn/client --config client.ovpn --log-append /var/log/openvpn.log
   ```

5. 验证openvpn是否可用

   ```shell
   root@k8s-master01:~/openvpn# curl google.com
   <HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
   <TITLE>301 Moved</TITLE></HEAD><BODY>
   <H1>301 Moved</H1>
   The document has moved
   <A HREF="http://www.google.com/">here</A>.
   </BODY></HTML>
   ```

   



参考文档：

1. OpenVPN 服务器一键安装脚本 https://github.com/hwdsl2/openvpn-install/blob/master/README-zh.md