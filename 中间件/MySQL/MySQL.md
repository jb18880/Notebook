# Mysql

## 1. mysql的安装

#### 1.1安装linux系统自带的版本

centos8上有mysql和mariadb；在centos7上只有mariadb，没有mysql

#### 1.1.1 centos8

查看mysql的安装包

```sh
[root@mysql ~]# yum list mysql-server mysql
Last metadata expiration check: 0:10:04 ago on Tue 26 Sep 2023 04:57:53 PM CST.
Installed Packages
mysql.x86_64                        8.0.32-1.module+el8.8.0+1283+4b88a3a8.0.1                  @AppStream
mysql-server.x86_64                 8.0.32-1.module+el8.8.0+1283+4b88a3a8.0.1                  @AppStream
```

查看mariadb的安装包

```sh
[root@mysql ~]# yum list mariadb-server mariadb
Last metadata expiration check: 0:11:51 ago on Tue 26 Sep 2023 04:57:53 PM CST.
Available Packages
mariadb.x86_64                        3:10.3.39-1.module+el8.8.0+1452+2a7eab68                  AppStream
mariadb-server.x86_64                 3:10.3.39-1.module+el8.8.0+1452+2a7eab68                  AppStream
```



安装mysql服务器端的安装包

由于依赖关系，安装mysql-server的时候，会自动叫将mysql客户端的安装包也装上

```sh
[root@mysql ~]# yum -y install mysql-server
```



#### 1.1.2 centos7

查看mysql和mariadb的版本

```sh
[root@centos7 ~]# yum list mysql-server mysql
Loaded plugins: fastestmirror
Repodata is over 2 weeks old. Install yum-cron? Or run: yum makecache fast
Determining fastest mirrors
 * base: mirror.tuna.tsinghua.edu.cn
 * epel: mirror.tuna.tsinghua.edu.cn
 * extras: mirror.tuna.tsinghua.edu.cn
Error: No matching Packages to list
[root@centos7 ~]# yum list mariadb-server mariadb 
Loaded plugins: fastestmirror
Repodata is over 2 weeks old. Install yum-cron? Or run: yum makecache fast
Loading mirror speeds from cached hostfile
 * base: mirror.tuna.tsinghua.edu.cn
 * epel: mirror.tuna.tsinghua.edu.cn
 * extras: mirror.tuna.tsinghua.edu.cn
Available Packages
mariadb.x86_64                                        1:5.5.68-1.el7                                 base
mariadb-server.x86_64                                 1:5.5.68-1.el7                                 base
```

安装mariadb

```sh
[root@centos7 ~]# yum -y install mariadb-server
```



### 1.2 rpm包安装

#### 1.2.1 手动安装

（这个安装方式好蠢，不建议使用这种安装方式，推荐使用配置yum源之后再进行安装）

去官网下载rpm安装包

```sh
https://dev.mysql.com/downloads/
```

在下面这个网站选择自己需要的安装包

```sh
https://downloads.mysql.com/archives/community/
```

本次实验安装的是5.7版本的mysql（直接下载bundle集合包）

```
mysql-5.7.42-1.el7.x86_64.rpm-bundle.tar
```

将文件传输到linux中之后，先解压，再安装

```sh
[root@centos7 ~]# tar xf mysql-5.7.42-1.el7.x86_64.rpm-bundle.tar
[root@centos7 ~]# yum -y install ./*
```

#### 1.2.2 自动安装

#### 1.2.2.1 centos7自动安装

1. 配置yum源（在centos7上亲测有效，centos8上不行）

   参考文档：https://mirrors.tuna.tsinghua.edu.cn/help/mysql/

   ```sh
   [root@centos7 ~]# cat /etc/yum.repos.d/mysql-community.repo
   [mysql-connectors-community]
   name=MySQL Connectors Community
   baseurl=https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-connectors-community-el7-$basearch/
   enabled=1
   gpgcheck=0
   gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql
   
   [mysql-tools-community]
   name=MySQL Tools Community
   baseurl=https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-tools-community-el7-$basearch/
   enabled=1
   gpgcheck=0
   gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql
   
   [mysql-5.7-community]
   name=MySQL 5.7 Community Server
   baseurl=https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-5.7-community-el7-$basearch/
   enabled=1
   gpgcheck=0
   gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql
   ```
   
   安装mysql服务器端
   
   ```sh
   yum clean all
   yum -y install  mysql-community-server
   systemctl status mysqld
   systemctl enable --now mysqld
   systemctl status mysqld
   ss -antlp
   ```
   
   登录mysql（临时密码在/var/log/mysqld.log中）（该临时密码只能用来修改密码，不能做其他操作）
   
   ```sh
   [root@mysql7 ~]# cat /var/log/mysqld.log  | grep password
   2023-10-07T02:08:48.743967Z 1 [Note] A temporary password is generated for root@localhost: 4XsQWdyS)qiZ
   [root@centos7 yum.repos.d]# mysql -u root -p'4XsQWdyS)qiZ'
   mysql: [Warning] Using a password on the command line interface can be insecure.
   Welcome to the MySQL monitor.  Commands end with ; or \g.
   Your MySQL connection id is 4
   Server version: 5.7.43
   
   Copyright (c) 2000, 2023, Oracle and/or its affiliates.
   
   Oracle is a registered trademark of Oracle Corporation and/or its
   affiliates. Other names may be trademarks of their respective
   owners.
   
   Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
   
   mysql> 
   ```
   

修改密码
```sh
        #简单密码修改失败
        mysql> alter user root@localhost identified by 'Hjb@2023';
        ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
        
        #使用复杂密码
        mysql> alter user root@localhost identified by 'Hjb@2023';
        Query OK, 0 rows affected (0.00 sec)
```

#### 1.2.2.2 centos8自动安装

```sh
yum -y install mysql-server mysql
systemctl status mysqld
systemctl enable --now mysqld
systemctl status mysqld
ss -antlp
```

### 1.3 二进制安装

（已经经过网友编译后的mysql，直接解压就能用了）

1.3.1 安装工具

```sh
yum -y install wget vim
```

安装相关依赖包

```sh
yum -y install libaio numactl-libs ncurses-compat-libs
```

添加用户和组

```sh
groupadd mysql
#-r 建立系统帐号；-g 指定用户所属的群组；-s 指定用户登入后所使用的shell。
useradd -r -g mysql -s /bin/false mysql
```

1.3.3 准备二进制程序（/usr/local是mysqld程序的安装路径）

下载安装包的网页在这里

```sh
https://dev.mysql.com/downloads/mysql/
```

mysql-5.7.43-linux-glibc2.12-x86_64.tar.gz包名中包含linux字样，代表该包为已经编译过的二进制包

/usr/local路径为编译时指定的目录，该包为二进制包，是已经完成了编译过程的，指定的就是/usr/local/目录

```sh
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.43-linux-glibc2.12-x86_64.tar.gz
tar xf mysql-5.7.43-linux-glibc2.12-x86_64.tar.gz -C /usr/local
cd /usr/local/
ln -s mysql-5.7.43-linux-glibc2.12-x86_64/ mysql
chown -R mysql.mysql /usr/local/mysql/
```

准备环境变量

添加环境变量后就可以直接输入mysql命令了，就不用加上绝对路径了

```
echo 'PATH=/usr/local/mysql/bin:$PATH' > /etc/profile.d/mysql.sh
. /etc/profile.d/mysql.sh
```

1.3.4 准备配置文件

/data/mysql为数据库中的数据存放的路径

/usr/local为数据库程序所在的路径

```sh
cp /etc/my.cnf{,.bak}
vim /etc/my.cnf
[mysqld]
datadir=/data/mysql
skip_name_resolve=1
socket=/data/mysql/mysql.sock        
log-error=/data/mysql/mysql.log
pid-file=/data/mysql/mysql.pid
[client]
socket=/data/mysql/mysql.sock
```

1.3.5  初始化数据库文件并提取root密码

```sh
#/data/mysql   会自动生成,但是/data/必须事先存在
mkdir -pv /data/mysql

mysqld --initialize --user=mysql --datadir=/data/mysql

grep password /data/mysql/mysql.log
2019-12-26T13:31:30.458826Z 1 [Note] A temporary password is generated for
root@localhost: LufavlMka6,!
awk '/temporary password/{print $NF}' /data/mysql/mysql.log
LufavlMka6,!

```

准备服务开机自启脚本（可以通过写service文件达到相同效果）

mysql.server为官方提供的启动脚本，将该脚本放到/etc/init.d目录下，命名为mysqld

再通过chkconfig --add mysqld命令添加到服务列表中，就可以实现开机自启

```sh
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
/sbin/chkconfig mysqld on
chkconfig --add mysqld
systemctl start mysqld
systemctl status mysqld
```

修改口令

```sh
修改口令
#修改前面生成的随机密码为指定密码
mysqladmin -uroot -p'LufavlMka6,!' password Hjb@2023
```

测试登录

```sh
mysql -uroot -p'Hjb@2023'
```



### 1.4 多实例安装

1.4.1 不同版本多实例安装

使用二进制安装的方法，配置不同的安装路径即可

1.4.2 相同版本的多实例安装

相同版本的多实例安装，需要配置不同的端口

![image-20231010095911433](F:\typora图片\image-20231010095911433.png)

which可以用来查看PATH变量中的命令的绝对路径，如果查不到结果，说明PATH变量中是没有这个命令的，新安装的软件需要将命令添加到PATH变量中才可以被查看到

![image-20231010100341490](F:\typora图片\image-20231010100341490.png)



多实例安装步骤

```sh
yum -y install mariadb-server
mkdir -pv /mysql/{3306,3307,3308}/{data,etc,socket,log,bin,pid}
#-R选项是递归，所有者和所属组之间可以用英语的句号，也可以用冒号
chown -R mysql.mysql /mysql
#-d是只看目录结构，不列出文件
tree -d /mysql/
#初始化步骤为mysql5.6的命令，在老版的mysql和mariadb中可以使用
mysql_install_db --user=mysql --datadir=/mysql/3306/data
mysql_install_db --user=mysql --datadir=/mysql/3307/data
mysql_install_db --user=mysql --datadir=/mysql/3308/data

#准备配置文件
vim /mysql/3306/etc/my.cnf
[mysqld]
port=3306
datadir=/mysql/3306/data
socket=/mysql/3306/socket/mysql.sock
log-error=/mysql/3306/log/mysql.log
pid-file=/mysql/3306/pid/mysql.pid

sed 's/3306/3307/' /mysql/3306/etc/my.cnf > /mysql/3307/etc/my.cnf
sed 's/3306/3308/' /mysql/3306/etc/my.cnf > /mysql/3308/etc/my.cnf

#准备启动脚本
vim /mysql/3306/bin/mysqld
#!/bin/bash
port=3306
mysql_user="root"
mysql_pwd="123456"
cmd_path="/usr/bin"
mysql_basedir="/mysql"
mysql_sock="${mysql_basedir}/${port}/socket/mysql.sock"

function_start_mysql()
{
    if [ ! -e "$mysql_sock" ];then
     printf "Starting MySQL...\n"
     ${cmd_path}/mysqld_safe --defaults-file=${mysql_basedir}/${port}/etc/my.cnf &> /dev/null &
    else
      printf "MySQL is running...\n"
      exit
    fi
}

function_stop_mysql()
{
    if [ ! -e "$mysql_sock" ];then
       printf "MySQL is stopped...\n"
       exit
    else
       printf "Stoping MySQL...\n"
       #新安装的mysql没有密码，用这一项
       #${cmd_path}/mysqladmin -u${mysql_user} -S ${mysql_sock} shutdown
       #修改mysql登陆的用户密码之后，停止mysql的时候就需要密码了
       ${cmd_path}/mysqladmin -u${mysql_user} -p${mysql_pwd} -S ${mysql_sock} shutdown
   fi
}

function_restart_mysql()
{
   printf "Restarting MySQL...\n"
   function_stop_mysql
    sleep 2
   function_start_mysql
}

case $1 in
start)
   function_start_mysql
;;
stop)
   function_stop_mysql
;;
restart)
   function_restart_mysql
;;
*)
   printf "Usage: ${mysql_basedir}/${port}/bin/mysqld {start|stop|restart}\n"
esac


sed 's/3306/3307/' /mysql/3306/bin/mysqld > /mysql/3307/bin/mysqld
sed 's/3306/3308/' /mysql/3306/bin/mysqld > /mysql/3308/bin/mysqld

chmod +x /mysql/3306/bin/mysqld
chmod +x /mysql/3307/bin/mysqld
chmod +x /mysql/3308/bin/mysqld


/mysql/3306/bin/mysqld start
/mysql/3307/bin/mysqld start
/mysql/3308/bin/mysqld start


/mysql/3308/bin/mysqld start
mysql -h127.0.0.1 -P3308
mysql -uroot -S /mysql/3306/socket/mysql.sock
/mysql/3308/bin/mysqld stop
/mysql/3308/bin/mysqld start

#修改登陆密码方式1
mysqladmin -uroot -S /mysql/3306/socket/mysql.sock password '123456'
mysqladmin -uroot -S /mysql/3307/socket/mysql.sock password '123456'
mysqladmin -uroot -S /mysql/3308/socket/mysql.sock password '123456'
#修改登陆密码方式2
Mariadb>update mysql.user set password=password("centos") where user='root';
Mariadb>flush privileges;

#测试连接
mysql -uroot -p -S /mysql/3306/socket/mysql.sock
mysql -uroot -p123456 -S /mysql/3306/socket/mysql.sock

#将mysql服务添加开机自启
vim /etc/rc.d/rc.local
for i in {3306..3308};do /mysql/$i/bin/mysqld start;done
chmod +x /etc/rc.d/rc.local
```





## 2. 管理mysql

查看mysql服务的状态（mysql的服务名称是mysqld）

```sh
[root@mysql ~]# systemctl status mysqld
● mysqld.service - MySQL 8.0 database server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
[root@mysql ~]# systemctl status mysqld.service
● mysqld.service - MySQL 8.0 database server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
```

启动mysqld服务

```sh
[root@mysql ~]# systemctl enable --now mysqld
Created symlink /etc/systemd/system/multi-user.target.wants/mysqld.service → /usr/lib/systemd/system/mysqld.service.
[root@mysql ~]# systemctl status mysqld.service
● mysqld.service - MySQL 8.0 database server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2023-09-26 17:19:48 CST; 35s ago
  Process: 4541 ExecStartPost=/usr/libexec/mysql-check-upgrade (code=exited, status=0/SUCCESS)
  Process: 4415 ExecStartPre=/usr/libexec/mysql-prepare-db-dir mysqld.service (code=exited, status=0/SUC>
  Process: 4391 ExecStartPre=/usr/libexec/mysql-check-socket (code=exited, status=0/SUCCESS)
 Main PID: 4493 (mysqld)
   Status: "Server is operational"
    Tasks: 39 (limit: 10931)
   Memory: 465.7M
   CGroup: /system.slice/mysqld.service
           └─4493 /usr/libexec/mysqld --basedir=/usr

Sep 26 17:19:44 mysql systemd[1]: Starting MySQL 8.0 database server...
Sep 26 17:19:44 mysql mysql-prepare-db-dir[4415]: Initializing MySQL database
Sep 26 17:19:48 mysql systemd[1]: Started MySQL 8.0 database server.
lines 1-16/16 (END)
```



从上面的 `Main PID: 4493 (mysqld)`可以得知mysql的主进程PID为4493，通过pstree命令可以看到mysql是`单进程多线程`的工作模式。

```sh
[root@mysql ~]# pstree -p 4493
mysqld(4493)─┬─{mysqld}(4498)
             ├─{mysqld}(4499)
             ├─{mysqld}(4500)
             ├─{mysqld}(4501)
             ├─{mysqld}(4502)
             ├─{mysqld}(4503)
             ├─{mysqld}(4504)
             ├─{mysqld}(4505)
             ├─{mysqld}(4506)
             ├─{mysqld}(4507)
             ├─{mysqld}(4508)
             ├─{mysqld}(4509)
             ├─{mysqld}(4510)
             ├─{mysqld}(4511)
             ├─{mysqld}(4512)
             ├─{mysqld}(4513)
             ├─{mysqld}(4514)
             ├─{mysqld}(4517)
             ├─{mysqld}(4518)
             ├─{mysqld}(4519)
             ├─{mysqld}(4520)
             ├─{mysqld}(4521)
             ├─{mysqld}(4522)
             ├─{mysqld}(4523)
             ├─{mysqld}(4524)
             ├─{mysqld}(4525)
             ├─{mysqld}(4526)
             ├─{mysqld}(4530)
             ├─{mysqld}(4531)
             ├─{mysqld}(4532)
             ├─{mysqld}(4533)
             ├─{mysqld}(4534)
             ├─{mysqld}(4535)
             ├─{mysqld}(4536)
             ├─{mysqld}(4537)
             ├─{mysqld}(4538)
             └─{mysqld}(4540)
```

通过进程的PID4493，查看当前进程运行状态

发现运行mysql进程的用户为mysql，是因为在安装mysql服务的时候，系统自动创建了一个mysql用户

```sh
[root@mysql ~]# ps aux | grep 4493
mysql       4493  0.5 23.5 1838784 421192 ?      Ssl  17:19   0:01 /usr/libexec/mysqld --basedir=/usr
root        4584  0.0  0.0  12144  1112 pts/0    S+   17:25   0:00 grep --color=auto 4493
```

查看用户信息（同`cat /etc/passwd`）

```sh
[root@mysql ~]# getent passwd | grep mysql
mysql:x:27:27:MySQL Server:/var/lib/mysql:/sbin/nologin
```

数据库的家目录就是/var/lib/mysql



查看mysql的端口（3306）

```sh
[root@mysql ~]# ss -ntlp
State   Recv-Q  Send-Q    Local Address:Port      Peer Address:Port  Process                             
LISTEN  0       128             0.0.0.0:22             0.0.0.0:*      users:(("sshd",pid=848,fd=3))      
LISTEN  0       128                [::]:22                [::]:*      users:(("sshd",pid=848,fd=4))      
LISTEN  0       70                    *:33060                *:*      users:(("mysqld",pid=4493,fd=21))  
LISTEN  0       151                   *:3306                 *:*      users:(("mysqld",pid=4493,fd=24))  
```

连接mysql进程

前提是mysqld服务已经正常启动，mysql进程端口3306已经正常打开

```sh
[root@mysql ~]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.32 Source distribution

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```



查看mysql命令是由哪个安装包提供的

