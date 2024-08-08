安装tomcat之前需要先安装java环境

java环境包括jdk和jre

jdk是开发用的，有写代码的需求的话，就需要安装jdk

jre是用来跑Java程序的，如果不用写java代码的话就可以直接安装jre



安装jdk

```
 [root@tomcat ~]# wget https://download.oracle.com/java/20/latest/jdk-20_linux-x64_bin.tar.gz
 [root@tomcat ~]# mv jdk-20.0.1 /usr/local/jdk
 [root@tomcat local]# echo 'PATH=/usr/local/tomcat/bin:$PATH' > /etc/profile.d/tomcat.sh
 [root@tomcat local]# . /etc/profile.d/tomcat.sh
 
 #检查jdk是否安装成功
 [root@tomcat local]# echo $PATH
 /usr/local/tomcat/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
 [root@tomcat local]# java -version
 java version "20.0.1" 2023-04-18
 Java(TM) SE Runtime Environment (build 20.0.1+9-29)
 Java HotSpot(TM) 64-Bit Server VM (build 20.0.1+9-29, mixed mode, sharing)
 
 #检查java进程端口
 #8005是关闭tomcat的端口
 #8080是tomcat的监听端口
 [root@tomcat bin]# ss -antlp | grep java
 LISTEN 0      1      [::ffff:127.0.0.1]:8005            *:*    users:(("java",pid=2044,fd=51))  
 LISTEN 0      100                     *:8080            *:*    users:(("java",pid=2044,fd=44))  
 
```

修改/dev/random

```
 [root@tomcat bin]# mv /dev/random /dev/random.bak
 [root@tomcat bin]# ln -s /dev/urandom /dev/random
```

安装tomcat

```
 [root@tomcat ~]# wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.74/bin/apache-tomcat-9.0.74.tar.gz
 [root@tomcat ~]# tar xf apache-tomcat-9.0.74.tar.gz
 [root@tomcat ~]# cp -r apache-tomcat-9.0.74 /usr/local/tomcat
```

关闭防护墙

```
 [root@tomcat tomcat]# systemctl stop firewalld
```

启动tomcat

```
 [root@tomcat tomcat]# /usr/local/tomcat/bin/startup.sh 
 Using CATALINA_BASE:   /usr/local/tomcat
 Using CATALINA_HOME:   /usr/local/tomcat
 Using CATALINA_TMPDIR: /usr/local/tomcat/temp
 Using JRE_HOME:        /usr
 Using CLASSPATH:       /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar
 Tomcat started.
```

浏览器验证

```
 http://10.0.0.8:8080/
```

重启tomcat

```
 [root@tomcat bin]# shutdown.sh
 [root@tomcat bin]# startup.sh
 [root@tomcat bin]# netstat -ntulp | grep java
 tcp6       0      0 127.0.0.1:8005          :::*                    LISTEN      2162/java           
 tcp6       0      0 :::8080                 :::*                    LISTEN      2162/java           
 [root@tomcat bin]# 
```



tomcat不用安装，解压完了就能用

- tomcat目录结构

  ```
   [root@tomcat tomcat]# ls
   bin  conf  lib  LICENSE  logs  NOTICE  RELEASE-NOTES  RUNNING.txt  temp  webapps  work
  ```

  - bin目录用来存放tomcat的主程序的目录

    常用的有启动tomcat的程序

    ```
    /usr/local/tomcat/bin/startup.sh
    ```

    和停止tomcat的程序

    ```
    /usr/local/tomcat/bin/shutdown.sh
    ```

  - webapps

    存放网站页面的目录

    ```
    [root@tomcat tomcat]# ls webapps/
    docs  examples  host-manager  manager  ROOT
    ```

    默认网页都存放在ROOT目录下

    index.jsp就是默认页面

    ```
    [root@tomcat tomcat]# ls webapps/ROOT
    asf-logo.png       bg-middle.png    bg-upper.png  index.jsp          tomcat.gif        tomcat.svg
    asf-logo-wide.gif  bg-nav-item.png  build.xml     RELEASE-NOTES.txt  tomcat.png        WEB-INF
    bg-button.png      bg-nav.png       favicon.ico   tomcat.css         tomcat-power.gif
    ```

  - conf是存放配置文件的目录

  - logs是存放日志的目录

  - lib是存放各种java库文件的目录

    将来java需要什么功能，都会到这个目录来调用相关的文件

  - work目录是用来存放临时页面数据的地方

    java网页运行之前需要先进行编译，编译后的临时文件就是存放在该目录下

  #### **tomcat操作**

  启动tomcat

  ```
  [root@tomcat tomcat]# /usr/local/tomcat/bin/startup.sh 
  Using CATALINA_BASE:   /usr/local/tomcat
  Using CATALINA_HOME:   /usr/local/tomcat
  Using CATALINA_TMPDIR: /usr/local/tomcat/temp
  Using JRE_HOME:        /usr
  Using CLASSPATH:       /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar
  Tomcat started.
  ```

  停止tomcat

  ```
  [root@tomcat tomcat]# bin/shutdown.sh 
  Using CATALINA_BASE:   /usr/local/tomcat
  Using CATALINA_HOME:   /usr/local/tomcat
  Using CATALINA_TMPDIR: /usr/local/tomcat/temp
  Using JRE_HOME:        /usr
  Using CLASSPATH:       /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar
  Using CATALINA_OPTS:   
  NOTE: Picked up JDK_JAVA_OPTIONS:  --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED
  ```

  重启tomcat

  ```
  [root@tomcat bin]# shutdown.sh
  [root@tomcat bin]# startup.sh
  [root@tomcat bin]# netstat -ntulp | grep java
  tcp6       0      0 127.0.0.1:8005          :::*                    LISTEN      2162/java           
  tcp6       0      0 :::8080                 :::*                    LISTEN      2162/java           
  ```

  测试tomcat静态页面

  webapps/ROOT/是tomcat网页的默认页面

  ```
  [root@tomcat tomcat]# echo "tomcat-test~~~" > webapps/ROOT/test01.html
  #通过浏览器测试
  http://10.0.0.8:8080/test01.html
  ```

  测试tomcat动态页面

  ```
  [root@tomcat tomcat]# vim webapps/ROOT/test02.jsp
  <html>
  <body>
  <center>
  Now time is: <%=new java.util.Date()%>
  </center>
  </body>
  </html>
  
  #测试页面
  http://10.0.0.8:8080/test02.jsp
  ```

