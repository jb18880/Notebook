# 搭建http和socks代理

### 前置准备工作

准备一台vps

安装docker

开启1090，7777端口

### 搭建http代理

1. 搭建

   ```
   docker run -d --name='tinyproxy' -p 7777:8888 endoffight/tinyproxy ANY
   #ANY 代表允许所有IP地址，如果只允许特定IP，把ANY改成对应的IP
   ```

2. 验证

   ```
   root@tools:~# curl -x <docker_host_ip>:7777 https://haoip.cn
   ```

### 搭建socks5代理

1. 搭建

   ```
   docker run -d --name socks5 -p 1090:9090 -e PROXY_PORT=9090 serjs/go-socks5-proxy
   ```

2. 验证

   ```
   root@tools:~# curl --socks5 <docker_host_ip>:1090 https://haoip.cn
   ```



> 参考链接：
>
> [老高的技术博客](https://blog.phpgao.com/)
>
> [socks5-server](https://github.com/serjs/socks5-server)