```sh
#mysql命令的绝对路径
[root@mysql ~]# which mysql
/usr/bin/mysql
#根据命令的绝对路径查看该命令属于哪个安装包
[root@mysql ~]# rpm -qf /usr/bin/mysql
mysql-8.0.32-1.module+el8.8.0+1283+4b88a3a8.0.1.x86_64
[root@mysql ~]# rpm -qf `which mysql`
mysql-8.0.32-1.module+el8.8.0+1283+4b88a3a8.0.1.x86_64
```





#### MySQL账号规格

mysql用户账号由两部分组成：`用户名`和`允许登录的主机`

```sh
'USERNAME'@'HOST'
wang@'10.0.0.100'
wang@'10.0.0.%'
wang@'%'
```

说明：1. HOST限制此用户可通过哪些远程主机连接mysql服务器，只有在特定主机上登陆特定的账户，才可以登录成功

​	   2. `%`匹配任意长度的任意字符,相当于shell中`*`, 示例: `172.16.0.0/255.255.0.0` 或 `172.16.%.%` 

​	   3. `_`匹配任意单个字符,相当于shell中`?`

- 连接mysql

  ```sh
  [root@centos8 ~]# mysql -u root -p123456 -h127.0.0.1 -P3306
  Welcome to the MariaDB monitor.  Commands end with ; or \g.
  Your MariaDB connection id is 8
  Server version: 10.3.39-MariaDB MariaDB Server
  
  Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.
  
  Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
  
  ```

  

- 查看数据库中的用户信息

  ```sh
  MariaDB [(none)]> select user.host from mysql.user;
  +-----------+
  | host      |
  +-----------+
  | 127.0.0.1 |
  | ::1       |
  | centos8   |
  | centos8   |
  | localhost |
  | localhost |
  +-----------+
  6 rows in set (0.001 sec)
  ```



#### mysql配置文件

##### mysql修改默认socket路径

当我们连接到mysql的服务器上时，需要指定mysql的用户名和密码，主机地址和端口，缺一不可，如果缺少某项信息就会报错，缺少主机地址时会报如下错误

```sh
[root@centos8 ~]# mysql -uroot -p123456 -P3306
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock' (2)
```



不过这些信息都可以在配置文件中指定，指定默认的配置项，比如：上述报错中的/var/lib/mysql/mysql.sock路径就是mysql默认的配置，我们现在修改一下，使得我们在命令行中不用每次都输入该主机地址

```sh
root@centos8 ~]# mysql --help
...
Default options are read from the following files in the given order:
/etc/my.cnf ~/.my.cnf 
```



mysql的默认配置文件是`/etc/my.cnf`和 `~/.my.cnf` ，通常都是家目录下的配置文件（ `~/.my.cnf` ）先生效，当家目录下没有这个配置文件的话，才会调用系统的配置文件（`/etc/my.cnf`）。配置文件中分为不同的模块，有`mysqld`模块和`mysql`、`client`等模块，当修改了`mysqld`模块时，需要重启`mysqld`应用才能将配置生效，而当修改的配置模块是其他的`非mysqld`模块时，无需重启`mysqld`应用，只需要重新打开对应的程序即可生效。

由于暂时没有创建家目录下的配置文件，所以一直都是主配置文件在生效

```sh
[root@centos8 ~]# ll ~/.my.cnf
ls: cannot access '/root/.my.cnf': No such file or directory
```

看一下主配置文件

```sh
[root@centos8 ~]# cat /etc/my.cnf
#
# This group is read both both by the client and the server
# use it for options that affect everything
#
[client-server]

#
# include all files from the config directory
#
!includedir /etc/my.cnf.d

```

主配置文件中没有相关的配置项，直接去配置目录查看

```sh
[root@centos8 ~]# ls /etc/my.cnf.d
auth_gssapi.cnf  client.cnf  enable_encryption.preset  mariadb-server.cnf  mysql-clients.cnf
```

查看myslq客户端的配置

```sh
[root@centos8 my.cnf.d]# cat mysql-clients.cnf
#
# These groups are read by MariaDB command-line tools
# Use it for options that affect only one utility
#

[mysql]

[mysql_upgrade]

[mysqladmin]

[mysqlbinlog]

[mysqlcheck]

[mysqldump]

[mysqlimport]

[mysqlshow]

[mysqlslap]


```

-在mysql下面的区域就是写mysql命令的配置文件的地方（在7-9行之间的区域写的配置只针对mysql命令生效，在9-11行之间的区域写的配置只针对mysql_upgrade命令生效...）

```sh
[root@centos8 my.cnf.d]# vim mysql-clients.cnf 
#
# These groups are read by MariaDB command-line tools
# Use it for options that affect only one utility
#

[mysql]
socket=/mysql/3306/socket/mysql.sock

[mysql_upgrade]

[mysqladmin]

[mysqlbinlog]

[mysqlcheck]

[mysqldump]

[mysqlimport]

[mysqlshow]

[mysqlslap]

```

- 修改mysql工具的默认socket路径

在[mysql]配置项中添加上socket的配置项，就可以配置socket的默认路径

我们再连接一次mysql，这次不在命令行中输入socket路径

```sh
[root@centos8 my.cnf.d]# mysql -uroot -p123456 -P3306
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 9
Server version: 10.3.39-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> 
```



##### mysql设置免密登录

通过二进制安装的mysql，每次登录mysql的时候，都需要输入用户名和密码，可以通过将用户名和密码写入到配置文件中，这样以后登录的时候，就不用输入用户名和密码了

注意：配置用户名和密码需要在`[mysql]`模块中配置

```
[root@mysql ~]# vim /etc/my.cnf 
[mysqld]
datadir=/data/mysql
skip_name_resolve=1
socket=/data/mysql/mysql.sock
log-error=/data/mysql/mysql.log
pid-file=/data/mysql/mysql.pid
[client]
socket=/data/mysql/mysql.sock

[mysql]
user=root
password=Hjb@2023
```





#### mysql管理命令

##### 命令1：mysql

mysql的管理命令分为两种：客户端命令和服务器端命令

```
mysql客户端命令不用以英文分号结尾，mysql服务器端命令必须以英文分号结尾。
建议在mysql内执行的所有命令都加上英文分号
```

客户端命令可以通过在mysql命令行界面输入`\h`进行查看，客户端命令可以在mysql命令行界面通过输入`help contents`进行查看

```
[root@centos8 ~]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 10
Server version: 8.0.32 Source distribution

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> \h

For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.
resetconnection(\x) Clean session context.
query_attributes Sets string parameters (name1 value1 name2 value2 ...) for the next query to pick up.
ssl_session_data_print Serializes the current SSL session data to stdout or file

For server side help, type 'help contents'
```

在mysql命令行中输入help contents后，可以看到myslq服务器端有很多子类别的命令，输入`help+子类别`就可以查看到该类别下面具体的命令，例如：`help Administration`

```sh
mysql> help contents
You asked for help about help category: "Contents"
For more information, type 'help <item>', where <item> is one of the following
categories:
   Account Management
   Administration
   Components
   Compound Statements
   Contents
   Data Definition
   Data Manipulation
   Data Types
   Functions
   Geographic Features
   Help Metadata
   Language Structure
   Loadable Functions
   Plugins
   Prepared Statements
   Replication Statements
   Storage Engines
   Table Maintenance
   Transactions
   Utility
```

以下为`help Administration`的帮助结果，可以看到有很多子选项，输入`help+子选项`就可查看对应的帮助，例如：`help SHOW CREATE DATABASE`

```sh
mysql> help Administration
You asked for help about help category: "Administration"
For more information, type 'help <item>', where <item> is one of the following
topics:
   BINLOG
   CACHE INDEX
   FLUSH
   HELP COMMAND
   KILL
   LOAD INDEX
   RESET
   RESET PERSIST
   RESTART
   SET
   SET CHARACTER SET
   SET CHARSET
   SET NAMES
   SHOW
   SHOW BINARY LOGS
   SHOW BINLOG EVENTS
   SHOW CHARACTER SET
   SHOW COLLATION
   SHOW COLUMNS
   SHOW CREATE DATABASE
   SHOW CREATE EVENT
   SHOW CREATE FUNCTION
   SHOW CREATE PROCEDURE
   SHOW CREATE SCHEMA
   SHOW CREATE TABLE
   SHOW CREATE TRIGGER
   SHOW CREATE USER
   SHOW CREATE VIEW
   SHOW DATABASES
   SHOW ENGINE
   SHOW ENGINES
   SHOW ERRORS
   SHOW EVENTS
   SHOW FIELDS
   SHOW FUNCTION CODE
   SHOW FUNCTION STATUS
   SHOW GRANTS
   SHOW INDEX
   SHOW MASTER LOGS
   SHOW MASTER STATUS
   SHOW OPEN TABLES
   SHOW PLUGINS
   SHOW PRIVILEGES
   SHOW PROCEDURE CODE
   SHOW PROCEDURE STATUS
   SHOW PROCESSLIST
   SHOW PROFILE
   SHOW PROFILES
   SHOW RELAYLOG EVENTS
   SHOW REPLICA STATUS
   SHOW REPLICAS
   SHOW SCHEMAS
   SHOW SLAVE HOSTS
   SHOW SLAVE STATUS
   SHOW STATUS
   SHOW TABLE STATUS
   SHOW TABLES
   SHOW TRIGGERS
   SHOW VARIABLES
   SHOW WARNINGS
   SHUTDOWN

```



mysql常用命令

- status

  查看当前mysql数据库的状态信息

  ==最下面那一行是数据库性能监控的重要指标==

```
mysql> status;
--------------
mysql  Ver 8.0.32 for Linux on x86_64 (Source distribution)

Connection id:		10
Current database:	
Current user:		root@localhost
SSL:			Not in use
Current pager:		stdout
Using outfile:		''
Using delimiter:	;
Server version:		8.0.32 Source distribution
Protocol version:	10
Connection:		Localhost via UNIX socket
Server characterset:	utf8mb4
Db     characterset:	utf8mb4
Client characterset:	utf8mb4
Conn.  characterset:	utf8mb4
UNIX socket:		/var/lib/mysql/mysql.sock
Binary data as:		Hexadecimal
Uptime:			1 day 30 min 4 sec

Threads: 2  Questions: 11  Slow queries: 0  Opens: 140  Flush tables: 3  Open tables: 56  Queries per second avg: 0.000
--------------
```

- use

  `show databases;`查看当前服务器上有多少个数据库，用`use+数据库名`进行切换数据库

  ```
  mysql> show databases;
  +--------------------+
  | Database           |
  +--------------------+
  | information_schema |
  | mysql              |
  | performance_schema |
  | sys                |
  +--------------------+
  4 rows in set (0.04 sec)
  
  mysql> use mysql;
  Reading table information for completion of table and column names
  You can turn off this feature to get a quicker startup with -A
  
  Database changed
  ```

- prompt

  prompt是mysql数据库的提示符，mysql默认是不显示在哪个数据库的，可以通过修改mysql的提示符来看到自己在哪个数据库，但是有个问题：在mysql命令行执行prompt命令只能会临时生效，退出mysql就没了，需要写进配置文件才可以永久生效

  ```sql
  [root@centos8 ~]# man mysql
  ...
         ·   Set the prompt interactively.  You can change your prompt interactively by using the prompt
             (or \R) command. For example:
  
                 mysql> prompt (\u@\h) [\d]>\_
                 PROMPT set to ´(\u@\h) [\d]>\_´
                 (user@host) [database]>
                 (user@host) [database]> prompt
                 Returning to default PROMPT of mysql>
  
  
  ---
  mysql> prompt (\u@\h) [\d]>\_
  PROMPT set to '(\u@\h) [\d]>\_'
  (root@localhost) [mysql]> 
  
  [root@centos8 my.cnf.d]# vim client.cnf
  [client]
  prompt=(\u@\h) [\d]>\_
  
  [root@centos8 my.cnf.d]# mysql
  Welcome to the MySQL monitor.  Commands end with ; or \g.
  Your MySQL connection id is 12
  Server version: 8.0.32 Source distribution
  
  Copyright (c) 2000, 2023, Oracle and/or its affiliates.
  
  Oracle is a registered trademark of Oracle Corporation and/or its
  affiliates. Other names may be trademarks of their respective
  owners.
  
  Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
  
  (root@localhost) [(none)]> 
  ```
  
  如果不想进入那么深的目录中修改配置文件的话，也可以直接修改主配置文件

  ```sh
  [root@centos8 my.cnf.d]# vim /etc/my.cnf
  #
  # This group is read both both by the client and the server
  # use it for options that affect everything
  #
  [client-server]
  
  #
  # include all files from the config directory
  #
  !includedir /etc/my.cnf.d
  
  [mysql]
  prompt=(\u@\h) [\d]>\_
  
  [root@centos8 my.cnf.d]# mysql
  Welcome to the MySQL monitor.  Commands end with ; or \g.
  Your MySQL connection id is 15
  Server version: 8.0.32 Source distribution
  
  Copyright (c) 2000, 2023, Oracle and/or its affiliates.
  
  Oracle is a registered trademark of Oracle Corporation and/or its
  affiliates. Other names may be trademarks of their respective
  owners.
  
  Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
  
  (root@localhost) [(none)]> 
  ```




##### 命令2：mysqladmin

mysqladmin命令的许多参数跟mysql的一样。例如-u，-p，-P

mysqladmin每次登录的时候也需要输入用户名和密码，建议也写进配置文件中

```sh
[root@mysql ~]# vim /etc/my.cnf 
[mysqld]
datadir=/data/mysql
skip_name_resolve=1
socket=/data/mysql/mysql.sock
log-error=/data/mysql/mysql.log
pid-file=/data/mysql/mysql.pid
[client]
socket=/data/mysql/mysql.sock

[mysql]
user=root
password=Hjb@2023

[mysqladmin]
user=root
password=Hjb@2023
```

查看mysql当前状态

```sh
[root@mysql ~]# mysqladmin status
Uptime: 61380  Threads: 1  Questions: 129  Slow queries: 0  Opens: 168  Flush tables: 1  Open tables: 161  Queries per second avg: 0.002
```

关闭数据库

```sh
[root@mysql ~]# mysqladmin shutdown
[root@mysql ~]# ss -antl
State       Recv-Q      Send-Q           Local Address:Port           Peer Address:Port     Process      
LISTEN      0           128                    0.0.0.0:22                  0.0.0.0:*                     
LISTEN      0           128                       [::]:22                     [::]:*                     
```

mysqladmin命令可以关闭数据库不能启动数据库（猜想：mysql命令和mysqladmin命令都是mysql内部的命令，mysql命令如果没有启动的话，是不能执行该命令的）

启动mysql

奇怪，启动不了mysql，重启才成功（可能是mysqladmin命令跟systemctl控制命令不兼容）

```sh
[root@mysql ~]# systemctl start mysqld
[root@mysql ~]# systemctl status mysqld
● mysqld.service - LSB: start and stop MySQL
   Loaded: loaded (/etc/rc.d/init.d/mysqld; generated)
   Active: active (exited) since Fri 2023-10-20 15:21:38 CST; 17h ago
     Docs: man:systemd-sysv-generator(8)
    Tasks: 0 (limit: 10931)
   Memory: 0B
   CGroup: /system.slice/mysqld.service

Oct 20 15:21:36 mysql systemd[1]: Starting LSB: start and stop MySQL...
Oct 20 15:21:38 mysql mysqld[880]: Starting MySQL..
Oct 20 15:21:38 mysql mysqld[1747]: [  OK  ]
Oct 20 15:21:38 mysql systemd[1]: Started LSB: start and stop MySQL.
```



通过mysqladmin创建和删除数据库

```sh
[root@mysql ~]# mysqladmin create hjbdb
[root@mysql ~]# mysql -e "show databases;"
+--------------------+
| Database           |
+--------------------+
| information_schema |
| hjbdb              |
| mysql              |
| performance_schema |
| sys                |
+--------------------+

[root@mysql ~]# mysqladmin drop hjbdb
Dropping the database is potentially a very bad thing to do.
Any data stored in the database will be destroyed.

Do you really want to drop the 'hjbdb' database [y/N] y
Database "hjbdb" dropped
[root@mysql ~]# mysql -e "show databases;"
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
```



mysqladmin命令判断数据库是否存活

```sh
#数据库是存活状态
[root@mysql ~]# mysqladmin ping
mysqld is alive
#停止数据库
[root@mysql ~]# systemctl stop mysqld
#mysqladmin连接不上，不发探测存活状态
[root@mysql ~]# mysqladmin ping
mysqladmin: connect to server at 'localhost' failed
error: 'Can't connect to local MySQL server through socket '/data/mysql/mysql.sock' (2)'
Check that mysqld is running and that the socket: '/data/mysql/mysql.sock' exists!
```





##### 命令3：mycli

Rocky先安装python，再安装mycli（失败了）

```sh
[root@mysql ~]# yum -y install python3-pip
[root@mysql ~]# pip3 install --upgrade pip
[root@mysql ~]# pip3 install mycli
```

Uubntu安装mycli

```
root@hjb:~# apt -y install mysql-server
root@hjb:~# ss -antlp
[root@ubuntu1804 ~]#apt -y install mycli
#[root@ubuntu1804 ~]#mycli -u root -S /var/run/mysqld/mysqld.sock

root@hjb:~# mycli
mysql 8.0.34-0ubuntu0.20.04.1
mycli 1.20.1
Chat: https://gitter.im/dbcli/mycli
Mail: https://groups.google.com/forum/#!forum/mycli-users
Home: http://mycli.net
Thanks to the contributor - Chris Anderton
mysql root@(none):(none)> show databases                                                                           
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set
Time: 0.007s
```



#### mysql脚本

通过mysql脚本也可以管理mysql的客户端

通常mysql的脚本都是sql后缀的（约定俗成）

1. 登录到mysql之后，通过source命令执行脚本

```sql
[root@mysql ~]# cat test.sql 
use mysql;
show databases;
select @@port;

[root@mysql ~]# mysql -uroot -pHjb@2023
mysql> source test.sql
Database changed
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)

+--------+
| @@port |
+--------+
|   3306 |
+--------+
1 row in set (0.00 sec)
```

2. 不登录mysql数据库，通过输入重定向直接调用脚本

   （这个执行结果看起来好奇怪啊）

```sql
[root@mysql ~]# mysql -uroot -pHjb@2023 < test.sql
mysql: [Warning] Using a password on the command line interface can be insecure.
Database
information_schema
mysql
performance_schema
sys
@@port
3306
```



#### 非交互执行mysql命令

通过mysql -e参数，可以非交互式执行mysql命令，执行的命令需要加双引号引起来，如果一次要执行多个命令，那么双引号内的多个命令之间需要用分号分隔开

