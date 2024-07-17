```shell
#!/bin/bash
nginx_version=1.24.0

#if [ -f nginx-${nginx_version}.tar.gz ]; then 
#rm -rf nginx-${nginx_version}.tar.gz 
#fi 

if [ -d nginx-${nginx_version} ]; then 
	mv nginx-${nginx_version} nginx-${nginx_version}_$(date +%Y%m%d_%H%M) 
fi 

yum -y install vim bash-completion net-tools psmisc tar wget unzip httpd-tools

egrep ^nginx /etc/passwd
if [ $? -ne 0 ]; then 
useradd nginx -s /sbin/nologin 
fi 

killall nginx
rm -rf /usr/local/nginx

cd ~

if [ ! -x /usr/bin/wget ]; then 
 yum -y install wget 
fi 

if [ ! -f nginx-${nginx_version}.tar.gz ]; then
wget https://nginx.org/download/nginx-${nginx_version}.tar.gz
fi

if [ ! -x /usr/bin/tar ]; then 
yum -y install tar 
fi 

tar xf nginx-${nginx_version}.tar.gz

cd nginx-${nginx_version}/

yum -y install gcc make pcre-devel openssl-devel zlib-devel

./configure --prefix=/usr/local/nginx \
	--user=nginx \
	--with-http_ssl_module \
	

make && make install

ls /usr/local/nginx

/usr/local/nginx/sbin/nginx -V
```
