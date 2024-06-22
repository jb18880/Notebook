rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
sed -i.bak 's#http://repo.zabbix.com#https://mirror.tuna.tsinghua.edu.cn/zabbix#' /etc/yum.repos.d/zabbix.repo
dnf clean all
dnf -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-agent2 mysql-server langpacks-zh_CN
systemctl enable --now mysqld
cat <<EOF | mysql
create database zabbix character set utf8 collate utf8_bin;
create user zabbix@localhost identified by '123456';
grant all privileges on zabbix.* to zabbix@localhost;
EOF
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p123456 zabbix
sed -i.bak '/# DBPassword/a DBPassword=123456' /etc/zabbix/zabbix_server.conf
sed -ri 's/^.*Europe\/Riga$/php_value[date.timezone] = Asia\/Shanghai/' /etc/php-fpm.d/zabbix.conf
systemctl restart zabbix-server zabbix-agent2 httpd php-fpm
systemctl enable zabbix-server zabbix-agent2 httpd php-fpm