```sql
[root@mysql ~]# mysql -uroot -pHjb@2023 -e status
mysql: [Warning] Using a password on the command line interface can be insecure.
--------------
mysql  Ver 14.14 Distrib 5.7.43, for linux-glibc2.12 (x86_64) using  EditLine wrapper

Connection id:		10
Current database:	
Current user:		root@localhost
SSL:			Not in use
Current pager:		stdout
Using outfile:		''
Using delimiter:	;
Server version:		5.7.43 MySQL Community Server (GPL)
Protocol version:	10
Connection:		Localhost via UNIX socket
Server characterset:	latin1
Db     characterset:	latin1
Client characterset:	utf8
Conn.  characterset:	utf8
UNIX socket:		/data/mysql/mysql.sock
Uptime:			21 min 58 sec

Threads: 1  Questions: 104  Slow queries: 0  Opens: 168  Flush tables: 1  Open tables: 161  Queries per second avg: 0.078
--------------


[root@mysql ~]# mysql -uroot -pHjb@2023 -e "select @@port;show databases;select @@hostname"
mysql: [Warning] Using a password on the command line interface can be insecure.
+--------+
| @@port |
+--------+
|   3306 |
+--------+
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
+------------+
| @@hostname |
+------------+
| mysql      |
+------------+

[root@mysql ~]# mysql -uroot -pHjb@2023 -e "select user()"
mysql: [Warning] Using a password on the command line interface can be insecure.
+----------------+
| user()         |
+----------------+
| root@localhost |
+----------------+
```





## 3. SQL语句

### 3.1 SQL语句规范

#### 3.1.1 SQL语句不区分大小写

在数据库系统中，SQL语句中的关键字不区分大小写，建议用大写；但是表名，数据库名是区分大小写的

SQL语句中的关键字是不区分大小写的

```sql
mysql> select @@hostname;
+------------+
| @@hostname |
+------------+
| mysql      |
+------------+
1 row in set (0.00 sec)

mysql> SELECT @@hostname;
+------------+
| @@hostname |
+------------+
| mysql      |
+------------+
1 row in set (0.00 sec)

mysql> SELECT @@HOSTname;
+------------+
| @@HOSTname |
+------------+
| mysql      |
+------------+
1 row in set (0.01 sec)

```



数据库中的表名和数据库名是区分大小写的

此处数据库是mysql，表名是user

```sql
mysql> select user,host from mysql.user;
+---------------+-----------+
| user          | host      |
+---------------+-----------+
| mysql.session | localhost |
| mysql.sys     | localhost |
| root          | localhost |
+---------------+-----------+
3 rows in set (0.04 sec)

mysql> select user,host from mysql.USER;
ERROR 1146 (42S02): Table 'mysql.USER' doesn't exist
mysql> select user,host from MYSQL.user;
ERROR 1146 (42S02): Table 'MYSQL.user' doesn't exist
mysql> select user,Host from mysql.user;
+---------------+-----------+
| user          | Host      |
+---------------+-----------+
| mysql.session | localhost |
| mysql.sys     | localhost |
| root          | localhost |
+---------------+-----------+
3 rows in set (0.00 sec)

mysql> select User,Host from mysql.user;
+---------------+-----------+
| User          | Host      |
+---------------+-----------+
| mysql.session | localhost |
| mysql.sys     | localhost |
| root          | localhost |
+---------------+-----------+
3 rows in set (0.00 sec)

```

#### 3.1.2 SQL语句可单行或多行书写

SQL语句可单行或多行书写，默认以 " ; " 结尾 

```sql
mysql> select User,Host from mysql.user;
+---------------+-----------+
| User          | Host      |
+---------------+-----------+
| mysql.session | localhost |
| mysql.sys     | localhost |
| root          | localhost |
+---------------+-----------+
3 rows in set (0.00 sec)

mysql> select User,Host 
    -> from 
    -> mysql.user;
+---------------+-----------+
| User          | Host      |
+---------------+-----------+
| mysql.session | localhost |
| mysql.sys     | localhost |
| root          | localhost |
+---------------+-----------+
3 rows in set (0.00 sec)
```

#### 3.1.3 关键词不能跨多行或简写 

```sql
mysql> select User,Host from mysql.user;
+---------------+-----------+
| User          | Host      |
+---------------+-----------+
| mysql.session | localhost |
| mysql.sys     | localhost |
| root          | localhost |
+---------------+-----------+
3 rows in set (0.00 sec)

mysql> selec
    -> t User,Host from mysql.user;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'selec
t User,Host from mysql.user' at line 1
mysql> select User,Host from my
    -> sql.user;
ERROR 1046 (3D000): No database selected
```

#### 3.1.4 用空格和TAB 缩进来提高语句的可读性 

#### 3.1.5 子句通常位于独立行，便于编辑，提高可读性

#### 3.1.6 SQL注释

一般是用于sql脚本使用哦

- SQL注释（关系型数据库通用注释）

  ```sh
  #单行注释，注意有空格
  -- 注释内容  
  
  #多行注释
  /*注释内容
  注释内容
  注释内容*/
  ```

- MySQL注释

  mysql的注释方式跟linux一样，也是用#开头，注释#开头的行

  ```sh
  #1.单行注释，注意有空格
  -- 注释内容  
  
  #2.多行注释
  /*注释内容
  注释内容
  注释内容*/
  
  #3.mysql专用注释
  # 注释内容
  
  ```



### 3.2 SQL语句类型

#### 3.2.1 DDL: Data Defination Language 数据定义语言

CREATE，DROP，ALTER（针对数据库进行的操作，创建、删除、修改数据库）

#### 3.2.2 DML: Data Manipulation Language 数据操纵语言

 INSERT，DELETE，UPDATE 软件开发：CRUD（针对表进行的增删改的操作，向表中插入、删除、修改数据）

#### 3.3.3 DQL：Data Query Language 数据查询语言

 SELECT （查询表中的数据）

#### 3.3.4 DCL：Data Control Language 数据控制语言

 GRANT，REVOKE（权限控制的相关操作；GRANT是授权，REVOKE是取消授权）

#### 3.3.5 TCL：Transaction Control Language 事务控制语言

 COMMIT，ROLLBACK，SAVEPOINT（事务相关的操作，COMMIT提交，ROLLBACK回滚，SAVEPOINT设置保存点）



### 3.3 SQL语句的组成



#### 3.3.1 SQL语句的组成

单个关健字Keyword组成子句clause，多条clause组成语句

示例：

```
SELECT *                 #SELECT子句
FROM products            #FROM子句
WHERE price>666          #WHERE子句
```

说明：该SQL语句由三个子句构成，SELECT,FROM和WHERE是关键字



#### 3.3.2 SQL语句的帮助文档

- 官方帮助文档

  ```sh
  https://dev.mysql.com/doc/refman/8.0/en/sql-statements.html
  ```

- 查帮助文档

  ```sql
  mysql> help contents;
  You asked for help about help category: "Contents"
  For more information, type 'help <item>', where <item> is one of the following
  categories:
     Account Management
     Administration
     Compound Statements
     Contents
     Data Definition
     Data Manipulation
     Data Types
     Functions
     Geographic Features
     Help Metadata
     Language Structure
     Loadable Functions
     Plugins
     Prepared Statements
     Procedures
     Replication Statements
     Storage Engines
     Table Maintenance
     Transactions
     Utility
  
  mysql> help Data Definition;
  You asked for help about help category: "Data Definition"
  For more information, type 'help <item>', where <item> is one of the following
  topics:
     ALTER DATABASE
     ALTER EVENT
     ALTER FUNCTION
     ALTER INSTANCE
     ALTER LOGFILE GROUP
     ALTER PROCEDURE
     ALTER SCHEMA
     ALTER SERVER
     ALTER TABLE
     ALTER TABLESPACE
     ALTER VIEW
     CREATE DATABASE
     CREATE EVENT
     CREATE FUNCTION
     CREATE INDEX
     CREATE LOGFILE GROUP
     CREATE PROCEDURE
     CREATE SCHEMA
     CREATE SERVER
     CREATE TABLE
     CREATE TABLESPACE
     CREATE TRIGGER
     CREATE VIEW
     DROP DATABASE
     DROP EVENT
     DROP FUNCTION
     DROP INDEX
     DROP PROCEDURE
     DROP SCHEMA
     DROP SERVER
     DROP TABLE
     DROP TABLESPACE
     DROP TRIGGER
     DROP VIEW
     FOREIGN KEY
     RENAME TABLE
     TRUNCATE TABLE
  
  mysql> help CREATE DATABASE;
  Name: 'CREATE DATABASE'
  Description:
  Syntax:
  CREATE {DATABASE | SCHEMA} [IF NOT EXISTS] db_name
      [create_option] ...
  
  create_option: [DEFAULT] {
      CHARACTER SET [=] charset_name
    | COLLATE [=] collation_name
  }
  
  CREATE DATABASE creates a database with the given name. To use this
  statement, you need the CREATE privilege for the database. CREATE
  SCHEMA is a synonym for CREATE DATABASE.
  
  URL: https://dev.mysql.com/doc/refman/5.7/en/create-database.html
  ```



### 3.4 字符集和排序

#### 3.4.1 字符集

早期MySQL版本默认为 latin1，从MySQL8.0开始默认字符集已经为 utf8mb4

latin1：只支持ASCII码，不支持中文显示，只要mysql中包含中文，就会乱码

uft8：在mysql中，utf8编码是一个精简版的utf8，有部分偏门文字是显示不了的，可以显示常用中文，不支持生僻字

utf8mb4：支持全球文字，支持所有文字



字符集有四个级别：实例级别，数据库级别，表级别，字段级别

==建议在数据库实例部署成功之后，就将字符集修改好，后面再创建数据库，创建表的时候就可以自动继承实例的字符集，不用单独设置了。==

```
实例1：
当安装mariadb之后，默认的字符集是latin1，此时创建的数据库和表默认都是latin1字符集类型的，现在如果通过alter命令修改表的字符集类型为utf8mb4，会发现表的字符集修改成功，但是表中已创建的资源仍然是latin1.是因为字符集设置仅对修改后创建的资源有效，不会影响修改前的资源。此种情况，就需要在配置文件中修改字符集，再将表中的记录修改字符集。
```

查看Linux系统当前的字符集类型

```sh
[root@mysql ~]# echo $LANG
en_US.UTF-8
```

查看mysql支持的字符集

```sql
mysql> show charset;
```

查看mysql当前使用的字符集

```sql
mysql> show variables like 'character%';
```

修改mysqld服务器默认的字符集

​	MySQL8.0的默认字符集是utf8mb4；mariadb和的默认字符集是utf8

​	第一步：修改mysql主配置文件

​	第二步：添加mysqld的配置项，在下面加上修改字符集的配置

​	第三步：重启mysqld

```sh
vim /etc/my.cnf
[mysqld]
character-set-server=utf8mb4

[root@mysql mysql]# systemctl restart mysqld
mysql> show variables like 'character_set%';
```

修改mysql客户端的默认字符集

​	客户端修改字符集后不需要重启

```sh
vim /etc/my.cnf
#针对mysql客户端
[mysql]
default-character-set=utf8mb4

#针对所有MySQL客户端
[client]
default-character-set=utf8mb4
```





#### 3.4.2 排序规则

说起排序规则就离不开字符集，严格来说，排序规则是依赖于字符集的。

字符集是用来定义MySQL存储不同字符的方式，而==排序规则一般指对字符集中字符串之间的比较、排序制定的规则==。一种字符集可以对应多种排序规则，但是一种排序规则只能对应指定的一种字符集，两个不同的字符集不能有相同的排序规则。（转自https://www.51cto.com/article/628621.html）

查看mysql支持的所有的排序规则

```sql
mysql> show collation;
```

查看mysql当前使用的排序规则

```sql
mysql> show variables like 'collation%';
+----------------------+--------------------+
| Variable_name        | Value              |
+----------------------+--------------------+
| collation_connection | utf8mb4_general_ci |
| collation_database   | utf8mb4_general_ci |
| collation_server     | utf8mb4_general_ci |
+----------------------+--------------------+
```



## 4. 数据库管理

数据库管理就是DDL语句的实际操作了，包含了创建数据库，删除数据库和修改数据库。

### 4.1 数据库的基本操作

#### 4.1.1 创建数据库

##### 4.1.1.1 查看创建数据库的帮助信息

```sql
mysql> help create database 
Name: 'CREATE DATABASE'
Description:
Syntax:
CREATE {DATABASE | SCHEMA} [IF NOT EXISTS] db_name
    [create_option] ...

create_option: [DEFAULT] {
    CHARACTER SET [=] charset_name
  | COLLATE [=] collation_name
}

CREATE DATABASE creates a database with the given name. To use this
statement, you need the CREATE privilege for the database. CREATE
SCHEMA is a synonym for CREATE DATABASE.

URL: https://dev.mysql.com/doc/refman/5.7/en/create-database.html
```



##### 4.1.1.2 创建默认字符集和排序规则的数据库

在创建数据库的时候，最简单的命令就是`create database basename`，在创建数据库的时候还可以指定`特定的字符集`和`排序规则`，如果在创建数据库的时候不指定，那么就会使用`/etc/my.cnf`中指定的`默认的字符集和排列规则`。

在mysql8.0之后的版本中还多了一个数据库密码的功能，在用户创建数据库的时候还可以指定访问密码，那么在用户访问该数据库的时候，就需要密码才能正常访问该数据库。

- 通过DDL语句创建数据库

  ```sql
  mysql> create
      -> database
      -> hjb
      -> ;
  Query OK, 1 row affected (0.02 sec)
  
  mysql> show databases;
  +--------------------+
  | Database           |
  +--------------------+
  | information_schema |
  | hjb                |
  | mysql              |
  | performance_schema |
  | sys                |
  +--------------------+
  5 rows in set (0.01 sec)
  ```

- 通过mysqladmin工具创建数据库

  ```sql
  [root@mysql mysql]# mysqladmin create db1
  mysql> show datebases;
  ```
  

##### 4.1.1.3 创建非默认字符集和排序规则的数据库

- 通过DDL语句创建字符集为`latin1`的数据库

```sql
mysql> create database hhh character set=latin1;
Query OK, 1 row affected (0.00 sec)
mysql> show databases;

mysql> use hhh
mysql> show variables like 'collation%';
mysql> show variables like 'character_set%';

```

- 通过DDL语句创建排序规则为`cp866_general_ci`的数据库

```sql

mysql> create database jjj collate=cp866_general_ci ;
Query OK, 1 row affected (0.00 sec)
mysql> show databases;

mysql> use jjj
mysql> show variables like 'collation%';
mysql> show variables like 'character_set%';
```

- 通过DDL语句创建`字符集`为`big5`、`排序规则`为`big5_chinese_ci`的数据库

```sql
mysql> create database bbb character set=big5  collate=big5_chinese_ci;
Query OK, 1 row affected (0.00 sec)
mysql> show databases;
mysql> use bbb
Database changed
mysql> show collation;
mysql> show variables like 'collation%';
mysql> show variables like 'character_set%';
```

##### 4.1.1.4 查看数据库是如何被创建的

```sql
mysql> show create database hhh;
mysql> show create database jjj;
mysql> show create database bbb;
```

##### 4.1.1.5 数据库中的数据存放的位置

数据库在linux系统中的表现形式是文件夹

​	二进制安装的数据库，数据存放的位置是自己指定的（`databir`后面指定的目录就是）

​	yum安装的数据库，数据存放位置是`/var/lib/mysql/`

```sh
#二进制安装的数据库，数据存放的位置由自己指定
[root@mysql mysql]# ll -d /data/mysql/{hhh,jjj,bbb}
drwxr-x--- 2 mysql mysql 20 Oct 24 11:52 /data/mysql/bbb
drwxr-x--- 2 mysql mysql 20 Oct 24 11:41 /data/mysql/hhh
drwxr-x--- 2 mysql mysql 20 Oct 24 11:47 /data/mysql/jjj
```



### 4.1.2 删除数据库

删除数据库的本质就是删除了该数据库在linux系统上的文件夹

- 通过DDL语句删除数据库

  ```sql
  mysql> drop database hhh;
  Query OK, 0 rows affected (0.01 sec)
  ```

  查看linux系统中的数据库文件夹

  ```sql
  [root@mysql mysql]# ll -d /data/mysql/{hhh,jjj,bbb}
  ls: cannot access '/data/mysql/hhh': No such file or directory
  drwxr-x--- 2 mysql mysql 20 Oct 24 11:52 /data/mysql/bbb
  drwxr-x--- 2 mysql mysql 20 Oct 24 11:47 /data/mysql/jjj
  ```



### 4.1.3 修改数据库

修改数据库主要就是修改数据库名、数据库的字符集和数据库的排序方式

```sql
mysql> show create database hjb;

mysql> alter database hjb character set latin1;

mysql> show create database hjb;
```





## 5. 数据类型

在学习如何操作表之前，需要先理解数据类型，理解了数据类型才知道表是如何被创建出来的。表创建出来之后，后续对表的优化，也是针对数据类型进行优化的

