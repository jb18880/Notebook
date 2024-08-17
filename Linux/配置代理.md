### apt服务配置代理

#### 临时配置

```shell
$ https_proxy=http://192.168.10.6:10809/ apt update
$ https_proxy=http://192.168.10.6:10809/ apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

#### 永久配置

> 国内无法安装docker，需要配置代理，才能正常的访问download.docker.com，才能正常的安装docker
>
> ```
> $ sudo apt update 
> Hit:1 http://mirrors.ustc.edu.cn/ubuntu jammy InRelease
> Hit:2 http://mirrors.ustc.edu.cn/ubuntu jammy-updates InRelease
> Hit:3 http://mirrors.ustc.edu.cn/ubuntu jammy-backports InRelease
> Hit:4 http://mirrors.ustc.edu.cn/ubuntu jammy-security InRelease
> Ign:5 https://download.docker.com/linux/ubuntu jammy InRelease
> Ign:5 https://download.docker.com/linux/ubuntu jammy InRelease
> Ign:5 https://download.docker.com/linux/ubuntu jammy InRelease
> Err:5 https://download.docker.com/linux/ubuntu jammy InRelease
>   Could not connect to download.docker.com:443 (2a03:2880:f12d:83:face:b00c:0:25de). - connect (113: No route to host) Could not connect to download.docker.com:443 (119.28.87.227), connection timed out
> Reading package lists... Done
> W: Failed to fetch https://download.docker.com/linux/ubuntu/dists/jammy/InRelease  Could not connect to download.docker.com:443 (2a03:2880:f12d:83:face:b00c:0:25de). - connect (113: No route to host) Could not connect to download.docker.com:443 (119.28.87.227), connection timed out
> W: Some index files failed to download. They have been ignored, or old ones used instead.
> ```
>
> 

1. 创建代理配置文件

   效果一样，看你自己选择哦

   ```shell
   touch /etc/apt/apt.conf.d/99-proxy.conf
   touch /etc/apt/apt.conf
   ```

2. 编写配置文件

   ```shell
   vim /etc/apt/apt.conf.d/99-proxy.conf
   
   Acquire::http::Proxy "http://192.168.10.6:10809";
   Acquire::https::Proxy "http://192.168.10.6:10809";
   ```

   > [!CAUTION]
   >
   > http的代理链接是`http://`开头的
   >
   > https的代理链接也是`http://`开头的，不是`https://`开头的，千万注意。**Claude-3-Haiku**不是很聪明，**Claude-3.5-Sonnet**可以给出正确答案。

3. 测试代理是否生效

   > [!NOTE]
   >
   > apt服务修改完配置之后不用重启，立即生效

   ```shell
   $ sudo apt update 
   Hit:1 https://download.docker.com/linux/ubuntu jammy InRelease
   Hit:2 http://mirrors.ustc.edu.cn/ubuntu jammy InRelease
   Hit:3 http://mirrors.ustc.edu.cn/ubuntu jammy-updates InRelease
   Hit:4 http://mirrors.ustc.edu.cn/ubuntu jammy-backports InRelease
   Hit:5 http://mirrors.ustc.edu.cn/ubuntu jammy-security InRelease
   Reading package lists... Done
   Building dependency tree... Done
   Reading state information... Done
   7 packages can be upgraded. Run 'apt list --upgradable' to see them.
   ```

   



### wget工具配置代理

#### 临时配置

```shell
wget -e use_proxy=yes -e http_proxy=http://192.168.10.6:10809 http://example.com
```

#### 永久配置

```shell
vim ~/.wgetrc 

use_proxy = on
http_proxy = http://192.168.10.6:10809/
https_proxy = http://192.168.10.6:10809/
```



### curl工具配置代理

#### 临时配置

```shell
curl -x 192.168.10.6:10809 google.com
```

#### 永久配置

通过`export`配置环境变量，或者将代理相关的环境变量写进`~/.zshrc`中

```shell
echo "export http_proxy=http://192.168.10.6:10809" >> ~/.zshrc
echo "export https_proxy=http://192.168.10.6:10809" >> ~/.zshrc
```