- 通过tomcat搭建虚拟主机

  <Host name="www.b.com" appBase="web_b">

一个<Host>开头，到一个</Host>结尾表示一个tomcat虚拟主机

Host name表示网站域名

appBase表示的是网页存放的路径

```
[root@tomcat tomcat]# vim conf/server.xml    
     <Host name="www.b.com"  appBase="web_b">
</Host>       
     <Host name="www.a.com"  appBase="webapps"
           unpackWARs="true" autoDeploy="true">
```

准备测试页面

```
[root@tomcat tomcat]# mkdir -p web_b/ROOT
[root@tomcat tomcat]# echo "tomcat-A~~~" > webapps/ROOT/index.html
[root@tomcat tomcat]# echo "tomcat-B~~~" > web_b/ROOT/index.html
```

准备域名解析

```
[root@tomcat tomcat]# cat /etc/hosts
10.0.0.8  www.a.com www.b.com www.c.com
```

重启tomcat

```
[root@tomcat tomcat]# bin/shutdown.sh
[root@tomcat tomcat]# bin/startup.sh
[root@tomcat tomcat]# ss -antlp | grep java
LISTEN 0      100                     *:8080            *:*    users:(("java",pid=2346,fd=44))
LISTEN 0      1      [::ffff:127.0.0.1]:8005            *:*    users:(("java",pid=2346,fd=51))
```

检查网页

```
[root@tomcat tomcat]# curl www.a.com:8080
tomcat-A~~~
[root@tomcat tomcat]# curl www.b.com:8080
tomcat-B~~~
```

- 通过tomcat配置自动解压war包

  unpackWARs自动解压war包，不用手动解压了，war包是java工程师常用的打包形式

  autoDeploy自动部署代码，一旦有代码传输过来就自动部署代码，不用频繁重启tomcat服务了

  ```
  [root@tomcat tomcat]# vim conf/server.xml 
        <Host name="www.b.com"  appBase="web_b"
         unpackWARs="true" autoDeploy="true">
  </Host>
        <Host name="www.a.com"  appBase="webapps"
         unpackWARs="true" autoDeploy="true">
  ```

  重启tomcat

  ```
  [root@tomcat tomcat]# bin/shutdown.sh
  [root@tomcat tomcat]# bin/startup.sh
  [root@tomcat tomcat]# ss -antlp | grep java
  LISTEN 0      100                     *:8080            *:*    users:(("java",pid=2346,fd=44))
  LISTEN 0      1      [::ffff:127.0.0.1]:8005            *:*    users:(("java",pid=2346,fd=51))
  ```

  生成war包

  （需要先安装jdk，不然无法使用该命令）

  将/var/log打包为b.war

  ```
  [root@tomcat tomcat]# jar -cf b.war /var/log
  ```

  验证自动解压war包

  将b.war包放到web_b目录下，tomcat会自动解压这个war包为b目录

  ```
  root@tomcat tomcat]# cp b.war web_b/
  [root@tomcat tomcat]# ls web_b/
  b  b.war  ROOT
  ```

  如果有问题，就看看java进程是否存在

  ```
  [root@tomcat tomcat]# ss -antlp | grep java
  LISTEN 0      100                     *:8080            *:*    users:(("java",pid=2346,fd=44))
  LISTEN 0      1      [::ffff:127.0.0.1]:8005            *:*    users:(("java",pid=2346,fd=51))
  ```

  tomcat再有问题

  就杀掉java再启动

  ```
  [root@tomcat tomcat]# killall java
  [root@tomcat tomcat]# bin/startup.sh 
  [root@tomcat tomcat]# ss -antlp| grep java
  LISTEN 0      100                     *:8080            *:*    users:(("java",pid=2575,fd=44))
  LISTEN 0      1      [::ffff:127.0.0.1]:8005            *:*    users:(("java",pid=2575,fd=51))
  ```



- 自定义tomcat的默认页面路径

  将网页的默认页面定义为web_b，将来访问tomcat时，访问的就是web_b下面的网页

  ```
        <Host name="www.b.com"  appBase="web_b"
                unpackWARs="true" autoDeploy="true">
                <Context path="" docBase="" />
  </Host>
        <Host name="www.a.com"  appBase="webapps"
              unpackWARs="true" autoDeploy="true">
  ```

  准备测试页面

  