[菜鸟教程](https://www.runoob.com/mysql/mysql-data-types.html)

[简书](https://www.jianshu.com/p/672049b65691)



### MySQL支持三类数据类型

数据类型的作用是用来限定表中存储的数据的规格的，例如数据长什么样，数据占磁盘多少空间。

```sh
选择正确的数据类型对于获得高性能至关重要
三大原则： 
1. 更小的通常更好，尽量使用可正确存储数据的最小数据类型 
2. 简单就好，简单数据类型的操作通常需要更少的CPU周期 
3. 尽量避免NULL，包含为NULL的列，对MySQL更难优化
```



1. 数值型

   数值型包括：整数类型、浮点小数类型、定点小数类型三种

   整数类型包括 `TINYINT`、`SMALLINT`、`MEDIUMINT`、`INT`、`BIGINT`、浮点小数数据类型包括 `FLOAT`和 `DOUBLE`、定点小数类型 包括`DECIMAL`

   | 类型名称     | 存储需求 | 数值范围                |
   | ------------ | -------- | ----------------------- |
   | TINYINT      | 1个字节  | (-128，127)             |
   | SMALLINT     | 2个字节  | (-32 768，32 767)       |
   | MEDIUMINT    | 3个字节  | (-8 388 608，8 388 607) |
   | INT(INTEGER) | 4个字节  |                         |
   | BIGINT       | 8个字节  |                         |

   ```sh
   注意：int(m)里的m是表示SELECT查询结果集中的显示宽度，并不影响实际的取值范围，规定了MySQL的一些 交互工具（例如MySQL命令行客户端）用来显示字符的个数。对于存储和计算来说，Int(1)和Int(20)是 相同的
   ```

2. 日期/时间类型

3. 字符串类型

   [char与varchar的区别](https://blog.csdn.net/qq_40994734/article/details/125345201)





## 6. 修饰符

适用所有类型的修饰符： NULL 数据列可包含NULL值，默认值 NOT NULL 数据列不允许包含NULL值，相当于网站注册表中的 * 为必填选项 DEFAULT 默认值 PRIMARY KEY 主键，所有记录中此字段的值不能重复，且不能为NULL UNIQUE KEY 唯一键，所有记录中此字段的值不能重复，但可以为NULL 存放的汉字个数与版本相关。 mysql 4.0以下版本，varchar(50) 指的是 50 字节，如果存放 UTF8 格式编码的汉字时（每个汉字3字 节），只能存放16 个。 mysql 5.0以上版本，varchar(50) 指的是 50 字符，无论存放的是数字、字母还是 UTF8 编码的汉字， 都可以存放 50 个。 CHARACTER SET name 指定一个字符集







适用数值型的修饰符： AUTO_INCREMENT 自动递增，适用于整数类型, 必须作用于某个 key 的字段,比如primary key UNSIGNED 无符号

## 7. 表管理

查看如何创建表

```sql
mysql> help create table
```



创建表

- 通过DML语句来创建表

  创建表的时候，需要指定三个参数：`表名+字段名+修饰符`

  创建表的时候，需要先切换到对应的数据库中，然后再进行创建操作

  ```sql
  mysql> use db1;
  Database changed
  
  CREATE TABLE student (
  id int UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(20) NOT NULL,
  age tinyint UNSIGNED,
  #height DECIMAL(5,2),
  gender ENUM('M','F') default 'M'
  );
  
  mysql> show tables;
  +---------------+
  | Tables_in_db1 |
  +---------------+
  | student       |
  +---------------+
  1 row in set (0.00 sec)
  ```

- 根据其他表来创建表

  1. 用`as`来创建表，会得到与原来的表`一样的数据`和`大致相同的表结构`

     ```sql
     MariaDB [db1]> create table teacher as select * from student;
     
     MariaDB [db1]> select * from teacher;
     +-----+--------+------+--------+
     | id  | name   | age  | gender |
     +-----+--------+------+--------+
     | 100 | 周深   |   18 | M      |
     +-----+--------+------+--------+
     1 row in set (0.000 sec)
     
     MariaDB [db1]> select * from student;
     +-----+--------+------+--------+
     | id  | name   | age  | gender |
     +-----+--------+------+--------+
     | 100 | 周深   |   18 | M      |
     +-----+--------+------+--------+
     1 row in set (0.000 sec)
     
     MariaDB [db1]> desc teacher;
     +--------+---------------------+------+-----+---------+-------+
     | Field  | Type                | Null | Key | Default | Extra |
     +--------+---------------------+------+-----+---------+-------+
     | id     | int(10) unsigned    | NO   |     | 0       |       |
     | name   | varchar(20)         | NO   |     | NULL    |       |
     | age    | tinyint(3) unsigned | YES  |     | NULL    |       |
     | gender | enum('M','F')       | YES  |     | M       |       |
     +--------+---------------------+------+-----+---------+-------+
     4 rows in set (0.001 sec)
     
     MariaDB [db1]> desc student;
     +--------+---------------------+------+-----+---------+----------------+
     | Field  | Type                | Null | Key | Default | Extra          |
     +--------+---------------------+------+-----+---------+----------------+
     | id     | int(10) unsigned    | NO   | PRI | NULL    | auto_increment |
     | name   | varchar(20)         | NO   |     | NULL    |                |
     | age    | tinyint(3) unsigned | YES  |     | NULL    |                |
     | gender | enum('M','F')       | YES  |     | M       |                |
     +--------+---------------------+------+-----+---------+----------------+
     4 rows in set (0.001 sec)
     ```

  2. 用like创建表，会得到和student一样的表结构，单数表中无数据

     ```sql
     MariaDB [db1]> create table emp like student;
     Query OK, 0 rows affected (0.005 sec)
     
     MariaDB [db1]> desc emp;
     +--------+---------------------+------+-----+---------+----------------+
     | Field  | Type                | Null | Key | Default | Extra          |
     +--------+---------------------+------+-----+---------+----------------+
     | id     | int(10) unsigned    | NO   | PRI | NULL    | auto_increment |
     | name   | varchar(20)         | NO   |     | NULL    |                |
     | age    | tinyint(3) unsigned | YES  |     | NULL    |                |
     | gender | enum('M','F')       | YES  |     | M       |                |
     +--------+---------------------+------+-----+---------+----------------+
     4 rows in set (0.001 sec)
     
     MariaDB [db1]> select * from emp;
     Empty set (0.000 sec)
     ```



查看表结构

 	1. `desc+表名`可以查看表结构，效果跟`show columns from +表名;`一样
 	2. `show create table +表名`可以看得更详细些，包含了创建表时未指定的默认项

```sql
mysql> desc student;
mysql> show columns from student;

mysql> show create table student;
```



查看表中的内容

​	查看表中的所有内容（`*`代表表中所有字段）

```sql
mysql> select * from student;
Empty set (0.01 sec)
```

​	查看表中的内容（纵向展示）

​	`\G`可以将表中的内容纵向展示，适合那些列数较多不便展示的表

```sql
mysql> show table status like 'student';
mysql> show table status like 'student'\G;
```



修改表的结构

​	一般来说，表被创建好之后是不需要进行修改表结构的，因为表的结构一旦发生变化，代表原来的一些数据都发生了变化，那么程序逻辑也要随之修改，工作量非常大，所以一般不建议创建表之后再修改表结构。可以在创建表的时候添加上一些冗余字段，将来要添加字段的时候，只需要将冗余字段进行修改就行了

==数据库和表的结构一旦定义好了之后，就不要去改动了。==

​	添加一个手机号的字段

```sql
mysql>  alter table student add phone_number char(11);
mysql> desc student;
```



删除表

```sql
mysql> drop table student;
Query OK, 0 rows affected (0.01 sec)

mysql> show tables;
Empty set (0.00 sec)
```



表在linux中的存在形式

​	表就存在于mysql数据库的文件夹中

```sh
[root@centos8 db1]# ll /data/mysql/db1
total 112
-rw-r----- 1 mysql mysql    65 Oct 27 15:04 db.opt
-rw-r----- 1 mysql mysql  8654 Oct 27 15:34 student.frm
-rw-r----- 1 mysql mysql 98304 Oct 27 15:34 student.ibd
```



### 7.1 DML语句

DML语句就是对表中的记录进行增删改的操作，包含了INSERT,DELETE,UPDATE

#### 7.1.1 INSERT语句

- INSERT用法

  ```sql
  mysql> help insert
  Name: 'INSERT'
  Description:
  Syntax:
  INSERT [LOW_PRIORITY | DELAYED | HIGH_PRIORITY] [IGNORE]
      [INTO] tbl_name
      [PARTITION (partition_name [, partition_name] ...)]
      [(col_name [, col_name] ...)]
      {VALUES | VALUE} (value_list) [, (value_list)] ...
      [ON DUPLICATE KEY UPDATE assignment_list]
  
  INSERT [LOW_PRIORITY | DELAYED | HIGH_PRIORITY] [IGNORE]
      [INTO] tbl_name
      [PARTITION (partition_name [, partition_name] ...)]
      SET assignment_list
      [ON DUPLICATE KEY UPDATE assignment_list]
  
  INSERT [LOW_PRIORITY | HIGH_PRIORITY] [IGNORE]
      [INTO] tbl_name
      [PARTITION (partition_name [, partition_name] ...)]
      [(col_name [, col_name] ...)]
      SELECT ...
      [ON DUPLICATE KEY UPDATE assignment_list]
  ```

  - INSERT实例

    创建一个表

    ```sql
    mysql> use db1;
    Database changed
    
    CREATE TABLE student (
    id int UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    age tinyint UNSIGNED,
    #height DECIMAL(5,2),
    gender ENUM('M','F') default 'M'
    );
    
    ```

    插入一条数据

    ```sql
    mysql> insert student (name,age,gender) values ('周维',18,'F');
    Query OK, 1 row affected (0.020 sec)
    ```

    

    使用mariadb数据库，在student表中插入一条数据

    安装数据库

    ```sh
    [root@centos8 ~]# yum -y install mariadb-server
    [root@centos8 ~]# systemctl start mariadb
    [root@centos8 ~]# mysql
    ```

    创建数据库

    ```sql
    MariaDB [(none)]> use db1;
    Database changed
    MariaDB [db1]> CREATE TABLE student (
        -> id int UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        -> name VARCHAR(20) NOT NULL,
        -> age tinyint UNSIGNED,
        -> #height DECIMAL(5,2),
        -> gender ENUM('M','F') default 'M'
        -> );
    Query OK, 0 rows affected (0.005 sec)
    ```

    插入相同的语句会报错

    ```sql
    #字符集不对，无法显示中文，需要修改字符集
    MariaDB [db1]> insert student (name,age,gender) values ('周深',19,'M');
    ERROR 1366 (22007): Incorrect string value: '\xE5\x91\xA8\xE6\xB7\xB1' for column `db1`.`student`.`name` at row 1
    ```

  解析：mysql和mariadb的默认字符集是不一样的，mysql8.0的默认字符集是`utf8mb4`，mariadb的默认字符集是`latin1`.而`latin1`字符集不支持中文，所以中文名字无法正常显示；现在需要mariadb数据库的字符集修改为`utf8mb4`，mariadb才能正常显示中文。

  建议：==如果有字符集的需要，可以在创建数据库实例的时候就把字符集的选项配置好==



- 修改mariadb数据库的默认字符集

  - 通过命令行的方式进行修改

    查看mariadb数据库的字符集

    ```sql
    MariaDB [db1]> show variables like 'character%';
    ```

    查看student表中各个字段的数据类型

    ```sql
    MariaDB [db1]> show create table student;
    ```

    通过DML语句修改mariadb的字符集

    ```sql
    MariaDB [db1]> alter table student character set utf8mb4;
    Query OK, 0 rows affected (0.001 sec)
    Records: 0  Duplicates: 0  Warnings: 0
    ```

    再次查看表结构

    ```sql
    MariaDB [db1]> show create table student;
    ```

    发现表的默认字符集改成了`utf8mb4`，但是`name`和`gender`字段的字符集仍然是`latin1`

    原因是：在数据库中修改了配置之后，只会影响之后添加的资源，先前添加的资源是不受影响的，所以之前创建的资源的字符集还是`latin1`，遇到这种情况，建议趁早删除数据库，再将字符集改正确之后，重新创建一个新的数据库。

  - 通过配置文件修改字符集

    在配置文件中，`[mysqld]`模块是针对数据库服务器生效的，`[client]`是针对所有的客户端（包括`mysql、mysqladmi...`）生效的。

    ```sh
    [root@centos8 ~]# vim /etc/my.cnf
    ...
    [mysqld]
    character-set-server=utf8mb4
    
    [client]
    default-character-set=utf8mb4
    
    [root@centos8 ~]# systemctl restart mariadb
    [root@centos8 ~]# mysql
    ```



- 修改字符集后重新插入数据

  配置文件中修改了字符集，修改的是将来创建的资源的字符集，已创建的资源是不受影响的，所以之前的资源的字符集仍然是latin1，现在需要将数据库删掉，再重新创建，重新插入

  1. 查看student表的结构

     ```sql
     MariaDB [db1]> show create table student;
     ```

  2. 创建数据库

     ```sql
     MariaDB [db1]> show create database db1;
     MariaDB [db1]> drop database db1;
     MariaDB [(none)]> create database db1;
     MariaDB [(none)]> show create database db1;
     ```

  3. 创建表

     ```sql
     MariaDB [(none)]> use db1;
     Database changed
     MariaDB [db1]> CREATE TABLE student (
      -> id int UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      -> name VARCHAR(20) NOT NULL,
      -> age tinyint UNSIGNED,
      -> #height DECIMAL(5,2),
      -> gender ENUM('M','F') default 'M'
      ->  );
     Query OK, 0 rows affected (0.003 sec)
     ```

  4. 插入数据

     ```sql
     MariaDB [db1]> insert into student (id,name,age,gender) values (100,'周深',18,'M');
     Query OK, 1 row affected (0.001 sec)
     ```

  5. 查看记录

     ```sql
     MariaDB [db1]> select * from student;
     +-----+--------+------+--------+
     | id  | name   | age  | gender |
     +-----+--------+------+--------+
     | 100 | 周深   |   18 | M      |
     +-----+--------+------+--------+
     1 row in set (0.000 sec)
     ```

  6. 再添加一条记录

     ​	注意：由于`id`字段设置了`自动增长（AUTO_INCREMENT）`修饰符，所以不用写`id`的具体的值，他会自己增长的；`gender`一栏设置了默认值，不写的话，默认就是`‘M’`；INSERT语句中`into`在`MySQL`中是可以省略不写的。

     ```sql
     mysql> insert student (name,age) values ('王维','24');
     Query OK, 1 row affected (0.00 sec)
     
     mysql> select * from student;
     +-----+--------+------+--------+
     | id  | name   | age  | gender |
     +-----+--------+------+--------+
     | 100 | 周深   |   18 | M      |
     | 101 | 王维   |   24 | M      |
     +-----+--------+------+--------+
     2 rows in set (0.00 sec)
     ```



- 批量插入记录到表中

  1. 通过复制表中的记录导入到新的表中

     ```sql
     MariaDB [db1]> select * from student;
     +-----+--------+------+--------+
     | id  | name   | age  | gender |
     +-----+--------+------+--------+
     | 100 | 周深   |   18 | M      |
     +-----+--------+------+--------+
     1 row in set (0.000 sec)
     
     MariaDB [db1]> create table emp like student;
     Query OK, 0 rows affected (0.005 sec)
     
     MariaDB [db1]> select * from emp;
     Empty set (0.001 sec)
     
     MariaDB [db1]> select * from emp;
     +-----+--------+------+--------+
     | id  | name   | age  | gender |
     +-----+--------+------+--------+
     | 100 | 周深   |   18 | M      |
     +-----+--------+------+--------+
     1 row in set (0.000 sec)
     ```

  2. 通过DML语句插入多条记录

     在插入记录的时候，如果所有字段都需要指定的话，可以不用写字段名，但是要按照`select`查出来的`字段顺序`进行赋值

     ```sql
     MariaDB [db1]> insert emp 
     Display all 761 possibilities? (y or n)
     MariaDB [db1]> insert emp values (101,'李白',20,'M'),(102,'杜甫','32','M');
     Query OK, 2 rows affected (0.001 sec)
     Records: 2  Duplicates: 0  Warnings: 0
     
     MariaDB [db1]> select * from emp;
     +-----+--------+------+--------+
     | id  | name   | age  | gender |
     +-----+--------+------+--------+
     | 100 | 周深   |   18 | M      |
     | 101 | 李白   |   20 | M      |
     | 102 | 杜甫   |   32 | M      |
     +-----+--------+------+--------+
     3 rows in set (0.000 sec)
     ```

     

- 添加一条默认值为NULL的数据

  由于在定义字段的属性的时候，设置了默认可以为空，所以当未定义年龄的时候，该字段就为空值。

  ```sql
  MariaDB [db1]> insert emp (name,gender) values ('李商隐','F');
  Query OK, 1 row affected (0.001 sec)
  
  MariaDB [db1]> desc emp;
  +--------+---------------------+------+-----+---------+----------------+
  | Field  | Type                | Null | Key | Default | Extra          |
  +--------+---------------------+------+-----+---------+----------------+
  | id     | int(10) unsigned    | NO   | PRI | NULL    | auto_increment |
  | name   | varchar(20)         | NO   |     | NULL    |                |
  | age    | tinyint(3) unsigned | YES  |     | NULL    |                |
  | gender | enum('M','F')       | YES  |     | M       |                |
  +--------+---------------------+------+-----+---------+----------------+
  4 rows in set (0.001 sec)
  
  MariaDB [db1]> select * from emp;
  +-----+-----------+------+--------+
  | id  | name      | age  | gender |
  +-----+-----------+------+--------+
  | 100 | 周深      |   18 | M      |
  | 101 | 李白      |   20 | M      |
  | 102 | 杜甫      |   32 | M      |
  | 103 | 李商隐    | NULL | F      |
  +-----+-----------+------+--------+
  4 rows in set (0.000 sec)
  ```

  

#### 7.1.2 UPDATE语句

update语句是用来修改表中内容的语句

```sql
MariaDB [db1]> help update
Name: 'UPDATE'
Description:
Syntax
------

Single-table syntax:

UPDATE [LOW_PRIORITY] [IGNORE] table_reference 
 [PARTITION (partition_list)]
 [FOR PORTION OF period FROM expr1 TO expr2]
 SET col1={expr1|DEFAULT} [,col2={expr2|DEFAULT}] ...
 [WHERE where_condition]
 [ORDER BY ...]
 [LIMIT row_count]
```

修改表中杜甫`id=102`的年龄为31`age=31`

​	修改单条数据的时候，一定要记得加`where`做限定条件，如果不加限定条件，就会将该表中所有记录的`age`都改成了31

```sql
MariaDB [db1]> update emp set age=31 where id=102;
Query OK, 1 row affected (0.001 sec)
Rows matched: 1  Changed: 1  Warnings: 0

MariaDB [db1]> select * from emp;
+-----+-----------+------+--------+
| id  | name      | age  | gender |
+-----+-----------+------+--------+
| 100 | 周深      |   18 | M      |
| 101 | 李白      |   20 | M      |
| 102 | 杜甫      |   31 | M      |
| 103 | 李商隐    | NULL | F      |
+-----+-----------+------+--------+
4 rows in set (0.000 sec)
```

修改同一条记录中的多个字段

```sql
MariaDB [db1]> update emp set age=16,name='吕布' where id=101;
Query OK, 1 row affected (0.001 sec)
Rows matched: 1  Changed: 1  Warnings: 0

MariaDB [db1]> select * from emp;
+-----+-----------+------+--------+
| id  | name      | age  | gender |
+-----+-----------+------+--------+
| 100 | 周深      |   18 | M      |
| 101 | 吕布      |   16 | M      |
| 102 | 杜甫      |   31 | M      |
| 103 | 李商隐    | NULL | F      |
+-----+-----------+------+--------+
4 rows in set (0.000 sec)
```



#### 7.1.3 DELETE语句

delete语句会将表中的记录删除掉

​	也是要注意添加where进行限定，否则会出事故

```sql
MariaDB [db1]> delete from emp where id=101;
Query OK, 1 row affected (0.001 sec)

MariaDB [db1]> select * from emp;
+-----+-----------+------+--------+
| id  | name      | age  | gender |
+-----+-----------+------+--------+
| 100 | 周深      |   18 | M      |
| 102 | 杜甫      |   31 | M      |
| 103 | 李商隐    | NULL | F      |
+-----+-----------+------+--------+
3 rows in set (0.000 sec)
```

​	生产中一般都不会使用delete语句，这样的操作太危险了，生产中都是在表中添加一个deleted字段，然后给该字段设置标签，值为1代表已经删除，值为0代表该数据任然存在。

添加deleted字段

```sql
MariaDB [db1]> select * from emp;
+-----+-----------+------+--------+
| id  | name      | age  | gender |
+-----+-----------+------+--------+
| 100 | 周深      |   18 | M      |
| 102 | 杜甫      |   31 | M      |
| 103 | 李商隐    | NULL | F      |
+-----+-----------+------+--------+
3 rows in set (0.000 sec)

MariaDB [db1]> alter table emp add deleted char(1);
Query OK, 0 rows affected (0.002 sec)
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [db1]> select * from emp;
+-----+-----------+------+--------+---------+
| id  | name      | age  | gender | deleted |
+-----+-----------+------+--------+---------+
| 100 | 周深      |   18 | M      | NULL    |
| 102 | 杜甫      |   31 | M      | NULL    |
| 103 | 李商隐    | NULL | F      | NULL    |
+-----+-----------+------+--------+---------+
3 rows in set (0.000 sec)

MariaDB [db1]> update emp set deleted=1 where id=102;
Query OK, 1 row affected (0.001 sec)
Rows matched: 1  Changed: 1  Warnings: 0

MariaDB [db1]> select * from emp;
+-----+-----------+------+--------+---------+
| id  | name      | age  | gender | deleted |
+-----+-----------+------+--------+---------+
| 100 | 周深      |   18 | M      | NULL    |
| 102 | 杜甫      |   31 | M      | 1       |
| 103 | 李商隐    | NULL | F      | NULL    |
+-----+-----------+------+--------+---------+
3 rows in set (0.000 sec)
```



清空表的两种方法

​	delete

```sql
MariaDB [db1]> delete from student;
Query OK, 1 row affected (0.001 sec)
```

​	truncate

```sql
MariaDB [db1]> truncate table student;
Query OK, 0 rows affected (0.005 sec)
```





### 7.2 DQL语句

运维用得最多的就是DQL语句

- 去重

  使用`distinct`去重

  关键字`distinct`要放在待去重字段前面

  ```sql
  select distinct university from user_profile;
  ```

  使用`gropup by`去重

  `group by +分组字段`放在`select`语句最后面

  ```sql
  select university from user_profile group by university;
  ```

- 限制输出结果

  LIMIT 子句可以被用于强制 SELECT 语句返回指定的记录数。
  LIMIT 接受一个或两个数字参数。参数必须是一个整数常量。
  如果只给定一个参数，它表示返回最大的记录行数目。
  如果给定两个参数，第一个参数指定第一个返回记录行的偏移量，第二个参数指定返回记录行的最大数目。
  为了检索从某一个偏移量到记录集的结束所有的记录行，可以指定第二个参数为 -1。
  初始记录行的偏移量是 0(而不是 1)。

  例5.检索记录行 6-10

  ```sql
  SELECT * FROM table LIMIT 5,5
  ```

  例6.检索记录行 11-last

  ```sql
  SELECT * FROM table LIMIT 10,-1
  ```

  例7.检索前 5 个记录行

  ```sql
  SELECT * FROM table LIMIT 5
  ```

- 取别名

  改变列标题(取别名)

  语法：

  ```sql
  列名 | 表达式 [ AS ] 新列名
  ```

  或：

  ```sql
  新列名＝列名 | 表达式
  ```

  例8.：

  ```sql
  SELECT 姓名, year(getdate())-year(出生日期) AS 年龄 FROM 学生表
  ```

  题解

  题目：现在你需要查看**2个**用户明细**设备ID**数据，并**将列名改为 'user_infors_example'**,，请你从用户信息表取出相应结果。

  ```sql
  SELECT device_id AS user_infos_example FROM user_profile LIMIT 2
  ```

- NULL

  |#查找年龄大于24岁的用户信息#

  ```sql
  SELECT device_id, gender, age, university FROM user_profile WHERE age is not null and age > 24
  ```

  null 是大于所有数值型还是小于所有数值型是由 DBMS 决定的，严谨起见，还是加上 age is not null 的条件

#### 7.2.1 单表查询

1. 查询的对象只存在于单张表中的查询过程称做单表查询

2. 查询某个表中的记录时有两种查询方法：

    1. 进入到数据库中，查询

       ```sql
       use mysql;
       select * from user;
       ```

   2. 不进入到数据库中，查询

   ```sql
   select * from mysql.user;
   ```

3. 当表中的字段过多时，可以选择部分字段进行显示

```sql
select * from mysql.user;
select user,host from mysql.user;
```

==注意==：不要随便使用select * 进行查询操作，该操作很危险，因为当表中的数据很多（几千万条数据）的情况下，该命令会对表进行全表扫描，会给系统带来很大的cpu占用率，可能导致系统瘫痪，无法访问。

4. 为字段取别名

   当表中的字段名为英文名时，查询的结果看起来不方便，可以给查询的字段设置别名；或者说某些字段太长，可以设置个别名精简一下。

   ```sql
   MariaDB [db1]> select * from emp;
   +-----+-----------+------+--------+---------+
   | id  | name      | age  | gender | deleted |
   +-----+-----------+------+--------+---------+
   | 100 | 周深      |   18 | M      | NULL    |
   | 102 | 杜甫      |   31 | M      | 1       |
   | 103 | 李商隐    | NULL | F      | NULL    |
   +-----+-----------+------+--------+---------+
   3 rows in set (0.000 sec)
   
   MariaDB [db1]> select id,name from emp;
   +-----+-----------+
   | id  | name      |
   +-----+-----------+
   | 100 | 周深      |
   | 102 | 杜甫      |
   | 103 | 李商隐    |
   +-----+-----------+
   3 rows in set (0.000 sec)
   
   MariaDB [db1]> select id 学员编号,name 姓名 from emp;
   +--------------+-----------+
   | 学员编号     | 姓名      |
   +--------------+-----------+
   |          100 | 周深      |
   |          102 | 杜甫      |
   |          103 | 李商隐    |
   +--------------+-----------+
   3 rows in set (0.000 sec)
   ```

5. 当表中数据过多时，一定要添加限制条件，毕竟不是每条数据都是我们想看的

   ```SQL
   MariaDB [db1]> select id 学员编号,name 姓名 from emp where gender='F';
   +--------------+-----------+
   | 学员编号     | 姓名      |
   +--------------+-----------+
   |          103 | 李商隐    |
   +--------------+-----------+
   1 row in set (0.000 sec)
   ```

6. 根据多个限定条件进行查询

   ```sql
   MariaDB [db1]> INSERT emp (name,age) values ('王昌龄',23),('白居易',25),('张飞',67),('黄忠',89),('廉颇',90);
   Query OK, 5 rows affected (0.001 sec)
   Records: 5  Duplicates: 0  Warnings: 0
   
   MariaDB [db1]> select * from emp;
   +-----+-----------+------+--------+---------+
   | id  | name      | age  | gender | deleted |
   +-----+-----------+------+--------+---------+
   | 100 | 周深      |   18 | M      | NULL    |
   | 102 | 杜甫      |   31 | M      | 1       |
   | 103 | 李商隐    | NULL | F      | NULL    |
   | 104 | 王昌龄    |   23 | M      | NULL    |
   | 105 | 白居易    |   25 | M      | NULL    |
   | 106 | 张飞      |   67 | M      | NULL    |
   | 107 | 黄忠      |   89 | M      | NULL    |
   | 108 | 廉颇      |   90 | M      | NULL    |
   +-----+-----------+------+--------+---------+
   8 rows in set (0.000 sec)
   
   MariaDB [db1]> select * from emp where age >=30 and age <= 80;
   +-----+--------+------+--------+---------+
   | id  | name   | age  | gender | deleted |
   +-----+--------+------+--------+---------+
   | 102 | 杜甫   |   31 | M      | 1       |
   | 106 | 张飞   |   67 | M      | NULL    |
   +-----+--------+------+--------+---------+
   2 rows in set (0.000 sec)
   ```

7. 查询字段含NULL的记录

   ​	使用`age=NULL`做限定条件来查询时，是查不出来的，应该用`age is NULL`

   ```SQL
   MariaDB [db1]> insert emp (name,gender) values ('孙二娘','F'),('董卿','F');
   Query OK, 2 rows affected (0.002 sec)
   Records: 2  Duplicates: 0  Warnings: 0
   
   MariaDB [db1]> select * from emp;
   +-----+-----------+------+--------+---------+
   | id  | name      | age  | gender | deleted |
   +-----+-----------+------+--------+---------+
   | 100 | 周深      |   18 | M      | NULL    |
   | 102 | 杜甫      |   31 | M      | 1       |
   | 103 | 李商隐    | NULL | F      | NULL    |
   | 104 | 王昌龄    |   23 | M      | NULL    |
   | 105 | 白居易    |   25 | M      | NULL    |
   | 106 | 张飞      |   67 | M      | NULL    |
   | 107 | 黄忠      |   89 | M      | NULL    |
   | 108 | 廉颇      |   90 | M      | NULL    |
   | 109 | 孙二娘    | NULL | F      | NULL    |
   | 110 | 董卿      | NULL | F      | NULL    |
   +-----+-----------+------+--------+---------+
   10 rows in set (0.001 sec)
   
   MariaDB [db1]> select * from emp where age = NULL ;
   Empty set (0.000 sec)
   
   MariaDB [db1]> select * from emp where age is NULL ;
   +-----+-----------+------+--------+---------+
   | id  | name      | age  | gender | deleted |
   +-----+-----------+------+--------+---------+
   | 103 | 李商隐    | NULL | F      | NULL    |
   | 109 | 孙二娘    | NULL | F      | NULL    |
   | 110 | 董卿      | NULL | F      | NULL    |
   +-----+-----------+------+--------+---------+
   3 rows in set (0.000 sec)
   
   MariaDB [db1]> select * from emp where age is not NULL ;
   +-----+-----------+------+--------+---------+
   | id  | name      | age  | gender | deleted |
   +-----+-----------+------+--------+---------+
   | 100 | 周深      |   18 | M      | NULL    |
   | 102 | 杜甫      |   31 | M      | 1       |
   | 104 | 王昌龄    |   23 | M      | NULL    |
   | 105 | 白居易    |   25 | M      | NULL    |
   | 106 | 张飞      |   67 | M      | NULL    |
   | 107 | 黄忠      |   89 | M      | NULL    |
   | 108 | 廉颇      |   90 | M      | NULL    |
   +-----+-----------+------+--------+---------+
   7 rows in set (0.000 sec)
   ```

8. 模糊查询，模糊匹配

   ​	查询表中所有李姓的人，由于是==模糊匹配==，所以要用`like`，不能用`=`，`=`是精确匹配用的。

   ```sql
   MariaDB [db1]> select * from emp where name = '李%';
   Empty set (0.001 sec)
   
   MariaDB [db1]> select * from emp where name like '李%';
   +-----+-----------+------+--------+---------+
   | id  | name      | age  | gender | deleted |
   +-----+-----------+------+--------+---------+
   | 103 | 李商隐    | NULL | F      | NULL    |
   +-----+-----------+------+--------+---------+
   1 row in set (0.001 sec)
   ```

   ​	查询名字中包含“昌”字的用户

   ```sql
   MariaDB [db1]> select * from emp where name like '%昌%';
   +-----+-----------+------+--------+---------+
   | id  | name      | age  | gender | deleted |
   +-----+-----------+------+--------+---------+
   | 104 | 王昌龄    |   23 | M      | NULL    |
   +-----+-----------+------+--------+---------+
   1 row in set (0.001 sec)
   ```

9. 聚合函数

   常见的聚合函数包括`sum，max，min，avg，count`等

   导入数据库脚本，生成实验数据

   ```sh
   [root@centos8 ~]# mysql < hellodb_innodb.sql 
   ```

   查看表中数据

   ```sql
   MariaDB [(none)]> use hellodb
   Reading table information for completion of table and column names
   You can turn off this feature to get a quicker startup with -A
   
   MariaDB [hellodb]> show tables;
   +-------------------+
   | Tables_in_hellodb |
   +-------------------+
   | classes           |
   | coc               |
   | courses           |
   | scores            |
   | students          |
   | teachers          |
   | toc               |
   +-------------------+
   7 rows in set (0.000 sec)
   
   MariaDB [hellodb]> select * from students;
   +-------+---------------+-----+--------+---------+-----------+
   | StuID | Name          | Age | Gender | ClassID | TeacherID |
   +-------+---------------+-----+--------+---------+-----------+
   |     1 | Shi Zhongyu   |  22 | M      |       2 |         3 |
   |     2 | Shi Potian    |  22 | M      |       1 |         7 |
   |     3 | Xie Yanke     |  53 | M      |       2 |        16 |
   |     4 | Ding Dian     |  32 | M      |       4 |         4 |
   |     5 | Yu Yutong     |  26 | M      |       3 |         1 |
   |     6 | Shi Qing      |  46 | M      |       5 |      NULL |
   |     7 | Xi Ren        |  19 | F      |       3 |      NULL |
   |     8 | Lin Daiyu     |  17 | F      |       7 |      NULL |
   |     9 | Ren Yingying  |  20 | F      |       6 |      NULL |
   |    10 | Yue Lingshan  |  19 | F      |       3 |      NULL |
   |    11 | Yuan Chengzhi |  23 | M      |       6 |      NULL |
   |    12 | Wen Qingqing  |  19 | F      |       1 |      NULL |
   |    13 | Tian Boguang  |  33 | M      |       2 |      NULL |
   |    14 | Lu Wushuang   |  17 | F      |       3 |      NULL |
   |    15 | Duan Yu       |  19 | M      |       4 |      NULL |
   |    16 | Xu Zhu        |  21 | M      |       1 |      NULL |
   |    17 | Lin Chong     |  25 | M      |       4 |      NULL |
   |    18 | Hua Rong      |  23 | M      |       7 |      NULL |
   |    19 | Xue Baochai   |  18 | F      |       6 |      NULL |
   |    20 | Diao Chan     |  19 | F      |       7 |      NULL |
   |    21 | Huang Yueying |  22 | F      |       6 |      NULL |
   |    22 | Xiao Qiao     |  20 | F      |       1 |      NULL |
   |    23 | Ma Chao       |  23 | M      |       4 |      NULL |
   |    24 | Xu Xian       |  27 | M      |    NULL |      NULL |
   |    25 | Sun Dasheng   | 100 | M      |    NULL |      NULL |
   +-------+---------------+-----+--------+---------+-----------+
   25 rows in set (0.001 sec)
   ```

   查看表中包含多少条记录

   ​	聚合函数需要加括号哦，例如count（）

   ```sql
   MariaDB [hellodb]> select count(*) from students;
   +----------+
   | count(*) |
   +----------+
   |       25 |
   +----------+
   1 row in set (0.000 sec)
   ```

   查看表中记录的平均年龄是多少

   ```sql
   MariaDB [hellodb]> select avg(age) from students;
   +----------+
   | avg(age) |
   +----------+
   |  27.4000 |
   +----------+
   1 row in set (0.001 sec)
   ```

   统计年纪的最大和最小值

   ```sql
   MariaDB [hellodb]> select max(age) from students;
   +----------+
   | max(age) |
   +----------+
   |      100 |
   +----------+
   1 row in set (0.000 sec)
   
   MariaDB [hellodb]> select min(age) from students;
   +----------+
   | min(age) |
   +----------+
   |       17 |
   +----------+
   1 row in set (0.000 sec)
   ```

10. 分组统计

    分组统计一般都要跟聚合函数联合使用

    通过分组查出来的记录数量跟分组数量是一样的，group by分出来几个组，查询出来的结果就有几条记录了

    统计男生女生各自的平均年龄

    ```sql
    MariaDB [hellodb]> select gender,avg(age) from students group by gender;
    +--------+----------+
    | gender | avg(age) |
    +--------+----------+
    | F      |  19.0000 |
    | M      |  33.0000 |
    +--------+----------+
    2 rows in set (0.001 sec)
    ```

    统计男生女生各自的最大年龄和最小年龄

    ```sql
    MariaDB [hellodb]> select gender,max(age),min(age) from students group by gender;
    +--------+----------+----------+
    | gender | max(age) | min(age) |
    +--------+----------+----------+
    | F      |       22 |       17 |
    | M      |      100 |       19 |
    +--------+----------+----------+
    2 rows in set (0.001 sec)
    ```

    统计各个班级的学生的平均年龄

    ```sql
    MariaDB [hellodb]> select classid,avg(age) from students group by classid;
    +---------+----------+
    | classid | avg(age) |
    +---------+----------+
    |    NULL |  63.5000 |
    |       1 |  20.5000 |
    |       2 |  36.0000 |
    |       3 |  20.2500 |
    |       4 |  24.7500 |
    |       5 |  46.0000 |
    |       6 |  20.7500 |
    |       7 |  19.6667 |
    +---------+----------+
    8 rows in set (0.001 sec)
    ```

    分组函数语法要求，`最后显示的字段`（`select后面跟的字段`）只能为`分组字段`或`聚合函数`

    ​	这里stuid显示的就是第一个男生和第一个女生的stuid

    ```sql
    MariaDB [hellodb]> select gender,stuid from students group by gender;
    +--------+-------+
    | gender | stuid |
    +--------+-------+
    | F      |     7 |
    | M      |     1 |
    +--------+-------+
    2 rows in set (0.000 sec)
    ```

    根据多个分组规则进行查询

    ​	统计各个班级的男女生的平均年龄

    ```sql
    MariaDB [hellodb]> select classid,gender,avg(age) from students group by classid,gender;
    +---------+--------+----------+
    | classid | gender | avg(age) |
    +---------+--------+----------+
    |    NULL | M      |  63.5000 |
    |       1 | F      |  19.5000 |
    |       1 | M      |  21.5000 |
    |       2 | M      |  36.0000 |
    |       3 | F      |  18.3333 |
    |       3 | M      |  26.0000 |
    |       4 | M      |  24.7500 |
    |       5 | M      |  46.0000 |
    |       6 | F      |  20.0000 |
    |       6 | M      |  23.0000 |
    |       7 | F      |  18.0000 |
    |       7 | M      |  23.0000 |
    +---------+--------+----------+
    12 rows in set (0.001 sec)
    ```

    如果不想查看班级为NULL的记录，可以`对搜索结果进行过滤`（having）或者`对搜索过程进行过滤`（where），总结一下，先过滤再分组用`where`，先分组再过滤用`having`。

    对搜索结果进行过滤

    ```sql
    MariaDB [hellodb]> select classid,gender,avg(age) from students group by classid,gender having classid ist null; 
    +---------+--------+----------+
    | classid | gender | avg(age) |
    +---------+--------+----------+
    |       1 | F      |  19.5000 |
    |       1 | M      |  21.5000 |
    |       2 | M      |  36.0000 |
    |       3 | F      |  18.3333 |
    |       3 | M      |  26.0000 |
    |       4 | M      |  24.7500 |
    |       5 | M      |  46.0000 |
    |       6 | F      |  20.0000 |
    |       6 | M      |  23.0000 |
    |       7 | F      |  18.0000 |
    |       7 | M      |  23.0000 |
    +---------+--------+----------+
    11 rows in set (0.001 sec)
    ```

    对搜索过程进行过滤

    ```sql
    MariaDB [hellodb]> select classid,gender,avg(age) from students where classid is not null group by classid,gender; 
    +---------+--------+----------+
    | classid | gender | avg(age) |
    +---------+--------+----------+
    |       1 | F      |  19.5000 |
    |       1 | M      |  21.5000 |
    |       2 | M      |  36.0000 |
    |       3 | F      |  18.3333 |
    |       3 | M      |  26.0000 |
    |       4 | M      |  24.7500 |
    |       5 | M      |  46.0000 |
    |       6 | F      |  20.0000 |
    |       6 | M      |  23.0000 |
    |       7 | F      |  18.0000 |
    |       7 | M      |  23.0000 |
    +---------+--------+----------+
    11 rows in set (0.001 sec)
    ```

    对搜索结果进行排序

    ​	排序用`order by +排序的字段`

    ```sql
    MariaDB [hellodb]> select classid,gender,avg(age) from students group by classid,gender order by classid; 
    +---------+--------+----------+
    | classid | gender | avg(age) |
    +---------+--------+----------+
    |    NULL | M      |  63.5000 |
    |       1 | F      |  19.5000 |
    |       1 | M      |  21.5000 |
    |       2 | M      |  36.0000 |
    |       3 | F      |  18.3333 |
    |       3 | M      |  26.0000 |
    |       4 | M      |  24.7500 |
    |       5 | M      |  46.0000 |
    |       6 | F      |  20.0000 |
    |       6 | M      |  23.0000 |
    |       7 | F      |  18.0000 |
    |       7 | M      |  23.0000 |
    +---------+--------+----------+
    12 rows in set (0.001 sec)
    ```

    倒序

    ​	在排序的字段后面加上一个`desc`

    ```sql
    MariaDB [hellodb]> select classid,gender,avg(age) from students group by classid,gender order by classid desc; 
    +---------+--------+----------+
    | classid | gender | avg(age) |
    +---------+--------+----------+
    |       7 | F      |  18.0000 |
    |       7 | M      |  23.0000 |
    |       6 | F      |  20.0000 |
    |       6 | M      |  23.0000 |
    |       5 | M      |  46.0000 |
    |       4 | M      |  24.7500 |
    |       3 | F      |  18.3333 |
    |       3 | M      |  26.0000 |
    |       2 | M      |  36.0000 |
    |       1 | F      |  19.5000 |
    |       1 | M      |  21.5000 |
    |    NULL | M      |  63.5000 |
    +---------+--------+----------+
    12 rows in set (0.001 sec)
    
    ```

    数字倒序，NULL在最后

    ​	在排序的字段前面加一个负号

    ```sql
    MariaDB [hellodb]> select classid,gender,avg(age) from students group by classid,gender order by -classid desc; 
    +---------+--------+----------+
    | classid | gender | avg(age) |
    +---------+--------+----------+
    |       1 | M      |  21.5000 |
    |       1 | F      |  19.5000 |
    |       2 | M      |  36.0000 |
    |       3 | M      |  26.0000 |
    |       3 | F      |  18.3333 |
    |       4 | M      |  24.7500 |
    |       5 | M      |  46.0000 |
    |       6 | F      |  20.0000 |
    |       6 | M      |  23.0000 |
    |       7 | F      |  18.0000 |
    |       7 | M      |  23.0000 |
    |    NULL | M      |  63.5000 |
    +---------+--------+----------+
    12 rows in set (0.001 sec)
    ```

    案例

    ```sql
    MariaDB [hellodb]> select * from students order by age;
    +-------+---------------+-----+--------+---------+-----------+
    | StuID | Name          | Age | Gender | ClassID | TeacherID |
    +-------+---------------+-----+--------+---------+-----------+
    |     8 | Lin Daiyu     |  17 | F      |       7 |      NULL |
    |    14 | Lu Wushuang   |  17 | F      |       3 |      NULL |
    |    19 | Xue Baochai   |  18 | F      |       6 |      NULL |
    |    12 | Wen Qingqing  |  19 | F      |       1 |      NULL |
    |    10 | Yue Lingshan  |  19 | F      |       3 |      NULL |
    |     7 | Xi Ren        |  19 | F      |       3 |      NULL |
    |    15 | Duan Yu       |  19 | M      |       4 |      NULL |
    |    20 | Diao Chan     |  19 | F      |       7 |      NULL |
    |     9 | Ren Yingying  |  20 | F      |       6 |      NULL |
    |    22 | Xiao Qiao     |  20 | F      |       1 |      NULL |
    |    16 | Xu Zhu        |  21 | M      |       1 |      NULL |
    |     1 | Shi Zhongyu   |  22 | M      |       2 |         3 |
    |    21 | Huang Yueying |  22 | F      |       6 |      NULL |
    |     2 | Shi Potian    |  22 | M      |       1 |         7 |
    |    23 | Ma Chao       |  23 | M      |       4 |      NULL |
    |    18 | Hua Rong      |  23 | M      |       7 |      NULL |
    |    11 | Yuan Chengzhi |  23 | M      |       6 |      NULL |
    |    17 | Lin Chong     |  25 | M      |       4 |      NULL |
    |     5 | Yu Yutong     |  26 | M      |       3 |         1 |
    |    24 | Xu Xian       |  27 | M      |    NULL |      NULL |
    |     4 | Ding Dian     |  32 | M      |       4 |         4 |
    |    13 | Tian Boguang  |  33 | M      |       2 |      NULL |
    |     6 | Shi Qing      |  46 | M      |       5 |      NULL |
    |     3 | Xie Yanke     |  53 | M      |       2 |        16 |
    |    25 | Sun Dasheng   | 100 | M      |    NULL |      NULL |
    +-------+---------------+-----+--------+---------+-----------+
    25 rows in set (0.000 sec)
    
    MariaDB [hellodb]> select * from students order by age desc;
    +-------+---------------+-----+--------+---------+-----------+
    | StuID | Name          | Age | Gender | ClassID | TeacherID |
    +-------+---------------+-----+--------+---------+-----------+
    |    25 | Sun Dasheng   | 100 | M      |    NULL |      NULL |
    |     3 | Xie Yanke     |  53 | M      |       2 |        16 |
    |     6 | Shi Qing      |  46 | M      |       5 |      NULL |
    |    13 | Tian Boguang  |  33 | M      |       2 |      NULL |
    |     4 | Ding Dian     |  32 | M      |       4 |         4 |
    |    24 | Xu Xian       |  27 | M      |    NULL |      NULL |
    |     5 | Yu Yutong     |  26 | M      |       3 |         1 |
    |    17 | Lin Chong     |  25 | M      |       4 |      NULL |
    |    23 | Ma Chao       |  23 | M      |       4 |      NULL |
    |    18 | Hua Rong      |  23 | M      |       7 |      NULL |
    |    11 | Yuan Chengzhi |  23 | M      |       6 |      NULL |
    |    21 | Huang Yueying |  22 | F      |       6 |      NULL |
    |     1 | Shi Zhongyu   |  22 | M      |       2 |         3 |
    |     2 | Shi Potian    |  22 | M      |       1 |         7 |
    |    16 | Xu Zhu        |  21 | M      |       1 |      NULL |
    |    22 | Xiao Qiao     |  20 | F      |       1 |      NULL |
    |     9 | Ren Yingying  |  20 | F      |       6 |      NULL |
    |    15 | Duan Yu       |  19 | M      |       4 |      NULL |
    |     7 | Xi Ren        |  19 | F      |       3 |      NULL |
    |    20 | Diao Chan     |  19 | F      |       7 |      NULL |
    |    10 | Yue Lingshan  |  19 | F      |       3 |      NULL |
    |    12 | Wen Qingqing  |  19 | F      |       1 |      NULL |
    |    19 | Xue Baochai   |  18 | F      |       6 |      NULL |
    |     8 | Lin Daiyu     |  17 | F      |       7 |      NULL |
    |    14 | Lu Wushuang   |  17 | F      |       3 |      NULL |
    +-------+---------------+-----+--------+---------+-----------+
    25 rows in set (0.001 sec)
    ```

    去重展示查询结果

    ```sql
    MariaDB [hellodb]> select age from students;
    +-----+
    | age |
    +-----+
    |  22 |
    |  22 |
    |  53 |
    |  32 |
    |  26 |
    |  46 |
    |  19 |
    |  17 |
    |  20 |
    |  19 |
    |  23 |
    |  19 |
    |  33 |
    |  17 |
    |  19 |
    |  21 |
    |  25 |
    |  23 |
    |  18 |
    |  19 |
    |  22 |
    |  20 |
    |  23 |
    |  27 |
    | 100 |
    +-----+
    25 rows in set (0.000 sec)
    
    MariaDB [hellodb]> select distinct age from students;
    +-----+
    | age |
    +-----+
    |  22 |
    |  53 |
    |  32 |
    |  26 |
    |  46 |
    |  19 |
    |  17 |
    |  20 |
    |  23 |
    |  33 |
    |  21 |
    |  25 |
    |  18 |
    |  27 |
    | 100 |
    +-----+
    15 rows in set (0.000 sec)
    
    MariaDB [hellodb]> select distinct age from students order by age;
    +-----+
    | age |
    +-----+
    |  17 |
    |  18 |
    |  19 |
    |  20 |
    |  21 |
    |  22 |
    |  23 |
    |  25 |
    |  26 |
    |  27 |
    |  32 |
    |  33 |
    |  46 |
    |  53 |
    | 100 |
    +-----+
    15 rows in set (0.001 sec)
    ```

11. 统计

    对表中的数据进行统计操作，统计表中的总数

    select count(*)就可以统计表中有多少行数据，写count(1)应该跟count(\*)一样

    select count(stuid)可以统计表中stuid有多少行数据

    select count(classid)可以统计表中的classid这一列有多少行数据,因为count是不统计空值的记录的，而classid有两个数据为NULL，所以统计出来就只有23条记录

    

    ```sql
    MariaDB [hellodb]> select count(*) from students;
    +----------+
    | count(*) |
    +----------+
    |       25 |
    +----------+
    1 row in set (0.000 sec)
    
    MariaDB [hellodb]> select count(stuid) from students;
    +--------------+
    | count(stuid) |
    +--------------+
    |           25 |
    +--------------+
    1 row in set (0.001 sec)
    
    MariaDB [hellodb]> select count(1) from students;
    +----------+
    | count(1) |
    +----------+
    |       25 |
    +----------+
    1 row in set (0.000 sec)
    
    MariaDB [hellodb]> select count(classid) from students;
    +----------------+
    | count(classid) |
    +----------------+
    |             23 |
    +----------------+
    1 row in set (0.000 sec)
    ```

12. 限制输出记录数

    用`limit`限制只显示前面10条记录

    ```sql
    MariaDB [hellodb]> select * from students order by stuid limit 10;
    +-------+--------------+-----+--------+---------+-----------+
    | StuID | Name         | Age | Gender | ClassID | TeacherID |
    +-------+--------------+-----+--------+---------+-----------+
    |     1 | Shi Zhongyu  |  22 | M      |       2 |         3 |
    |     2 | Shi Potian   |  22 | M      |       1 |         7 |
    |     3 | Xie Yanke    |  53 | M      |       2 |        16 |
    |     4 | Ding Dian    |  32 | M      |       4 |         4 |
    |     5 | Yu Yutong    |  26 | M      |       3 |         1 |
    |     6 | Shi Qing     |  46 | M      |       5 |      NULL |
    |     7 | Xi Ren       |  19 | F      |       3 |      NULL |
    |     8 | Lin Daiyu    |  17 | F      |       7 |      NULL |
    |     9 | Ren Yingying |  20 | F      |       6 |      NULL |
    |    10 | Yue Lingshan |  19 | F      |       3 |      NULL |
    +-------+--------------+-----+--------+---------+-----------+
    10 rows in set (0.001 sec)
    ```

    跳过前面3条记录，看后面5条记录

    ```sql
    MariaDB [hellodb]> select * from students order by stuid limit 3,5;
    +-------+-----------+-----+--------+---------+-----------+
    | StuID | Name      | Age | Gender | ClassID | TeacherID |
    +-------+-----------+-----+--------+---------+-----------+
    |     4 | Ding Dian |  32 | M      |       4 |         4 |
    |     5 | Yu Yutong |  26 | M      |       3 |         1 |
    |     6 | Shi Qing  |  46 | M      |       5 |      NULL |
    |     7 | Xi Ren    |  19 | F      |       3 |      NULL |
    |     8 | Lin Daiyu |  17 | F      |       7 |      NULL |
    +-------+-----------+-----+--------+---------+-----------+
    5 rows in set (0.001 sec)
    ```

    

#### 7.2.2 多表查询

1. 子查询

   一个查询中嵌入了另外一个查询就叫子查询

   将第一个表滴答查询结果作为第二张表的查询条件

   查询所有年纪比学生平均年龄还小的老师

   ```sql
   MariaDB [hellodb]>  update teachers set age = 20 where tid=4;
   Query OK, 1 row affected (0.002 sec)
   Rows matched: 1  Changed: 1  Warnings: 0
   
   MariaDB [hellodb]> select * from teachers;
   +-----+---------------+-----+--------+
   | TID | Name          | Age | Gender |
   +-----+---------------+-----+--------+
   |   1 | Song Jiang    |  45 | M      |
   |   2 | Zhang Sanfeng |  94 | M      |
   |   3 | Miejue Shitai |  77 | F      |
   |   4 | Lin Chaoying  |  20 | F      |
   +-----+---------------+-----+--------+
   4 rows in set (0.000 sec)
   
   MariaDB [hellodb]> select avg(age) from students;
   +----------+
   | avg(age) |
   +----------+
   |  27.4000 |
   +----------+
   1 row in set (0.000 sec)
   
   MariaDB [hellodb]> select * from teachers where age < (select avg(age) from students) ;
   +-----+--------------+-----+--------+
   | TID | Name         | Age | Gender |
   +-----+--------------+-----+--------+
   |   4 | Lin Chaoying |  20 | F      |
   +-----+--------------+-----+--------+
   1 row in set (0.000 sec)
   ```

   通过子查询修改数据

   ​	修改灭绝师太的年龄为学生的平均年龄

   ​	平均年龄是27.4，但是修改过后的年龄为27，是因为teachers表中的age字段的数据类型为tinyint，是整数，无法显示小数，所以根据四舍五入就显示27了

   ```sql
   MariaDB [hellodb]> update teachers set age = (select avg(age) from students) where tid = 3;
   Query OK, 1 row affected (0.002 sec)
   Rows matched: 1  Changed: 1  Warnings: 0
   
   MariaDB [hellodb]> select * from teachers;
   +-----+---------------+-----+--------+
   | TID | Name          | Age | Gender |
   +-----+---------------+-----+--------+
   |   1 | Song Jiang    |  45 | M      |
   |   2 | Zhang Sanfeng |  94 | M      |
   |   3 | Miejue Shitai |  27 | F      |
   |   4 | Lin Chaoying  |  20 | F      |
   +-----+---------------+-----+--------+
   4 rows in set (0.000 sec)
   
   MariaDB [hellodb]> desc teachers;
   +--------+----------------------+------+-----+---------+----------------+
   | Field  | Type                 | Null | Key | Default | Extra          |
   +--------+----------------------+------+-----+---------+----------------+
   | TID    | smallint(5) unsigned | NO   | PRI | NULL    | auto_increment |
   | Name   | varchar(100)         | NO   |     | NULL    |                |
   | Age    | tinyint(3) unsigned  | NO   |     | NULL    |                |
   | Gender | enum('F','M')        | YES  |     | NULL    |                |
   +--------+----------------------+------+-----+---------+----------------+
   4 rows in set (0.001 sec)
   ```

2. 联合查询

   就是将两张表的数据进行纵向合并（一张表有10条数据，另外一张表有20条数据，合并之后就是30条数据）。

   注意：

   	1. 合并的时候，两张表的`字段数`必须一致，不然会报错。
   	1. 查询出来的结果只是显示的作用，不是一张新的表，所以不存在id会冲突的问题

   ```sql
   (root@localhost) [hellodb]> select * from students;
   +-------+---------------+-----+--------+---------+-----------+
   | StuID | Name          | Age | Gender | ClassID | TeacherID |
   +-------+---------------+-----+--------+---------+-----------+
   |     1 | Shi Zhongyu   |  22 | M      |       2 |         3 |
   |     2 | Shi Potian    |  22 | M      |       1 |         7 |
   |     3 | Xie Yanke     |  53 | M      |       2 |        16 |
   |     4 | Ding Dian     |  32 | M      |       4 |         4 |
   |     5 | Yu Yutong     |  26 | M      |       3 |         1 |
   |     6 | Shi Qing      |  46 | M      |       5 |      NULL |
   |     7 | Xi Ren        |  19 | F      |       3 |      NULL |
   |     8 | Lin Daiyu     |  17 | F      |       7 |      NULL |
   |     9 | Ren Yingying  |  20 | F      |       6 |      NULL |
   |    10 | Yue Lingshan  |  19 | F      |       3 |      NULL |
   |    11 | Yuan Chengzhi |  23 | M      |       6 |      NULL |
   |    12 | Wen Qingqing  |  19 | F      |       1 |      NULL |
   |    13 | Tian Boguang  |  33 | M      |       2 |      NULL |
   |    14 | Lu Wushuang   |  17 | F      |       3 |      NULL |
   |    15 | Duan Yu       |  19 | M      |       4 |      NULL |
   |    16 | Xu Zhu        |  21 | M      |       1 |      NULL |
   |    17 | Lin Chong     |  25 | M      |       4 |      NULL |
   |    18 | Hua Rong      |  23 | M      |       7 |      NULL |
   |    19 | Xue Baochai   |  18 | F      |       6 |      NULL |
   |    20 | Diao Chan     |  19 | F      |       7 |      NULL |
   |    21 | Huang Yueying |  22 | F      |       6 |      NULL |
   |    22 | Xiao Qiao     |  20 | F      |       1 |      NULL |
   |    23 | Ma Chao       |  23 | M      |       4 |      NULL |
   |    24 | Xu Xian       |  27 | M      |    NULL |      NULL |
   |    25 | Sun Dasheng   | 100 | M      |    NULL |      NULL |
   +-------+---------------+-----+--------+---------+-----------+
   25 rows in set (0.014 sec)
   
   (root@localhost) [hellodb]> select * from teachers;
   +-----+---------------+-----+--------+
   | TID | Name          | Age | Gender |
   +-----+---------------+-----+--------+
   |   1 | Song Jiang    |  45 | M      |
   |   2 | Zhang Sanfeng |  94 | M      |
   |   3 | Miejue Shitai |  27 | F      |
   |   4 | Lin Chaoying  |  20 | F      |
   +-----+---------------+-----+--------+
   4 rows in set (0.001 sec)
   
   (root@localhost) [hellodb]> select * from students union select * from teachers;
   ERROR 1222 (21000): The used SELECT statements have a different number of columns
   
   (root@localhost) [hellodb]> select stuid,name,age,gender from students union select * from teachers;
   +-------+---------------+-----+--------+
   | stuid | name          | age | gender |
   +-------+---------------+-----+--------+
   |     1 | Shi Zhongyu   |  22 | M      |
   |     2 | Shi Potian    |  22 | M      |
   |     3 | Xie Yanke     |  53 | M      |
   |     4 | Ding Dian     |  32 | M      |
   |     5 | Yu Yutong     |  26 | M      |
   |     6 | Shi Qing      |  46 | M      |
   |     7 | Xi Ren        |  19 | F      |
   |     8 | Lin Daiyu     |  17 | F      |
   |     9 | Ren Yingying  |  20 | F      |
   |    10 | Yue Lingshan  |  19 | F      |
   |    11 | Yuan Chengzhi |  23 | M      |
   |    12 | Wen Qingqing  |  19 | F      |
   |    13 | Tian Boguang  |  33 | M      |
   |    14 | Lu Wushuang   |  17 | F      |
   |    15 | Duan Yu       |  19 | M      |
   |    16 | Xu Zhu        |  21 | M      |
   |    17 | Lin Chong     |  25 | M      |
   |    18 | Hua Rong      |  23 | M      |
   |    19 | Xue Baochai   |  18 | F      |
   |    20 | Diao Chan     |  19 | F      |
   |    21 | Huang Yueying |  22 | F      |
   |    22 | Xiao Qiao     |  20 | F      |
   |    23 | Ma Chao       |  23 | M      |
   |    24 | Xu Xian       |  27 | M      |
   |    25 | Sun Dasheng   | 100 | M      |
   |     1 | Song Jiang    |  45 | M      |
   |     2 | Zhang Sanfeng |  94 | M      |
   |     3 | Miejue Shitai |  27 | F      |
   |     4 | Lin Chaoying  |  20 | F      |
   +-------+---------------+-----+--------+
   29 rows in set (0.001 sec)
   
   ```

    3. union默认有去重功能

       当合并的两张表中有相同的记录时，会自动去重，如果不想开启去重功能，可以添加`union all`来显示全部搜索结果。

   ```sql
   (root@localhost) [hellodb]> select * from teachers union select * from teachers;
   +-----+---------------+-----+--------+
   | TID | Name          | Age | Gender |
   +-----+---------------+-----+--------+
   |   1 | Song Jiang    |  45 | M      |
   |   2 | Zhang Sanfeng |  94 | M      |
   |   3 | Miejue Shitai |  27 | F      |
   |   4 | Lin Chaoying  |  20 | F      |
   +-----+---------------+-----+--------+
   4 rows in set (0.001 sec)
   
   (root@localhost) [hellodb]> select * from teachers union all select * from teachers;
   +-----+---------------+-----+--------+
   | TID | Name          | Age | Gender |
   +-----+---------------+-----+--------+
   |   1 | Song Jiang    |  45 | M      |
   |   2 | Zhang Sanfeng |  94 | M      |
   |   3 | Miejue Shitai |  27 | F      |
   |   4 | Lin Chaoying  |  20 | F      |
   |   1 | Song Jiang    |  45 | M      |
   |   2 | Zhang Sanfeng |  94 | M      |
   |   3 | Miejue Shitai |  27 | F      |
   |   4 | Lin Chaoying  |  20 | F      |
   +-----+---------------+-----+--------+
   8 rows in set (0.001 sec)
   ```

3. 交叉连接 cross join

   将两张表的记录做笛卡尔乘积并进行展示的查询方式叫交叉连接。交叉连接后的表中会包含两张表中的所有字段，查询结果的记录数为两张表的记录数之积。

   例如：一张表有2条记录，另外一张表有三张记录，第一张表中的每条记录都会跟第二张表中的每条记录进行组合，那么交叉连接查询的结果就有2*3=6条记录。

   ​	一张表有3个字段，另外一张表有5个字段，那么交叉连接查询出来的表就有8个字段

   将学生表和老师表进行交叉连接，得到了一张10个字段100条记录的结果表，并且学生表的信息在前，老师表的记录在后（两张表的顺序不同，最后查询出来的结果也不同）

   ```sql
   (root@localhost) [hellodb]> select * from students cross join teachers;
   ```

4. 内连接 inner join

   就是求两张表的交集

   查询students表中teacherid字段值和teachers表中tid字段值相同的记录，在写限定条件的时候，要指定表名和字段名，因为两张表中可能会有相同的字段

   ```sql
   (root@localhost) [hellodb]> select * from students inner join teachers on students.teacherid=teachers.tid\G;
   *************************** 1. row ***************************
       StuID: 5
        Name: Yu Yutong
         Age: 26
      Gender: M
     ClassID: 3
   TeacherID: 1
         TID: 1
        Name: Song Jiang
         Age: 45
      Gender: M
   *************************** 2. row ***************************
       StuID: 1
        Name: Shi Zhongyu
         Age: 22
      Gender: M
     ClassID: 2
   TeacherID: 3
         TID: 3
        Name: Miejue Shitai
         Age: 27
      Gender: F
   *************************** 3. row ***************************
       StuID: 4
        Name: Ding Dian
         Age: 32
      Gender: M
     ClassID: 4
   TeacherID: 4
         TID: 4
        Name: Lin Chaoying
         Age: 20
      Gender: F
   3 rows in set (0.001 sec)
   
   ERROR: No query specified
   ```

   当表中的字段有重名的情况，必须指定该字段的表名

   ```sql
   (root@localhost) [hellodb]> select stuid,students.name,tid,teachers.name from students inner join teachers on students.teacherid=teachers.tid;
   +-------+-------------+-----+---------------+
   | stuid | name        | tid | name          |
   +-------+-------------+-----+---------------+
   |     5 | Yu Yutong   |   1 | Song Jiang    |
   |     1 | Shi Zhongyu |   3 | Miejue Shitai |
   |     4 | Ding Dian   |   4 | Lin Chaoying  |
   +-------+-------------+-----+---------------+
   3 rows in set (0.001 sec)
   ```

   添加别名，方便识别

   ```sql
   (root@localhost) [hellodb]> select stuid,students.name 学生姓名,tid,teachers.name 老师姓名 from students inner join teachers on students.teacherid=teachers.tid;
   +-------+--------------+-----+---------------+
   | stuid | 学生姓名      | tid | 老师姓名        |
   +-------+--------------+-----+---------------+
   |     5 | Yu Yutong    |   1 | Song Jiang    |
   |     1 | Shi Zhongyu  |   3 | Miejue Shitai |
   |     4 | Ding Dian    |   4 | Lin Chaoying  |
   +-------+--------------+-----+---------------+
   3 rows in set (0.001 sec)
   ```

   给表起别名，简化查询语句

   ​	不然的话，每一个重名的表都要加上完整的表名，太不方便了

   ```sql
   (root@localhost) [hellodb]> select stuid,s.name 学生姓名,s.gender,tid,t.name,t.gender from students s inner join teachers t on s.teacherid=t.tid;
   +-------+--------------+--------+-----+---------------+--------+
   | stuid | 学生姓名     | gender | tid | name          | gender |
   +-------+--------------+--------+-----+---------------+--------+
   |     5 | Yu Yutong    | M      |   1 | Song Jiang    | M      |
   |     1 | Shi Zhongyu  | M      |   3 | Miejue Shitai | F      |
   |     4 | Ding Dian    | M      |   4 | Lin Chaoying  | F      |
   +-------+--------------+--------+-----+---------------+--------+
   3 rows in set (0.001 sec)
   ```

5. 左外连接 lefter [outer] join

   保留左边的表；右边的表仅保留交集部分；右边的表其他部分剔除

   左表与右表非交集的部分表现为`NULL`

   ```sql
   (root@localhost) [hellodb]> select * from students s left outer join teachers t on s.teacherid=t.tid;
   ```

   左外连接变种

   ​	仅保留左边的表减去交集部分

   ```sql
   (root@localhost) [hellodb]> select * from students s left outer join teachers t on s.teacherid=t.tid where t.tid is NULL;
   ```

   

6. 右外连接

   跟左外连接一样

   ```sql
   (root@localhost) [hellodb]> select * from students s RIGHT outer join teachers t on s.teacherid=t.tid;
   +-------+-------------+------+--------+---------+-----------+-----+---------------+-----+--------+
   | StuID | Name        | Age  | Gender | ClassID | TeacherID | TID | Name          | Age | Gender |
   +-------+-------------+------+--------+---------+-----------+-----+---------------+-----+--------+
   |     1 | Shi Zhongyu |   22 | M      |       2 |         3 |   3 | Miejue Shitai |  27 | F      |
   |     4 | Ding Dian   |   32 | M      |       4 |         4 |   4 | Lin Chaoying  |  20 | F      |
   |     5 | Yu Yutong   |   26 | M      |       3 |         1 |   1 | Song Jiang    |  45 | M      |
   |  NULL | NULL        | NULL | NULL   |    NULL |      NULL |   2 | Zhang Sanfeng |  94 | M      |
   +-------+-------------+------+--------+---------+-----------+-----+---------------+-----+--------+
   ```

   右外连接变种

   ```sql
   (root@localhost) [hellodb]> select * from students s right outer join teachers t on s.teacherid=t.tid where teacherid is NULL;
   ```

7. 完全外连接

   完全外连接就是求两张表的交集，但是mysql不支持该`full outer join`的写法

   ```sql
   (root@localhost) [hellodb]> select * from  students s full  outer join terchers t on s.teacherid=t.tid;
   ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'full  outer join terchers t on s.teacherid=t.tid' at line 1
   ```

   不过可以使用左外连接和右外连接进行联合查询（union）来实现完全外连接

   ```sql
   (root@localhost) [hellodb]> select * from students s left outer join teachers t on s.teacherid=t.tid
       -> union
       -> select * from students s right outer join teachers t on s.teacherid=t.tid;
   ```

8. 自连接查询

   a表连接a表进行查询

   导入数据

   ```sql
   (root@localhost) [hellodb]> create table emp (id int,name varchar(10),leaderid int);
   Query OK, 0 rows affected (0.005 sec)
   
   (root@localhost) [hellodb]> insert emp values (1,'mage',null),(2,'zhangsir',1),(3,'wang',2),(4,'zhang',3);
   Query OK, 4 rows affected (0.001 sec)
   Records: 4  Duplicates: 0  Warnings: 0
   
   (root@localhost) [hellodb]> select * from emp;
   +------+----------+----------+
   | id   | name     | leaderid |
   +------+----------+----------+
   |    1 | mage     |     NULL |
   |    2 | zhangsir |        1 |
   |    3 | wang     |        2 |
   |    4 | zhang    |        3 |
   +------+----------+----------+
   4 rows in set (0.000 sec)
   ```

   现在，我们要查询每位员工的领导的姓名。

   我们可以给emp表起2个别名，就相当于有了两张一模一样的表，一张表定义为员工表（employee table简写e），一张表定义为领导表（leader table简写l），再将两张表以`e.leaderid=l.id`（员工表的领导的id等于领导表的id）进行内连接查询（就是求交集），就能得到员工对应领导的姓名

   ```sql
   (root@localhost) [hellodb]> select * from emp e inner join emp l on e.leaderid=l.id;
   +------+----------+----------+------+----------+----------+
   | id   | name     | leaderid | id   | name     | leaderid |
   +------+----------+----------+------+----------+----------+
   |    2 | zhangsir |        1 |    1 | mage     |     NULL |
   |    3 | wang     |        2 |    2 | zhangsir |        1 |
   |    4 | zhang    |        3 |    3 | wang     |        2 |
   +------+----------+----------+------+----------+----------+
   3 rows in set (0.000 sec)
   
   (root@localhost) [hellodb]> select e.name 员工姓名,l.name 领导姓名 from emp e inner join emp l on e.leaderid=l.id;
   +--------------+--------------+
   | 员工姓名      | 领导姓名       |
   +--------------+--------------+
   | zhangsir     | mage         |
   | wang         | zhangsir     |
   | zhang        | wang         |
   +--------------+--------------+
   3 rows in set (0.000 sec)
   
   ```

   马哥虽然没有领导，但是马哥也是员工，这条记录不能丢，所以此例中用left join更好

   ```sql
   (root@localhost) [hellodb]> select e.name 员工姓名,l.name 领导姓名 from emp e left outer join emp l on e.leaderid=l.id;
   +--------------+--------------+
   | 员工姓名     | 领导姓名     |
   +--------------+--------------+
   | zhangsir     | mage         |
   | wang         | zhangsir     |
   | zhang        | wang         |
   | mage         | NULL         |
   +--------------+--------------+
   4 rows in set (0.001 sec)
   ```

   将NULL替换为其他字符串

   ​	需要用到`IFNULL()`函数

   ```sql
   (root@localhost) [hellodb]> select e.name 员工姓名,IFNULL(l.name,'无上级')领导姓名 from emp e left outer join emp l on e.leaderid=l.id;
   +--------------+--------------+
   | 员工姓名      | 领导姓名       |
   +--------------+--------------+
   | zhangsir     | mage         |
   | wang         | zhangsir     |
   | zhang        | wang         |
   | mage         | 无上级        |
   +--------------+--------------+
   4 rows in set (0.000 sec)
   ```

9. 三表查询

   ```sql
   (root@localhost) [hellodb]> select* from students;
   +-------+---------------+-----+--------+---------+-----------+
   | StuID | Name          | Age | Gender | ClassID | TeacherID |
   +-------+---------------+-----+--------+---------+-----------+
   |     1 | Shi Zhongyu   |  22 | M      |       2 |         3 |
   
   (root@localhost) [hellodb]> select * from courses;
   +----------+----------------+
   | CourseID | Course         |
   +----------+----------------+
   |        1 | Hamo Gong      |
   
   (root@localhost) [hellodb]> select * from scores;
   +----+-------+----------+-------+
   | ID | StuID | CourseID | Score |
   +----+-------+----------+-------+
   |  1 |     1 |        2 |    77 |
   
   ```

   现在需要查询每个学生姓名对应的科目名称和对应的成绩

   ​	先把学生姓名写到表中

   ​	from后面接的表名就是下面这个查询结果的表名，表名没变哈

   ```sql
   (root@localhost) [hellodb]> select sc.id,s.name 学生姓名,sc.courseid,sc.score  from scores sc left join students s on sc.stuid=s.stuid;
   +----+--------------+----------+-------+
   | id | 学生姓名     | courseid | score |
   +----+--------------+----------+-------+
   |  1 | Shi Zhongyu  |        2 |    77 |
   |  2 | Shi Zhongyu  |        6 |    93 |
   |  3 | Shi Potian   |        2 |    47 |
   |  4 | Shi Potian   |        5 |    97 |
   |  5 | Xie Yanke    |        2 |    88 |
   |  6 | Xie Yanke    |        6 |    75 |
   |  7 | Ding Dian    |        5 |    71 |
   |  8 | Ding Dian    |        2 |    89 |
   |  9 | Yu Yutong    |        1 |    39 |
   | 10 | Yu Yutong    |        7 |    63 |
   | 11 | Shi Qing     |        1 |    96 |
   | 12 | Xi Ren       |        1 |    86 |
   | 13 | Xi Ren       |        7 |    83 |
   | 14 | Lin Daiyu    |        4 |    57 |
   | 15 | Lin Daiyu    |        3 |    93 |
   +----+--------------+----------+-------+
   15 rows in set (0.001 sec)
   ```

   ​	再把课程名写到表中

   ```sql
   (root@localhost) [hellodb]> select sc.id,s.name 学生姓名,co.course,sc.score  from scores sc left join students s on sc.stuid=s.stuid inner join courses co on co.courseid=sc.courseid; 
   +----+--------------+----------------+-------+
   | id | 学生姓名     | course         | score |
   +----+--------------+----------------+-------+
   |  1 | Shi Zhongyu  | Kuihua Baodian |    77 |
   |  2 | Shi Zhongyu  | Weituo Zhang   |    93 |
   |  3 | Shi Potian   | Kuihua Baodian |    47 |
   |  4 | Shi Potian   | Daiyu Zanghua  |    97 |
   |  5 | Xie Yanke    | Kuihua Baodian |    88 |
   |  6 | Xie Yanke    | Weituo Zhang   |    75 |
   |  7 | Ding Dian    | Daiyu Zanghua  |    71 |
   |  8 | Ding Dian    | Kuihua Baodian |    89 |
   |  9 | Yu Yutong    | Hamo Gong      |    39 |
   | 10 | Yu Yutong    | Dagou Bangfa   |    63 |
   | 11 | Shi Qing     | Hamo Gong      |    96 |
   | 12 | Xi Ren       | Hamo Gong      |    86 |
   | 13 | Xi Ren       | Dagou Bangfa   |    83 |
   | 14 | Lin Daiyu    | Taiji Quan     |    57 |
   | 15 | Lin Daiyu    | Jinshe Jianfa  |    93 |
   +----+--------------+----------------+-------+
   15 rows in set (0.001 sec)
   ```

   

## 8. 视图

视图（view）：虚拟表，不是一个真实存在的表，是查询命令的返回结果，就是==将一个长长的select命令的结果抽象成表，便于经常查看==。相当于select命令的别名，可以把一个长长的select语句定义成一个视图，相当于简化命令了。

可以理解为视图就是执行了一条简化版的select查询命令。

- 创建视图

  查询1条记录

  ```sql
  (root@localhost) [hellodb]> select * from students where age > 35; 
  +-------+-------------+-----+--------+---------+-----------+
  | StuID | Name        | Age | Gender | ClassID | TeacherID |
  +-------+-------------+-----+--------+---------+-----------+
  |     3 | Xie Yanke   |  53 | M      |       2 |        16 |
  |     6 | Shi Qing    |  46 | M      |       5 |      NULL |
  |    25 | Sun Dasheng | 100 | M      |    NULL |      NULL |
  +-------+-------------+-----+--------+---------+-----------+
  3 rows in set (0.040 sec)
  ```

  根据上面的命令创建视图

  ```sql
  (root@localhost) [hellodb]> create view v_old_students as select * from students where age > 35;
  Query OK, 0 rows affected (0.042 sec)
  ```

  查看该数据库中的表

  ​	创建的视图就像是一个新的表一样（但不是真的表啊），跟表的用法一模一样。

  ```sql
  (root@localhost) [hellodb]> show tables;
  +-------------------+
  | Tables_in_hellodb |
  +-------------------+
  | classes           |
  | coc               |
  | courses           |
  | emp               |
  | scores            |
  | students          |
  | teachers          |
  | toc               |
  | v_old_students    |
  +-------------------+
  9 rows in set (0.000 sec)
  ```

  查看视图

  ```sql
  (root@localhost) [hellodb]> select * from v_old_students;
  +-------+-------------+-----+--------+---------+-----------+
  | StuID | Name        | Age | Gender | ClassID | TeacherID |
  +-------+-------------+-----+--------+---------+-----------+
  |     3 | Xie Yanke   |  53 | M      |       2 |        16 |
  |     6 | Shi Qing    |  46 | M      |       5 |      NULL |
  |    25 | Sun Dasheng | 100 | M      |    NULL |      NULL |
  +-------+-------------+-----+--------+---------+-----------+
  3 rows in set (0.021 sec)
  ```



- 观察实体表与视图的不同

  查看表状态

  ​	实体表中是有各种状态信息的，而视图中是没有状态信息的。

  ```sql
  (root@localhost) [hellodb]> show table status like 'v_old_students'\G;
  *************************** 1. row ***************************
              Name: v_old_students
            Engine: NULL
           Version: NULL
        Row_format: NULL
              Rows: NULL
    Avg_row_length: NULL
       Data_length: NULL
   Max_data_length: NULL
      Index_length: NULL
         Data_free: NULL
    Auto_increment: NULL
       Create_time: NULL
       Update_time: NULL
        Check_time: NULL
         Collation: NULL
          Checksum: NULL
    Create_options: NULL
           Comment: VIEW
  Max_index_length: NULL
         Temporary: NULL
  1 row in set (0.001 sec)
  
  ERROR: No query specified
  
  (root@localhost) [hellodb]> show table status like 'students'\G;
  *************************** 1. row ***************************
              Name: students
            Engine: InnoDB
           Version: 10
        Row_format: Dynamic
              Rows: 25
    Avg_row_length: 655
       Data_length: 16384
   Max_data_length: 0
      Index_length: 0
         Data_free: 0
    Auto_increment: 26
       Create_time: 2023-10-28 18:48:12
       Update_time: 2023-10-28 18:48:12
        Check_time: NULL
         Collation: utf8_general_ci
          Checksum: NULL
    Create_options: 
           Comment: 
  Max_index_length: 0
         Temporary: N
  1 row in set (0.013 sec)
  
  ERROR: No query specified
  ```



- 通过视图修改表内容

  修改表内容

  ```sql
  (root@localhost) [hellodb]> update v_old_students set age = 40 where stuid = 3 ;
  Query OK, 1 row affected (0.007 sec)
  Rows matched: 1  Changed: 1  Warnings: 0
  ```

  查看表内容

  ​	发现表中的数据和视图中的数据都已经被修改了

  ```sql
  (root@localhost) [hellodb]> select * from v_old_students;
  +-------+-------------+-----+--------+---------+-----------+
  | StuID | Name        | Age | Gender | ClassID | TeacherID |
  +-------+-------------+-----+--------+---------+-----------+
  |     3 | Xie Yanke   |  40 | M      |       2 |        16 |
  |     6 | Shi Qing    |  46 | M      |       5 |      NULL |
  |    25 | Sun Dasheng | 100 | M      |    NULL |      NULL |
  +-------+-------------+-----+--------+---------+-----------+
  3 rows in set (0.000 sec)
  
  (root@localhost) [hellodb]> select * from students where stuid=3;
  +-------+-----------+-----+--------+---------+-----------+
  | StuID | Name      | Age | Gender | ClassID | TeacherID |
  +-------+-----------+-----+--------+---------+-----------+
  |     3 | Xie Yanke |  40 | M      |       2 |        16 |
  +-------+-----------+-----+--------+---------+-----------+
  1 row in set (0.002 sec)
  ```

  

  将年龄改成20岁（视图设置的是年龄大于35岁的）

  修改表内容

  ```sql
  (root@localhost) [hellodb]> update v_old_students set age = 20 where stuid = 3 ;
  Query OK, 1 row affected (0.038 sec)
  Rows matched: 1  Changed: 1  Warnings: 0
  ```

  查看表内容

  ​	发现实体表中的数据已经被改掉了，但是在视图表中是查看不到该数据的，因为该数据不再视图的范围之内（视图中学生的年龄都是35以上的，而3号学生的年龄是20）

  ```sql
  (root@localhost) [hellodb]> select * from students where stuid=3;
  +-------+-----------+-----+--------+---------+-----------+
  | StuID | Name      | Age | Gender | ClassID | TeacherID |
  +-------+-----------+-----+--------+---------+-----------+
  |     3 | Xie Yanke |  20 | M      |       2 |        16 |
  +-------+-----------+-----+--------+---------+-----------+
  1 row in set (0.001 sec)
  
  (root@localhost) [hellodb]> select * from v_old_students;
  +-------+-------------+-----+--------+---------+-----------+
  | StuID | Name        | Age | Gender | ClassID | TeacherID |
  +-------+-------------+-----+--------+---------+-----------+
  |     6 | Shi Qing    |  46 | M      |       5 |      NULL |
  |    25 | Sun Dasheng | 100 | M      |    NULL |      NULL |
  +-------+-------------+-----+--------+---------+-----------+
  2 rows in set (0.001 sec)
  ```



- 删除视图

  ```sql
  (root@localhost) [hellodb]> drop view v_old_students;
  Query OK, 0 rows affected (0.014 sec)
  ```



问：创建视图在前，更新数据在后，视图中的数据会随之更新吗？

答：会。视图中是一个虚拟表，这里面是不存数据的，所有的数据都从实体表中来。不论先后，只要修改了数据都是在修改实体表中的数据，只要表中的数据发生改变，视图中显示的内容就会随之发生改变。







## 9. 函数FUNCTION

函数的作用：可以==将常用的sql命令定义为函数，将来可以重复调用==。

### 9.1 UDF:用户自定义函数

- 创建无参UDF

  1. 打开允许创建自定义函数的开关

     mysql5.7之前的版本不需要打开该开关

     mysql8.0之后，需要手动开启该开关，才能创建自定义函数

     ```sql
     mysql> CREATE FUNCTION simpleFun() RETURNS VARCHAR(20) RETURN "Hello World";
     ERROR 1418 (HY000): This function has none of DETERMINISTIC, NO SQL, or READS SQL DATA in its declaration and binary logging is enabled (you *might* want to use the less safe log_bin_trust_function_creators variable)
     ```

     打开允许创建函数的开关

     ```sql
     
     mysql> select @@log_bin_trust_function_creators;
     +-----------------------------------+
     | @@log_bin_trust_function_creators |
     +-----------------------------------+
     |                                 0 |
     +-----------------------------------+
     1 row in set (0.00 sec)
     
     mysql> set global log_bin_trust_function_creators=ON;
     Query OK, 0 rows affected (0.00 sec)
     
     mysql> select @@log_bin_trust_function_creators;
     +-----------------------------------+
     | @@log_bin_trust_function_creators |
     +-----------------------------------+
     |                                 1 |
     +-----------------------------------+
     1 row in set (0.00 sec)
     ```

     

  2. 创建自定义函数

     ```sql
     mysql> CREATE FUNCTION simpleFun() RETURNS VARCHAR(20) RETURN "Hello World";
     ```

  3. 查看自定义函数

     ```sql
     mysql> select simpleFun();
     +-------------+
     | simpleFun() |
     +-------------+
     | Hello World |
     +-------------+
     1 row in set (0.00 sec)
     ```

- 创建有参UDF

  [delimiter命令](https://blog.csdn.net/pan_junbiao/article/details/86291722)

  delimiter命令可以指定本次会话中的mysql的分隔符

  1. 定义分隔符为`//`

     ```sql
     mysql> DELIMITER //
     ```

  2. 创建有参UDF

     创建的这个参数为形参（id），参数`id`的数据类型为`SMALLINT UNSIGNED`，返回值的数据类型为`VARCHAR(20)`

     ```sql
     mysql> CREATE FUNCTION deleteById(id SMALLINT UNSIGNED) RETURNS VARCHAR(20)
         -> BEGIN
         ->  DELETE FROM students WHERE stuid = id;
         ->  RETURN (SELECT COUNT(*) FROM students);
         -> END//
     Query OK, 0 rows affected (0.00 sec)
     ```

  3. 修改mysql分隔符为`;`

     ```sql
     mysql> DELIMITER ;
     ```

  4. 通过函数删除student表中的数据

     ```sql
     mysql> select deleteById(3);
     +---------------+
     | deleteById(3) |
     +---------------+
     | 24            |
     +---------------+
     1 row in set (0.00 sec)
     ```

  5. 查看删除后的表

     第三条数据没有了

     ```sql
     mysql> select * from students;
     +-------+---------------+-----+--------+---------+-----------+
     | StuID | Name          | Age | Gender | ClassID | TeacherID |
     +-------+---------------+-----+--------+---------+-----------+
     |     1 | Shi Zhongyu   |  22 | M      |       2 |         3 |
     |     2 | Shi Potian    |  22 | M      |       1 |         7 |
     |     4 | Ding Dian     |  32 | M      |       4 |         4 |
     |     5 | Yu Yutong     |  26 | M      |       3 |         1 |
     |     6 | Shi Qing      |  46 | M      |       5 |      NULL |
     |     7 | Xi Ren        |  19 | F      |       3 |      NULL |
     ```

     

## 10. 存储过程



存储过程更像是shell中的函数了，可以直接使用，不用像UDF那样，还需要嵌入到SQL语句中才能使用。

- 存储过程使用实例

  ```sql
  # 创建无参存储过程
  delimiter //
  CREATE PROCEDURE showTime()
  BEGIN
   SELECT now();
  END//
  delimiter ;
  CALL showTime;
  ```

  ```sql
  delimiter //
  CREATE PROCEDURE deleteById(IN id SMALLINT UNSIGNED, OUT num SMALLINT UNSIGNED)
  BEGIN
  DELETE FROM students WHERE stuid >= id;
  SELECT row_count() into num;
  END//
  delimiter ;
  call deleteById(20,@Line);
  SELECT @Line;
  
  #说明:创建存储过程deleteById,包含一个IN参数和一个OUT参数.调用时,传入删除的ID和保存被修改的行
  数值的用户变量@Line,select @Line;输出被影响行数
  #row_count() 系统内置函数，用于存放前一条SQL修改过的表的记录数
  ```

  

## 11. 触发器

适合多表联动，当一个表中的数据变动时，带动另外一张表同时改动。

例如：客户下单时买商品的个数与库存商品总数的联动。



## 12. 事件EVENT

有点类似于linux中的定时任务



## 13. 用户和权限

### 13.1 用户类别

在linux下用户是根据角色定义的，具体分为三种角色：

超级用户：拥有对系统的最高管理权限，默认是root用户。
普通用户：只能对自己目录下的文件进行访问和修改，具有登录系统的权限，例如上面提到的www用户、ftp用户等。
虚拟用户：也叫“伪”用户，这类用户最大的特点是不能登录系统，它们的存在主要是方便系统管理，满足相应的系统进程对文件属主的要求。例如系统默认的bin、adm、nobody用户等，一般运行的web服务，默认就是使用的nobody用户，但是nobody用户是不能登录系统的。

本节涉及的mysql账户就属于虚拟账户，该账户不能用来登录到linux系统中，只能对mysqld服务器进行管理。

### 13.2 账号格式

```sql
账号格式：'USERNAME'@'HOST'
@'HOST': 主机名： user1@'web1.magedu.org'
IP地址或Network
 通配符： %   _
 示例：wang@'172.16.%.%'  
     user2@'192.168.1.%'
     mage@'10.0.0.0/255.255.0.0'
	root@localhost
	hjb@10.0.0.100
```



### 13.2 管理用户

1. 创建用户

   ```sql
   #示例:
   create user test@'10.0.0.0/255.255.255.0' identified by '123456';
   create user test2@'10.0.0.%' identified by 123456;
   
   ```

   创建用户

   ```sql
   mysql> create user root@10.0.0.100 identified by '123456';
   Query OK, 0 rows affected (0.01 sec)
   
   mysql> select user,host from mysql.user;
   +------------------+------------+
   | user             | host       |
   +------------------+------------+
   | root             | 10.0.0.100 |
   | mysql.infoschema | localhost  |
   | mysql.session    | localhost  |
   | mysql.sys        | localhost  |
   | root             | localhost  |
   +------------------+------------+
   5 rows in set (0.00 sec)
   ```

- 查看当前登录用户的信息

  通过远程主机登录到mysql

  ```sh
  root@hjb:~# mysql -uroot -p123456 -h10.0.0.8
  ```

  查看当前登录用户的信息

  ```sql
  mysql> select user();
  +-----------------+
  | user()          |
  +-----------------+
  | root@10.0.0.100 |
  +-----------------+
  1 row in set (0.00 sec)
  ```

  ```sql
  mysql> status;
  --------------
  mysql  Ver 8.0.34-0ubuntu0.20.04.1 for Linux on x86_64 ((Ubuntu))
  
  Connection id:		10
  Current database:	
  Current user:		root@10.0.0.100
  SSL:			Cipher in use is TLS_AES_256_GCM_SHA384
  Current pager:		stdout
  Using outfile:		''
  Using delimiter:	;
  Server version:		8.0.32 Source distribution
  Protocol version:	10
  Connection:		10.0.0.8 via TCP/IP
  Server characterset:	utf8mb4
  Db     characterset:	utf8mb4
  Client characterset:	utf8mb4
  Conn.  characterset:	utf8mb4
  TCP port:		3306
  Binary data as:		Hexadecimal
  Uptime:			20 min 54 sec
  
  Threads: 3  Questions: 16  Slow queries: 0  Opens: 166  Flush tables: 3  Open tables: 85  Queries per second avg: 0.012
  --------------
  ```

- 在mysqld主机查看登录用户的线程

  ```sql
  mysql> show processlist;
  +----+-----------------+------------------+------+---------+------+------------------------+------------------+
  | Id | User            | Host             | db   | Command | Time | State                  | Info             |
  +----+-----------------+------------------+------+---------+------+------------------------+------------------+
  |  5 | event_scheduler | localhost        | NULL | Daemon  | 1376 | Waiting on empty queue | NULL             |
  |  8 | root            | localhost        | NULL | Query   |    0 | init                   | show processlist |
  | 10 | root            | 10.0.0.100:50206 | NULL | Sleep   |  125 |                        | NULL             |
  +----+-----------------+------------------+------+---------+------+------------------------+------------------+
  3 rows in set (0.00 sec)
  ```



问：新创建的root@10.0.0.100用户与10.0.0.8服务器上的root@localhost用户的权限是一样的吗？

答：不是的，mysql创建的用户都是普通的用户，默认权限的，此处不过是用户的姓名碰巧叫root而已。如果创建的用户需要更多的权限，那么就需要使用root@localhost用户进行额外的赋权操作。



2. 删除用户

   ```sql
   DROP USER 'USERNAME'@'HOST'
   ```

   删除空用户

   ```sql
   DROP USER ''@'localhost';
   ```

3. 修改用户密码

   新版mysql中用户密码是保存在mysql.user表的authentication_string字段中

   旧版mysql中用户密码是保存在mysql.user表的password字段中

   如果mysql.user表的authentication_string和password字段都保存密码，authentication_string 优先生效

   ```sql
   #方法1,用户可以也可通过此方式修改自已的密码
   SET PASSWORD FOR 'user'@'host' = PASSWORD('password');  #MySQL8.0 版本不支持此方法,
   因为password函数被取消
   set password for root@'localhost'='123456' ;  #MySQL8.0版本支持此方法,此方式直接将密码
   123456加密后存放在mysql.user表的authentication_string字段
   #方法2
   ALTER  USER test@'%' IDENTIFIED BY 'centos';  #通用改密码方法, 用户可以通过此方式修改自已的密码,MySQL8 版本修改密码
   #方法3 此方式MySQL8.0不支持,因为password函数被取消
   UPDATE mysql.user SET password=PASSWORD('password') WHERE clause;
   #mariadb 10.3
   update mysql.user set authentication_string=password('ubuntu') where
   user='mage';
   #此方法需要执行下面指令才能生效：
   FLUSH PRIVILEGES;
   #方法4 通过mysqladmin工具修改密码
   mysqladmin -uroot -p'old_password' password 'new_password';
   ```

4. 忘记管理员用户的密码

   修改配置文件跳过读取授权文件

   ```sh
   [root@centos8 ~]# vim /etc/my.cnf
   
   [mysqld]
   skip-grant-tables 
   
   [root@centos8 ~]# systemctl restart mysqld
   ```

   修改账户密码

   ```sql
   #登录到mysqld服务器
   [root@centos8 ~]# mysql
   Welcome to the MySQL monitor.  Commands end with ; or \g.
   Your MySQL connection id is 7
   Server version: 8.0.32 Source distribution
   
   Copyright (c) 2000, 2023, Oracle and/or its affiliates.
   
   Oracle is a registered trademark of Oracle Corporation and/or its
   affiliates. Other names may be trademarks of their respective
   owners.
   
   Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
   
   mysql>
   
   #刷新权限
   mysql> flush privileges;
   Query OK, 0 rows affected (0.01 sec)
   #修改密码
   mysql> alter user root@'localhost' identified by '';
   Query OK, 0 rows affected (0.00 sec)
   ```

   



### 13.3 账号赋权



```
mysql> grant select on hellodb.students to root@'10.0.0.%';
```



mysql恢复数据库密码

 
