# Dockerfile实例

1. 创建alpine镜像

   ```dockerfile
   FROM scratch
   ADD alpine-minirootfs-20240807-x86_64.tar.gz /
   CMD ["/bin/sh"]
   ```

   > [alpine-minirootfs-20240807-x86_64.tar.gz](https://github.com/alpinelinux/docker-alpine/blob/35654ae14e617434d5ca29771296f6b9485eaa85/x86_64/alpine-minirootfs-20240807-x86_64.tar.gz)

   > 创建Docker，生成镜像，并推送至仓库
   >
   > ```shell
   > 
   > #创建项目目录
   > mkdir /path/to/project
   > cd /path/to/project
   > #创建Dockerfile文件
   > vim Dockerfile
   > #下载获取项目所需文件到本地，该文件需要放在Dockerfile同目录中
   > wget https://github.com/alpinelinux/docker-alpine/blob/35654ae14e617434d5ca29771296f6b9485eaa85/x86_64/alpine-minirootfs-20240807-x86_64.tar.gz
   > #构建镜像
   > docker build -t sekitonu/alpine:20240807 .
   > #查看刚刚打包的镜像
   > docker images
   > #登录到dockerhub
   > docker login
   > #推送镜像到dockerhub
   > #推送了三次才成功
   > docker push sekitonu/alpine:20240807
   > 
   > #或者推送镜像到本地harbor仓库：如果要推送到非官方仓库，需要先修改镜像的tag
   > #docker tag sekitonu/alpine:20240807 192.168.10.10/sekitonu/alpine:20240807
   > #docker push 192.168.10.10/sekitonu/alpine:20240807
   > ```

2. 创建rocky镜像

   ```dockerfile
   FROM rockylinux:8.5.20220308
   LABEL author=jb
   LABEL version=v1.0
   LABEL multi.description="this is a rocky mirror" multi.source="this mirror is come from offical rocky mirror" multi.date="20240818"
   ENV OS_VERSION=rockylinux:8.5
   #RUN rm -rf /etc/yum.repo.d/*
   #COPY base.repo /etc/yum.repo.d/
   RUN dnf clean all && \
   	dnf -y install bash-completion \
   				   psmisc \
   				   git \
   				   tree \
   				   net-tools \ 
   				   vim  \
   				   lsof \
   				   iproute && \
   	groupadd -g 88 www && \ 
   	useradd -g www -u 88  -r -s  /sbin/nologin -M -d /home/www www && \
   	rm -rf /etc/localtime && \
   	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \ 
   	rm -rf /var/cache/dnf/* 
   	
   #CMD tail -f /etc/hosts
   CMD [ "/bin/tial","-f","/etc/hosts"]
   ```

3. 创建一个可以自定义启动参数的nginx镜像

   ```dockerfile
   FROM rockylinux:8
   LABEL maintainer="jb"
   ADD nginx-1.26.2.tar.gz /usr/local/
   RUN dnf -y install gcc make pcre pcre-devel zlib zlib-devel openssl openssl-devel && \
   	cd /usr/local/nginx-1.26.2 && \
   	./configure --prefix=/usr/local/nginx/ && \
   	make && \
   	make install && \
   	rm -rf /usr/local/nginx-1.26.2 && \
   	sed -i 's/.*nobody.*/user nginx;/' /usr/local/nginx/conf/nginx.conf && \
   	useradd -r nginx && \
   	dnf clean all
   COPY index.html /usr/share/nginx/www/html/
   VOLUME ["/usr/share/nginx/www/html"]
   EXPOSE 82 443
   CMD ["/usr/local/nginx/sbin/nginx" "-g" "daemon off;"]
   #ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
   #HEALTHCHECK --interval=5s --timeout=3s CMD curl -fs http://127.0.0.1:82
   ```

   ```
   vim index.html
   
   this is a index.html from docker inside
   ```

   ```
   wget https://nginx.org/download/nginx-1.26.2.tar.gz
   ```

   
