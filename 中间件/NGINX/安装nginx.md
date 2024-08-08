# 安装Nginx

### 通过官方软件源安装

1. 卸载旧版nginx

   ```shell
   sudo apt remove nginx nginx-common nginx-full nginx-core
   ```

2. 更新apt软件源

   ```
   #备份source.list文件
   cd /etc/apt
   cp sources.list sources.list.bak
   
   #查看系统代号
   cat /etc/os-release | grep VERSION_CODENAME
   
   #在sources.list中加入nginx的软件源，将"jammy"更改为自己系统的代号
   vim sources.list
   deb [signed-by=/etc/apt/keyrings/nginx_signing.key] http://nginx.org/packages/mainline/ubuntu/ jammy nginx
   deb-src [signed-by=/etc/apt/keyrings/nginx_signing.key]  http://nginx.org/packages/mainline/ubuntu/ jammy nginx
   ```

3. 导入nginx公钥

   ```
   mkdir -p /etc/apt/keyrings/
   cd /etc/apt/keyrings/
   sudo wget http://nginx.org/keys/nginx_signing.key
   ```

4. 安装新版nginx

   ```
   sudo apt-get update
   sudo apt-get install nginx
   ```



> 参考链接：
>
> [Ubuntu使用apt安装最新稳定版nginx步骤（亲测）](https://blog.csdn.net/willingtolove/article/details/111462639)
>
> [What commands (exactly) should replace the deprecated apt-key?](https://askubuntu.com/questions/1286545/what-commands-exactly-should-replace-the-deprecated-apt-key)

 
